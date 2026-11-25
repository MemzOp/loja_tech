-- Referências: IA, w3schools, stack overflow
-- Bloco 1: Consultas SQL

-- 1.1 Listar todos os clientes
SELECT * FROM clientes;

-- 1.2 Listar produtos com preço maior que 100
SELECT nome, preco FROM produtos WHERE preco > 100;

-- 1.3 Contar pedidos por cliente
SELECT c.nome, COUNT(p.id) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;

-- 1.4 Produtos mais vendidos
SELECT pr.nome, SUM(ip.quantidade) AS total_vendido
FROM itens_pedido ip
JOIN produtos pr ON ip.produto_id = pr.id
GROUP BY pr.id, pr.nome
ORDER BY total_vendido DESC
LIMIT 5;

-- 1.5 Clientes que compraram no último mês
SELECT DISTINCT c.nome, c.email
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

-- 1.6 Ticket médio por cliente
SELECT c.nome, AVG(p.valor_total) AS ticket_medio
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome;

-- 1.7 Produtos sem estoque
SELECT nome, estoque FROM produtos WHERE estoque = 0;

-- 1.8 Vendas por categoria
SELECT cat.nome AS categoria, SUM(ip.quantidade * ip.preco_unitario) AS total_vendas
FROM itens_pedido ip
JOIN produtos pr ON ip.produto_id = pr.id
JOIN categorias cat ON pr.categoria_id = cat.id
GROUP BY cat.id, cat.nome
ORDER BY total_vendas DESC;

-- 1.9 Clientes inativos (sem pedidos nos últimos 6 meses)
SELECT c.nome, c.email
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id AND p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
WHERE p.id IS NULL;

-- 1.10 Relatório completo de vendas
SELECT p.id AS pedido_id, c.nome AS cliente, p.data_pedido, p.valor_total,
       pr.nome AS produto, ip.quantidade, ip.preco_unitario
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
JOIN itens_pedido ip ON p.id = ip.pedido_id
JOIN produtos pr ON ip.produto_id = pr.id
ORDER BY p.data_pedido DESC;