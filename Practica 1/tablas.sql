
-- Tablas de Dimensiones

USE practica1semi2;


-- Dimensión Cliente
CREATE TABLE DimCliente (
    IdCliente NVARCHAR(100) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL
);

select * from DimCliente;

-- Dimensión Fecha
CREATE TABLE DimFecha (
    IdFecha INT PRIMARY KEY,
    Anio INT NOT NULL,
    Mes INT NOT NULL,
    MesNombre NVARCHAR(150),
    DiaSemana NVARCHAR(150)
);


TRUNCATE TABLE DimFecha;

select * from DimFecha;



-- Dimensión Producto
CREATE TABLE DimProducto (
    IdProducto NVARCHAR(150) PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL
);

ALTER TABLE DimProducto
ADD Marca NVARCHAR(150) NOT NULL;

truncate table DimProducto;
select * from DimProducto;




-- Dimensión Proveedor
CREATE TABLE DimProveedor (
    IdProveedor NVARCHAR(150) PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL
);

select * from DimProveedor;


-- Dimensión Sucursal
CREATE TABLE DimSucursal (
    IdSucursal NVARCHAR(150) PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL,
    Departamento NVARCHAR(150) NOT NULL,
    Region NVARCHAR(150) NOT NULL
);

delete from DimSucursal;

ALTER TABLE DimSucursal
ADD Departamento NVARCHAR(150) NOT NULL;

ALTER TABLE DimSucursal
ADD Region NVARCHAR(150) NOT NULL;

select * from DimSucursal;


CREATE TABLE DimVendedor (
    IdVendedor NVARCHAR(150) PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL
);

select * from DimVendedor;

select * from DimSucursal;

-- Tablas de Hechos


-- Hecho Compras
CREATE TABLE HechoCompras (
    IdCompra INT IDENTITY(1,1) PRIMARY KEY,
    IdFecha INT NOT NULL,
    IdProveedor NVARCHAR(150),
    IdProducto NVARCHAR(150),
    IdSucursal NVARCHAR(150),
    Cantidad INT NOT NULL,
    Costo DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_HechoCompras_Fecha FOREIGN KEY (IdFecha) REFERENCES DimFecha(IdFecha),
    CONSTRAINT FK_HechoCompras_Proveedor FOREIGN KEY (IdProveedor) REFERENCES DimProveedor(IdProveedor),
    CONSTRAINT FK_HechoCompras_Producto FOREIGN KEY (IdProducto) REFERENCES DimProducto(IdProducto),
    CONSTRAINT FK_HechoCompras_Sucuarsal FOREIGN KEY (IdSucursal) REFERENCES DimSucursal(IdSucursal)
);

TRUNCATE table HechoCompras;

select * from HechoCompras;

-- Hecho Ventas
CREATE TABLE HechoVentas (
    IdVenta INT IDENTITY(1,1) PRIMARY KEY,
    IdFecha INT NOT NULL,
    IdCliente NVARCHAR(100),
    IdProducto NVARCHAR(150),
    IdSucursal NVARCHAR(150),
    IdVendedor NVARCHAR(150),
    Cantidad INT NOT NULL,
    Precio DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_HechoVentas_Fecha FOREIGN KEY (IdFecha) REFERENCES DimFecha(IdFecha),
    CONSTRAINT FK_HechoVentas_Cliente FOREIGN KEY (IdCliente) REFERENCES DimCliente(IdCliente),
    CONSTRAINT FK_HechoVentas_Producto FOREIGN KEY (IdProducto) REFERENCES DimProducto(IdProducto),
    CONSTRAINT FK_HechoVentas_Sucursal FOREIGN KEY (IdSucursal) REFERENCES DimSucursal(IdSucursal),
    CONSTRAINT FK_HechoVentas_Vendedor FOREIGN KEY (IdVendedor) REFERENCES DimVendedor(IdVendedor)
);


select * from HechoVentas;

truncate table HechoVentas;
--  
-- Consultas


-- Compras por año
SELECT 
    df.Anio,
    SUM(hc.Costo * hc.Cantidad) AS TotalCompras
FROM HechoCompras hc
JOIN DimFecha df ON hc.IdFecha = df.IdFecha
GROUP BY df.Anio
ORDER BY df.Anio;

-- Ventas por año
SELECT 
    df.Anio,
    SUM(hv.Precio * hv.Cantidad) AS TotalVentas
FROM HechoVentas hv
JOIN DimFecha df ON hv.IdFecha = df.IdFecha
GROUP BY df.Anio
ORDER BY df.Anio;

-- Ventas con perdida

SELECT 
    p.Nombre AS Producto,
    AVG(hv.Precio) AS PrecioPromedioVenta,
    AVG(hc.Costo) AS CostoPromedioCompra
FROM HechoVentas hv
JOIN DimProducto p ON hv.IdProducto = p.IdProducto
JOIN HechoCompras hc ON hc.IdProducto = p.IdProducto
GROUP BY p.Nombre
HAVING AVG(hv.Precio) < AVG(hc.Costo);

-- top 5

SELECT TOP 5
    p.Nombre AS Producto,
    SUM(hv.Cantidad) AS TotalUnidadesVendidas
FROM HechoVentas hv
JOIN DimProducto p ON hv.IdProducto = p.IdProducto
GROUP BY p.Nombre
ORDER BY SUM(hv.Cantidad) DESC;


-- región y añio

SELECT 
    s.Region,
    df.Anio,
    SUM(hv.Precio * hv.Cantidad) AS IngresosTotales
FROM HechoVentas hv
JOIN DimSucursal s ON hv.IdSucursal = s.IdSucursal
JOIN DimFecha df ON hv.IdFecha = df.IdFecha
GROUP BY s.Region, df.Anio
ORDER BY s.Region, df.Anio;

-- Proveedores con mas volumen

SELECT 
    pr.Nombre AS Proveedor,
    SUM(hc.Cantidad) AS TotalUnidadesCompradas,
    SUM(hc.Costo * hc.Cantidad) AS TotalGastado
FROM HechoCompras hc
JOIN DimProveedor pr ON hc.IdProveedor = pr.IdProveedor
GROUP BY pr.Nombre
ORDER BY TotalUnidadesCompradas DESC;

