# Diccionario de Datos - Sistema de Préstamos Universitarios

A continuación se documenta cada una de las tablas, columnas, tipos de datos, restricciones y descripciones del esquema relacional obtenido a partir del modelo EER.

---

## 1. Tabla: `usuario_universitario`
Almacena la información general de los perfiles que conforman la comunidad universitaria.

| Columna | Tipo de dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `boleta_o_id` | VARCHAR(20) | PRIMARY KEY, NOT NULL | Identificador único institucional (boleta de estudiante o ID de empleado). |
| `nombre_completo` | VARCHAR(150) | NOT NULL | Nombre y apellidos completos del usuario registrado. |
| `correo_institucional` | VARCHAR(100) | UNIQUE, NOT NULL | Dirección de correo electrónico oficial de dominio institucional. |
| `dir_calle` | VARCHAR(100) | Opcional (NULL) | Calle del domicilio del usuario (componente desglosado de dirección). |
| `dir_numero` | VARCHAR(20) | Opcional (NULL) | Número exterior o interior del domicilio del usuario. |
| `dir_colonia` | VARCHAR(100) | Opcional (NULL) | Colonia o asentamiento del domicilio del usuario. |
| `dir_cp` | VARCHAR(10) | Opcional (NULL) | Código postal del domicilio del usuario. |

---

## 2. Tabla: `telefono_usuario`
Almacena los números telefónicos de contacto (atributo multivaluado) de los usuarios.

| Columna | Tipo de dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `boleta_o_id` | VARCHAR(20) | PK, FK (`usuario_universitario`), ON DELETE CASCADE | Clave foránea al usuario propietario del teléfono. |
| `telefono` | VARCHAR(20) | PRIMARY KEY, NOT NULL | Número telefónico de contacto registrado para el usuario. |

---

## 3. Tabla: `alumno`
Almacena los atributos específicos de los usuarios que pertenecen al subtipo de alumnos.

| Columna | Tipo de dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `boleta_o_id` | VARCHAR(20) | PK, FK (`usuario_universitario`), ON DELETE CASCADE | Identificador del alumno en la especialización de usuario. |
| `carrera` | VARCHAR(100) | NOT NULL | Programa académico o ingeniería en la que está inscrito el alumno. |
| `semestre` | INT | NOT NULL, CHECK (semestre > 0) | Semestre lectivo actual que cursa el alumno. |

---

## 4. Tabla: `trabajador`
Almacena los atributos específicos de los usuarios que pertenecen al subtipo de trabajadores.

| Columna | Tipo de dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `boleta_o_id` | VARCHAR(20) | PK, FK (`usuario_universitario`), ON DELETE CASCADE | Identificador del trabajador en la especialización de usuario. |
| `departamento` | VARCHAR(100) | Opcional (NULL) | Área o departamento universitario al que está adscrito el trabajador. |
| `puesto` | VARCHAR(100) | Opcional (NULL) | Cargo operativo o administrativo que desempeña el trabajador. |

---

## 5. Tabla: `recurso`
Almacena el catálogo de artículos e insumos disponibles para préstamo en el inventario.

| Columna | Tipo de dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_recurso` | VARCHAR(20) | PRIMARY KEY, NOT NULL | Código o clave de inventario única asignada al recurso físico. |
| `titulo` | VARCHAR(150) | NOT NULL | Nombre o título descriptivo del recurso físico. |
| `categoria` | VARCHAR(50) | NOT NULL | Tipo de recurso (ej. Material Deportivo, Libro, Tecnología). |
| `stock_disponible` | INT | NOT NULL, CHECK (stock_disponible >= 0) | Unidades físicas disponibles para préstamo en el almacén. |

---

## 6. Tabla: `prestamo`
Registra la cabecera de las transacciones de préstamo realizadas en la institución.

| Columna | Tipo de dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_prestamo` | VARCHAR(20) | PRIMARY KEY, NOT NULL | Folio único de identificación de la transacción de préstamo. |
| `id_solicitante` | VARCHAR(20) | FK (`usuario_universitario`), NOT NULL | Identificador del usuario que realiza la solicitud del préstamo. |
| `id_atendido_por` | VARCHAR(20) | FK (`trabajador`), NOT NULL | Identificador del trabajador que autoriza y entrega el recurso. |
| `fecha_prestamo` | TIMESTAMP | NOT NULL | Fecha y hora exacta en que se genera la salida del préstamo. |
| `fecha_limite` | TIMESTAMP | NOT NULL, CHECK (fecha_limite >= fecha_prestamo) | Fecha y hora máxima programada para la devolución del recurso. |

---

## 7. Tabla: `detalle_prestamo`
Relación de muchos a muchos convertida en entidad débil que detalla los recursos incluidos por préstamo.

| Columna | Tipo de dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_prestamo` | VARCHAR(20) | PK, FK (`prestamo`), ON DELETE CASCADE | Identificador de la transacción de préstamo asociada. |
| `id_recurso` | VARCHAR(20) | PK, FK (`recurso`), ON DELETE RESTRICT | Identificador del recurso específico solicitado. |
| `cantidad_solicitada` | INT | NOT NULL, CHECK (cantidad_solicitada > 0) | Número de unidades solicitadas de este recurso en la transacción. |

---

## 8. Tabla: `sancion`
Registra las penalizaciones o multas generadas a partir de retrasos o anomalías en los préstamos.