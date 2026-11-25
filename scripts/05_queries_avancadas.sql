-- Referências: IA, w3schools, stack overflow
-- Bloco 5: Consultas Avançadas

-- 5.1 Ranking de clientes por frequência de compra (NTILE)
SELECT
    c.nome,
    COUNT(p.id) AS total_pedidos,
    NTILE(4) OVER (ORDER BY COUNT(p.id) DESC) AS quartil_frequencia
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.status = 'entregue'
GROUP BY c.id, c.nome;

-- 5.2 Vendas acumuladas por mês (Window Function)
SELECT
    YEAR(data_pedido) AS ano,
    MONTH(data_pedido) AS mes,
    SUM(valor_total) AS faturamento_mes,
    SUM(SUM(valor_total)) OVER (ORDER BY YEAR(data_pedido), MONTH(data_pedido)) AS faturamento_acumulado
FROM pedidos
WHERE status = 'entregue'
GROUP BY YEAR(data_pedido), MONTH(data_pedido);

-- 5.3 Produtos nunca vendidos (NOT EXISTS)
SELECT p.nome, p.estoque, p.preco
FROM produtos p
WHERE NOT EXISTS (
    SELECT 1 FROM itens_pedido ip WHERE ip.produto_id = p.id
);

-- 5.4 Clientes com maior ticket médio (Subquery correlacionada)
SELECT c.nome, c.email,
    (SELECT AVG(valor_total) FROM pedidos p WHERE p.cliente_id = c.id AND p.status = 'entregue') AS ticket_medio
FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id AND p.status = 'entregue')
ORDER BY ticket_medio DESC
LIMIT 10;

-- 5.5 Análise de cohort (primeira compra por mês)
WITH primeira_compra AS (
    SELECT
        cliente_id,
        MIN(data_pedido) AS primeira_data
    FROM pedidos
    WHERE status = 'entregue'
    GROUP BY cliente_id
),
cohort_mensal AS (
    SELECT
        DATE_FORMAT(primeira_data, '%Y-%m') AS cohort_mes,
        cliente_id
    FROM primeira_compra
)
SELECT
    cm.cohort_mes,
    COUNT(DISTINCT cm.cliente_id) AS total_clientes,
    COUNT(DISTINCT CASE WHEN p.data_pedido >= cm.primeira_data AND p.data_pedido < DATE_ADD(cm.primeira_data, INTERVAL 1 MONTH) THEN p.cliente_id END) AS retencao_mes_1,
    COUNT(DISTINCT CASE WHEN p.data_pedido >= cm.primeira_data AND p.data_pedido < DATE_ADD(cm.primeira_data, INTERVAL 2 MONTH) THEN p.cliente_id END) AS retencao_mes_2
FROM cohort_mensal cm
LEFT JOIN pedidos p ON cm.cliente_id = p.cliente_id AND p.status = 'entregue'
GROUP BY cm.cohort_mes
ORDER BY cm.cohort_mes;

-- 5.6 Produtos com maior variação de preço (CASE WHEN)
SELECT
    pr.nome,
    MIN(ip.preco_unitario) AS preco_min,
    MAX(ip.preco_unitario) AS preco_max,
    MAX(ip.preco_unitario) - MIN(ip.preco_unitario) AS variacao,
    CASE
        WHEN MAX(ip.preco_unitario) - MIN(ip.preco_unitario) > 50 THEN 'Alta'
        WHEN MAX(ip.preco_unitario) - MIN(ip.preco_unitario) > 20 THEN 'Media'
        ELSE 'Baixa'
    END AS classificacao_variacao
FROM itens_pedido ip
JOIN produtos pr ON ip.produto_id = pr.id
GROUP BY pr.id, pr.nome
HAVING COUNT(DISTINCT ip.preco_unitario) > 1
ORDER BY variacao DESC;

-- 5.7 Top 3 produtos por categoria (ROW_NUMBER)
WITH ranked AS (
    SELECT
        cat.nome AS categoria,
        pr.nome AS produto,
        SUM(ip.quantidade) AS total_vendido,
        ROW_NUMBER() OVER (PARTITION BY cat.id ORDER BY SUM(ip.quantidade) DESC) AS rn
    FROM itens_pedido ip
    JOIN produtos pr ON ip.produto_id = pr.id
    JOIN categorias cat ON pr.categoria_id = cat.id
    JOIN pedidos p ON ip.pedido_id = p.id
    WHERE p.status = 'entregue'
    GROUP BY cat.id, cat.nome, pr.id, pr.nome
)
SELECT categoria, produto, total_vendido
FROM ranked
WHERE rn <= 3
ORDER BY categoria, total_vendido DESC;

-- 5.8 Detecção de clientes inativos (LAG)
WITH ultimas_compras AS (
    SELECT
        c.id,
        c.nome,
        p.data_pedido,
        LAG(p.data_pedido) OVER (PARTITION BY c.id ORDER BY p.data_pedido) AS compra_anterior
    FROM clientes c
    JOIN pedidos p ON c.id = p.cliente_id
    WHERE p.status = 'entregue'
)
SELECT
    id,
    nome,
    data_pedido AS ultima_compra,
    compra_anterior,
    DATEDIFF(data_pedido, compra_anterior) AS intervalo_dias
FROM ultimas_compras
WHERE compra_anterior IS NOT NULL
AND DATEDIFF(data_pedido, compra_anterior) > 60
ORDER BY intervalo_dias DESC;

-- 5.9 Análise ABC de produtos (Pareto)
WITH vendas_produto AS (
    SELECT
        pr.id,
        pr.nome,
        SUM(ip.quantidade * ip.preco_unitario) AS receita
    FROM itens_pedido ip
    JOIN produtos pr ON ip.produto_id = pr.id
    JOIN pedidos p ON ip.pedido_id = p.id
    WHERE p.status = 'entregue'
    GROUP BY pr.id, pr.nome
),
receita_acumulada AS (
    SELECT
        id,
        nome,
        receita,
        SUM(receita) OVER (ORDER BY receita DESC) AS receita_acum,
        SUM(receita) OVER () AS receita_total
    FROM vendas_produto
)
SELECT
    id,
    nome,
    receita,
    ROUND((receita_acum / receita_total) * 100, 2) AS perc_acumulado,
    CASE
        WHEN (receita_acum / receita_total) <= 0.8 THEN 'A'
        WHEN (receita_acum / receita_total) <= 0.95 THEN 'B'
        ELSE 'C'
    END AS classificacao_abc
FROM receita_acumulada
ORDER BY receita DESC;

-- 5.10 Comparativo ano a ano (PIVOT simulado)
SELECT
    cat.nome AS categoria,
    SUM(CASE WHEN YEAR(p.data_pedido) = YEAR(CURDATE()) - 1 THEN ip.quantidade * ip.preco_unitario ELSE 0 END) AS ano_anterior,
    SUM(CASE WHEN YEAR(p.data_pedido) = YEAR(CURDATE()) THEN ip.quantidade * ip.preco_unitario ELSE 0 END) AS ano_atual,
    ROUND(
        (SUM(CASE WHEN YEAR(p.data_pedido) = YEAR(CURDATE()) THEN ip.quantidade * ip.preco_unitario ELSE 0 END) -
         SUM(CASE WHEN YEAR(p.data_pedido) = YEAR(CURDATE()) - 1 THEN ip.quantidade * ip.preco_unitario ELSE 0 END)) /
        NULLIF(SUM(CASE WHEN YEAR(p.data_pedido) = YEAR(CURDATE()) - 1 THEN ip.quantidade * ip.preco_unitario ELSE 0 END), 0) * 100, 2
    ) AS crescimento_pct
FROM itens_pedido ip
JOIN produtos pr ON ip.produto_id = pr.id
JOIN categorias cat ON pr.categoria_id = cat.id
JOIN pedidos p ON ip.pedido_id = p.id
WHERE p.status = 'entregue'
AND YEAR(p.data_pedido) IN (YEAR(CURDATE()) - 1, YEAR(CURDATE()))
GROUP BY cat.id, cat.nome
ORDER BY crescimento_pct DESC;