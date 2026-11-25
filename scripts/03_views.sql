-- Referências: IA, w3schools, stack overflow
-- Bloco 3: Views

-- 3.1 View: Resumo de clientes
CREATE VIEW vw_resumo_clientes AS
SELECT
    c.id,
    c.nome,
    c.email,
    c.telefone,
    COUNT(p.id) AS total_pedidos,
    COALESCE(SUM(p.valor_total), 0) AS total_gasto,
    MAX(p.data_pedido) AS ultima_compra
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome, c.email, c.telefone;

-- 3.2 View: Produtos com informações de categoria
CREATE VIEW vw_produtos_completos AS
SELECT
    p.id,
    p.nome,
    p.descricao,
    p.preco,
    p.estoque,
    cat.nome AS categoria,
    cat.descricao AS descricao_categoria
FROM produtos p
JOIN categorias cat ON p.categoria_id = cat.id;

-- 3.3 View: Detalhes de pedidos
CREATE VIEW vw_detalhes_pedidos AS
SELECT
    p.id AS pedido_id,
    p.data_pedido,
    p.valor_total,
    p.status,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    v.nome AS vendedor_nome
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
LEFT JOIN vendedores v ON p.vendedor_id = v.id;

-- 3.4 View: Itens de pedido com produto
CREATE VIEW vw_itens_pedido_completo AS
SELECT
    ip.pedido_id,
    ip.produto_id,
    pr.nome AS produto_nome,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS subtotal
FROM itens_pedido ip
JOIN produtos pr ON ip.produto_id = pr.id;

-- 3.5 View: Vendas por mês
CREATE VIEW vw_vendas_por_mes AS
SELECT
    YEAR(p.data_pedido) AS ano,
    MONTH(p.data_pedido) AS mes,
    COUNT(p.id) AS total_pedidos,
    SUM(p.valor_total) AS faturamento_total,
    AVG(p.valor_total) AS ticket_medio
FROM pedidos p
WHERE p.status = 'entregue'
GROUP BY YEAR(p.data_pedido), MONTH(p.data_pedido)
ORDER BY ano DESC, mes DESC;

-- 3.6 View: Top 10 clientes por valor
CREATE VIEW vw_top_clientes AS
SELECT
    c.id,
    c.nome,
    c.email,
    SUM(p.valor_total) AS total_compras,
    COUNT(p.id) AS qtd_pedidos
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.status = 'entregue'
GROUP BY c.id, c.nome, c.email
ORDER BY total_compras DESC
LIMIT 10;

-- 3.7 View: Produtos mais vendidos
CREATE VIEW vw_produtos_mais_vendidos AS
SELECT
    pr.id,
    pr.nome,
    SUM(ip.quantidade) AS total_vendido,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_total
FROM itens_pedido ip
JOIN produtos pr ON ip.produto_id = pr.id
JOIN pedidos p ON ip.pedido_id = p.id
WHERE p.status = 'entregue'
GROUP BY pr.id, pr.nome
ORDER BY total_vendido DESC;

-- 3.8 View: Estoque crítico
CREATE VIEW vw_estoque_critico AS
SELECT
    p.id,
    p.nome,
    p.estoque,
    p.preco,
    cat.nome AS categoria
FROM produtos p
JOIN categorias cat ON p.categoria_id = cat.id
WHERE p.estoque <= 5
ORDER BY p.estoque ASC;

-- 3.9 View: Performance de vendedores
CREATE VIEW vw_performance_vendedores AS
SELECT
    v.id,
    v.nome,
    COUNT(p.id) AS total_pedidos,
    SUM(p.valor_total) AS faturamento,
    AVG(p.valor_total) AS ticket_medio,
    SUM(p.valor_total * 0.05) AS comissao_estimada
FROM vendedores v
LEFT JOIN pedidos p ON v.id = p.vendedor_id AND p.status = 'entregue'
GROUP BY v.id, v.nome
ORDER BY faturamento DESC;

-- 3.10 View: Relatório completo de vendas
CREATE VIEW vw_relatorio_vendas_completo AS
SELECT
    p.id AS pedido_id,
    p.data_pedido,
    p.status,
    c.nome AS cliente,
    c.email AS cliente_email,
    v.nome AS vendedor,
    pr.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS subtotal
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
LEFT JOIN vendedores v ON p.vendedor_id = v.id
JOIN itens_pedido ip ON p.id = ip.pedido_id
JOIN produtos pr ON ip.produto_id = pr.id
ORDER BY p.data_pedido DESC;