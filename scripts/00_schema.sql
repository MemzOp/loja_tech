-- Referências: IA, w3schools, stack overflow
-- Schema do banco de dados para a atividade

CREATE DATABASE IF NOT EXISTS loja_db;
USE loja_db;

CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    endereco TEXT,
    cpf_cnpj VARCHAR(20) UNIQUE,
    rg VARCHAR(20),
    data_cadastro DATE DEFAULT (CURDATE()),
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE vendedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    comissao_pct DECIMAL(5,2) DEFAULT 5.00,
    data_admissao DATE,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT DEFAULT 0,
    categoria_id INT,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    vendedor_id INT,
    data_pedido DATE DEFAULT (CURDATE()),
    valor_total DECIMAL(10,2) DEFAULT 0,
    status ENUM('pendente', 'processando', 'enviado', 'entregue', 'cancelado') DEFAULT 'pendente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (vendedor_id) REFERENCES vendedores(id)
);

CREATE TABLE itens_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

CREATE TABLE comissoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendedor_id INT NOT NULL,
    mes INT NOT NULL,
    ano INT NOT NULL,
    faturamento DECIMAL(10,2),
    comissao DECIMAL(10,2),
    bonus DECIMAL(10,2) DEFAULT 0,
    data_calculo DATE DEFAULT (CURDATE()),
    FOREIGN KEY (vendedor_id) REFERENCES vendedores(id),
    UNIQUE KEY uk_vendedor_mes_ano (vendedor_id, mes, ano)
);

CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_data ON pedidos(data_pedido);
CREATE INDEX idx_pedidos_status ON pedidos(status);
CREATE INDEX idx_itens_pedido ON itens_pedido(pedido_id);
CREATE INDEX idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX idx_clientes_email ON clientes(email);

INSERT INTO categorias (nome, descricao) VALUES
('Eletrônicos', 'Produtos eletrônicos em geral'),
('Roupas', 'Vestuário e acessórios'),
('Casa', 'Artigos para casa e decoração'),
('Livros', 'Livros e materiais de leitura');

INSERT INTO vendedores (nome, email, comissao_pct, data_admissao) VALUES
('João Silva', 'joao@loja.com', 5.00, '2023-01-15'),
('Maria Santos', 'maria@loja.com', 6.00, '2023-03-20'),
('Pedro Costa', 'pedro@loja.com', 5.50, '2023-06-10');

INSERT INTO clientes (nome, email, telefone, endereco, cpf_cnpj) VALUES
('Ana Oliveira', 'ana@email.com', '11999990001', 'Rua A, 123', '12345678901'),
('Carlos Ferreira', 'carlos@email.com', '11999990002', 'Rua B, 456', '23456789012'),
('Beatriz Lima', 'beatriz@email.com', '11999990003', 'Rua C, 789', '34567890123');

INSERT INTO produtos (nome, descricao, preco, estoque, categoria_id) VALUES
('Smartphone XYZ', 'Smartphone última geração', 2999.99, 15, 1),
('Notebook ABC', 'Notebook para trabalho', 4599.99, 8, 1),
('Camiseta Básica', 'Camiseta algodão 100%', 49.90, 50, 2),
('Calça Jeans', 'Calça jeans tradicional', 129.90, 30, 2),
('Sofá 3 Lugares', 'Sofá retrátil', 1899.99, 5, 3),
('Mesa de Jantar', 'Mesa 6 cadeiras', 899.99, 3, 3),
('Livro SQL', 'Guia completo de SQL', 89.90, 25, 4),
('Livro Python', 'Programação em Python', 99.90, 20, 4);