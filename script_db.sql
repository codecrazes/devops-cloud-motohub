-- Cria o banco (caso ainda não exista) já com charset/collation.
CREATE DATABASE IF NOT EXISTS motohub
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE motohub;

-- Evita erro de ordem de exclusão por FK.
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS intencao;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS moto;

SET FOREIGN_KEY_CHECKS = 1;

-- Tabela de usuários do sistema.
CREATE TABLE usuario (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    username  VARCHAR(50)  NOT NULL,
    password  VARCHAR(100) NOT NULL,               
    role      VARCHAR(20)  NOT NULL,                -- ex.: ADMIN/USER
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_usuario_username UNIQUE (username) -- username único
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Clientes “negociais” (proprietários/solicitantes).
CREATE TABLE cliente (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    email     VARCHAR(100),
    telefone  VARCHAR(20),
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_cliente_email UNIQUE (email)       -- ajuda a evitar duplicados
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Cadastro de motos.
CREATE TABLE moto (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    modelo      VARCHAR(50)  NOT NULL,
    marca       VARCHAR(50)  NOT NULL,
    tipo_uso    VARCHAR(20)  NOT NULL,              -- ex.: ENTREGA, RESERVA, MANUTENCAO
    ano         INT          NOT NULL,              -- considere CHECK (ano) para faixa válida (MySQL 8.0+)
    disponivel  BOOLEAN      NOT NULL DEFAULT TRUE, -- BOOLEAN em MySQL = TINYINT(1)
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Intenções (vínculo cliente x moto x tipo de intenção).
CREATE TABLE intencao (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id  BIGINT NOT NULL,
    moto_id     BIGINT NOT NULL,
    tipo        VARCHAR(20) NOT NULL,               -- ex.: RESERVA, VENDA, LOCACAO
    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Índices para acelerar joins e buscas por FK (boa prática).
    INDEX idx_intencao_cliente (cliente_id),
    INDEX idx_intencao_moto    (moto_id),

    -- Regra opcional: impedir duplicidade da mesma intenção para o mesmo par cliente+moto.
    CONSTRAINT uk_intencao_unica UNIQUE (cliente_id, moto_id, tipo),

    CONSTRAINT fk_intencao_cliente FOREIGN KEY (cliente_id)
      REFERENCES cliente(id)
      ON DELETE CASCADE           -- se remover cliente, remove intenções
      ON UPDATE RESTRICT,

    CONSTRAINT fk_intencao_moto FOREIGN KEY (moto_id)
      REFERENCES moto(id)
      ON DELETE RESTRICT          -- bloqueia excluir moto se houver intenção
      ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- SEEDS (apenas para desenvolvimento/demonstração)
INSERT INTO usuario (username, password, role) VALUES
('admin', '1234', 'ADMIN'),
('user',  '1234', 'USER');

INSERT INTO cliente (nome, email, telefone) VALUES
('Caroline', 'caroline@email.com', '999999999'),
('Luis',     'luis@email.com',     '888888888');
