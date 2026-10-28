# Ejercicio 5. Entidades débiles y jerarquías

A partir del modelo Entidad-Relación Extendido (EER) del sistema de préstamos universitarios, se aplican las reglas de transformación para entidades débiles (Regla 8) y jerarquías de generalización/especialización (Regla 9).

---

## 1. Aplicación de la Regla 8: Entidades débiles

### Entidad Débil: `DetallePrestamo` (Dependencia de Existencia)
* **Tipo de dependencia:** Dependencia de existencia respecto a la entidad fuerte `Prestamo`.
* **Transformación:** La tabla conserva su clave primaria combinada con el identificador del recurso, agregando la clave foránea del préstamo como obligatoria con eliminación en cascada.
* **Diseño resultante:**
  * **Clave Primaria Compuesta:** `PRIMARY KEY (id_prestamo, id_recurso)`
  * **Claves Foráneas:** 
    * `id_prestamo`: `varchar`, restricciones `NOT NULL`, con `ON DELETE CASCADE`.
    * `id_recurso`: `varchar`, restricciones `NOT NULL`.
  * **Atributos:** `cantidad_solicitada` (`int`, `NOT NULL`).

### Entidad Débil / Historial: `Sancion` (Dependencia con el Préstamo)
* **Tipo de dependencia:** Dependencia directa de la transacción de préstamo asociada.
* **Transformación:** Conserva su identificador principal como clave y propaga la clave foránea de la entidad propietaria con restricción de unicidad y obligatoriedad.
* **Diseño resultante:**
  * **Clave Primaria:** `id_sancion` (`varchar`).
  * **Claves Foráneas:** 
    * `id_prestamo`: `varchar`, restricciones `NOT NULL`, `UNIQUE`, con `ON DELETE CASCADE`.
  * **Atributos:** `fecha_sancion` (`date`, `NOT NULL`), `motivo` (`varchar`, `NOT NULL`).

---

## 2. Aplicación de la Regla 9: Jerarquías

### Tabla comparativa de estrategias
| Estrategia | Ventaja | Desventaja | Cuándo conviene |
| :--- | :--- | :--- | :--- |
| **A. Tabla por supertipo y por subtipo** | Sin redundancia ni valores nulos | Requiere combinaciones para consultar todo | Subtipos con muchos atributos propios |
| **B. Tabla única con discriminador** | Consultas simples y rápidas | Muchos valores nulos | Subtipos con pocos atributos propios |
| **C. Tabla por subtipo, sin supertipo** | No requiere combinaciones | Repite los atributos comunes | Especialización total y disjunta |

### Análisis de la Jerarquía del Modelo
* **Supertipo:** `UsuarioUniversitario`
* **Subtipos:** `Alumno` y `Trabajador`
* **1. Naturaleza de la jerarquía:** Es **disjunta (d)**, ya que un perfil dentro de la comunidad universitaria pertenece a una única categoría operativa específica a la vez, y es **parcial (p)** debido a que pueden existir perfiles administrativos u operativos auxiliares que no encajan estrictamente ni en alumno ni en docente/trabajador.

### 2. Elección de Estrategia
* **Estrategia elegida:** **Estrategia A (Tabla por supertipo y por subtipo)**.
* **Justificación:** Se selecciona esta estrategia porque los subtipos (`Alumno` y `Trabajador`) poseen atributos propios específicos y diferenciados que no aplican de manera general a toda la comunidad (`carrera` y `semestre` para alumnos; `departamento` y `puesto` para trabajadores). Mantener tablas separadas evita la saturación masiva de valores nulos que produciría una tabla única (Estrategia B), preservando la integridad estricta del modelo relacional.

### 3. Diseño de las tablas resultantes y atributo discriminador
* **Tabla Supertipo: `UsuarioUniversitario`**
  * **Clave Primaria:** `boleta_o_id` (`varchar`).
  * **Atributos:** `nombre_completo` (`NOT NULL`), `correo_institucional` (`UNIQUE`, `NOT NULL`), y los componentes desglosados de dirección (`dir_calle`, `dir_numero`, `dir_colonia`, `dir_cp`).

* **Tabla Subtipo 1: `Alumno`**
  * **Clave Primaria y Foránea:** `boleta_o_id` (`varchar`, `NOT NULL`, referencia a `UsuarioUniversitario.boleta_o_id` con `UNIQUE`).
  * **Atributos propios:** `carrera` (`varchar`, `NOT NULL`), `semestre` (`int`, `NOT NULL`).

* **Tabla Subtipo 2: `Trabajador`**
  * **Clave Primaria y Foránea:** `boleta_o_id` (`varchar`, `NOT NULL`, referencia a `UsuarioUniversitario.boleta_o_id` con `UNIQUE`).
  * **Atributos propios:** `departamento` (`varchar`), `puesto` (`varchar`).

* **Atributo discriminador:** 