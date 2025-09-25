ALTER TABLE moto ADD COLUMN disponivel BOOLEAN DEFAULT TRUE;

INSERT INTO usuario (username, password, role) VALUES 
('admin', '1234', 'ADMIN'),
('user', '1234', 'USER');

INSERT INTO cliente (nome, email, telefone) VALUES 
('Caroline', 'caroline@email.com', '999999999'),
('Luis', 'luis@email.com', '888888888');
