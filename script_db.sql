USE motohub;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS intencao;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS moto;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE usuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cliente (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE moto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    marca  VARCHAR(50) NOT NULL,
    tipo_uso VARCHAR(20) NOT NULL,
    ano INT NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE intencao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    moto_id    BIGINT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id),
    CONSTRAINT fk_moto    FOREIGN KEY (moto_id)    REFERENCES moto(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO usuario (username, password, role) VALUES
('admin', '1234', 'ADMIN'),
('user',  '1234', 'USER');

INSERT INTO cliente (nome, email, telefone) VALUES
('Caroline', 'caroline@email.com', '999999999'),
('Luis',     'luis@email.com',     '888888888');
