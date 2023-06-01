use proyecto;

CREATE TABLE clientes (
    nit             varchar(10) primary key not null,
    numeroTelefono  int not null,
    primerNombre    varchar(50) not null,
    segundoNombre   varchar(50),
    primerApellido  varchar(50) not null,
    segundoApellido varchar(50),
    direccion       varchar (50),
)

CREATE TABLE categoria(
    idCategoria int  IDENTITY(1,1) primary key,
    nombre varchar(50)
);

CREATE TABLE producto (
    idProducto int IDENTITY(1,1) primary key not null,
    nombre varchar(100),
    precioCompra money,
    precioVenta money,
    existencia int,
    idCategoria int,
    CONSTRAINT idCategoria FOREIGN KEY (idCategoria) REFERENCES categoria(idCategoria),
)

CREATE TABLE estado
(
    idEstado int  IDENTITY(1,1) primary key,
    nombre varchar(50)
);

CREATE TABLE  orden
(
    idOrden         int IDENTITY(1,1) primary key not null,
    idCliente       varchar(10),
    idEstado        int,
    fechaOrden      date,
    descripcion     varchar(50),
    fechaEntrega    date,
    anticipo        money,
    saldo           money,
    total           money,
    CONSTRAINT idCliente FOREIGN KEY (idCliente) REFERENCES clientes(nit),
    CONSTRAINT idEstado FOREIGN KEY (idEstado) REFERENCES estado(idEstado)
);


CREATE TABLE detalleOrden(
    idDetalleOrden int  IDENTITY(1,1) primary key,
    idProducto  int,
    cantidad    int,
    idOrden     int,
    subtotal money,
    CONSTRAINT idProducto FOREIGN KEY (idProducto) REFERENCES producto(idProducto),
    CONSTRAINT idOrden    FOREIGN KEY (idOrden) REFERENCES orden(idOrden)
);

CREATE TABLE gastos(
    idGasto int  IDENTITY(1,1) primary key,
    fecha date,
    descripcion varchar(100),
    total money
);
