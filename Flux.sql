CREATE DATABASE Flux;
USE Flux;



CREATE TABLE Sucursal (
    id_sucursal   INT          AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(255) NOT NULL,
    localidad     VARCHAR(255) NOT NULL
);



CREATE TABLE Cliente (
    id_cliente  INT         AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(45) NOT NULL,
    ap_pat      VARCHAR(45) NOT NULL,
    ap_mat      VARCHAR(45),
    direccion   VARCHAR(255)
);



CREATE TABLE Cuenta (
    id_cuenta      INT            AUTO_INCREMENT PRIMARY KEY,
    id_sucursal    INT            NOT NULL,
    numero_cuenta  VARCHAR(20)    NOT NULL,
    tipo_cuenta    ENUM(
                     'debito',
                     'credito',
                     'ahorro'
                   )              NOT NULL,
    saldo          DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
    fecha_creacion DATE           NOT NULL,

    CONSTRAINT cuenta_numero_unico
        UNIQUE (numero_cuenta),

    CONSTRAINT cuenta_pertenece_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES Sucursal(id_sucursal)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


--  TARJETA  -> nueva, para simular el login


CREATE TABLE Tarjeta (
    id_tarjeta     INT         AUTO_INCREMENT PRIMARY KEY,
    id_cuenta      INT         NOT NULL,
    numero_tarjeta VARCHAR(16) NOT NULL,
    nip       INT NOT NULL,        
    fecha_expiracion DATE      NOT NULL,
    activa         TINYINT(1)  NOT NULL DEFAULT 1,

    CONSTRAINT tarjeta_numero_unico
        UNIQUE (numero_tarjeta),

    CONSTRAINT tarjeta_vinculada_cuenta
        FOREIGN KEY (id_cuenta)
        REFERENCES Cuenta(id_cuenta)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

--  CLIENTE_CUENTA  (relación N:M)


CREATE TABLE Cliente_Cuenta (
    id_cliente  INT NOT NULL,
    id_cuenta   INT NOT NULL,

    PRIMARY KEY (id_cliente, id_cuenta),

    CONSTRAINT clientecuenta_apunta_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES Cliente(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT clientecuenta_apunta_cuenta
        FOREIGN KEY (id_cuenta)
        REFERENCES Cuenta(id_cuenta)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE Transaccion (
    id_transaccion  INT           AUTO_INCREMENT PRIMARY KEY,
    id_cuenta       INT           NOT NULL,          -- cuenta que origina el movimiento
    tipo            ENUM(
                      'retiro',
                      'deposito',
                      'transferencia_entrada',
                      'transferencia_salida'
                    )             NOT NULL,
    monto           DECIMAL(12,2) NOT NULL,
    cuenta_origen   VARCHAR(20),                     -- numero_cuenta origen  (transferencias)
    cuenta_destino  VARCHAR(20),                     -- numero_cuenta destino (transferencias)
    fecha           DATE          NOT NULL,
    hora            TIME          NOT NULL,
    token           VARCHAR(64),                     -- referencia externa / comprobante (si es que lo hacemos xd)

    CONSTRAINT transaccion_pertenece_cuenta
        FOREIGN KEY (id_cuenta)
        REFERENCES Cuenta(id_cuenta)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- el monto nunca puede ser negativo ni cero, esto es para las restricciones
    CONSTRAINT transaccion_monto_positivo
        CHECK (monto > 0)
);