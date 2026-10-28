# Análisis del Esquema del Proyecto Asignado: DWSismos (Data Warehouse de Sismos en México)

**Repositorio de origen:** `gabrielhuav/DWSismos`  
**Referencia académica:** Villa Vargas, J. M., Hurtado Avilés, G., & Climent Hernández, J. A. (2026). *Cuando México tiembla: la historia contada por los datos*. AZCATL Revista de Divulgación en Ciencias, Ingeniería e Innovación, 4(6), 28–33. DOI: 10.24275/AZC2026E1004.

---

## 1. Contexto y Arquitectura General del Esquema

El proyecto **DWSismos** es un sistema de almacén de datos (Data Warehouse / OLAP) implementado sobre **PostgreSQL** y contenedorizado mediante **Docker**. Su objetivo principal es integrar y consolidar dos fuentes heterogéneas de datos a nivel nacional:

1. **Servicio Sismológico Nacional (SSN):** Registros históricos y en tiempo real de eventos sísmicos (magnitud, profundidad, coordenadas geográficas, fecha/hora exacta, epicentro).
2. **Instituto Nacional de Estadística y Geografía (INEGI):** Información geográfica, demográfica y socioeconómica por estado, municipio y localidad.

Dado que su propósito es facilitar la visualización analítica, la correlación de impacto sísmico sobre la población y la generación de métricas avanzadas en PHP/JavaScript, el esquema relacional en PostgreSQL está diseñado bajo una arquitectura dimensional (Esquema de Estrella o Copo de Nieve).

---

## 2. Las Reglas Detrás del Esquema (Análisis Tabla por Tabla)

A partir de la reconstrucción del modelo conceptual Entidad-Relación Extendido (EER), las tablas del esquema real del repositorio se explican mediante las reglas de transformación relacional:

### 2.1 Tabla de Hechos: `fact_sismo` (o `hecho_evento_sismico`)
* **Regla de origen:** Derivada de la asociación compleja $M:N$ (Reglas 5 y 7) entre las entidades del dominio: *Sismo*, *Ubicación Geográfica (INEGI)* y *Tiempo*.
* **Claves y Restricciones:**
  * **Clave Primaria:** `id_hecho` (Serial autoincremental / Surrogate Key).
  * **Claves Foráneas:**
    * `fk_dim_tiempo`: Referencia a la dimensión temporal (`dim_tiempo.id_tiempo`).
    * `fk_dim_ubicacion`: Referencia a la división territorial del INEGI (`dim_ubicacion.id_ubicacion`).
    * `fk_dim_sismo`: Referencia a los metadatos del evento sísmico (`dim_sismo.id_sismo`).
  * **Métricas y Restricciones:** `magnitud` (NUMERIC, CHECK > 0), `profundidad_km` (NUMERIC, CHECK >= 0), `poblacion_expuesta` (BIGINT), `costo_estimado_danos` (NUMERIC). Claves foráneas declaradas con `NOT NULL` para asegurar que ningún hecho quede huérfano.

### 2.2 Tabla de Dimensión: `dim_sismo`
* **Regla de origen:** **Regla 1** (Transformación de la entidad fuerte *Sismo* del SSN).
* **Claves y Restricciones:**
  * **Clave Primaria:** `id_sismo` (PK).
  * **Atributos:** `clave_ssn` (VARCHAR, UNIQUE, NOT NULL - clave natural de origen), `epicentro_referencia` (VARCHAR), `tipo_falla` (VARCHAR).

### 2.3 Tabla de Dimensión: `dim_ubicacion` (Datos INEGI)
* **Regla de origen:** **Regla 1** (Entidad fuerte de geografía) y **Regla 2** (Descomposición de componentes territoriales).
* **Claves y Restricciones:**
  * **Clave Primaria:** `id_ubicacion` (PK).
  * **Atributos:** `clave_entidad_inegi` (VARCHAR), `nombre_estado` (VARCHAR, NOT NULL), `nombre_municipio` (VARCHAR, NOT NULL), `latitud` (DECIMAL), `longitud` (DECIMAL).

### 2.4 Tabla de Dimensión: `dim_tiempo`
* **Regla de origen:** Dimensión sintética generada para descomponer marcas de tiempo (Regla 2 aplicada a atributos de fecha/hora).
* **Claves y Restricciones:**
  * **Clave Primaria:** `id_tiempo` (INT).
  * **Atributos:** `fecha_completa` (DATE, UNIQUE, NOT NULL), `anio` (INT), `mes` (INT), `dia` (INT), `hora` (INT), `trimestre` (INT).

---

## 3. Decisiones de Desnormalización (Dónde se Aparta de las Reglas)

Dado que **DWSismos** es un Data Warehouse diseñado para lecturas analíticas rápidas y agregaciones sobre grandes volúmenes de datos sísmicos, el esquema desnormaliza intencionalmente en tres aspectos clave:

### Decisiones Identificadas

1. **Aplanado de la Jerarquía Territorial del INEGI en una Sola Tabla (`dim_ubicacion`):**
   * *Decisión:* En un modelo EER estricto (3FN), existirían las entidades separadas `Estado`, `Municipio` y `Localidad` relacionadas $1:N$. En el esquema del proyecto, se colapsaron todos los niveles jerárquicos (Entidad Federativa + Municipio + Coordenadas) dentro de la misma tabla `dim_ubicacion`.
   * *Qué se gana:* Evita realizar múltiples `JOIN` entre tablas territoriales en cada consulta de visualización gráfica, acelerando el tiempo de respuesta en mapas interactivos y tableros.
   * *Qué se pierde:* Se genera redundancia masiva de datos (el nombre de un estado como "Oaxaca" o "Michoacán" se repite miles de veces en filas distintas).

2. **Uso de Claves Subrogadas (Surrogate Keys) en lugar de Claves Naturales:**
   - *Decisión:* Se definieron IDs enteros autoincrementales (`id_sismo`, `id_ubicacion`) como claves primarias, desplazando el código de evento del SSN (`clave_ssn`) y la clave geoestadística del INEGI a columnas secundarias con índice `UNIQUE`.
   - *Qué se gana:* Aísla el almacén ante cambios o corrupciones en los sistemas de origen (SSN e INEGI) e incrementa el rendimiento de indexing y joins al comparar enteros de 4 u 8 bytes en lugar de cadenas de texto (`VARCHAR`).
   - *Qué se pierde:* Se pierde la trazabilidad directa e inmediata en consultas simples sin involucrar búsquedas sobre los campos de clave natural.

3. **Almacenamiento de Datos Derivados y Métricas Precalculadas:**
   - *Decisión:* La tabla de hechos almacena atributos como `poblacion_expuesta` o métricas demográficas históricas directamente en la fila del evento sísmico en lugar de calcularlas en tiempo de ejecución cruzando dinámicamente con censos del INEGI.
   - *Qué se gana:* Permite renderizar gráficos y dashboards de riesgo en tiempo real en la interfaz de PHP/JS sin sobrecargar la CPU del servidor PostgreSQL.
   - *Qué se pierde:* Los datos históricos agregados quedan congelados al momento de la carga (ETL), requiriendo re-procesamientos si el INEGI actualiza sus estimaciones demográficas.