# Ejercicio 7. El esquema del proyecto asignado

A partir del esquema real del proyecto asignado en la Práctica 2 (el cual corresponde a un modelo de almacén dimensional o esquema de estrella/copo de nieve orientado a analítica), se realiza el análisis estructural bajo los lineamientos de las reglas de transformación y las decisiones de desnormalización.

---

## 7.1 Las reglas detrás del esquema

A continuación se explica el origen de las tablas principales del esquema asignado a la luz de las reglas aplicadas en los ejercicios anteriores:

1. **Tabla de Hechos (`fact_transaccion` o similar)**
   - **Regla de origen:** Derivada de las relaciones de orden superior o asociaciones de muchos a muchos complejas del modelo conceptual (Reglas 4, 5 y 7). Agrupa las métricas y los identificadores de contexto.
   - **Claves y restricciones:** Posee una clave primaria compuesta (o clave subrogada de hecho). Contiene múltiples claves foráneas (`NOT NULL`) que apuntan a las distintas tablas de dimensión del esquema, respaldadas por restricciones de integridad referencial.

2. **Tablas de Dimensión (`dim_usuario`, `dim_recurso`, `dim_tiempo`)**
   - **Regla de origen:** Se originan a partir de la **Regla 1** (transformación de entidades fuertes del dominio conceptual en tablas relacionales).
   - **Claves y restricciones:** Cada dimensión cuenta con una clave primaria declarada (`PK`) y restricciones estrictas como `NOT NULL` y `UNIQUE` en sus atributos de identificación descriptiva.

3. **Tablas auxiliares o de desglose jerárquico**
   - **Regla de origen:** Explicadas por la **Regla 8** (entidades débiles) o la **Regla 9** (estrategias de jerarquías de generalización). En algunos casos, estructuran los subcomponentes de entidades especializadas del dominio analítico.

---

## 7.2 Dónde se aparta de las reglas (Desnormalización intencional)

Un almacén dimensional desnormaliza a propósito para optimizar el rendimiento analítico y las consultas de agregación masiva. Se identifican las siguientes decisiones que una transformación relacional estricta no produciría:

1. **Tablas de dimensión con atributos redundantes (Desnormalización por anexión):**
   - *Decisión:* La tabla de dimensión `dim_usuario` incluye atributos descriptivos de categorías o ubicaciones que en un modelo EER estricto pertenecerían a entidades secundarias separadas (por ejemplo, el detalle completo de la dirección o área dentro de la misma fila del usuario).
   - *Qué se gana:* Se eliminan las uniones (`JOIN`) complejas en consultas de análisis masivo, acelerando drásticamente los reportes.
   - *Qué se pierde:* Ocurre redundancia de datos y mayor consumo de espacio en disco, incrementando el riesgo de anomalías de actualización si no se controlan mediante procesos ETL.

2. **Jerarquías del dominio aplanadas en una sola tabla:**
   - *Decisión:* Las jerarquías de categorías o ubicaciones geográficas no se dividen en tablas normalizadas por niveles, sino que se aplanan en columnas denotadas dentro de una misma dimensión (`categoria`, `subcategoria`, `departamento` en un solo plano).
   - *Qué se gana:* Simplicidad extrema en las consultas OLAP y reportes ejecutivos tipo tabla dinámica.
   - *Qué se pierde:* Se pierde la flexibilidad estructural pura del modelo EER ante cambios en los niveles jerárquicos y se generan celdas con valores repetitivos.

3. **Uso masivo de claves subrogadas (Surrogate Keys):**
   - *Decisión:* Se implementan identificadores autoincrementales numéricos (`SERIAL` o enteros secuenciales) como claves primarias en lugar de conservar exclusivamente las claves naturales del dominio (como la boleta o el ID institucional).
   - *Qué se gana:* Aislamiento de los hechos analíticos ante cambios en los sistemas transaccionales fuente y un rendimiento superior en los índices de búsqueda y uniones.
   - *Qué se pierde:* Se rompe la trazabilidad directa e inmediata con la clave natural del negocio sin consultar previamente la dimensión correspondiente.
---

## 7.3 Comparación entre modelos (EER vs. Relacional / Dimensional)

| Elemento del Modelo | Modelo EER (Conceptual / Transaccional) | Modelo Relacional / Dimensional (Asignado) | Qué se ganó | Qué se perdió |
| :--- | :--- | :--- | :--- | :--- |
| **Entidades fuertes** | Se convierten en tablas limpias aplicando formas normales estrictas (3FN). | Se transforman en tablas de dimensión optimizadas para lectura masiva. | Mayor velocidad de respuesta en consultas de lectura y reportes analíticos. | Mayor redundancia de datos y pérdida parcial de normalización estricta. |
| **Entidades débiles** | Dependen de existencia o identificación de una entidad fuerte mediante FKs en cascada. | Se integran directamente en los hechos o se absorben como atributos descriptivos. | Simplificación de la estructura transaccional y menor cantidad de bloqueos. | Rigor conceptual en la dependencia estricta de borrado y existencia. |
| **Relaciones muchos a muchos ($M:N$)** | Se resuelven obligatoriamente mediante tablas intermedias (Regla 5). | Se transforman en tablas de hechos centrales rodeadas de dimensiones (Esquema de estrella). | Agilidad analítica para cruzar múltiples variables sin alterar las tablas base. | Complejidad en la comprensión de los modelos de hechos y dimensiones. |
| **Jerarquías** | Se modelan mediante supertipos y subtipos con restricciones de disyunción y completitud (Regla 9). | Se aplanan intencionalmente en atributos de una misma tabla o dimensiones de copo de nieve. | Consultas de especialización directas y sin uniones complejas. | Valores nulos masivos o duplicación de etiquetas dvescriptivas comunes. |