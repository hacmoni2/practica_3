
---

## 1. Relación: `UsuarioUniversitario` – `Alumno` / `Trabajador` (Jerarquía de Generalización)
* **Regla aplicada:** Regla 6 (Relaciones uno a uno - Estrategia 1: Propagación de clave de la entidad obligatoria a la opcional con restricción `UNIQUE`).
* **Justificación:** La relación entre el supertipo `UsuarioUniversitario` y sus subtipos (`Alumno` y `Trabajador`) es uno a uno con especialización parcial. Todo registro específico de alumno o trabajador proviene obligatoriamente de un usuario general registrado (`(1, 1)`), mientras que un usuario general puede o no pertenecer a una de estas categorías específicas (`(0, 1)`).
* **Tabla resultante:** Se mantienen las tablas `Alumno` y `Trabajador` añadiendo `boleta_o_id` como clave primaria y foránea al mismo tiempo, referenciando a `UsuarioUniversitario(boleta_o_id)` con la restricción `UNIQUE` y `NOT NULL`.

---

## 2. Relación: `Alumno` – `Realiza` – `Prestamo`
* **Regla aplicada:** Regla 4 (Relaciones uno a muchos).
* **Justificación:** Un alumno puede realizar cero o múltiples préstamos a lo largo de su trayectoria `(0, N)`, pero un préstamo pertenece de forma exclusiva a un único alumno `(1, 1)`. La clave primaria del lado uno (`Alumno.boleta_o_id`) se propaga hacia la tabla `Prestamo` como clave foránea. Dado que la cardinalidad mínima del lado muchos en la participación del préstamo es obligatoria, la clave foránea es `NOT NULL`.
* **Tabla resultante:** Se propaga el atributo `id_solicitante` (que referencia a `Alumno.boleta_o_id`) dentro de la tabla **`Prestamo`** con restricción `NOT NULL`.

---

## 3. Relación: `Prestamo` – `Incluye` – `Recurso`
* **Regla aplicada:** Regla 5 (Relaciones muchos a muchos).
* **Justificación:** Un préstamo puede incluir múltiples recursos del inventario y un recurso puede formar parte de múltiples transacciones de préstamo a lo largo del tiempo `(1, N) : (0, N)`. Esta relación requiere una tabla intermedia.
* **Tabla resultante:** Se crea la tabla propia **`DetallePrestamo`**, que incluye como claves foráneas compuestas a `id_prestamo` (referenciando a `Prestamo`) y `id_recurso` (referenciando a `Recurso`). Además, incluye el atributo propio de la relación: `cantidad_solicitada` (`int NOT NULL`). La clave primaria de esta tabla es la combinación de ambas claves foráneas (`PRIMARY KEY (id_prestamo, id_recurso)`).

---

## 4. Relación: `Prestamo` – `Genera` – `Sancion`
* **Regla aplicada:** Regla 6 (Relaciones uno a uno - Estrategia 1).
* **Justificación:** Todo registro de sanción proviene de exactamente un préstamo específico que incurrió en retrasos o anomalías (`(1, 1)`), y un préstamo puede generar como máximo una sanción (`(0, 1)`). Se propaga la clave de la entidad obligatoria (`Prestamo`) hacia la opcional (`Sancion`) como clave foránea con restricción `UNIQUE`.
* **Tabla resultante:** La tabla **`Sancion`** incorpora la columna `id_prestamo` como clave foránea con restricción `UNIQUE` y `NOT NULL`, además de sus propios atributos (`id_sancion` como PK, `fecha_sancion` y `motivo`).

---

## 5. Relación: `Prestamo` – `AtendidoPor` – `Trabajador` (Relación de orden superior / Asignación administrativa)
* **Regla aplicada:** Regla 4 (Relaciones uno a muchos) o adaptada como clave foránea directa en la cabecera del préstamo.
* **Justificación:** Un trabajador del área administrativa atiende cero o múltiples préstamos, mientras que cada registro de préstamo es validado y entregado por un único trabajador responsable del área.
* **Tabla resultante:** Se propaga la clave del trabajador como clave foránea `id_atendido_por` dentro de la tabla **`Prestamo`**.