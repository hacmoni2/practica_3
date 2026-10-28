# Ejercicio 3. Reglas de transformación básica


---

## Regla 1. Toda entidad fuerte se transforma en una tabla

Cada entidad fuerte del modelo conceptual se convierte en una tabla relacional independiente, declarando sus tipos de datos, clave primaria y restricciones operativas (`NOT NULL`, `UNIQUE`).

### 1. Tabla `Recurso`
Representa los artículos disponibles para préstamo en el inventario.
* **`id_recurso`**: `varchar` — **Clave Primaria (PK)**.
* **`titulo`**: `varchar` — Restricción `NOT NULL`.
* **`categoria`**: `varchar` — Restricción `NOT NULL`.
* **`stock_disponible`**: `int` — Restricción `NOT NULL`.

### 2. Tabla `UsuarioUniversitario` (Supertipo)
Almacena la información general de los perfiles que conforman la comunidad universitaria.
* **`boleta_o_id`**: `varchar` — **Clave Primaria (PK)**.
* **`nombre_completo`**: `varchar` — Restricción `NOT NULL`.
* **`correo_institucional`**: `varchar` — Restricción `UNIQUE` y `NOT NULL`.

### 3. Tabla `Prestamo`
Registra la cabecera de las transacciones de préstamo de recursos.
* **`id_prestamo`**: `varchar` — **Clave Primaria (PK)**.
* **`id_solicitante`**: `varchar` — **Clave Foránea (FK)** hacia `UsuarioUniversitario`, restricción `NOT NULL`.
* **`id_atendido_por`**: `varchar` — **Clave Foránea (FK)** hacia el personal que autoriza el recurso.
* **`fecha_prestamo`**: `timestamp` — Restricción `NOT NULL`.
* **`fecha_limite`**: `timestamp` — Restricción `NOT NULL`.

---

## Regla 2. Atributos compuestos

Los atributos compuestos se descomponen en sus componentes simples, eliminando el atributo padre y creando una columna independiente por cada subcomponente dentro de la tabla correspondiente.

* **Caso aplicado:** El atributo compuesto **`direccion`** de la entidad `UsuarioUniversitario`.
* **Columnas resultantes en la tabla `UsuarioUniversitario`:**
  * `dir_calle` (`varchar`)
  * `dir_numero` (`varchar`)
  * `dir_colonia` (`varchar`)
  * `dir_cp` (`varchar`)

---

## Regla 3. Atributos multivaluados

Los atributos multivaluados se extraen de la tabla principal y se convierten en una tabla independiente. Esta nueva tabla almacena la clave primaria de la entidad original como clave foránea y el valor del atributo, definiendo como clave primaria la combinación de ambas columnas.

* **Caso aplicado:** El atributo multivaluado **`telefonos_contacto`** de los usuarios.
* **Tabla resultante: `TelefonoUsuario`**
  * **`boleta_o_id`**: `varchar` — **Clave Foránea (FK)** que referencia a `UsuarioUniversitario`.
  * **`telefono`**: `varchar` — Almacena el número telefónico de contacto.
  * **Clave Primaria Compuesta**: `PRIMARY KEY (boleta_o_id, telefono)`.