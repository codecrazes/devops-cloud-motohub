-- script_bd.sql (SQL Server - Azure SQL)
-- Tabelas: usuario, cliente, moto, intencao

-- Tabela de usuários do sistema (login/perfil)
CREATE TABLE usuario (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(100) NOT NULL,
  [role] VARCHAR(20) NOT NULL
);

-- Clientes (pessoas interessadas em alugar/comprar motos)
CREATE TABLE cliente (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  telefone VARCHAR(20)
);

-- Motos (ativos gerenciados)
CREATE TABLE moto (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  modelo VARCHAR(50) NOT NULL,
  marca VARCHAR(50) NOT NULL,
  tipo_uso VARCHAR(20) NOT NULL,
  ano INT NOT NULL,
  disponivel BIT DEFAULT 1
);

-- Intenções (vínculo cliente ↔ moto, com tipo de interesse)
CREATE TABLE intencao (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  cliente_id BIGINT NOT NULL,
  moto_id BIGINT NOT NULL,
  tipo VARCHAR(20) NOT NULL,
  CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id),
  CONSTRAINT fk_moto FOREIGN KEY (moto_id) REFERENCES moto(id)
);
