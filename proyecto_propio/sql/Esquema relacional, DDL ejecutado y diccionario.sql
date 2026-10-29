


-- 0. Limpieza previa (Eliminación en orden inverso por dependencias)
DROP TABLE IF EXISTS sancion CASCADE;
DROP TABLE IF EXISTS detalle_prestamo CASCADE;
DROP TABLE IF EXISTS prestamo CASCADE;
DROP TABLE IF EXISTS recurso CASCADE;
DROP TABLE IF EXISTS trabajador CASCADE;
DROP TABLE IF EXISTS alumno CASCADE;
DROP TABLE IF EXISTS telefono_usuario CASCADE;
DROP TABLE IF EXISTS usuario_universitario CASCADE;




-- Tabla Supertipo Usuario
CREATE TABLE usuario_universitario (
    boleta_o_id VARCHAR(20) NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    correo_institucional VARCHAR(100) NOT NULL,
    dir_calle VARCHAR(100),
    dir_numero VARCHAR(20),
    dir_colonia VARCHAR(100),
    dir_cp VARCHAR(10),
    CONSTRAINT pk_usuario_universitario PRIMARY KEY (boleta_o_id),
    CONSTRAINT uq_usuario_correo UNIQUE (correo_institucional)
);

-- Atributo Multivaluado Telefono
CREATE TABLE telefono_usuario (
    boleta_o_id VARCHAR(20) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    CONSTRAINT pk_telefono_usuario PRIMARY KEY (boleta_o_id, telefono),
    CONSTRAINT fk_telefono_usuario FOREIGN KEY (boleta_o_id)
        REFERENCES usuario_universitario (boleta_o_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Subtipo Alumno
CREATE TABLE alumno (
    boleta_o_id VARCHAR(20) NOT NULL,
    carrera VARCHAR(100) NOT NULL,
    semestre INT NOT NULL,
    CONSTRAINT pk_alumno PRIMARY KEY (boleta_o_id),
    CONSTRAINT fk_alumno_usuario FOREIGN KEY (boleta_o_id)
        REFERENCES usuario_universitario (boleta_o_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_alumno_semestre CHECK (semestre > 0)
);

-- Subtipo Trabajador
CREATE TABLE trabajador (
    boleta_o_id VARCHAR(20) NOT NULL,
    departamento VARCHAR(100),
    puesto VARCHAR(100),
    CONSTRAINT pk_trabajador PRIMARY KEY (boleta_o_id),
    CONSTRAINT fk_trabajador_usuario FOREIGN KEY (boleta_o_id)
        REFERENCES usuario_universitario (boleta_o_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla Recurso
CREATE TABLE recurso (
    id_recurso VARCHAR(20) NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    stock_disponible INT NOT NULL,
    CONSTRAINT pk_recurso PRIMARY KEY (id_recurso),
    CONSTRAINT chk_recurso_stock CHECK (stock_disponible >= 0)
);

-- Tabla Prestamo (Transaccional)
CREATE TABLE prestamo (
    id_prestamo VARCHAR(20) NOT NULL,
    id_solicitante VARCHAR(20) NOT NULL,
    id_atendido_por VARCHAR(20) NOT NULL,
    fecha_prestamo TIMESTAMP NOT NULL,
    fecha_limite TIMESTAMP NOT NULL,
    CONSTRAINT pk_prestamo PRIMARY KEY (id_prestamo),
    CONSTRAINT fk_prestamo_solicitante FOREIGN KEY (id_solicitante)
        REFERENCES usuario_universitario (boleta_o_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamo_atendido FOREIGN KEY (id_atendido_por)
        REFERENCES trabajador (boleta_o_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_prestamo_fechas CHECK (fecha_limite >= fecha_prestamo)
);

-- Entidad Débil / Relación M:N DetallePrestamo
CREATE TABLE detalle_prestamo (
    id_prestamo VARCHAR(20) NOT NULL,
    id_recurso VARCHAR(20) NOT NULL,
    cantidad_solicitada INT NOT NULL,
    CONSTRAINT pk_detalle_prestamo PRIMARY KEY (id_prestamo, id_recurso),
    CONSTRAINT fk_detalle_prestamo FOREIGN KEY (id_prestamo)
        REFERENCES prestamo (id_prestamo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_recurso FOREIGN KEY (id_recurso)
        REFERENCES recurso (id_recurso)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad_solicitada > 0)
);

-- Tabla Sancion
CREATE TABLE sancion (
    id_sancion VARCHAR(20) NOT NULL,
    id_prestamo VARCHAR(20) NOT NULL,
    boleta_o_id VARCHAR(20) NOT NULL,
    fecha_sancion DATE NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    CONSTRAINT pk_sancion PRIMARY KEY (id_sancion),
    CONSTRAINT uq_sancion_prestamo UNIQUE (id_prestamo),
    CONSTRAINT fk_sancion_prestamo FOREIGN KEY (id_prestamo)
        REFERENCES prestamo (id_prestamo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sancion_alumno FOREIGN KEY (boleta_o_id)
        REFERENCES alumno (boleta_o_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO usuario_universitario (boleta_o_id, nombre_completo, correo_institucional) 
VALUES ('2024630001', 'Diego Pérez', 'diego.perez@ipn.mx');

INSERT INTO alumno (boleta_o_id, carrera, semestre) 
VALUES ('2024630001', 'Ingeniería en Inteligencia Artificial', 3);

INSERT INTO usuario_universitario (boleta_o_id, nombre_completo, correo_institucional) 
VALUES ('TRAB-001', 'Laura Gómez', 'lgomez@ipn.mx');

INSERT INTO trabajador (boleta_o_id, departamento, puesto) 
VALUES ('TRAB-001', 'Biblioteca Central', 'Encargada de Circulación');

INSERT INTO recurso (id_recurso, titulo, categoria, stock_disponible) 
VALUES ('REC-01', 'Clean Code', 'Libro', 5);

INSERT INTO prestamo (id_prestamo, id_solicitante, id_atendido_por, fecha_prestamo, fecha_limite) 
VALUES ('PRES-001', '2024630001', 'TRAB-001', '2026-10-27 10:00:00', '2026-11-03 10:00:00');
