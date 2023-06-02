use proyecto;

CREATE TABLE clientes
(
    nit             varchar(10) primary key not null,
    numeroTelefono  int                     not null,
    primerNombre    varchar(50)             not null,
    segundoNombre   varchar(50),
    primerApellido  varchar(50)             not null,
    segundoApellido varchar(50),
    direccion       varchar(50),
)

CREATE TABLE categoria
(
    idCategoria int IDENTITY (1,1) primary key,
    nombre      varchar(50)
);

CREATE TABLE producto
(
    idProducto   int IDENTITY (1,1) primary key not null,
    nombre       varchar(100),
    precioCompra money,
    precioVenta  money,
    existencia   int,
    idCategoria  int,
    CONSTRAINT idCategoria FOREIGN KEY (idCategoria) REFERENCES categoria (idCategoria),
)

CREATE TABLE estado
(
    idEstado int IDENTITY (1,1) primary key,
    nombre   varchar(50)
);

CREATE TABLE orden
(
    idOrden      int IDENTITY (1,1) primary key not null,
    idCliente    varchar(10),
    idEstado     int,
    fechaOrden   date,
    descripcion  varchar(50),
    fechaEntrega date,
    anticipo     money,
    saldo        money,
    total        money,
    CONSTRAINT idCliente FOREIGN KEY (idCliente) REFERENCES clientes (nit),
    CONSTRAINT idEstado FOREIGN KEY (idEstado) REFERENCES estado (idEstado)
);


CREATE TABLE detalleOrden
(
    idDetalleOrden int IDENTITY (1,1) primary key,
    idProducto     int,
    cantidad       int,
    idOrden        int,
    subtotal       money,
    CONSTRAINT idProducto FOREIGN KEY (idProducto) REFERENCES producto (idProducto),
    CONSTRAINT idOrden FOREIGN KEY (idOrden) REFERENCES orden (idOrden)
);

CREATE TABLE gastos
(
    idGasto     int IDENTITY (1,1) primary key,
    fecha       date,
    descripcion varchar(100),
    total       money
);

DROP TABLE detalleOrden;
DROP TABLE orden;
DROP TABLE clientes;


CREATE PROCEDURE accionClientes @accion varchar(15),
                                @nit varchar(10),
                                @numeroTelefono int,
                                @primerNombre varchar(50),
                                @segundoNombre varchar(50),
                                @primerApellido varchar(50),
                                @segundoApellido varchar(50),
                                @direccion varchar(50)
AS
    IF (@accion = 'insertar')
        BEGIN
            INSERT INTO dbo.clientes (nit, numeroTelefono, primerNombre, segundoNombre, primerApellido, segundoApellido,
                                      direccion)
            VALUES (@nit, @numeroTelefono, @primerNombre, @segundoNombre, @primerApellido, @segundoApellido, @direccion)
        END
    ELSE IF (@accion = 'actualizar')
            BEGIN
                UPDATE dbo.clientes
                SET numeroTelefono  = @numeroTelefono,
                    primerNombre    = @primerNombre,
                    segundoNombre   = @segundoNombre,
                    primerApellido  = @primerApellido,
                    segundoApellido = @segundoApellido,
                    direccion       = @direccion
                WHERE nit = @nit;
            END
    ELSE IF (@accion = 'eliminar')
    BEGIN
        DELETE FROM dbo.clientes WHERE nit = @nit;
    END
GO;

CREATE PROCEDURE accionOrden @accion varchar(10),
    @idOrden      int,
    @idCliente    varchar(10),
    @idEstado     int,
    @fechaOrden   date,
    @descripcion  varchar(50),
    @fechaEntrega date,
    @anticipo     money,
    @total        money
AS
    IF(@accion = 'insertar')
    BEGIN

        INSERT INTO dbo.orden (idCliente, idEstado, fechaOrden, descripcion, fechaEntrega, anticipo,total)
        VALUES (@idCliente, @idEstado, @fechaOrden, @descripcion, @fechaEntrega, @anticipo, @total);
    END
    ELSE IF(@accion = 'actualizar')
    BEGIN
        IF(@idEstado != 5)
        BEGIN
            UPDATE dbo.orden SET idEstado = @idEstado WHERE idOrden = @idOrden;
        END
        ELSE IF (@idEstado = 5 AND ((SELECT total FROM orden) = (SELECT saldo FROM orden)))
        BEGIN
            UPDATE dbo.orden SET idEstado = @idEstado WHERE idOrden = @idOrden;
        END
        ELSE
            SELECT 'La orden tiene saldo pendiente';
    END
    ELSE IF(@accion = 'eliminar')
    BEGIN
        DELETE FROM dbo.orden WHERE idOrden = @idOrden;
    END
GO;

CREATE PROCEDURE insertarDetalleOrden
    @idProducto     int,
    @cantidad       int,
    @idOrden        int,
    @subtotal       money
AS
    INSERT INTO dbo.detalleOrden (idProducto, cantidad, idOrden, subtotal)
    VALUES (@idProducto,@cantidad,@idOrden,@subtotal);
GO;


CREATE VIEW  vstDetalleOrden
AS
    SELECT o.* FROM orden o
    JOIN detalleOrden dO ON o.idOrden = dO.idOrden
    JOIN clientes c on o.idCliente = c.nit;
GO;


CREATE PROCEDURE obtenerDetalleOrden @idOrden int
AS
    SELECT * FROM vstDetalleOrden;
GO;

CREATE PROCEDURE obtenerOrdenesCliente @nit varchar(10)
AS
    SELECT * FROM vstDetalleOrden WHERE idCliente = @nit;
GO;


CREATE FUNCTION obtenerDatosCliente(@nit varchar(10))
    RETURNS TABLE
AS
    RETURN (SELECT * FROM dbo.clientes WHERE nit = @nit)
;


CREATE FUNCTION devolverSaldo(@total money, @anticipo money)
    RETURNS  money
AS
BEGIN
    DECLARE @saldo money

    SET @saldo = @total - @anticipo

    RETURN @saldo
END;


CREATE TRIGGER actualizarOrden
    ON orden
    AFTER INSERT
AS
    DECLARE @saldo money;
    DECLARE @total money;
    DECLARE @anticipo money;

    IF((SELECT COUNT(*) FROM inserted)>0)
    BEGIN
        SET @total      = (select total from inserted);
        SET @anticipo   = (select anticipo from inserted);
        SET @saldo      = dbo.devolverSaldo(@total,@anticipo);

        UPDATE orden SET saldo = @saldo,idEstado = 2
                    WHERE idOrden = (SELECT idOrden FROM inserted);

    END
GO;


INSERT INTO estado(nombre) VALUES ('disenio');
INSERT INTO estado(nombre) VALUES ('enCola');
INSERT INTO estado(nombre) VALUES ('impresion');
INSERT INTO estado(nombre) VALUES ('listo');
INSERT INTO estado(nombre) VALUES ('entregado');
SELECT * from estado;
select * from estado;