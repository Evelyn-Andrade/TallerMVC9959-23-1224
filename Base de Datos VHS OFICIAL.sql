
-- Creacion de la base de dato

CREATE DATABASE IF NOT EXISTS RentaVideoVHS;
USE RentaVideoVHS;

-- direccon

CREATE TABLE direccion (
id_direccion INT NOT NULL AUTO_INCREMENT,
calle VARCHAR(150) NOT NULL,
ciudad VARCHAR(100) NOT NULL,
departamento VARCHAR(100),
pais VARCHAR(80)  NOT NULL,
PRIMARY KEY (id_direccion)
);

-- empleado
-- Justificación NOT NULL:
--   nombre y puesto son obligatorios para identificar
--   al empleado dentro del sistema.
--   telefono es opcional; un empleado puede no tener
--   teléfono registrado al momento del alta.


CREATE TABLE empleado (
id_empleado  INT NOT NULL AUTO_INCREMENT ,
nombre VARCHAR(100) NOT NULL,
puesto VARCHAR(50)  NOT NULL,
telefono  VARCHAR(20),
PRIMARY KEY (id_empleado)
);

-- tipo_membresia
-- Justificación NOT NULL:
--   tipo y descuento_disponible son los dos atributos
--   que definen completamente esta entidad; ambos
--   son obligatorios.


CREATE TABLE tipo_membresia (
id_tipo_membresia INT NOT NULL AUTO_INCREMENT,
tipo VARCHAR(50) NOT NULL,
descuento_disponible TINYINT(1)  NOT NULL DEFAULT 0,
PRIMARY KEY (id_tipo_membresia),
UNIQUE KEY uq_tipo (tipo)
);

-- video
-- Justificación NOT NULL:
--   titulo es obligatorio para identificar el video.
--   genero es opcional; puede no clasificarse al inicio.
--   precio_renta, stock y estado son obligatorios para
--   que el sistema opere correctamente.
-- Justificación CHECK:
--   precio_renta > 0: no tiene sentido un video gratuito
--   o con precio negativo en un sistema de cobro.
--   stock >= 0: no puede haber unidades negativas físicamente.
--   estado solo acepta valores del dominio definido por
--   el negocio: disponible, rentado, dañado, dado_de_baja.

CREATE TABLE video (
id_video INT AUTO_INCREMENT PRIMARY KEY,
titulo VARCHAR(150) NOT NULL,
genero VARCHAR(50),
precio_renta DECIMAL(10,2) NOT NULL DEFAULT 0,
stock INT NOT NULL DEFAULT 0,
estado VARCHAR(30) NOT NULL DEFAULT 'disponible',
codigo VARCHAR(20) NOT NULL,
director VARCHAR(100) NOT NULL,
anio SMALLINT NOT NULL,
clasificacion VARCHAR(10) NOT NULL,
duracion INT NOT NULL,
idioma VARCHAR(30) NOT NULL DEFAULT 'Español',
CONSTRAINT CHK_video_precio CHECK(precio_renta > 0),
CONSTRAINT CHK_video_stock CHECK(stock >= 0),
CONSTRAINT UQ_video_codigo UNIQUE(codigo)
);

-- Auditoria base de datos (Creada con IA)

CREATE TABLE auditoria (
id_auditoria INT NOT NULL AUTO_INCREMENT,
tabla_afectada VARCHAR(50) NOT NULL,
operacion VARCHAR(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
id_registro_afectado INT NOT NULL,
datos_anteriores TEXT, -- Texto simple con los datos previos
datos_nuevos TEXT,     -- Texto simple con los datos nuevos
usuario_app VARCHAR(50),
usuario_db VARCHAR(100) NOT NULL,
fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (id_auditoria)
);

CREATE TABLE usuario (
id_usuario INT NOT NULL AUTO_INCREMENT,
usuario VARCHAR(50) NOT NULL UNIQUE,
contrasena VARCHAR(255) NOT NULL,
id_empleado INT NOT NULL,
rol VARCHAR(20) NOT NULL,
estado BIT NOT NULL DEFAULT 1, 
PRIMARY KEY (id_usuario),
FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado) ON UPDATE CASCADE ON DELETE CASCADE,

-- esta parte fue con IA

CONSTRAINT chk_usuario_rol CHECK (rol IN ('Empleado', 'Administrador', 'Auditor'))


);

-- cliente
-- Justificación NOT NULL:
--   nombre es obligatorio para identificar al cliente.
--   telefono es opcional; puede registrarse sin él
--   y actualizarse después.
--   id_direccion es opcional (SET NULL en FK) porque
--   puede darse de alta el cliente antes de registrar
--   su dirección completa.

CREATE TABLE cliente (
id_cliente INT AUTO_INCREMENT,
nombre VARCHAR(100) NOT NULL,
dpi VARCHAR(14) NOT NULL,
telefono VARCHAR(8) NOT NULL,
direccion VARCHAR(100) NOT NULL,
correo VARCHAR(50) NOT NULL,
no_rentas INT,
descuento bit,
id_membresia INT NULL,
PRIMARY KEY (id_cliente)
);

-- membresia
-- Justificación NOT NULL:
--   id_cliente e id_tipo_membresia son obligatorios;
--   sin ellos la membresía no tiene sentido.
--   fecha_inicio es obligatoria para saber desde cuándo
--   aplica la membresía.
--   fecha_fin es opcional porque puede ser indefinida
--   (membresía abierta sin vencimiento).
--   videos_acumulados inicia en 0 por defecto.
-- Justificación CHECK:
--   fecha_fin debe ser posterior a fecha_inicio para
--   garantizar coherencia temporal.

CREATE TABLE membresia (
id_membresia INT NOT NULL AUTO_INCREMENT,
id_cliente INT NOT NULL,
id_tipo_membresia INT NOT NULL,
fecha_inicio DATE NOT NULL,
fecha_fin DATE,
videos_acumulados INT  NOT NULL DEFAULT 0,
PRIMARY KEY (id_membresia),
FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (id_tipo_membresia) REFERENCES tipo_membresia(id_tipo_membresia) ON UPDATE CASCADE,
CONSTRAINT chk_membresia_fechas CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
CONSTRAINT chk_membresia_videos CHECK (videos_acumulados >= 0)
);

ALTER TABLE cliente ADD CONSTRAINT fk_cliente_membresia 
FOREIGN KEY (id_membresia) REFERENCES membresia(id_membresia) ON UPDATE CASCADE ON DELETE CASCADE;

-- proveedor
-- Justificación NOT NULL:
--   nombre es obligatorio para identificar al proveedor.
--   telefono y id_direccion opcionales por la misma
--   razón que en cliente.

CREATE TABLE proveedor (
id_proveedor INT NOT NULL AUTO_INCREMENT,
nombre VARCHAR(100) NOT NULL,
telefono VARCHAR(20),
id_direccion INT,
PRIMARY KEY (id_proveedor),
FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion) ON UPDATE CASCADE ON DELETE SET NULL
);

-- compra
-- Justificación CHECK:
--   total > 0: toda compra debe tener un valor positivo.

CREATE TABLE compra (
id_compra INT NOT NULL AUTO_INCREMENT,
fecha DATE NOT NULL,
total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
id_proveedor INT NOT NULL,
id_empleado INT NOT NULL,
PRIMARY KEY (id_compra),
FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor) ON UPDATE CASCADE,
FOREIGN KEY (id_empleado)  REFERENCES empleado(id_empleado)   ON UPDATE CASCADE,
CONSTRAINT chk_compra_total CHECK (total > 0)
);

-- detalle_compra
-- Justificación CHECK:
--   Misma lógica que detalle_renta; cantidad, precio
--   y subtotal no pueden ser cero ni negativos.

CREATE TABLE detalle_compra (
id_detalle_compra INT NOT NULL AUTO_INCREMENT,
id_compra INT NOT NULL,
id_video INT NOT NULL,
cantidad INT NOT NULL DEFAULT 1,
precio_unitario DECIMAL(10,2) NOT NULL,
subtotal DECIMAL(10,2) NOT NULL,
PRIMARY KEY (id_detalle_compra),
FOREIGN KEY (id_compra) REFERENCES compra(id_compra) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (id_video)  REFERENCES video(id_video) ON UPDATE CASCADE,
CONSTRAINT chk_detalle_compra_cantidad CHECK (cantidad >= 1),
CONSTRAINT chk_detalle_compra_precio CHECK (precio_unitario > 0),
CONSTRAINT chk_detalle_compra_subtotal CHECK (subtotal > 0)
);

-- renta
-- Justificación NOT NULL:
--   Todos los campos son obligatorios; una renta sin
--   fecha, cliente o empleado es inválida.
-- Justificación CHECK:
--   fecha_limite > fecha_renta: la fecha de devolución
--   esperada siempre debe ser posterior a la fecha de renta.
--   estado solo acepta: activa, completada, cancelada.

CREATE TABLE renta (
id_renta INT NOT NULL AUTO_INCREMENT,
fecha_renta DATE NOT NULL,
fecha_limite DATE NOT NULL,
estado VARCHAR(30) NOT NULL DEFAULT 'activa',
id_cliente INT NOT NULL,
id_empleado INT NOT NULL,
PRIMARY KEY (id_renta),
FOREIGN KEY (id_cliente)  REFERENCES cliente(id_cliente)   ON UPDATE CASCADE,
FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado) ON UPDATE CASCADE,
CONSTRAINT chk_renta_fechas CHECK (fecha_limite > fecha_renta),
CONSTRAINT chk_renta_estado CHECK (estado IN ('activa', 'completada', 'cancelada'))
);

-- detalle_renta
-- Justificación CHECK:
--   cantidad >= 1: no se puede rentar 0 o menos unidades.
--   precio_unitario > 0: el precio debe ser positivo.
--   subtotal > 0: resultado de cantidad * precio_unitario.

CREATE TABLE detalle_renta (
id_detalle_renta INT NOT NULL AUTO_INCREMENT,
id_renta INT NOT NULL,
id_video INT NOT NULL,
cantidad INT NOT NULL DEFAULT 1,
precio_unitario DECIMAL(10,2) NOT NULL,
subtotal DECIMAL(10,2) NOT NULL,
PRIMARY KEY (id_detalle_renta),
FOREIGN KEY (id_renta) REFERENCES renta(id_renta) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (id_video) REFERENCES video(id_video) ON UPDATE CASCADE,
CONSTRAINT chk_detalle_renta_cantidad CHECK (cantidad >= 1),
CONSTRAINT chk_detalle_renta_precio CHECK (precio_unitario > 0),
CONSTRAINT chk_detalle_renta_subtotal CHECK (subtotal > 0)
);

-- factura
-- Justificación NOT NULL:
--   Todos los campos son obligatorios para que la factura
--   sea un documento financiero válido.
-- Justificación CHECK:
--   subtotal > 0: toda factura debe tener un monto base.
--   descuento >= 0: no puede haber descuento negativo.
--   total > 0: el monto final siempre debe ser positivo.

CREATE TABLE factura (
id_factura INT NOT NULL AUTO_INCREMENT,
id_renta INT NOT NULL,
fecha DATE NOT NULL,
subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
descuento DECIMAL(10,2) NOT NULL DEFAULT 0.00,
total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
PRIMARY KEY (id_factura),
FOREIGN KEY (id_renta) REFERENCES renta(id_renta) ON UPDATE CASCADE,
CONSTRAINT chk_factura_subtotal CHECK (subtotal > 0),
CONSTRAINT chk_factura_descuento CHECK (descuento >= 0),
CONSTRAINT chk_factura_total CHECK (total > 0)
);

-- devolucion
-- Justificación NOT NULL:
--   Todos los campos son obligatorios; una devolución
--   sin fecha, renta o empleado es inválida.
-- Justificación CHECK:
--   estado solo acepta: completada, pendiente, rechazada.

CREATE TABLE devolucion (
id_devolucion INT NOT NULL AUTO_INCREMENT,
id_renta INT NOT NULL,
id_empleado INT NOT NULL,
id_mora INT NULL,
fecha_devolucion DATE NOT NULL,
estado VARCHAR(30) NOT NULL,
PRIMARY KEY (id_devolucion),
FOREIGN KEY (id_renta) REFERENCES renta(id_renta) ON UPDATE CASCADE,
FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado) ON UPDATE CASCADE
);

-- mora
-- Justificación NOT NULL:
--   Todos los campos son obligatorios para registrar
--   correctamente el cobro por atraso.
-- Justificación CHECK:
--   dias_atraso >= 1: si existe una mora, hubo al menos
--   un día de atraso.
--   monto > 0: toda mora tiene un valor a cobrar.
--   estado_pago solo acepta: pendiente, pagado, condonado.

CREATE TABLE mora (
id_mora INT NOT NULL AUTO_INCREMENT,
id_devolucion INT NOT NULL,
dias_atraso INT NOT NULL DEFAULT 0,
monto DECIMAL(10,2) NOT NULL DEFAULT 0.00,
estado_pago  VARCHAR(30) NOT NULL,
PRIMARY KEY (id_mora),
FOREIGN KEY (id_devolucion) REFERENCES devolucion(id_devolucion) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT chk_mora_dias CHECK (dias_atraso >= 1),
CONSTRAINT chk_mora_monto CHECK (monto > 0),
CONSTRAINT chk_mora_estado CHECK (estado_pago IN ('pendiente', 'pagado', 'condonado'))
);

ALTER TABLE devolucion ADD CONSTRAINT fk_devolucion_mora
FOREIGN KEY (id_mora) REFERENCES mora(id_mora) ON UPDATE CASCADE;

DELIMITER //

-- Trigger de UPDATE para la tabla video
CREATE TRIGGER trg_audit_video_update
AFTER UPDATE ON video
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        id_registro_afectado,
        datos_anteriores,
        datos_nuevos,
        usuario_app,
        usuario_db
    )
    VALUES (
        'video',
        'UPDATE',
        OLD.id_video,
        CONCAT('Código: ', OLD.codigo, ' | Título: ', OLD.titulo, ' | Precio: Q', OLD.precio_renta, ' | Stock: ', OLD.stock, ' | Estado: ', OLD.estado),
        CONCAT('Código: ', NEW.codigo, ' | Título: ', NEW.titulo, ' | Precio: Q', NEW.precio_renta, ' | Stock: ', NEW.stock, ' | Estado: ', NEW.estado),
        @app_usuario,
        CURRENT_USER()
    );
END //

-- triggers creados con IA

DELIMITER //
-- Trigger de DELETE para la tabla video
CREATE TRIGGER trg_audit_video_delete
AFTER DELETE ON video
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        id_registro_afectado,
        datos_anteriores,
        usuario_app,
        usuario_db
    )
    VALUES (
        'video',
        'DELETE',
        OLD.id_video,
        CONCAT('Código: ', OLD.codigo, ' | Título: ', OLD.titulo, ' | Precio: Q', OLD.precio_renta, ' | Stock: ', OLD.stock),
        @app_usuario,
        CURRENT_USER()
    );
END //

DELIMITER ;


-- Creacion de trigger para insertar clientes

DELIMITER //
CREATE TRIGGER trg_cliente_insert AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (
        tabla_afectada, operacion, id_registro_afectado, 
        datos_anteriores, datos_nuevos, usuario_app, usuario_db, fecha_hora
    )
    VALUES (
        'cliente', 'INSERT', NEW.id_cliente,
        'N/A', 
        CONCAT('Nombre: ', NEW.nombre, ', DPI: ', NEW.dpi),
        IFNULL(@app_usuario, 'Desconocido'),
        USER(), NOW()
    );
END //
DELIMITER ;

-- =====================================================================
-- SCRIPT DE CARGA DE DATOS - RentaVideoVHS
-- 100 registros por tabla (salvo catalogos de dominio acotado)
-- Generado respetando el orden de dependencias de llaves foraneas
-- =====================================================================
USE RentaVideoVHS;

-- 1. direccion --------------------------------------------------------
INSERT INTO direccion (calle, ciudad, departamento, pais) VALUES
('Calzada San Juan 2-45 zona 8', 'Chimaltenango', 'Chimaltenango', 'Guatemala'),
('Avenida Las Americas 7-96 zona 18', 'Villa Nueva', 'Guatemala', 'Guatemala'),
('Avenida Elena 28-14 zona 1', 'Villa Nueva', 'Guatemala', 'Guatemala'),
('1a Calle 15-74 zona 20', 'Guatemala', 'Guatemala', 'Guatemala'),
('Calzada Independencia 13-93 zona 18', 'Zacapa', 'Zacapa', 'Guatemala'),
('Boulevard Liberacion 29-85 zona 9', 'Guatemala', 'Guatemala', 'Guatemala'),
('Calzada Aguilar Batres 45-64 zona 11', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('Avenida Las Americas 14-53 zona 4', 'Villa Nueva', 'Guatemala', 'Guatemala'),
('Diagonal 6 7-55 zona 12', 'Peten (Flores)', 'Peten', 'Guatemala'),
('Avenida Petapa 3-68 zona 18', 'Antigua Guatemala', 'Sacatepequez', 'Guatemala'),
('Diagonal 6 6-80 zona 10', 'Peten (Flores)', 'Peten', 'Guatemala'),
('Avenida Bolivar 37-34 zona 3', 'Mixco', 'Guatemala', 'Guatemala'),
('Boulevard Liberacion 19-20 zona 8', 'Antigua Guatemala', 'Sacatepequez', 'Guatemala'),
('Diagonal 6 18-68 zona 21', 'Puerto Barrios', 'Izabal', 'Guatemala'),
('Calzada Aguilar Batres 24-55 zona 7', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('6a Avenida 39-91 zona 6', 'Chiquimula', 'Chiquimula', 'Guatemala'),
('Boulevard Liberacion 11-69 zona 13', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('Calzada Independencia 15-97 zona 11', 'Mixco', 'Guatemala', 'Guatemala'),
('Boulevard Liberacion 3-50 zona 13', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('6a Avenida 14-82 zona 11', 'Coban', 'Alta Verapaz', 'Guatemala'),
('Ruta 3 26-92 zona 15', 'Quetzaltenango', 'Quetzaltenango', 'Guatemala'),
('Avenida Petapa 9-41 zona 18', 'Chiquimula', 'Chiquimula', 'Guatemala'),
('Avenida Petapa 38-64 zona 19', 'Jalapa', 'Jalapa', 'Guatemala'),
('Avenida Bolivar 15-27 zona 17', 'Santa Lucia Cotzumalguapa', 'Escuintla', 'Guatemala'),
('6a Avenida 4-24 zona 5', 'Escuintla', 'Escuintla', 'Guatemala'),
('2a Calle 39-18 zona 13', 'Jalapa', 'Jalapa', 'Guatemala'),
('3a Calle 30-77 zona 9', 'Chiquimula', 'Chiquimula', 'Guatemala'),
('Avenida Reforma 44-24 zona 18', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('Calzada Atanasio Tzul 8-47 zona 14', 'Escuintla', 'Escuintla', 'Guatemala'),
('5a Avenida 1-43 zona 17', 'Escuintla', 'Escuintla', 'Guatemala'),
('Boulevard Los Proceres 7-90 zona 10', 'San Marcos', 'San Marcos', 'Guatemala'),
('3a Calle 13-29 zona 12', 'Escuintla', 'Escuintla', 'Guatemala'),
('Calzada Independencia 34-10 zona 20', 'Retalhuleu', 'Retalhuleu', 'Guatemala'),
('Ruta 3 2-24 zona 12', 'Mazatenango', 'Suchitepequez', 'Guatemala'),
('Boulevard Liberacion 4-40 zona 19', 'Villa Nueva', 'Guatemala', 'Guatemala'),
('6a Avenida 32-18 zona 18', 'Quetzaltenango', 'Quetzaltenango', 'Guatemala'),
('Avenida Las Americas 43-70 zona 18', 'Escuintla', 'Escuintla', 'Guatemala'),
('Avenida Petapa 34-87 zona 14', 'Coban', 'Alta Verapaz', 'Guatemala'),
('Calzada Independencia 45-35 zona 10', 'Jalapa', 'Jalapa', 'Guatemala'),
('Avenida Bolivar 29-76 zona 15', 'Antigua Guatemala', 'Sacatepequez', 'Guatemala'),
('Boulevard Liberacion 15-18 zona 11', 'Guatemala', 'Guatemala', 'Guatemala'),
('Avenida Elena 36-39 zona 19', 'Chimaltenango', 'Chimaltenango', 'Guatemala'),
('Avenida Reforma 5-90 zona 2', 'Chimaltenango', 'Chimaltenango', 'Guatemala'),
('6a Avenida 3-52 zona 3', 'San Marcos', 'San Marcos', 'Guatemala'),
('Boulevard Liberacion 18-95 zona 16', 'Coban', 'Alta Verapaz', 'Guatemala'),
('Calzada Independencia 9-83 zona 19', 'Santa Lucia Cotzumalguapa', 'Escuintla', 'Guatemala'),
('Boulevard Liberacion 31-62 zona 7', 'Antigua Guatemala', 'Sacatepequez', 'Guatemala'),
('Calzada San Juan 43-65 zona 12', 'Zacapa', 'Zacapa', 'Guatemala'),
('2a Calle 30-16 zona 21', 'Antigua Guatemala', 'Sacatepequez', 'Guatemala'),
('Calzada Roosevelt 26-53 zona 4', 'Chimaltenango', 'Chimaltenango', 'Guatemala'),
('1a Calle 13-78 zona 15', 'Quetzaltenango', 'Quetzaltenango', 'Guatemala'),
('2a Calle 12-45 zona 15', 'Chimaltenango', 'Chimaltenango', 'Guatemala'),
('6a Avenida 29-80 zona 4', 'Mixco', 'Guatemala', 'Guatemala'),
('Calzada Independencia 1-21 zona 8', 'Escuintla', 'Escuintla', 'Guatemala'),
('2a Calle 32-71 zona 7', 'Jalapa', 'Jalapa', 'Guatemala'),
('Calzada Roosevelt 11-58 zona 1', 'Jalapa', 'Jalapa', 'Guatemala'),
('Avenida Petapa 30-46 zona 14', 'Chiquimula', 'Chiquimula', 'Guatemala'),
('Ruta 3 10-34 zona 10', 'Coban', 'Alta Verapaz', 'Guatemala'),
('Calzada Roosevelt 38-79 zona 2', 'Retalhuleu', 'Retalhuleu', 'Guatemala'),
('Calzada Roosevelt 4-84 zona 16', 'San Marcos', 'San Marcos', 'Guatemala'),
('Boulevard Los Proceres 11-17 zona 17', 'Villa Nueva', 'Guatemala', 'Guatemala'),
('Calzada Aguilar Batres 5-86 zona 3', 'Chimaltenango', 'Chimaltenango', 'Guatemala'),
('Diagonal 6 8-82 zona 8', 'Jutiapa', 'Jutiapa', 'Guatemala'),
('3a Calle 3-89 zona 3', 'Zacapa', 'Zacapa', 'Guatemala'),
('Avenida Elena 37-76 zona 11', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('1a Calle 43-50 zona 8', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('Diagonal 6 9-95 zona 21', 'Mazatenango', 'Suchitepequez', 'Guatemala'),
('5a Avenida 21-19 zona 1', 'Solola', 'Solola', 'Guatemala'),
('3a Calle 37-22 zona 3', 'Chiquimula', 'Chiquimula', 'Guatemala'),
('1a Calle 33-43 zona 5', 'Puerto Barrios', 'Izabal', 'Guatemala'),
('6a Avenida 16-57 zona 10', 'Escuintla', 'Escuintla', 'Guatemala'),
('5a Avenida 35-48 zona 20', 'San Marcos', 'San Marcos', 'Guatemala'),
('Avenida Reforma 43-80 zona 10', 'Antigua Guatemala', 'Sacatepequez', 'Guatemala'),
('Avenida Las Americas 17-24 zona 4', 'Chiquimula', 'Chiquimula', 'Guatemala'),
('Avenida Las Americas 18-46 zona 20', 'Coban', 'Alta Verapaz', 'Guatemala'),
('Calzada Atanasio Tzul 14-97 zona 21', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('Boulevard Los Proceres 32-42 zona 2', 'Villa Nueva', 'Guatemala', 'Guatemala'),
('2a Calle 18-15 zona 1', 'Retalhuleu', 'Retalhuleu', 'Guatemala'),
('Avenida Las Americas 41-43 zona 6', 'Solola', 'Solola', 'Guatemala'),
('Calzada Independencia 28-81 zona 1', 'Antigua Guatemala', 'Sacatepequez', 'Guatemala'),
('6a Avenida 45-29 zona 18', 'Mixco', 'Guatemala', 'Guatemala'),
('Avenida Bolivar 38-80 zona 5', 'Zacapa', 'Zacapa', 'Guatemala'),
('Avenida Las Americas 3-49 zona 12', 'Mixco', 'Guatemala', 'Guatemala'),
('Avenida Bolivar 14-97 zona 8', 'Antigua Guatemala', 'Sacatepequez', 'Guatemala'),
('Avenida Bolivar 36-62 zona 20', 'Quetzaltenango', 'Quetzaltenango', 'Guatemala'),
('Boulevard Liberacion 11-32 zona 14', 'Guatemala', 'Guatemala', 'Guatemala'),
('Calzada Aguilar Batres 22-62 zona 8', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('Calzada Aguilar Batres 45-23 zona 13', 'Mixco', 'Guatemala', 'Guatemala'),
('Ruta 3 15-35 zona 15', 'Puerto Barrios', 'Izabal', 'Guatemala'),
('Ruta 6 15-38 zona 1', 'Coban', 'Alta Verapaz', 'Guatemala'),
('Diagonal 6 22-45 zona 3', 'Huehuetenango', 'Huehuetenango', 'Guatemala'),
('Avenida Bolivar 42-75 zona 13', 'Chiquimula', 'Chiquimula', 'Guatemala'),
('Calzada Atanasio Tzul 2-24 zona 9', 'Escuintla', 'Escuintla', 'Guatemala'),
('Avenida Elena 17-14 zona 4', 'Peten (Flores)', 'Peten', 'Guatemala'),
('2a Calle 23-50 zona 14', 'Peten (Flores)', 'Peten', 'Guatemala'),
('Boulevard Los Proceres 8-59 zona 19', 'Coban', 'Alta Verapaz', 'Guatemala'),
('Avenida Petapa 3-65 zona 1', 'San Marcos', 'San Marcos', 'Guatemala'),
('Calzada Independencia 44-95 zona 7', 'Puerto Barrios', 'Izabal', 'Guatemala'),
('2a Calle 5-95 zona 11', 'Peten (Flores)', 'Peten', 'Guatemala'),
('Calzada Atanasio Tzul 43-25 zona 10', 'San Marcos', 'San Marcos', 'Guatemala');

select * from direccion;
-- 2. empleado ---------------------------------------------------------
INSERT INTO empleado (nombre, puesto, telefono) VALUES
('Delia Reyes Chocooj', 'Auditor Interno', '44218542'),
('Dominga Us Chen', 'Gerente de Sucursal', '57812810'),
('Vinicio Sical Barrios', 'Supervisor', '58801207'),
('Marleny Us Barrios', 'Asistente Administrativo', '42422633'),
('Suceli Chub Say', 'Administrador de Sistema', '44940441'),
('Gloria Cifuentes Mendez', 'Cajero', '45107776'),
('Cecilia Perez Xocop', 'Supervisor', '47442089'),
('Norma Estrada Mendez', 'Cajero', '48132769'),
('Ricardo Coy Ixcoy', 'Asistente Administrativo', '45180853'),
('Sergio Sanchez Xocop', 'Administrador de Sistema', '59468772'),
('Concepcion Cotzojay Xitumul', 'Asistente Administrativo', '55348512'),
('Estuardo Ixcoy Aguilar', 'Auxiliar de Sucursal', '58379837'),
('Rudy Estrada Boror', 'Administrador de Sistema', '52351868'),
('Hector Cabrera Gudiel', 'Gerente de Sucursal', '42077581'),
('Delia Castillo Salazar', 'Asistente Administrativo', '52044645'),
('Rony Gudiel Guzman', 'Cajero', '59002392'),
('Elmer Chavez Mazariegos', 'Supervisor', '54700025'),
('Gloria Boror Tzoc', 'Asistente Administrativo', '47523941'),
('Norma Pop Xitumul', 'Asistente Administrativo', '49961107'),
('Amilcar Guzman Villatoro', 'Cajero', '48190929'),
('Sergio Chacon Rodriguez', 'Auditor Interno', '56492066'),
('Sergio Reyes Castillo', 'Supervisor', '58072684'),
('Rosa Solares Lopez', 'Cajero', '54761823'),
('Luis Mazariegos Lopez', 'Auxiliar de Sucursal', '41341919'),
('Francisco Sanchez Solares', 'Encargado de Bodega', '48801975'),
('Aracely Xitumul Recinos', 'Encargado de Bodega', '46218367'),
('Pablo Lopez Chavez', 'Supervisor', '54327421'),
('Pablo Coy Say', 'Auxiliar de Sucursal', '46059717'),
('Jorge Gonzalez Ortiz', 'Supervisor', '52156902'),
('Maria Quiche Aguilar', 'Encargado de Bodega', '57076506'),
('Alba Tzoc Chacon', 'Auditor Interno', '58799287'),
('Reyna Boror Reyes', 'Auxiliar de Sucursal', '45679639'),
('Vilma Mazariegos Xocop', 'Supervisor', '51481506'),
('Heidy Chacon Aguilar', 'Auxiliar de Sucursal', '55334434'),
('Yolanda Recinos Coy', 'Auditor Interno', '49667566'),
('Oscar Estrada Pop', 'Supervisor', '55031966'),
('Lourdes Cotzojay Lopez', 'Encargado de Bodega', '54717770'),
('Vilma Chavez Chub', 'Administrador de Sistema', '59907391'),
('Elvia Chen Rosales', 'Administrador de Sistema', '58612582'),
('Evelyn Paz Cabrera', 'Encargado de Bodega', '46294016'),
('Cesar Mazariegos Coy', 'Gerente de Sucursal', '44630331'),
('Yolanda Pop Guzman', 'Auditor Interno', '44256752'),
('Gloria Marroquin Chacon', 'Auditor Interno', '49961299'),
('Estuardo Gonzalez Rodriguez', 'Auditor Interno', '49235577'),
('Carlos Villatoro Sical', 'Asistente Administrativo', '58389840'),
('Ingrid Rodriguez Paz', 'Asistente Administrativo', '42096280'),
('Lourdes Perez Villatoro', 'Cajero', '43503120'),
('Rosa Estrada Morales', 'Supervisor', '49767312'),
('Marleny Cotzojay Chavez', 'Supervisor', '52010496'),
('Roberto Say Barrios', 'Auditor Interno', '43634980'),
('Ricardo Rosales Perez', 'Gerente de Sucursal', '47853787'),
('Telma Solares Sical', 'Cajero', '45833597'),
('Yesenia Perez Us', 'Auxiliar de Sucursal', '54318855'),
('Patricia Salazar Cabrera', 'Gerente de Sucursal', '53386328'),
('Jose Xitumul Chavez', 'Auditor Interno', '53086308'),
('Evelyn Coy Chocooj', 'Auditor Interno', '58344375'),
('Diego Gonzalez Tzoc', 'Administrador de Sistema', '51433940'),
('Manuel Us Villatoro', 'Cajero', '51674975'),
('Anibal Ixcoy Tzul', 'Asistente Administrativo', '54044882'),
('Lourdes Ramirez Solares', 'Administrador de Sistema', '56591986'),
('Silvia Xitumul Castillo', 'Supervisor', '55835492'),
('Concepcion Gonzalez Xocop', 'Encargado de Bodega', '55234550'),
('Patricia Chocooj Bautista', 'Cajero', '57933143'),
('Alejandro Ixcoy Marroquin', 'Asistente Administrativo', '51865901'),
('Estuardo Rosales Sanchez', 'Auditor Interno', '59132114'),
('Juan Say Recinos', 'Auxiliar de Sucursal', '46213522'),
('Alfredo Quiche Ramirez', 'Auxiliar de Sucursal', '48741810'),
('Hector Aguilar Toc', 'Auditor Interno', '57970771'),
('Beatriz Estrada Xocop', 'Gerente de Sucursal', '54197911'),
('Miguel Boror Quiche', 'Administrador de Sistema', '51043037'),
('Evelyn Guzman Guzman', 'Asistente Administrativo', '48491822'),
('Zoila Castillo Rosales', 'Supervisor', '56398528'),
('Francisco Villatoro Gudiel', 'Auxiliar de Sucursal', '51732280'),
('Beatriz Toc Gudiel', 'Supervisor', '49310235'),
('Marvin Bautista Guzman', 'Administrador de Sistema', '48387112'),
('Baudilio Xocop Garcia', 'Gerente de Sucursal', '53589751'),
('Anibal Paz Castillo', 'Supervisor', '46512415'),
('Heidy Say Toc', 'Asistente Administrativo', '42147909'),
('Rudy Cabrera Chen', 'Encargado de Bodega', '52651601'),
('Mynor Xitumul Coy', 'Auditor Interno', '41771600'),
('Karla Sical Ortiz', 'Administrador de Sistema', '53442255'),
('Baudilio Quiche Villatoro', 'Gerente de Sucursal', '43937176'),
('Mario Gudiel Alvarado', 'Auxiliar de Sucursal', '53401116'),
('Sergio Say Paz', 'Asistente Administrativo', '51157662'),
('Sucely Us Salazar', 'Gerente de Sucursal', '48410995'),
('Reyna Chavez Say', 'Supervisor', '58664433'),
('Miriam Gudiel Solares', 'Encargado de Bodega', '47398231'),
('Petronila Sical Coy', 'Auditor Interno', '47640518'),
('Maria Villatoro Us', 'Cajero', '55801541'),
('Diego Ortiz Cabrera', 'Auxiliar de Sucursal', '53294774'),
('Luis Chavez Cotzojay', 'Cajero', '53204724'),
('Rudy Reyes Chen', 'Supervisor', '44368777'),
('Cesar Marroquin Ixcoy', 'Auditor Interno', '45311242'),
('Sucely Chen Castillo', 'Encargado de Bodega', '52263313'),
('Manuel Us Pop', 'Supervisor', '52515030'),
('Maria Paz Salazar', 'Encargado de Bodega', '57183841'),
('Reyna Gudiel Say', 'Administrador de Sistema', '44922880'),
('Ana Alvarado Rosales', 'Administrador de Sistema', '42060605'),
('Evelyn Tzul Quiche', 'Encargado de Bodega', '41760793'),
('Vinicio Aguilar Morales', 'Encargado de Bodega', '43276065');

select * from empleado;

-- 3. tipo_membresia -----------------------------------------------------
-- NOTA: catalogo de dominio fijo, se usan 4 tipos reales de membresia
--       en vez de 100 filas duplicadas.
INSERT INTO tipo_membresia (tipo, descuento_disponible) VALUES
('Basica', 0),
('Plata', 1),
('Oro', 1),
('Platino', 1);

select * from tipo_membresia;

-- 4. video --------------------------------------------------------------
INSERT INTO video (titulo, genero, precio_renta, stock, estado, codigo, director, anio, clasificacion, duracion, idioma) VALUES
('Titanic', 'Romance', 29.00, 7, 'disponible', 'VHS-0001', 'James Cameron', 1997, 'PG-13', 194, 'Ingles'),
('El Padrino', 'Drama', 25.00, 8, 'disponible', 'VHS-0002', 'Francis Ford Coppola', 1972, 'R', 175, 'Ingles'),
('Jurassic Park', 'Ciencia Ficcion', 22.00, 6, 'disponible', 'VHS-0003', 'Steven Spielberg', 1993, 'PG-13', 127, 'Ingles'),
('Forrest Gump', 'Drama', 20.00, 11, 'disponible', 'VHS-0004', 'Robert Zemeckis', 1994, 'PG-13', 142, 'Ingles'),
('El Rey Leon', 'Animacion', 18.00, 12, 'disponible', 'VHS-0005', 'Roger Allers', 1994, 'G', 88, 'Espanol'),
('Terminator 2: El Juicio Final', 'Accion', 22.00, 12, 'disponible', 'VHS-0006', 'James Cameron', 1991, 'R', 137, 'Ingles'),
('Mi Pobre Angelito', 'Comedia', 15.00, 9, 'disponible', 'VHS-0007', 'Chris Columbus', 1990, 'PG', 103, 'Espanol'),
('Duro de Matar', 'Accion', 20.00, 7, 'disponible', 'VHS-0008', 'John McTiernan', 1988, 'R', 132, 'Ingles'),
('Volver al Futuro', 'Ciencia Ficcion', 20.00, 10, 'disponible', 'VHS-0009', 'Robert Zemeckis', 1985, 'PG', 116, 'Espanol'),
('E.T. El Extraterrestre', 'Ciencia Ficcion', 18.00, 12, 'disponible', 'VHS-0010', 'Steven Spielberg', 1982, 'PG', 115, 'Espanol'),
('Star Wars: Una Nueva Esperanza', 'Ciencia Ficcion', 25.00, 12, 'disponible', 'VHS-0011', 'George Lucas', 1977, 'PG', 121, 'Ingles'),
('El Imperio Contraataca', 'Ciencia Ficcion', 25.00, 3, 'disponible', 'VHS-0012', 'Irvin Kershner', 1980, 'PG', 124, 'Ingles'),
('El Retorno del Jedi', 'Ciencia Ficcion', 25.00, 15, 'disponible', 'VHS-0013', 'Richard Marquand', 1983, 'PG', 131, 'Ingles'),
('En Busca del Arca Perdida', 'Aventura', 20.00, 7, 'disponible', 'VHS-0014', 'Steven Spielberg', 1981, 'PG', 115, 'Ingles'),
('Los Cazafantasmas', 'Comedia', 18.00, 11, 'disponible', 'VHS-0015', 'Ivan Reitman', 1984, 'PG', 105, 'Ingles'),
('Tiburon', 'Suspenso', 20.00, 2, 'disponible', 'VHS-0016', 'Steven Spielberg', 1975, 'PG', 124, 'Ingles'),
('Rocky', 'Drama', 17.00, 14, 'disponible', 'VHS-0017', 'John G. Avildsen', 1976, 'PG', 120, 'Ingles'),
('Rambo: Acorralado', 'Accion', 18.00, 8, 'disponible', 'VHS-0018', 'Ted Kotcheff', 1982, 'R', 93, 'Ingles'),
('Scarface', 'Drama', 22.00, 10, 'disponible', 'VHS-0019', 'Brian De Palma', 1983, 'R', 170, 'Ingles'),
('Pulp Fiction', 'Crimen', 22.00, 7, 'disponible', 'VHS-0020', 'Quentin Tarantino', 1994, 'R', 154, 'Ingles'),
('Sueno de Fuga', 'Drama', 20.00, 5, 'disponible', 'VHS-0021', 'Frank Darabont', 1994, 'R', 142, 'Ingles'),
('Siete', 'Suspenso', 18.00, 1, 'disponible', 'VHS-0022', 'David Fincher', 1995, 'R', 127, 'Ingles'),
('El Silencio de los Inocentes', 'Suspenso', 20.00, 12, 'disponible', 'VHS-0023', 'Jonathan Demme', 1991, 'R', 118, 'Ingles'),
('Aladdin', 'Animacion', 16.00, 6, 'disponible', 'VHS-0024', 'Ron Clements', 1992, 'G', 90, 'Espanol'),
('Toy Story', 'Animacion', 16.00, 4, 'disponible', 'VHS-0025', 'John Lasseter', 1995, 'G', 81, 'Espanol'),
('La Bella y la Bestia', 'Animacion', 16.00, 8, 'disponible', 'VHS-0026', 'Gary Trousdale', 1991, 'G', 84, 'Espanol'),
('La Sirenita', 'Animacion', 15.00, 8, 'disponible', 'VHS-0027', 'Ron Clements', 1989, 'G', 83, 'Espanol'),
('La Senora Doubtfire', 'Comedia', 17.00, 4, 'disponible', 'VHS-0028', 'Chris Columbus', 1993, 'PG-13', 125, 'Espanol'),
('Dos Tontos Muy Tontos', 'Comedia', 14.00, 14, 'disponible', 'VHS-0029', 'Peter Farrelly', 1994, 'PG-13', 107, 'Ingles'),
('Duro de Matar 2', 'Accion', 18.00, 6, 'disponible', 'VHS-0030', 'Renny Harlin', 1990, 'R', 124, 'Ingles'),
('Mentiras Verdaderas', 'Accion', 20.00, 2, 'disponible', 'VHS-0031', 'James Cameron', 1994, 'R', 141, 'Ingles'),
('La Mascara', 'Comedia', 16.00, 11, 'disponible', 'VHS-0032', 'Chuck Russell', 1994, 'PG-13', 101, 'Espanol'),
('Ace Ventura: Detective de Mascotas', 'Comedia', 14.00, 6, 'disponible', 'VHS-0033', 'Tom Shadyac', 1994, 'PG-13', 86, 'Espanol'),
('Batman', 'Accion', 20.00, 9, 'disponible', 'VHS-0034', 'Tim Burton', 1989, 'PG-13', 126, 'Ingles'),
('Batman Regresa', 'Accion', 20.00, 15, 'disponible', 'VHS-0035', 'Tim Burton', 1992, 'PG-13', 126, 'Ingles'),
('Robocop', 'Ciencia Ficcion', 18.00, 11, 'disponible', 'VHS-0036', 'Paul Verhoeven', 1987, 'R', 102, 'Ingles'),
('Depredador', 'Accion', 18.00, 6, 'disponible', 'VHS-0037', 'John McTiernan', 1987, 'R', 107, 'Ingles'),
('Desafio Total', 'Ciencia Ficcion', 18.00, 1, 'disponible', 'VHS-0038', 'Paul Verhoeven', 1990, 'R', 113, 'Ingles'),
('Bajos Instintos', 'Suspenso', 20.00, 7, 'disponible', 'VHS-0039', 'Paul Verhoeven', 1992, 'R', 127, 'Ingles'),
('Mujer Bonita', 'Romance', 17.00, 5, 'disponible', 'VHS-0040', 'Garry Marshall', 1990, 'R', 119, 'Espanol'),
('Ghost: La Sombra del Amor', 'Romance', 17.00, 4, 'disponible', 'VHS-0041', 'Jerry Zucker', 1990, 'PG-13', 127, 'Espanol'),
('Danza con Lobos', 'Drama', 22.00, 2, 'disponible', 'VHS-0042', 'Kevin Costner', 1990, 'PG-13', 181, 'Ingles'),
('Corazon Valiente', 'Drama', 22.00, 14, 'disponible', 'VHS-0043', 'Mel Gibson', 1995, 'R', 178, 'Ingles'),
('Apolo 13', 'Drama', 20.00, 14, 'disponible', 'VHS-0044', 'Ron Howard', 1995, 'PG', 140, 'Ingles'),
('Dia de la Independencia', 'Ciencia Ficcion', 20.00, 8, 'disponible', 'VHS-0045', 'Roland Emmerich', 1996, 'PG-13', 145, 'Espanol'),
('Twister', 'Accion', 18.00, 2, 'disponible', 'VHS-0046', 'Jan de Bont', 1996, 'PG-13', 113, 'Ingles'),
('Mision Imposible', 'Accion', 20.00, 11, 'disponible', 'VHS-0047', 'Brian De Palma', 1996, 'PG-13', 110, 'Espanol'),
('La Roca', 'Accion', 20.00, 4, 'disponible', 'VHS-0048', 'Michael Bay', 1996, 'R', 136, 'Ingles'),
('Con Air: Riesgo en el Aire', 'Accion', 18.00, 11, 'disponible', 'VHS-0049', 'Simon West', 1997, 'R', 115, 'Espanol'),
('El Avion del Presidente', 'Accion', 18.00, 11, 'disponible', 'VHS-0050', 'Wolfgang Petersen', 1997, 'R', 124, 'Espanol'),
('Hombres de Negro', 'Ciencia Ficcion', 18.00, 10, 'disponible', 'VHS-0051', 'Barry Sonnenfeld', 1997, 'PG-13', 98, 'Espanol'),
('El Quinto Elemento', 'Ciencia Ficcion', 20.00, 1, 'disponible', 'VHS-0052', 'Luc Besson', 1997, 'PG-13', 126, 'Ingles'),
('Cara a Cara', 'Accion', 18.00, 1, 'disponible', 'VHS-0053', 'John Woo', 1997, 'R', 138, 'Ingles'),
('Mente Indomable', 'Drama', 20.00, 13, 'disponible', 'VHS-0054', 'Gus Van Sant', 1997, 'R', 126, 'Ingles'),
('Mejor Imposible', 'Comedia', 17.00, 6, 'disponible', 'VHS-0055', 'James L. Brooks', 1997, 'PG-13', 139, 'Espanol'),
('Matrix', 'Ciencia Ficcion', 22.00, 4, 'disponible', 'VHS-0056', 'Hermanas Wachowski', 1999, 'R', 136, 'Ingles'),
('American Beauty', 'Drama', 20.00, 3, 'disponible', 'VHS-0057', 'Sam Mendes', 1999, 'R', 122, 'Ingles'),
('El Club de la Pelea', 'Drama', 22.00, 13, 'disponible', 'VHS-0058', 'David Fincher', 1999, 'R', 139, 'Ingles'),
('El Sexto Sentido', 'Suspenso', 20.00, 10, 'disponible', 'VHS-0059', 'M. Night Shyamalan', 1999, 'PG-13', 107, 'Espanol'),
('Notting Hill', 'Romance', 17.00, 4, 'disponible', 'VHS-0060', 'Roger Michell', 1999, 'PG-13', 124, 'Espanol'),
('Gladiador', 'Accion', 22.00, 2, 'disponible', 'VHS-0061', 'Ridley Scott', 2000, 'R', 155, 'Ingles'),
('Naufrago', 'Drama', 20.00, 14, 'disponible', 'VHS-0062', 'Robert Zemeckis', 2000, 'PG-13', 143, 'Espanol'),
('Mision Imposible 2', 'Accion', 20.00, 13, 'disponible', 'VHS-0063', 'John Woo', 2000, 'PG-13', 123, 'Espanol'),
('X-Men', 'Accion', 20.00, 9, 'disponible', 'VHS-0064', 'Bryan Singer', 2000, 'PG-13', 104, 'Ingles'),
('Shrek', 'Animacion', 18.00, 4, 'disponible', 'VHS-0065', 'Andrew Adamson', 2001, 'PG', 90, 'Espanol'),
('Monsters Inc.', 'Animacion', 18.00, 10, 'disponible', 'VHS-0066', 'Pete Docter', 2001, 'G', 92, 'Espanol'),
('Harry Potter y la Piedra Filosofal', 'Fantasia', 22.00, 4, 'disponible', 'VHS-0067', 'Chris Columbus', 2001, 'PG', 152, 'Espanol'),
('El Senor de los Anillos: La Comunidad del Anillo', 'Fantasia', 25.00, 14, 'disponible', 'VHS-0068', 'Peter Jackson', 2001, 'PG-13', 178, 'Espanol'),
('El Hombre Arana', 'Accion', 20.00, 14, 'disponible', 'VHS-0069', 'Sam Raimi', 2002, 'PG-13', 121, 'Espanol'),
('La Era de Hielo', 'Animacion', 16.00, 4, 'disponible', 'VHS-0070', 'Chris Wedge', 2002, 'PG', 81, 'Espanol'),
('Buscando a Nemo', 'Animacion', 18.00, 6, 'disponible', 'VHS-0071', 'Andrew Stanton', 2003, 'G', 100, 'Espanol'),
('Piratas del Caribe: La Maldicion del Perla Negra', 'Aventura', 22.00, 13, 'disponible', 'VHS-0072', 'Gore Verbinski', 2003, 'PG-13', 143, 'Espanol'),
('Matrix Recargado', 'Ciencia Ficcion', 20.00, 3, 'disponible', 'VHS-0073', 'Hermanas Wachowski', 2003, 'R', 138, 'Ingles'),
('Shrek 2', 'Animacion', 18.00, 13, 'disponible', 'VHS-0074', 'Andrew Adamson', 2004, 'PG', 93, 'Espanol'),
('Los Increibles', 'Animacion', 18.00, 15, 'disponible', 'VHS-0075', 'Brad Bird', 2004, 'PG', 115, 'Espanol'),
('Sr. y Sra. Smith', 'Accion', 18.00, 10, 'disponible', 'VHS-0076', 'Doug Liman', 2005, 'PG-13', 120, 'Espanol'),
('King Kong', 'Aventura', 22.00, 1, 'disponible', 'VHS-0077', 'Peter Jackson', 2005, 'PG-13', 187, 'Espanol'),
('Cars', 'Animacion', 16.00, 5, 'disponible', 'VHS-0078', 'John Lasseter', 2006, 'G', 117, 'Espanol'),
('El Laberinto del Fauno', 'Fantasia', 20.00, 14, 'disponible', 'VHS-0079', 'Guillermo del Toro', 2006, 'R', 118, 'Espanol'),
('Amores Perros', 'Drama', 18.00, 3, 'disponible', 'VHS-0080', 'Alejandro Gonzalez Inarritu', 2000, 'R', 154, 'Espanol'),
('Y Tu Mama Tambien', 'Drama', 18.00, 3, 'rentado', 'VHS-0081', 'Alfonso Cuaron', 2001, 'R', 106, 'Espanol'),
('Como Agua para Chocolate', 'Romance', 17.00, 9, 'rentado', 'VHS-0082', 'Alfonso Arau', 1992, 'R', 105, 'Espanol'),
('El Mariachi', 'Accion', 15.00, 5, 'rentado', 'VHS-0083', 'Robert Rodriguez', 1992, 'R', 81, 'Espanol'),
('Nueve Reinas', 'Suspenso', 17.00, 13, 'rentado', 'VHS-0084', 'Fabian Bielinsky', 2000, 'R', 114, 'Espanol'),
('Diarios de Motocicleta', 'Drama', 18.00, 3, 'rentado', 'VHS-0085', 'Walter Salles', 2004, 'R', 128, 'Espanol'),
('El Secreto de sus Ojos', 'Drama', 18.00, 2, 'rentado', 'VHS-0086', 'Juan Jose Campanella', 2009, 'R', 129, 'Espanol'),
('Como Caido del Cielo', 'Comedia', 14.00, 11, 'rentado', 'VHS-0087', 'Luis Estrada', 1990, 'PG-13', 95, 'Espanol'),
('La Ley de Herodes', 'Comedia', 16.00, 14, 'rentado', 'VHS-0088', 'Luis Estrada', 1999, 'R', 122, 'Espanol'),
('Sexo, Pudor y Lagrimas', 'Comedia', 16.00, 1, 'rentado', 'VHS-0089', 'Antonio Serrano', 1999, 'R', 117, 'Espanol'),
('Frida', 'Drama', 18.00, 3, 'rentado', 'VHS-0090', 'Julie Taymor', 2002, 'R', 123, 'Espanol'),
('El Crimen del Padre Amaro', 'Drama', 17.00, 1, 'rentado', 'VHS-0091', 'Carlos Carrera', 2002, 'R', 120, 'Espanol'),
('La Misma Luna', 'Drama', 16.00, 6, 'rentado', 'VHS-0092', 'Patricia Riggen', 2007, 'PG-13', 106, 'Espanol'),
('Kamchatka', 'Drama', 16.00, 13, 'rentado', 'VHS-0093', 'Marcelo Pineyro', 2002, 'PG-13', 105, 'Espanol'),
('Volver', 'Drama', 18.00, 13, 'danado', 'VHS-0094', 'Pedro Almodovar', 2006, 'R', 121, 'Espanol'),
('Todo Sobre mi Madre', 'Drama', 18.00, 4, 'danado', 'VHS-0095', 'Pedro Almodovar', 1999, 'R', 101, 'Espanol'),
('Amelie', 'Romance', 18.00, 10, 'danado', 'VHS-0096', 'Jean-Pierre Jeunet', 2001, 'R', 122, 'Frances'),
('Cinema Paradiso', 'Drama', 18.00, 6, 'danado', 'VHS-0097', 'Giuseppe Tornatore', 1988, 'PG', 155, 'Italiano'),
('La Vida es Bella', 'Drama', 18.00, 1, 'danado', 'VHS-0098', 'Roberto Benigni', 1997, 'PG-13', 116, 'Italiano'),
('Tigre y Dragon', 'Fantasia', 18.00, 0, 'dado_de_baja', 'VHS-0099', 'Ang Lee', 2000, 'PG-13', 120, 'Mandarin'),
('La Milla Verde', 'Drama', 22.00, 0, 'dado_de_baja', 'VHS-0100', 'Frank Darabont', 1999, 'R', 189, 'Ingles');

select * from video;

-- 5. usuario --------------------------------------------------------------
-- usuario = primer nombre + inicial del primer apellido (concuerda con empleado)
INSERT INTO usuario (usuario, contrasena, id_empleado, rol, estado) VALUES
('DeliaR', '1234', 1, 'Auditor', 1),
('DomingaU', '1234', 2, 'Administrador', 1),
('VinicioS', '1234', 3, 'Empleado', 1),
('MarlenyU', '1234', 4, 'Empleado', 1),
('SuceliC', '1234', 5, 'Administrador', 1),
('GloriaC', '1234', 6, 'Empleado', 1),
('CeciliaP', '1234', 7, 'Empleado', 1),
('NormaE', '1234', 8, 'Empleado', 1),
('RicardoC', '1234', 9, 'Empleado', 1),
('SergioS', '1234', 10, 'Administrador', 1),
('ConcepcionC', '1234', 11, 'Empleado', 1),
('EstuardoI', '1234', 12, 'Empleado', 0),
('RudyE', '1234', 13, 'Administrador', 1),
('HectorC', '1234', 14, 'Administrador', 1),
('DeliaC', '1234', 15, 'Empleado', 1),
('RonyG', '1234', 16, 'Empleado', 1),
('ElmerC', '1234', 17, 'Empleado', 1),
('GloriaB', '1234', 18, 'Empleado', 1),
('NormaP', '1234', 19, 'Empleado', 1),
('AmilcarG', '1234', 20, 'Empleado', 1),
('SergioC', '1234', 21, 'Auditor', 1),
('SergioR', '1234', 22, 'Empleado', 1),
('RosaS', '1234', 23, 'Empleado', 1),
('LuisM', '1234', 24, 'Empleado', 1),
('FranciscoS', '1234', 25, 'Empleado', 1),
('AracelyX', '1234', 26, 'Empleado', 1),
('PabloL', '1234', 27, 'Empleado', 1),
('PabloC', '1234', 28, 'Empleado', 1),
('JorgeG', '1234', 29, 'Empleado', 1),
('MariaQ', '1234', 30, 'Empleado', 1),
('AlbaT', '1234', 31, 'Auditor', 1),
('ReynaB', '1234', 32, 'Empleado', 1),
('VilmaM', '1234', 33, 'Empleado', 1),
('HeidyC', '1234', 34, 'Empleado', 1),
('YolandaR', '1234', 35, 'Auditor', 1),
('OscarE', '1234', 36, 'Empleado', 1),
('LourdesC', '1234', 37, 'Empleado', 1),
('VilmaC', '1234', 38, 'Administrador', 1),
('ElviaC', '1234', 39, 'Administrador', 1),
('EvelynP', '1234', 40, 'Empleado', 1),
('CesarM', '1234', 41, 'Administrador', 1),
('YolandaP', '1234', 42, 'Auditor', 1),
('GloriaM', '1234', 43, 'Auditor', 1),
('EstuardoG', '1234', 44, 'Auditor', 1),
('CarlosV', '1234', 45, 'Empleado', 1),
('IngridR', '1234', 46, 'Empleado', 1),
('LourdesP', '1234', 47, 'Empleado', 1),
('RosaE', '1234', 48, 'Empleado', 1),
('MarlenyC', '1234', 49, 'Empleado', 1),
('RobertoS', '1234', 50, 'Auditor', 1),
('RicardoR', '1234', 51, 'Administrador', 1),
('TelmaS', '1234', 52, 'Empleado', 1),
('YeseniaP', '1234', 53, 'Empleado', 1),
('PatriciaS', '1234', 54, 'Administrador', 1),
('JoseX', '1234', 55, 'Auditor', 1),
('EvelynC', '1234', 56, 'Auditor', 1),
('DiegoG', '1234', 57, 'Administrador', 1),
('ManuelU', '1234', 58, 'Empleado', 1),
('AnibalI', '1234', 59, 'Empleado', 1),
('LourdesR', '1234', 60, 'Administrador', 1),
('SilviaX', '1234', 61, 'Empleado', 1),
('ConcepcionG', '1234', 62, 'Empleado', 1),
('PatriciaC', '1234', 63, 'Empleado', 1),
('AlejandroI', '1234', 64, 'Empleado', 1),
('EstuardoR', '1234', 65, 'Auditor', 1),
('JuanS', '1234', 66, 'Empleado', 1),
('AlfredoQ', '1234', 67, 'Empleado', 1),
('HectorA', '1234', 68, 'Auditor', 1),
('BeatrizE', '1234', 69, 'Administrador', 1),
('MiguelB', '1234', 70, 'Administrador', 1),
('EvelynG', '1234', 71, 'Empleado', 1),
('ZoilaC', '1234', 72, 'Empleado', 1),
('FranciscoV', '1234', 73, 'Empleado', 1),
('BeatrizT', '1234', 74, 'Empleado', 1),
('MarvinB', '1234', 75, 'Administrador', 1),
('BaudilioX', '1234', 76, 'Administrador', 1),
('AnibalP', '1234', 77, 'Empleado', 1),
('HeidyS', '1234', 78, 'Empleado', 1),
('RudyC', '1234', 79, 'Empleado', 1),
('MynorX', '1234', 80, 'Auditor', 1),
('KarlaS', '1234', 81, 'Administrador', 1),
('BaudilioQ', '1234', 82, 'Administrador', 1),
('MarioG', '1234', 83, 'Empleado', 1),
('SergioS2', '1234', 84, 'Empleado', 1),
('SucelyU', '1234', 85, 'Administrador', 1),
('ReynaC', '1234', 86, 'Empleado', 1),
('MiriamG', '1234', 87, 'Empleado', 1),
('PetronilaS', '1234', 88, 'Auditor', 0),
('MariaV', '1234', 89, 'Empleado', 1),
('DiegoO', '1234', 90, 'Empleado', 1),
('LuisC', '1234', 91, 'Empleado', 1),
('RudyR', '1234', 92, 'Empleado', 1),
('CesarM2', '1234', 93, 'Auditor', 1),
('SucelyC', '1234', 94, 'Empleado', 1),
('ManuelU2', '1234', 95, 'Empleado', 1),
('MariaP', '1234', 96, 'Empleado', 0),
('ReynaG', '1234', 97, 'Administrador', 1),
('AnaA', '1234', 98, 'Administrador', 1),
('EvelynT', '1234', 99, 'Empleado', 1),
('VinicioA', '1234', 100, 'Empleado', 1);

INSERT INTO usuario (usuario, contrasena, id_empleado, rol, estado) VALUES
('OscarM', '1234', 1, 'Auditor', 1);

select * from usuario;

-- 6. cliente ----------------------------------------------------------
-- NOTA: no_rentas = total historico de rentas del cliente con la tienda.
--       descuento = 1 unicamente cuando no_rentas >= 50 (regla de negocio).
INSERT INTO cliente (nombre, dpi, telefono, direccion, correo, no_rentas, descuento, id_membresia) VALUES
('Karla Hernandez Gudiel', '0166299795453', '59950391', '6a Avenida 30-82 zona 5, Villa Nueva', 'karla833@yahoo.com', 6, 0, NULL),
('Beatriz Cabrera Cabrera', '2945625577017', '36896198', 'Ruta 3 30-31 zona 10, Puerto Barrios', 'beatriz619@hotmail.com', 32, 0, NULL),
('Selvin Rosales Tzul', '1487696393827', '42108301', 'Calzada Atanasio Tzul 14-98 zona 19, Zacapa', 'selvin804@yahoo.com', 93, 1, NULL),
('Ricardo Chub Chub', '1971997581724', '42167822', '3a Calle 7-97 zona 20, Jalapa', 'ricardo336@yahoo.com', 41, 0, NULL),
('Marvin Guzman Mazariegos', '0227846997335', '46109503', '2a Calle 23-21 zona 19, Guatemala', 'marvin627@yahoo.com', 8, 0, NULL),
('Concepcion Rodriguez Garcia', '8514036965666', '44543617', 'Calzada Aguilar Batres 31-27 zona 7, Chiquimula', 'concepcion394@outlook.com', 26, 0, NULL),
('Marvin Garcia Perez', '0276212679692', '49546564', '2a Calle 36-67 zona 13, Puerto Barrios', 'marvin232@hotmail.com', 50, 1, NULL),
('Vilma Toc Bautista', '4689500975197', '52343236', 'Avenida Las Americas 34-45 zona 15, San Marcos', 'vilma81@gmail.com', 15, 0, NULL),
('Cecilia Rodriguez Castillo', '8077879565442', '36101462', 'Avenida Elena 17-17 zona 21, Santa Lucia Cotzumalguapa', 'cecilia593@hotmail.com', 36, 0, NULL),
('Rudy Aguilar Ramirez', '2814429444019', '33535634', '5a Avenida 24-32 zona 9, Chimaltenango', 'rudy497@hotmail.com', 33, 0, NULL),
('Hector Recinos Mendez', '7663723950410', '38784878', 'Diagonal 6 31-48 zona 16, Chiquimula', 'hector240@yahoo.com', 99, 1, NULL),
('Alba Ixcoy Tzoc', '0476580185694', '45535319', 'Avenida Petapa 7-42 zona 21, Jutiapa', 'alba401@yahoo.com', 80, 1, NULL),
('Baudilio Castillo Us', '2580010618175', '35752935', 'Avenida Petapa 13-14 zona 1, Peten (Flores)', 'baudilio95@gmail.com', 77, 1, NULL),
('Byron Ramirez Recinos', '2692124471746', '56425820', 'Avenida Petapa 11-19 zona 9, Mixco', 'byron392@yahoo.com', 21, 0, NULL),
('Ingrid Cotzojay Perez', '7396271286391', '45345236', 'Calzada San Juan 3-19 zona 3, Jutiapa', 'ingrid746@outlook.com', 49, 0, NULL),
('Alba Tzul Say', '0064256908776', '42176077', 'Calzada Independencia 15-10 zona 13, Santa Lucia Cotzumalguapa', 'alba125@outlook.com', 21, 0, NULL),
('Oscar Marroquin Salazar', '5174328063461', '57027401', 'Ruta 3 6-90 zona 15, Coban', 'oscar144@gmail.com', 53, 1, NULL),
('Wilfredo Gudiel Perez', '8478700505061', '39776491', '5a Avenida 44-78 zona 5, Jutiapa', 'wilfredo239@gmail.com', 68, 1, NULL),
('Anibal Alvarado Gonzalez', '3202041792911', '39340683', '3a Calle 40-38 zona 3, Coban', 'anibal437@outlook.com', 47, 0, NULL),
('Jorge Salazar Sanchez', '5309251142625', '53768343', '5a Avenida 16-84 zona 2, Quetzaltenango', 'jorge103@yahoo.com', 49, 0, NULL),
('Rosa Garcia Garcia', '2194672324876', '33928445', '3a Calle 45-14 zona 20, Escuintla', 'rosa735@yahoo.com', 39, 0, NULL),
('Delia Garcia Rosales', '3318195883734', '34250065', 'Calzada San Juan 10-97 zona 16, Santa Lucia Cotzumalguapa', 'delia181@hotmail.com', 42, 0, NULL),
('Sucely Barrios Tzoc', '4597010822078', '32188825', 'Boulevard Liberacion 29-85 zona 19, Retalhuleu', 'sucely430@hotmail.com', 47, 0, NULL),
('Selvin Cabrera Hernandez', '3636317970623', '58633480', 'Calzada Aguilar Batres 25-57 zona 5, Solola', 'selvin738@hotmail.com', 40, 0, NULL),
('Gerson Sanchez Gonzalez', '9042177625349', '33851044', 'Avenida Elena 36-39 zona 3, Zacapa', 'gerson878@yahoo.com', 110, 1, NULL),
('Maria Pop Tzoc', '3356939290600', '49459346', 'Calzada Roosevelt 28-77 zona 13, Santa Lucia Cotzumalguapa', 'maria830@gmail.com', 28, 0, NULL),
('Alfredo Mazariegos Garcia', '6325431074279', '51409590', '5a Avenida 30-27 zona 13, Escuintla', 'alfredo809@outlook.com', 40, 0, NULL),
('Werner Coy Castillo', '8046498931950', '57106747', 'Calzada Roosevelt 8-59 zona 12, Solola', 'werner634@gmail.com', 23, 0, NULL),
('Alfredo Toc Barrios', '2538179335548', '58095573', 'Avenida Petapa 4-18 zona 12, Puerto Barrios', 'alfredo464@yahoo.com', 32, 0, NULL),
('Amparo Us Salazar', '4795137116241', '33764318', 'Avenida Petapa 8-99 zona 5, Santa Lucia Cotzumalguapa', 'amparo155@hotmail.com', 33, 0, NULL),
('Amparo Sanchez Solares', '5670431038569', '46474513', 'Ruta 3 38-95 zona 17, Chiquimula', 'amparo456@yahoo.com', 19, 0, NULL),
('Danilo Cabrera Solares', '5402547292842', '33575047', 'Calzada Aguilar Batres 16-24 zona 2, Retalhuleu', 'danilo589@hotmail.com', 28, 0, NULL),
('Roberto Rosales Toc', '0552578284106', '43439136', '5a Avenida 21-29 zona 1, Chiquimula', 'roberto520@outlook.com', 87, 1, NULL),
('Petronila Chub Mendez', '9751702814069', '38482180', 'Avenida Bolivar 6-51 zona 2, Peten (Flores)', 'petronila657@hotmail.com', 37, 0, NULL),
('Miriam Lopez Ramirez', '8718637599805', '43482120', '2a Calle 24-59 zona 12, Guatemala', 'miriam292@outlook.com', 89, 1, NULL),
('Roberto Pop Cotzojay', '6742662991234', '49813089', 'Calzada Atanasio Tzul 5-85 zona 13, Villa Nueva', 'roberto7@yahoo.com', 40, 0, NULL),
('Alfredo Xocop Toc', '9232648704947', '58775431', 'Boulevard Liberacion 2-10 zona 5, Huehuetenango', 'alfredo308@yahoo.com', 7, 0, NULL),
('Wilfredo Coy Tzul', '3014719597964', '58986637', 'Calzada San Juan 24-75 zona 19, Guatemala', 'wilfredo866@outlook.com', 10, 0, NULL),
('Yesenia Coy Sanchez', '5204565044818', '34074382', 'Calzada San Juan 39-31 zona 18, Retalhuleu', 'yesenia894@outlook.com', 43, 0, NULL),
('Silvia Salazar Guzman', '5202845765213', '39445363', 'Boulevard Liberacion 13-81 zona 20, San Marcos', 'silvia867@gmail.com', 26, 0, NULL),
('Marvin Lopez Solares', '5452798524013', '33388393', 'Boulevard Liberacion 20-26 zona 7, Quetzaltenango', 'marvin81@yahoo.com', 44, 0, NULL),
('Anibal Mazariegos Tzoc', '0310890714014', '51172342', 'Calzada San Juan 8-87 zona 7, Jutiapa', 'anibal923@hotmail.com', 11, 0, NULL),
('Hector Chen Boror', '9552893891190', '54640623', '1a Calle 19-31 zona 18, Guatemala', 'hector997@gmail.com', 114, 1, NULL),
('Reyna Chacon Cotzojay', '1256638361517', '39719581', 'Avenida Las Americas 32-56 zona 10, Chiquimula', 'reyna740@gmail.com', 91, 1, NULL),
('Werner Sical Xocop', '9473864631752', '39248490', 'Calzada San Juan 26-66 zona 17, Villa Nueva', 'werner123@hotmail.com', 101, 1, NULL),
('Fernando Perez Marroquin', '3539613674994', '57714837', 'Avenida Bolivar 31-95 zona 20, Jalapa', 'fernando497@outlook.com', 9, 0, NULL),
('Danilo Aguilar Aguilar', '3201017026952', '42616210', '6a Avenida 43-76 zona 16, Solola', 'danilo207@outlook.com', 113, 1, NULL),
('Amparo Castillo Salazar', '8006167567700', '36084244', 'Calzada Aguilar Batres 32-65 zona 5, Mazatenango', 'amparo733@yahoo.com', 64, 1, NULL),
('Concepcion Us Salazar', '9778280647969', '56918393', 'Ruta 6 21-17 zona 1, Jutiapa', 'concepcion47@hotmail.com', 94, 1, NULL),
('Gerson Gudiel Hernandez', '6556503334911', '42920509', 'Calzada Atanasio Tzul 11-12 zona 18, Retalhuleu', 'gerson39@yahoo.com', 104, 1, NULL),
('Yolanda Lopez Coy', '7905696591713', '49333769', 'Boulevard Los Proceres 43-53 zona 6, Peten (Flores)', 'yolanda307@outlook.com', 75, 1, NULL),
('Cesar Barrios Sical', '4049639191954', '39909769', 'Ruta 3 28-36 zona 12, Villa Nueva', 'cesar668@outlook.com', 32, 0, NULL),
('Miriam Quiche Chocooj', '4987820829737', '49937547', '3a Calle 28-82 zona 21, Mixco', 'miriam535@hotmail.com', 23, 0, NULL),
('Hector Chen Us', '4665136442493', '45001087', 'Calzada San Juan 10-34 zona 1, Chimaltenango', 'hector817@outlook.com', 112, 1, NULL),
('Elvia Tzul Gonzalez', '3242044820700', '36266448', '3a Calle 20-18 zona 14, Puerto Barrios', 'elvia688@gmail.com', 25, 0, NULL),
('Jorge Chen Bautista', '1898471391559', '57542286', 'Boulevard Liberacion 28-37 zona 5, Antigua Guatemala', 'jorge180@hotmail.com', 17, 0, NULL),
('Reyna Rodriguez Aguilar', '8515867342575', '41353566', '3a Calle 3-94 zona 2, Chimaltenango', 'reyna260@yahoo.com', 19, 0, NULL),
('Mynor Gudiel Garcia', '6441343275604', '39249220', 'Ruta 3 27-52 zona 14, Antigua Guatemala', 'mynor845@hotmail.com', 83, 1, NULL),
('Elmer Quiche Recinos', '8570027206345', '52379624', 'Calzada San Juan 11-41 zona 17, Quetzaltenango', 'elmer868@yahoo.com', 107, 1, NULL),
('Danilo Chacon Us', '9543165266930', '34837070', '6a Avenida 30-35 zona 9, Escuintla', 'danilo51@yahoo.com', 104, 1, NULL),
('Alba Ramirez Marroquin', '2910867713334', '49290765', 'Diagonal 6 9-65 zona 7, Peten (Flores)', 'alba221@outlook.com', 46, 0, NULL),
('Rony Mendez Lopez', '4439735971072', '47669861', '1a Calle 25-64 zona 20, Huehuetenango', 'rony75@gmail.com', 35, 0, NULL),
('Vilma Solares Ortiz', '9900489646528', '34009366', 'Avenida Petapa 11-74 zona 16, Retalhuleu', 'vilma899@yahoo.com', 8, 0, NULL),
('Alba Paz Morales', '5027456449485', '43767969', 'Calzada Atanasio Tzul 32-29 zona 18, Solola', 'alba55@hotmail.com', 9, 0, NULL),
('Luis Solares Paz', '2761707587771', '53483929', 'Calzada San Juan 23-21 zona 7, Mazatenango', 'luis185@hotmail.com', 47, 0, NULL),
('Pablo Garcia Ixcoy', '9261371504165', '52779557', 'Calzada Atanasio Tzul 10-13 zona 3, Solola', 'pablo851@yahoo.com', 84, 1, NULL),
('Gerson Gonzalez Tzul', '9759230450189', '42552748', 'Diagonal 6 17-32 zona 8, Jalapa', 'gerson92@gmail.com', 13, 0, NULL),
('Sucely Tzul Mazariegos', '2147649251583', '48473283', 'Diagonal 6 31-44 zona 19, Peten (Flores)', 'sucely434@gmail.com', 48, 0, NULL),
('Erick Say Tzoc', '1085732788147', '42328472', 'Ruta 3 20-29 zona 5, Mazatenango', 'erick862@hotmail.com', 33, 0, NULL),
('Alfredo Perez Gonzalez', '8186617945491', '51272943', 'Calzada San Juan 43-69 zona 6, Escuintla', 'alfredo864@yahoo.com', 2, 0, NULL),
('Heidy Guzman Pop', '7794523219416', '51300567', 'Avenida Reforma 26-24 zona 1, Escuintla', 'heidy672@yahoo.com', 101, 1, NULL),
('Evelyn Alvarado Alvarado', '5641220310303', '43435283', 'Boulevard Liberacion 28-90 zona 18, Coban', 'evelyn89@outlook.com', 49, 0, NULL),
('Elvia Lopez Morales', '2277707933496', '36601074', 'Avenida Reforma 7-90 zona 14, Zacapa', 'elvia869@yahoo.com', 47, 0, NULL),
('Wilfredo Chocooj Aguilar', '8997308069581', '47998405', 'Ruta 3 8-73 zona 20, Puerto Barrios', 'wilfredo460@yahoo.com', 1, 0, NULL),
('Anibal Ortiz Cotzojay', '3839597246657', '34476383', 'Ruta 6 45-21 zona 16, Quetzaltenango', 'anibal178@hotmail.com', 10, 0, NULL),
('Lourdes Chavez Estrada', '3800545228015', '42912087', '3a Calle 15-25 zona 18, Chimaltenango', 'lourdes499@outlook.com', 21, 0, NULL),
('Alba Coy Bautista', '9107711991808', '33802571', 'Calzada San Juan 14-56 zona 6, Mazatenango', 'alba726@yahoo.com', 114, 1, NULL),
('Hector Tzul Marroquin', '5213760375482', '35463001', 'Avenida Bolivar 27-56 zona 21, Chimaltenango', 'hector156@yahoo.com', 14, 0, NULL),
('Delia Xocop Ixcoy', '5072081155626', '37597913', 'Calzada Roosevelt 43-92 zona 5, Jutiapa', 'delia60@outlook.com', 101, 1, NULL),
('Heidy Ortiz Garcia', '4892673899756', '36058857', '6a Avenida 3-78 zona 11, Jalapa', 'heidy743@hotmail.com', 33, 0, NULL),
('Oscar Bautista Rosales', '4852008943468', '32005722', 'Avenida Bolivar 17-90 zona 17, Puerto Barrios', 'oscar127@gmail.com', 65, 1, NULL),
('Petronila Chen Garcia', '7539989354492', '57336179', 'Boulevard Los Proceres 16-23 zona 11, San Marcos', 'petronila597@hotmail.com', 96, 1, NULL),
('Hector Toc Tzoc', '6110627371586', '59706452', 'Diagonal 6 17-84 zona 16, Zacapa', 'hector451@yahoo.com', 46, 0, NULL),
('Nery Sanchez Aguilar', '7288137702851', '57855503', 'Calzada San Juan 8-57 zona 19, Mazatenango', 'nery42@hotmail.com', 7, 0, NULL),
('Evelyn Sical Aguilar', '0229604432701', '56849358', '6a Avenida 3-63 zona 16, Jutiapa', 'evelyn318@yahoo.com', 98, 1, NULL),
('Marvin Bautista Say', '7772519966365', '51768727', '5a Avenida 18-92 zona 3, Escuintla', 'marvin725@gmail.com', 89, 1, NULL),
('Alfredo Ramirez Cifuentes', '9890983780182', '35613105', '1a Calle 16-84 zona 15, Villa Nueva', 'alfredo827@outlook.com', 55, 1, NULL),
('Gerson Tzoc Chacon', '6085641118242', '35287493', '6a Avenida 10-49 zona 14, Escuintla', 'gerson61@outlook.com', 11, 0, NULL),
('Dominga Hernandez Reyes', '2654610339937', '59462784', 'Diagonal 6 8-44 zona 2, Retalhuleu', 'dominga476@yahoo.com', 4, 0, NULL),
('Gloria Lopez Boror', '8913824967183', '37263022', 'Calzada Independencia 11-41 zona 18, Zacapa', 'gloria985@yahoo.com', 50, 1, NULL),
('Brenda Garcia Rodriguez', '7494653984028', '52173318', 'Ruta 6 6-60 zona 4, Quetzaltenango', 'brenda743@outlook.com', 76, 1, NULL),
('Floridalma Say Paz', '7435537950209', '41071793', 'Avenida Reforma 44-32 zona 14, Chiquimula', 'floridalma917@yahoo.com', 100, 1, NULL),
('Miguel Salazar Lopez', '7156956201753', '41157090', 'Boulevard Liberacion 2-45 zona 12, Coban', 'miguel93@outlook.com', 45, 0, NULL),
('Aracely Gonzalez Boror', '7930361498728', '33944885', '6a Avenida 38-26 zona 3, Quetzaltenango', 'aracely266@hotmail.com', 33, 0, NULL),
('Cesar Alvarado Paz', '8706056641877', '49678130', 'Calzada Roosevelt 15-16 zona 9, Zacapa', 'cesar546@yahoo.com', 20, 0, NULL),
('Gerson Ramirez Villatoro', '0361332541107', '41403047', 'Avenida Elena 41-52 zona 9, Chimaltenango', 'gerson111@yahoo.com', 15, 0, NULL),
('Marta Estrada Perez', '9971791100651', '32040224', '5a Avenida 4-48 zona 20, Zacapa', 'marta68@gmail.com', 57, 1, NULL),
('Rudy Gudiel Chocooj', '1963990767699', '36697818', 'Avenida Reforma 30-76 zona 11, Jutiapa', 'rudy198@gmail.com', 51, 1, NULL),
('Pablo Cifuentes Villatoro', '2845679723200', '36228902', 'Avenida Elena 28-75 zona 21, Puerto Barrios', 'pablo319@hotmail.com', 9, 0, NULL),
('Sucely Marroquin Garcia', '8920388065333', '36730290', '1a Calle 43-70 zona 15, Peten (Flores)', 'sucely710@outlook.com', 92, 1, NULL);

select * from cliente;

-- 7. membresia ----------------------------------------------------------
INSERT INTO membresia (id_cliente, id_tipo_membresia, fecha_inicio, fecha_fin, videos_acumulados) VALUES
(1, 3, '2024-06-06', '2025-06-06', 6),
(2, 1, '2024-04-01', NULL, 32),
(3, 2, '2024-10-07', NULL, 93),
(4, 3, '2024-04-13', '2025-04-13', 41),
(5, 1, '2023-01-03', NULL, 8),
(6, 1, '2022-05-15', '2023-05-15', 26),
(7, 3, '2021-01-07', '2022-01-07', 50),
(8, 2, '2022-05-24', '2023-05-24', 15),
(9, 2, '2022-04-01', '2023-04-01', 36),
(10, 3, '2021-01-27', NULL, 33),
(11, 4, '2021-06-07', NULL, 99),
(12, 2, '2023-06-22', '2024-06-22', 80),
(13, 4, '2021-02-05', NULL, 77),
(14, 2, '2022-04-18', NULL, 21),
(15, 3, '2023-10-14', NULL, 49),
(16, 2, '2021-10-19', '2022-10-19', 21),
(17, 3, '2022-06-08', '2023-06-08', 53),
(18, 3, '2022-09-19', NULL, 68),
(19, 2, '2021-08-26', NULL, 47),
(20, 1, '2022-09-13', NULL, 49),
(21, 3, '2024-09-15', '2025-09-15', 39),
(22, 3, '2025-12-16', NULL, 42),
(23, 4, '2024-05-19', NULL, 47),
(24, 1, '2022-04-07', NULL, 40),
(25, 2, '2024-04-10', NULL, 110),
(26, 4, '2025-03-27', NULL, 28),
(27, 1, '2022-02-10', NULL, 40),
(28, 3, '2022-10-02', NULL, 23),
(29, 3, '2024-08-15', NULL, 32),
(30, 3, '2024-06-09', NULL, 33),
(31, 2, '2024-04-09', NULL, 19),
(32, 3, '2021-05-27', NULL, 28),
(33, 1, '2023-04-04', '2024-04-04', 87),
(34, 3, '2021-09-07', NULL, 37),
(35, 3, '2023-05-24', NULL, 89),
(36, 3, '2022-12-20', NULL, 40),
(37, 3, '2021-05-10', NULL, 7),
(38, 4, '2024-10-25', NULL, 10),
(39, 4, '2025-03-28', NULL, 43),
(40, 2, '2022-08-08', NULL, 26),
(41, 4, '2024-06-26', '2025-06-26', 44),
(42, 2, '2024-12-14', NULL, 11),
(43, 4, '2025-01-12', '2026-01-12', 114),
(44, 2, '2023-12-01', NULL, 91),
(45, 3, '2023-04-14', NULL, 101),
(46, 4, '2025-05-11', NULL, 9),
(47, 1, '2022-03-11', NULL, 113),
(48, 4, '2024-04-13', '2025-04-13', 64),
(49, 4, '2022-08-04', NULL, 94),
(50, 4, '2023-02-06', '2024-02-06', 104),
(51, 2, '2021-12-20', NULL, 75),
(52, 2, '2022-02-13', NULL, 32),
(53, 2, '2023-11-17', '2024-11-17', 23),
(54, 1, '2023-09-01', '2024-09-01', 112),
(55, 4, '2024-03-04', '2025-03-04', 25),
(56, 4, '2024-12-03', NULL, 17),
(57, 2, '2022-04-10', NULL, 19),
(58, 4, '2022-10-19', NULL, 83),
(59, 2, '2025-12-22', NULL, 107),
(60, 2, '2021-03-15', '2022-03-15', 104),
(61, 4, '2025-04-17', NULL, 46),
(62, 4, '2024-08-19', '2025-08-19', 35),
(63, 1, '2023-11-15', NULL, 8),
(64, 3, '2024-10-27', NULL, 9),
(65, 2, '2024-04-06', NULL, 47),
(66, 4, '2024-07-22', '2025-07-22', 84),
(67, 1, '2024-12-02', NULL, 13),
(68, 2, '2023-11-18', NULL, 48),
(69, 1, '2022-08-14', NULL, 33),
(70, 1, '2023-02-25', '2024-02-25', 2),
(71, 3, '2024-08-06', NULL, 101),
(72, 1, '2024-01-03', NULL, 49),
(73, 4, '2024-06-24', NULL, 47),
(74, 2, '2024-01-01', NULL, 1),
(75, 2, '2023-11-24', NULL, 10),
(76, 4, '2021-02-18', NULL, 21),
(77, 4, '2022-08-27', NULL, 114),
(78, 2, '2022-01-20', '2023-01-20', 14),
(79, 3, '2021-09-24', NULL, 101),
(80, 1, '2021-11-09', '2022-11-09', 33),
(81, 3, '2022-04-23', '2023-04-23', 65),
(82, 2, '2024-12-02', NULL, 96),
(83, 1, '2024-12-10', NULL, 46),
(84, 1, '2021-07-25', NULL, 7),
(85, 2, '2023-04-07', '2024-04-07', 98),
(86, 4, '2021-01-11', NULL, 89),
(87, 1, '2022-02-26', NULL, 55),
(88, 2, '2022-01-14', NULL, 11),
(89, 3, '2023-09-21', '2024-09-21', 4),
(90, 2, '2025-07-14', '2026-07-14', 50),
(91, 2, '2021-06-11', '2022-06-11', 76),
(92, 4, '2023-01-13', NULL, 100),
(93, 2, '2021-11-27', NULL, 45),
(94, 3, '2021-02-07', NULL, 33),
(95, 4, '2021-12-18', NULL, 20),
(96, 2, '2023-02-20', NULL, 15),
(97, 4, '2022-06-06', NULL, 57),
(98, 3, '2024-02-11', '2025-02-11', 51),
(99, 4, '2024-09-21', NULL, 9),
(100, 1, '2022-01-20', NULL, 92);

select * from membresia;

-- Vincular cada cliente con su membresia (FK circular resuelta con UPDATE)
UPDATE cliente c JOIN membresia m ON m.id_cliente = c.id_cliente SET c.id_membresia = m.id_membresia;

-- 8. proveedor ----------------------------------------------------------
INSERT INTO proveedor (nombre, telefono, id_direccion) VALUES
('Importadora Express S.A.', '28189001', 1),
('Video Quetzal S.A.', '22005341', 2),
('Comercial Latina S.A.', '65976369', 3),
('Video del Norte S.A.', '64429016', 4),
('Distribuidora Nacional S.A.', '78444490', 5),
('Multimedia del Norte S.A.', '66327414', 6),
('Distribuidora Peten S.A.', '65839473', 7),
('Distribuidora Nacional S.A.', '76557792', 8),
('Multimedia Nacional S.A.', '21907210', 9),
('Video Nacional S.A.', '77400271', 10),
('Almacenes Latina S.A.', '28421584', 11),
('Distribuidora Central S.A.', '62174152', 12),
('Video Guatemala S.A.', '73374513', 13),
('Video del Norte S.A.', '23913796', 14),
('Grupo Peten S.A.', '24964626', 15),
('Almacenes Central S.A.', '68836205', 16),
('Cine del Norte S.A.', '74314108', 17),
('Video VHS S.A.', '25177013', 18),
('Cine Express S.A.', '78520742', 19),
('Video Express S.A.', '62342445', 20),
('Multimedia VHS S.A.', '63814647', 21),
('Suministros Digital S.A.', '69477402', 22),
('Grupo VHS S.A.', '29086630', 23),
('Distribuidora VHS S.A.', '62396415', 24),
('Cine Quetzal S.A.', '73563536', 25),
('Almacenes del Norte S.A.', '67382895', 26),
('Suministros Express S.A.', '65751739', 27),
('Entretenimiento Peten S.A.', '79067229', 28),
('Importadora Latina S.A.', '28872850', 29),
('Video del Norte S.A.', '21070138', 30),
('Distribuidora Peten S.A.', '77279004', 31),
('Suministros VHS S.A.', '67621123', 32),
('Multimedia VHS S.A.', '66164208', 33),
('Grupo Central S.A.', '61651407', 34),
('Importadora VHS S.A.', '73723988', 35),
('Video VHS S.A.', '66848179', 36),
('Almacenes Digital S.A.', '77177044', 37),
('Distribuidora VHS S.A.', '65140479', 38),
('Video Digital S.A.', '27063525', 39),
('Distribuidora del Norte S.A.', '68641531', 40),
('Comercial Express S.A.', '23708302', 41),
('Distribuidora Central S.A.', '27448284', 42),
('Entretenimiento Quetzal S.A.', '29699607', 43),
('Video VHS S.A.', '28161714', 44),
('Cine Express S.A.', '79945633', 45),
('Entretenimiento Quetzal S.A.', '67905652', 46),
('Importadora Central S.A.', '76777952', 47),
('Comercial Express S.A.', '74515255', 48),
('Entretenimiento Express S.A.', '23825261', 49),
('Suministros Guatemala S.A.', '22171745', 50),
('Entretenimiento Peten S.A.', '65837546', 51),
('Entretenimiento del Norte S.A.', '27285607', 52),
('Comercial del Norte S.A.', '29161633', 53),
('Comercial Peten S.A.', '28560833', 54),
('Grupo Nacional S.A.', '24371228', 55),
('Distribuidora del Norte S.A.', '25351203', 56),
('Entretenimiento Digital S.A.', '72831995', 57),
('Comercial Central S.A.', '62437925', 58),
('Entretenimiento Central S.A.', '62078144', 59),
('Multimedia Guatemala S.A.', '74938956', 60),
('Suministros Digital S.A.', '72691296', 61),
('Distribuidora Guatemala S.A.', '61121243', 62),
('Grupo Guatemala S.A.', '24541139', 63),
('Almacenes Guatemala S.A.', '69725395', 64),
('Cine Digital S.A.', '66654424', 65),
('Grupo VHS S.A.', '67220742', 66),
('Multimedia Latina S.A.', '27060108', 67),
('Entretenimiento VHS S.A.', '71960353', 68),
('Multimedia Latina S.A.', '21051752', 69),
('Suministros VHS S.A.', '73329735', 70),
('Distribuidora Quetzal S.A.', '29902483', 71),
('Cine Nacional S.A.', '68581927', 72),
('Grupo Digital S.A.', '77931114', 73),
('Video Guatemala S.A.', '76405343', 74),
('Distribuidora Latina S.A.', '26461406', 75),
('Suministros Nacional S.A.', '79129167', 76),
('Entretenimiento Quetzal S.A.', '26844074', 77),
('Entretenimiento Digital S.A.', '72685367', 78),
('Entretenimiento Express S.A.', '74272848', 79),
('Comercial Peten S.A.', '79466397', 80),
('Distribuidora del Norte S.A.', '62461125', 81),
('Cine Peten S.A.', '63819458', 82),
('Suministros Central S.A.', '65041658', 83),
('Video Nacional S.A.', '22500416', 84),
('Importadora VHS S.A.', '71490260', 85),
('Comercial Latina S.A.', '65703624', 86),
('Video Express S.A.', '78991026', 87),
('Importadora del Norte S.A.', '79253698', 88),
('Importadora Latina S.A.', '22084932', 89),
('Multimedia VHS S.A.', '77403032', 90),
('Almacenes VHS S.A.', '24750560', 91),
('Cine Central S.A.', '62471032', 92),
('Importadora Central S.A.', '64156740', 93),
('Importadora Quetzal S.A.', '63137710', 94),
('Multimedia VHS S.A.', '71028160', 95),
('Cine Guatemala S.A.', '79985927', 96),
('Video VHS S.A.', '66362719', 97),
('Multimedia del Norte S.A.', '74726916', 98),
('Importadora VHS S.A.', '28727632', 99),
('Multimedia del Norte S.A.', '64672603', 100);

select * from proveedor;
-- 9. compra ---------------------------------------------------------------
-- (el total se actualizara al final segun el detalle_compra)
INSERT INTO compra (fecha, total, id_proveedor, id_empleado) VALUES
('2025-11-15', 1.00, 19, 77),
('2024-03-24', 1.00, 86, 90),
('2022-10-11', 1.00, 40, 65),
('2022-05-28', 1.00, 91, 74),
('2025-11-27', 1.00, 28, 64),
('2024-12-13', 1.00, 8, 43),
('2023-12-07', 1.00, 94, 29),
('2022-03-28', 1.00, 63, 94),
('2025-05-27', 1.00, 85, 21),
('2022-09-13', 1.00, 44, 55),
('2025-06-25', 1.00, 51, 51),
('2022-09-24', 1.00, 37, 37),
('2023-12-28', 1.00, 71, 51),
('2022-03-11', 1.00, 97, 75),
('2022-12-10', 1.00, 59, 84),
('2023-10-05', 1.00, 57, 90),
('2025-05-05', 1.00, 27, 28),
('2023-12-21', 1.00, 2, 47),
('2026-02-22', 1.00, 19, 49),
('2025-11-27', 1.00, 22, 8),
('2022-06-16', 1.00, 23, 7),
('2022-09-21', 1.00, 44, 76),
('2025-03-21', 1.00, 93, 52),
('2023-01-04', 1.00, 31, 51),
('2025-05-23', 1.00, 77, 23),
('2025-12-26', 1.00, 86, 85),
('2022-08-28', 1.00, 84, 49),
('2024-11-21', 1.00, 57, 48),
('2022-02-04', 1.00, 11, 16),
('2025-11-22', 1.00, 66, 29),
('2022-10-19', 1.00, 74, 62),
('2024-12-24', 1.00, 13, 76),
('2023-07-16', 1.00, 83, 90),
('2025-05-19', 1.00, 17, 13),
('2024-02-23', 1.00, 69, 24),
('2025-12-01', 1.00, 51, 72),
('2026-09-16', 1.00, 9, 67),
('2026-09-23', 1.00, 84, 16),
('2023-11-04', 1.00, 24, 77),
('2023-01-18', 1.00, 58, 41),
('2022-01-05', 1.00, 74, 27),
('2023-02-18', 1.00, 33, 97),
('2022-02-04', 1.00, 65, 39),
('2024-09-06', 1.00, 55, 85),
('2022-04-10', 1.00, 6, 67),
('2024-11-18', 1.00, 57, 18),
('2026-08-23', 1.00, 41, 67),
('2024-10-18', 1.00, 66, 27),
('2022-11-27', 1.00, 6, 31),
('2022-04-05', 1.00, 39, 28),
('2023-10-18', 1.00, 28, 76),
('2024-05-05', 1.00, 94, 80),
('2025-02-18', 1.00, 33, 34),
('2025-11-06', 1.00, 52, 59),
('2022-05-22', 1.00, 55, 89),
('2023-09-07', 1.00, 10, 81),
('2024-11-23', 1.00, 83, 25),
('2024-10-22', 1.00, 83, 66),
('2026-03-14', 1.00, 20, 41),
('2025-07-01', 1.00, 78, 32),
('2022-05-04', 1.00, 69, 15),
('2026-07-03', 1.00, 43, 82),
('2022-06-11', 1.00, 100, 35),
('2023-04-09', 1.00, 2, 13),
('2025-04-13', 1.00, 14, 16),
('2023-09-24', 1.00, 40, 76),
('2025-02-17', 1.00, 45, 90),
('2026-05-18', 1.00, 35, 78),
('2022-01-06', 1.00, 41, 97),
('2025-03-12', 1.00, 95, 87),
('2026-09-20', 1.00, 52, 62),
('2026-03-09', 1.00, 2, 88),
('2026-12-05', 1.00, 85, 17),
('2023-07-19', 1.00, 95, 35),
('2022-12-21', 1.00, 48, 91),
('2023-11-20', 1.00, 54, 91),
('2025-03-15', 1.00, 46, 60),
('2026-05-09', 1.00, 55, 67),
('2023-05-21', 1.00, 12, 40),
('2025-06-28', 1.00, 12, 82),
('2022-02-24', 1.00, 31, 12),
('2023-10-02', 1.00, 11, 96),
('2024-09-16', 1.00, 2, 55),
('2026-12-05', 1.00, 62, 64),
('2026-11-22', 1.00, 69, 90),
('2022-07-01', 1.00, 79, 25),
('2022-12-14', 1.00, 90, 69),
('2024-04-24', 1.00, 85, 68),
('2026-01-20', 1.00, 58, 22),
('2026-04-06', 1.00, 10, 47),
('2023-09-12', 1.00, 7, 55),
('2025-07-06', 1.00, 48, 15),
('2024-11-08', 1.00, 70, 99),
('2022-05-10', 1.00, 62, 38),
('2024-04-01', 1.00, 95, 81),
('2026-07-07', 1.00, 40, 83),
('2026-01-15', 1.00, 80, 63),
('2022-06-01', 1.00, 79, 59),
('2024-05-12', 1.00, 14, 1),
('2024-12-06', 1.00, 52, 46);

select * from compra;

-- 10. detalle_compra --------------------------------------------------------
INSERT INTO detalle_compra (id_compra, id_video, cantidad, precio_unitario, subtotal) VALUES
(1, 2, 2, 25.00, 50.00),
(2, 56, 8, 22.00, 176.00),
(3, 26, 2, 16.00, 32.00),
(4, 68, 9, 25.00, 225.00),
(5, 20, 7, 22.00, 154.00),
(6, 16, 8, 20.00, 160.00),
(7, 1, 3, 29.00, 87.00),
(8, 99, 5, 18.00, 90.00),
(9, 29, 8, 14.00, 112.00),
(10, 51, 6, 18.00, 108.00),
(11, 39, 6, 20.00, 120.00),
(12, 55, 3, 17.00, 51.00),
(13, 69, 5, 20.00, 100.00),
(14, 14, 8, 20.00, 160.00),
(15, 85, 8, 18.00, 144.00),
(16, 21, 3, 20.00, 60.00),
(17, 46, 7, 18.00, 126.00),
(18, 1, 6, 29.00, 174.00),
(19, 91, 4, 17.00, 68.00),
(20, 15, 4, 18.00, 72.00),
(21, 37, 1, 18.00, 18.00),
(22, 18, 7, 18.00, 126.00),
(23, 54, 6, 20.00, 120.00),
(24, 5, 3, 18.00, 54.00),
(25, 86, 4, 18.00, 72.00),
(26, 62, 5, 20.00, 100.00),
(27, 16, 7, 20.00, 140.00),
(28, 63, 9, 20.00, 180.00),
(29, 64, 3, 20.00, 60.00),
(30, 42, 7, 22.00, 154.00),
(31, 65, 7, 18.00, 126.00),
(32, 17, 2, 17.00, 34.00),
(33, 14, 1, 20.00, 20.00),
(34, 17, 3, 17.00, 51.00),
(35, 45, 9, 20.00, 180.00),
(36, 2, 4, 25.00, 100.00),
(37, 7, 6, 15.00, 90.00),
(38, 55, 10, 17.00, 170.00),
(39, 95, 1, 18.00, 18.00),
(40, 56, 8, 22.00, 176.00),
(41, 38, 5, 18.00, 90.00),
(42, 63, 2, 20.00, 40.00),
(43, 98, 7, 18.00, 126.00),
(44, 32, 10, 16.00, 160.00),
(45, 20, 9, 22.00, 198.00),
(46, 24, 4, 16.00, 64.00),
(47, 36, 2, 18.00, 36.00),
(48, 34, 4, 20.00, 80.00),
(49, 86, 7, 18.00, 126.00),
(50, 26, 8, 16.00, 128.00),
(51, 91, 2, 17.00, 34.00),
(52, 90, 9, 18.00, 162.00),
(53, 79, 3, 20.00, 60.00),
(54, 25, 10, 16.00, 160.00),
(55, 81, 3, 18.00, 54.00),
(56, 30, 2, 18.00, 36.00),
(57, 17, 7, 17.00, 119.00),
(58, 5, 5, 18.00, 90.00),
(59, 25, 3, 16.00, 48.00),
(60, 55, 1, 17.00, 17.00),
(61, 79, 4, 20.00, 80.00),
(62, 12, 1, 25.00, 25.00),
(63, 49, 7, 18.00, 126.00),
(64, 68, 5, 25.00, 125.00),
(65, 90, 4, 18.00, 72.00),
(66, 29, 6, 14.00, 84.00),
(67, 55, 8, 17.00, 136.00),
(68, 8, 9, 20.00, 180.00),
(69, 55, 1, 17.00, 17.00),
(70, 39, 2, 20.00, 40.00),
(71, 35, 6, 20.00, 120.00),
(72, 36, 6, 18.00, 108.00),
(73, 92, 7, 16.00, 112.00),
(74, 32, 6, 16.00, 96.00),
(75, 7, 3, 15.00, 45.00),
(76, 6, 1, 22.00, 22.00),
(77, 7, 6, 15.00, 90.00),
(78, 28, 5, 17.00, 85.00),
(79, 61, 5, 22.00, 110.00),
(80, 78, 2, 16.00, 32.00),
(81, 56, 3, 22.00, 66.00),
(82, 33, 8, 14.00, 112.00),
(83, 47, 6, 20.00, 120.00),
(84, 39, 2, 20.00, 40.00),
(85, 13, 1, 25.00, 25.00),
(86, 88, 9, 16.00, 144.00),
(87, 99, 3, 18.00, 54.00),
(88, 43, 6, 22.00, 132.00),
(89, 95, 6, 18.00, 108.00),
(90, 96, 10, 18.00, 180.00),
(91, 68, 10, 25.00, 250.00),
(92, 48, 4, 20.00, 80.00),
(93, 84, 5, 17.00, 85.00),
(94, 27, 10, 15.00, 150.00),
(95, 50, 2, 18.00, 36.00),
(96, 14, 3, 20.00, 60.00),
(97, 81, 10, 18.00, 180.00),
(98, 16, 1, 20.00, 20.00),
(99, 76, 4, 18.00, 72.00),
(100, 25, 8, 16.00, 128.00);

-- Recalcular el total real de cada compra segun su detalle
UPDATE compra c JOIN (SELECT id_compra, SUM(subtotal) AS total FROM detalle_compra GROUP BY id_compra) d
  ON d.id_compra = c.id_compra SET c.total = d.total;

-- 11. renta -----------------------------------------------------------------
INSERT INTO renta (fecha_renta, fecha_limite, estado, id_cliente, id_empleado) VALUES
('2024-02-18', '2024-02-23', 'completada', 93, 61),
('2024-09-24', '2024-09-27', 'completada', 17, 25),
('2025-09-23', '2025-09-28', 'activa', 45, 47),
('2025-11-23', '2025-11-25', 'completada', 9, 62),
('2025-09-17', '2025-09-19', 'completada', 77, 36),
('2026-03-10', '2026-03-12', 'cancelada', 8, 89),
('2024-12-13', '2024-12-20', 'activa', 66, 10),
('2024-08-25', '2024-09-04', 'activa', 100, 50),
('2025-10-09', '2025-10-12', 'completada', 1, 21),
('2026-04-19', '2026-04-21', 'activa', 59, 65),
('2026-12-17', '2026-12-22', 'completada', 29, 38),
('2026-05-18', '2026-05-20', 'completada', 29, 6),
('2026-04-10', '2026-04-12', 'completada', 36, 18),
('2025-01-21', '2025-01-24', 'completada', 69, 15),
('2024-11-12', '2024-11-17', 'completada', 11, 91),
('2026-05-24', '2026-05-27', 'completada', 79, 38),
('2025-01-21', '2025-01-23', 'completada', 29, 94),
('2025-03-09', '2025-03-11', 'activa', 85, 100),
('2026-02-24', '2026-03-03', 'completada', 81, 82),
('2026-09-07', '2026-09-14', 'completada', 42, 35),
('2024-10-21', '2024-10-28', 'completada', 58, 30),
('2026-12-14', '2026-12-19', 'completada', 62, 12),
('2025-03-15', '2025-03-18', 'completada', 25, 73),
('2025-12-06', '2025-12-11', 'completada', 40, 21),
('2024-07-22', '2024-07-25', 'completada', 19, 10),
('2025-04-15', '2025-04-22', 'completada', 93, 68),
('2024-12-25', '2024-12-27', 'cancelada', 13, 49),
('2025-01-04', '2025-01-06', 'completada', 17, 32),
('2024-05-05', '2024-05-07', 'completada', 14, 70),
('2026-06-23', '2026-06-25', 'completada', 18, 62),
('2026-08-06', '2026-08-11', 'completada', 62, 20),
('2024-01-18', '2024-01-23', 'activa', 16, 3),
('2024-02-18', '2024-02-23', 'completada', 66, 54),
('2024-01-08', '2024-01-10', 'completada', 55, 50),
('2024-06-21', '2024-06-26', 'completada', 88, 50),
('2026-12-04', '2026-12-11', 'completada', 15, 29),
('2024-05-12', '2024-05-14', 'cancelada', 43, 16),
('2025-02-02', '2025-02-05', 'completada', 55, 68),
('2025-10-06', '2025-10-13', 'completada', 86, 88),
('2025-10-10', '2025-10-15', 'completada', 35, 64),
('2026-06-09', '2026-06-11', 'completada', 20, 100),
('2026-03-11', '2026-03-14', 'completada', 58, 93),
('2025-02-04', '2025-02-11', 'completada', 19, 12),
('2025-03-06', '2025-03-13', 'completada', 41, 64),
('2025-08-23', '2025-09-02', 'cancelada', 82, 43),
('2024-11-08', '2024-11-15', 'completada', 71, 64),
('2026-09-16', '2026-09-19', 'completada', 11, 75),
('2026-07-17', '2026-07-20', 'completada', 31, 47),
('2024-04-01', '2024-04-06', 'activa', 61, 18),
('2024-01-12', '2024-01-17', 'completada', 38, 59),
('2024-09-14', '2024-09-17', 'completada', 29, 8),
('2026-03-04', '2026-03-07', 'completada', 94, 4),
('2026-07-12', '2026-07-14', 'completada', 85, 75),
('2024-08-20', '2024-08-23', 'completada', 19, 47),
('2024-02-08', '2024-02-10', 'completada', 73, 54),
('2024-03-16', '2024-03-19', 'activa', 90, 39),
('2025-07-24', '2025-08-01', 'activa', 83, 89),
('2024-05-04', '2024-05-07', 'completada', 83, 5),
('2026-03-17', '2026-03-20', 'completada', 51, 55),
('2026-08-18', '2026-08-23', 'cancelada', 65, 40),
('2026-04-14', '2026-04-17', 'completada', 12, 67),
('2025-03-24', '2025-03-27', 'completada', 80, 8),
('2024-07-06', '2024-07-08', 'activa', 62, 41),
('2026-11-13', '2026-11-20', 'completada', 7, 48),
('2026-07-07', '2026-07-12', 'completada', 14, 10),
('2025-10-25', '2025-11-02', 'completada', 31, 37),
('2024-09-04', '2024-09-06', 'completada', 77, 2),
('2025-04-18', '2025-04-21', 'completada', 31, 35),
('2024-10-19', '2024-10-21', 'cancelada', 62, 6),
('2024-06-03', '2024-06-08', 'completada', 46, 97),
('2025-07-17', '2025-07-20', 'completada', 97, 51),
('2026-06-05', '2026-06-07', 'completada', 53, 95),
('2026-02-17', '2026-02-20', 'completada', 76, 49),
('2025-10-02', '2025-10-07', 'completada', 20, 88),
('2025-02-21', '2025-02-23', 'completada', 28, 88),
('2026-03-25', '2026-03-28', 'activa', 67, 94),
('2026-11-17', '2026-11-22', 'activa', 17, 44),
('2025-06-20', '2025-06-27', 'completada', 92, 100),
('2026-07-08', '2026-07-11', 'cancelada', 78, 10),
('2024-10-21', '2024-10-28', 'completada', 2, 19),
('2025-09-26', '2025-09-28', 'activa', 13, 59),
('2025-03-10', '2025-03-13', 'completada', 36, 74),
('2025-06-03', '2025-06-05', 'completada', 91, 99),
('2025-05-16', '2025-05-21', 'activa', 84, 18),
('2024-10-16', '2024-10-18', 'completada', 37, 52),
('2025-10-22', '2025-10-25', 'activa', 47, 66),
('2026-06-12', '2026-06-14', 'completada', 65, 58),
('2025-11-02', '2025-11-04', 'completada', 90, 72),
('2024-03-04', '2024-03-09', 'completada', 21, 73),
('2025-02-08', '2025-02-15', 'activa', 86, 12),
('2025-08-15', '2025-08-22', 'completada', 11, 24),
('2026-02-13', '2026-02-20', 'completada', 52, 43),
('2024-06-11', '2024-06-18', 'completada', 90, 95),
('2025-02-09', '2025-02-16', 'completada', 70, 20),
('2025-03-21', '2025-03-24', 'completada', 73, 5),
('2026-07-02', '2026-07-07', 'completada', 61, 28),
('2024-04-01', '2024-04-08', 'completada', 33, 82),
('2024-02-05', '2024-02-07', 'completada', 52, 11),
('2025-12-15', '2025-12-22', 'activa', 28, 86),
('2025-03-02', '2025-03-04', 'completada', 44, 97);

delete all from detalle_renta;
select * from detalle_renta;
-- 12. detalle_renta -----------------------------------------------------------
INSERT INTO detalle_renta (id_renta, id_video, cantidad, precio_unitario, subtotal) VALUES
(1, 39, 1, 20.00, 20.00),
(2, 26, 2, 16.00, 32.00),
(3, 54, 2, 20.00, 40.00),
(4, 61, 3, 22.00, 66.00),
(5, 89, 1, 16.00, 16.00),
(6, 90, 2, 18.00, 36.00),
(7, 46, 3, 18.00, 54.00),
(8, 74, 2, 18.00, 36.00),
(9, 2, 3, 25.00, 75.00),
(10, 77, 1, 22.00, 22.00),
(11, 10, 3, 18.00, 54.00),
(12, 86, 3, 18.00, 54.00),
(13, 79, 1, 20.00, 20.00),
(14, 42, 3, 22.00, 66.00),
(15, 94, 3, 18.00, 54.00),
(16, 95, 3, 18.00, 54.00),
(17, 41, 1, 17.00, 17.00),
(18, 20, 2, 22.00, 44.00),
(19, 19, 2, 22.00, 44.00),
(20, 41, 1, 17.00, 17.00),
(21, 87, 2, 14.00, 28.00),
(22, 34, 3, 20.00, 60.00),
(23, 93, 1, 16.00, 16.00),
(24, 58, 1, 22.00, 22.00),
(25, 82, 2, 17.00, 34.00),
(26, 82, 3, 17.00, 51.00),
(27, 13, 1, 25.00, 25.00),
(28, 28, 3, 17.00, 51.00),
(29, 25, 2, 16.00, 32.00),
(30, 90, 3, 18.00, 54.00),
(31, 100, 1, 22.00, 22.00),
(32, 77, 2, 22.00, 44.00),
(33, 28, 2, 17.00, 34.00),
(34, 27, 1, 15.00, 15.00),
(35, 87, 3, 14.00, 42.00),
(36, 2, 2, 25.00, 50.00),
(37, 47, 1, 20.00, 20.00),
(38, 39, 2, 20.00, 40.00),
(39, 65, 1, 18.00, 18.00),
(40, 90, 2, 18.00, 36.00),
(41, 84, 2, 17.00, 34.00),
(42, 53, 2, 18.00, 36.00),
(43, 46, 2, 18.00, 36.00),
(44, 70, 2, 16.00, 32.00),
(45, 67, 2, 22.00, 44.00),
(46, 15, 1, 18.00, 18.00),
(47, 59, 2, 20.00, 40.00),
(48, 48, 1, 20.00, 20.00),
(49, 71, 3, 18.00, 54.00),
(50, 21, 3, 20.00, 60.00),
(51, 56, 2, 22.00, 44.00),
(52, 37, 3, 18.00, 54.00),
(53, 89, 3, 16.00, 48.00),
(54, 56, 3, 22.00, 66.00),
(55, 37, 3, 18.00, 54.00),
(56, 80, 1, 18.00, 18.00),
(57, 12, 1, 25.00, 25.00),
(58, 12, 3, 25.00, 75.00),
(59, 3, 3, 22.00, 66.00),
(60, 53, 1, 18.00, 18.00),
(61, 64, 3, 20.00, 60.00),
(62, 97, 3, 18.00, 54.00),
(63, 70, 1, 16.00, 16.00),
(64, 82, 2, 17.00, 34.00),
(65, 65, 3, 18.00, 54.00),
(66, 5, 3, 18.00, 54.00),
(67, 38, 2, 18.00, 36.00),
(68, 28, 1, 17.00, 17.00),
(69, 100, 2, 22.00, 44.00),
(70, 71, 2, 18.00, 36.00),
(71, 15, 1, 18.00, 18.00),
(72, 61, 1, 22.00, 22.00),
(73, 45, 2, 20.00, 40.00),
(74, 53, 3, 18.00, 54.00),
(75, 91, 3, 17.00, 51.00),
(76, 51, 1, 18.00, 18.00),
(77, 48, 1, 20.00, 20.00),
(78, 65, 2, 18.00, 36.00),
(79, 35, 3, 20.00, 60.00),
(80, 34, 2, 20.00, 40.00),
(81, 54, 3, 20.00, 60.00),
(82, 31, 1, 20.00, 20.00),
(83, 54, 1, 20.00, 20.00),
(84, 2, 1, 25.00, 25.00),
(85, 20, 2, 22.00, 44.00),
(86, 67, 3, 22.00, 66.00),
(87, 77, 2, 22.00, 44.00),
(88, 43, 1, 22.00, 22.00),
(89, 74, 2, 18.00, 36.00),
(90, 31, 3, 20.00, 60.00),
(91, 51, 1, 18.00, 18.00),
(92, 79, 3, 20.00, 60.00),
(93, 51, 1, 18.00, 18.00),
(94, 74, 2, 18.00, 36.00),
(95, 17, 3, 17.00, 51.00),
(96, 50, 3, 18.00, 54.00),
(97, 23, 2, 20.00, 40.00),
(98, 41, 3, 17.00, 51.00),
(99, 21, 2, 20.00, 40.00),
(100, 30, 1, 18.00, 18.00);

-- 13. factura -------------------------------------------------------------
INSERT INTO factura (id_renta, fecha, subtotal, descuento, total) VALUES
(1, '2024-02-18', 20.00, 0.00, 20.00),
(2, '2024-09-24', 32.00, 3.20, 28.80),
(3, '2025-09-23', 40.00, 4.00, 36.00),
(4, '2025-11-23', 66.00, 0.00, 66.00),
(5, '2025-09-17', 16.00, 1.60, 14.40),
(6, '2026-03-10', 36.00, 0.00, 36.00),
(7, '2024-12-13', 54.00, 5.40, 48.60),
(8, '2024-08-25', 36.00, 3.60, 32.40),
(9, '2025-10-09', 75.00, 0.00, 75.00),
(10, '2026-04-19', 22.00, 2.20, 19.80),
(11, '2026-12-17', 54.00, 0.00, 54.00),
(12, '2026-05-18', 54.00, 0.00, 54.00),
(13, '2026-04-10', 20.00, 0.00, 20.00),
(14, '2025-01-21', 66.00, 0.00, 66.00),
(15, '2024-11-12', 54.00, 5.40, 48.60),
(16, '2026-05-24', 54.00, 5.40, 48.60),
(17, '2025-01-21', 17.00, 0.00, 17.00),
(18, '2025-03-09', 44.00, 4.40, 39.60),
(19, '2026-02-24', 44.00, 4.40, 39.60),
(20, '2026-09-07', 17.00, 0.00, 17.00),
(21, '2024-10-21', 28.00, 2.80, 25.20),
(22, '2026-12-14', 60.00, 0.00, 60.00),
(23, '2025-03-15', 16.00, 1.60, 14.40),
(24, '2025-12-06', 22.00, 0.00, 22.00),
(25, '2024-07-22', 34.00, 0.00, 34.00),
(26, '2025-04-15', 51.00, 0.00, 51.00),
(27, '2024-12-25', 25.00, 2.50, 22.50),
(28, '2025-01-04', 51.00, 5.10, 45.90),
(29, '2024-05-05', 32.00, 0.00, 32.00),
(30, '2026-06-23', 54.00, 5.40, 48.60),
(31, '2026-08-06', 22.00, 0.00, 22.00),
(32, '2024-01-18', 44.00, 0.00, 44.00),
(33, '2024-02-18', 34.00, 3.40, 30.60),
(34, '2024-01-08', 15.00, 0.00, 15.00),
(35, '2024-06-21', 42.00, 0.00, 42.00),
(36, '2026-12-04', 50.00, 0.00, 50.00),
(37, '2024-05-12', 20.00, 2.00, 18.00),
(38, '2025-02-02', 40.00, 0.00, 40.00),
(39, '2025-10-06', 18.00, 1.80, 16.20),
(40, '2025-10-10', 36.00, 3.60, 32.40),
(41, '2026-06-09', 34.00, 0.00, 34.00),
(42, '2026-03-11', 36.00, 3.60, 32.40),
(43, '2025-02-04', 36.00, 0.00, 36.00),
(44, '2025-03-06', 32.00, 0.00, 32.00),
(45, '2025-08-23', 44.00, 4.40, 39.60),
(46, '2024-11-08', 18.00, 1.80, 16.20),
(47, '2026-09-16', 40.00, 4.00, 36.00),
(48, '2026-07-17', 20.00, 0.00, 20.00),
(49, '2024-04-01', 54.00, 0.00, 54.00),
(50, '2024-01-12', 60.00, 0.00, 60.00),
(51, '2024-09-14', 44.00, 0.00, 44.00),
(52, '2026-03-04', 54.00, 0.00, 54.00),
(53, '2026-07-12', 48.00, 4.80, 43.20),
(54, '2024-08-20', 66.00, 0.00, 66.00),
(55, '2024-02-08', 54.00, 0.00, 54.00),
(56, '2024-03-16', 18.00, 1.80, 16.20),
(57, '2025-07-24', 25.00, 0.00, 25.00),
(58, '2024-05-04', 75.00, 0.00, 75.00),
(59, '2026-03-17', 66.00, 6.60, 59.40),
(60, '2026-08-18', 18.00, 0.00, 18.00),
(61, '2026-04-14', 60.00, 6.00, 54.00),
(62, '2025-03-24', 54.00, 0.00, 54.00),
(63, '2024-07-06', 16.00, 0.00, 16.00),
(64, '2026-11-13', 34.00, 3.40, 30.60),
(65, '2026-07-07', 54.00, 0.00, 54.00),
(66, '2025-10-25', 54.00, 0.00, 54.00),
(67, '2024-09-04', 36.00, 3.60, 32.40),
(68, '2025-04-18', 17.00, 0.00, 17.00),
(69, '2024-10-19', 44.00, 0.00, 44.00),
(70, '2024-06-03', 36.00, 0.00, 36.00),
(71, '2025-07-17', 18.00, 1.80, 16.20),
(72, '2026-06-05', 22.00, 0.00, 22.00),
(73, '2026-02-17', 40.00, 0.00, 40.00),
(74, '2025-10-02', 54.00, 0.00, 54.00),
(75, '2025-02-21', 51.00, 0.00, 51.00),
(76, '2026-03-25', 18.00, 0.00, 18.00),
(77, '2026-11-17', 20.00, 2.00, 18.00),
(78, '2025-06-20', 36.00, 3.60, 32.40),
(79, '2026-07-08', 60.00, 0.00, 60.00),
(80, '2024-10-21', 40.00, 0.00, 40.00),
(81, '2025-09-26', 60.00, 6.00, 54.00),
(82, '2025-03-10', 20.00, 0.00, 20.00),
(83, '2025-06-03', 20.00, 2.00, 18.00),
(84, '2025-05-16', 25.00, 0.00, 25.00),
(85, '2024-10-16', 44.00, 0.00, 44.00),
(86, '2025-10-22', 66.00, 6.60, 59.40),
(87, '2026-06-12', 44.00, 0.00, 44.00),
(88, '2025-11-02', 22.00, 2.20, 19.80),
(89, '2024-03-04', 36.00, 0.00, 36.00),
(90, '2025-02-08', 60.00, 6.00, 54.00),
(91, '2025-08-15', 18.00, 1.80, 16.20),
(92, '2026-02-13', 60.00, 0.00, 60.00),
(93, '2024-06-11', 18.00, 1.80, 16.20),
(94, '2025-02-09', 36.00, 0.00, 36.00),
(95, '2025-03-21', 51.00, 0.00, 51.00),
(96, '2026-07-02', 54.00, 0.00, 54.00),
(97, '2024-04-01', 40.00, 4.00, 36.00),
(98, '2024-02-05', 51.00, 0.00, 51.00),
(99, '2025-12-15', 40.00, 0.00, 40.00),
(100, '2025-03-02', 18.00, 1.80, 16.20);

-- 14. devolucion ---------------------------------------------------------
INSERT INTO devolucion (id_renta, id_empleado, id_mora, fecha_devolucion, estado) VALUES
(1, 91, NULL, '2024-02-21', 'pendiente'),
(2, 16, NULL, '2024-10-06', 'completada'),
(3, 98, NULL, '2025-09-28', 'pendiente'),
(4, 21, NULL, '2025-12-01', 'completada'),
(5, 12, NULL, '2025-09-19', 'completada'),
(6, 56, NULL, '2026-03-11', 'rechazada'),
(7, 20, NULL, '2024-12-14', 'rechazada'),
(8, 91, NULL, '2024-09-06', 'completada'),
(9, 74, NULL, '2025-10-16', 'completada'),
(10, 96, NULL, '2026-04-22', 'pendiente'),
(11, 82, NULL, '2026-12-23', 'completada'),
(12, 31, NULL, '2026-05-22', 'completada'),
(13, 25, NULL, '2026-04-19', 'completada'),
(14, 93, NULL, '2025-01-28', 'completada'),
(15, 85, NULL, '2024-11-13', 'completada'),
(16, 11, NULL, '2026-05-27', 'completada'),
(17, 82, NULL, '2025-02-03', 'completada'),
(18, 15, NULL, '2025-03-17', 'rechazada'),
(19, 16, NULL, '2026-02-26', 'completada'),
(20, 37, NULL, '2026-09-12', 'completada'),
(21, 12, NULL, '2024-10-23', 'pendiente'),
(22, 47, NULL, '2026-12-18', 'completada'),
(23, 13, NULL, '2025-03-23', 'completada'),
(24, 53, NULL, '2025-12-08', 'pendiente'),
(25, 81, NULL, '2024-07-24', 'completada'),
(26, 88, NULL, '2025-04-22', 'completada'),
(27, 41, NULL, '2025-01-05', 'completada'),
(28, 24, NULL, '2025-01-09', 'completada'),
(29, 23, NULL, '2024-05-15', 'rechazada'),
(30, 5, NULL, '2026-06-25', 'completada'),
(31, 45, NULL, '2026-08-14', 'rechazada'),
(32, 77, NULL, '2024-01-27', 'completada'),
(33, 21, NULL, '2024-02-27', 'completada'),
(34, 16, NULL, '2024-01-12', 'rechazada'),
(35, 4, NULL, '2024-07-02', 'completada'),
(36, 67, NULL, '2026-12-13', 'completada'),
(37, 28, NULL, '2024-05-18', 'completada'),
(38, 28, NULL, '2025-02-03', 'completada'),
(39, 18, NULL, '2025-10-10', 'completada'),
(40, 94, NULL, '2025-10-13', 'completada'),
(41, 36, NULL, '2026-06-17', 'completada'),
(42, 12, NULL, '2026-03-17', 'pendiente'),
(43, 84, NULL, '2025-02-09', 'pendiente'),
(44, 96, NULL, '2025-03-14', 'completada'),
(45, 66, NULL, '2025-09-02', 'completada'),
(46, 33, NULL, '2024-11-11', 'completada'),
(47, 88, NULL, '2026-09-21', 'completada'),
(48, 14, NULL, '2026-07-27', 'rechazada'),
(49, 40, NULL, '2024-04-04', 'completada'),
(50, 93, NULL, '2024-01-20', 'completada'),
(51, 58, NULL, '2024-09-21', 'rechazada'),
(52, 96, NULL, '2026-03-09', 'completada'),
(53, 80, NULL, '2026-07-14', 'rechazada'),
(54, 50, NULL, '2024-08-27', 'completada'),
(55, 73, NULL, '2024-02-14', 'completada'),
(56, 81, NULL, '2024-03-18', 'pendiente'),
(57, 22, NULL, '2025-07-25', 'pendiente'),
(58, 33, NULL, '2024-05-14', 'completada'),
(59, 38, NULL, '2026-03-27', 'pendiente'),
(60, 46, NULL, '2026-08-25', 'completada'),
(61, 15, NULL, '2026-04-17', 'completada'),
(62, 55, NULL, '2025-03-27', 'completada'),
(63, 32, NULL, '2024-07-08', 'completada'),
(64, 85, NULL, '2026-11-19', 'completada'),
(65, 19, NULL, '2026-07-13', 'completada'),
(66, 2, NULL, '2025-11-03', 'completada'),
(67, 92, NULL, '2024-09-10', 'completada'),
(68, 60, NULL, '2025-04-28', 'completada'),
(69, 30, NULL, '2024-10-28', 'completada'),
(70, 50, NULL, '2024-06-08', 'rechazada'),
(71, 28, NULL, '2025-07-26', 'completada'),
(72, 14, NULL, '2026-06-14', 'completada'),
(73, 92, NULL, '2026-02-27', 'completada'),
(74, 74, NULL, '2025-10-09', 'completada'),
(75, 41, NULL, '2025-02-27', 'completada'),
(76, 26, NULL, '2026-03-26', 'pendiente'),
(77, 64, NULL, '2026-11-18', 'completada'),
(78, 54, NULL, '2025-06-22', 'completada'),
(79, 58, NULL, '2026-07-11', 'rechazada'),
(80, 42, NULL, '2024-11-03', 'completada'),
(81, 31, NULL, '2025-10-08', 'completada'),
(82, 37, NULL, '2025-03-11', 'rechazada'),
(83, 1, NULL, '2025-06-11', 'completada'),
(84, 17, NULL, '2025-05-23', 'completada'),
(85, 69, NULL, '2024-10-25', 'completada'),
(86, 44, NULL, '2025-10-23', 'completada'),
(87, 61, NULL, '2026-06-14', 'completada'),
(88, 93, NULL, '2025-11-07', 'completada'),
(89, 41, NULL, '2024-03-10', 'completada'),
(90, 11, NULL, '2025-02-17', 'completada'),
(91, 64, NULL, '2025-08-25', 'completada'),
(92, 51, NULL, '2026-02-18', 'pendiente'),
(93, 64, NULL, '2024-06-13', 'completada'),
(94, 80, NULL, '2025-02-11', 'completada'),
(95, 29, NULL, '2025-03-22', 'completada'),
(96, 18, NULL, '2026-07-04', 'completada'),
(97, 89, NULL, '2024-04-08', 'completada'),
(98, 22, NULL, '2024-02-07', 'completada'),
(99, 93, NULL, '2025-12-21', 'pendiente'),
(100, 1, NULL, '2025-03-03', 'completada');

-- 15. mora -----------------------------------------------------------------
-- NOTA: la mora solo aplica cuando hubo atraso en la devolucion;
--       no todas las 100 devoluciones generan mora (regla de negocio).
INSERT INTO mora (id_devolucion, dias_atraso, monto, estado_pago) VALUES
(6, 13, 39.00, 'pagado'),
(7, 12, 36.00, 'pendiente'),
(10, 6, 18.00, 'pagado'),
(12, 11, 33.00, 'pagado'),
(15, 12, 36.00, 'pendiente'),
(16, 2, 6.00, 'condonado'),
(17, 1, 3.00, 'pagado'),
(18, 1, 3.00, 'pagado'),
(19, 8, 24.00, 'condonado'),
(22, 4, 12.00, 'condonado'),
(29, 2, 6.00, 'pagado'),
(31, 4, 12.00, 'pagado'),
(34, 13, 39.00, 'pagado'),
(35, 12, 36.00, 'condonado'),
(36, 11, 33.00, 'pagado'),
(39, 14, 42.00, 'pendiente'),
(41, 15, 45.00, 'pagado'),
(42, 4, 12.00, 'pagado'),
(43, 7, 21.00, 'condonado'),
(49, 14, 42.00, 'pagado'),
(53, 13, 39.00, 'condonado'),
(58, 4, 12.00, 'pendiente'),
(59, 5, 15.00, 'condonado'),
(62, 3, 9.00, 'pagado'),
(63, 14, 42.00, 'pendiente'),
(67, 3, 9.00, 'condonado'),
(68, 15, 45.00, 'pendiente'),
(73, 12, 36.00, 'pendiente'),
(74, 4, 12.00, 'pendiente'),
(75, 15, 45.00, 'condonado'),
(79, 3, 9.00, 'pagado'),
(85, 1, 3.00, 'condonado'),
(87, 11, 33.00, 'condonado'),
(89, 6, 18.00, 'pagado'),
(95, 2, 6.00, 'pendiente');

-- Vincular cada devolucion con su mora (FK circular resuelta con UPDATE)
UPDATE devolucion d JOIN mora m ON m.id_devolucion = d.id_devolucion SET d.id_mora = m.id_mora;
UPDATE cliente c JOIN membresia m ON m.id_cliente = c.id_cliente SET c.id_membresia = m.id_membresia;
SET SQL_SAFE_UPDATES = 0;

-- Calculos para el Dashboard
DELIMITER // 
create procedure DashboardDatos(
	out totalventas float,
    out totalstock float,
    out numclientes float,
    out numusuarios float,
    out numepleados float,
    out numvideos float,
    out numdevoluciones float
)
Begin
	Select sum(cantidad) into totalventas from detalle_renta;
    Select sum(stock) into totalstock from video;
	Select count(id_cliente) into numclientes from cliente;
	Select count(id_usuario) into numusuarios from usuario;
	Select count(id_empleado) into numepleados from empleado;
	Select count(id_video) into numvideos from video;
	Select count(id_devolucion) into numdevoluciones from devolucion;
End //
DELIMITER ;

call DashboardDatos(@ventas, @stock, @clientes, @usuarios, @empleados, @videos, @devoluciones);
select @ventas, @stock, @clientes, @usuarios, @empleados, @videos, @devoluciones;

-- Top 5 peliculas favoritas
DELIMITER // 
create procedure PeliculasPreferidas()
begin
	select v.titulo, sum(cantidad) as total_rentado
	from detalle_renta dr
	inner join video v on v.id_video = dr.id_video
	group by dr.id_video
	order by total_rentado desc
	limit 5;
end //
DELIMITER ;

call PeliculasPreferidas();

-- Cantidad de peliculas por genero
DELIMITER // 
create procedure PeliculasPorGenero()
begin
	select genero, count(*) as total_genero
	from video
	group by genero
	order by total_genero desc;
end //
DELIMITER ;

call PeliculasPorGenero();