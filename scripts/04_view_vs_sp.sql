-- Referências: IA, w3schools, stack overflow
-- Bloco 4: View vs Stored Procedure - 5 Cenários

-- CENÁRIO 1: Relatório de vendas mensal (apenas leitura, dados agregados)
-- DECISÃO: VIEW
-- JUSTIFICATIVA: Consulta somente leitura, dados pré-agregados, reutilizável em múltiplas consultas
CREATE VIEW vw_vendas_mensal AS
SELECT
    YEAR(data_pedido) AS ano,
    MONTH(data_pedido) AS mes,
    COUNT(*) AS qtd_pedidos,
    SUM(valor_total) AS faturamento
FROM pedidos
WHERE status = 'entregue'
GROUP BY YEAR(data_pedido), MONTH(data_pedido);

-- CENÁRIO 2: Processar novo pedido com validação de estoque e transação
-- DECISÃO: STORED PROCEDURE
-- JUSTIFICATIVA: Envolve lógica de negócio complexa, transação, validações, efeitos colaterais (atualiza estoque)
CREATE PROCEDURE sp_processar_pedido(
    IN p_cliente_id INT,
    IN p_itens JSON,
    OUT p_pedido_id INT,
    OUT p_sucesso BOOLEAN,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Erro ao processar pedido';
    END;

    START TRANSACTION;
    -- Lógica de inserção e validação de estoque
    INSERT INTO pedidos (cliente_id, data_pedido, valor_total, status)
    VALUES (p_cliente_id, CURDATE(), 0, 'processando');
    SET p_pedido_id = LAST_INSERT_ID();
    -- Processar itens e validar estoque...
    COMMIT;
    SET p_sucesso = TRUE;
    SET p_mensagem = 'Pedido processado com sucesso';
END;

-- CENÁRIO 3: Lista de produtos ativos com categoria (consulta frequente de catálogo)
-- DECISÃO: VIEW
-- JUSTIFICATIVA: Consulta simples de leitura, junta tabelas, usado como base para outras queries
CREATE VIEW vw_catalogo_produtos AS
SELECT
    p.id,
    p.nome,
    p.preco,
    p.estoque,
    cat.nome AS categoria
FROM produtos p
JOIN categorias cat ON p.categoria_id = cat.id
WHERE p.ativo = TRUE AND p.estoque > 0;

-- CENÁRIO 4: Calcular comissão mensal de vendedores com regras complexas
-- DECISÃO: STORED PROCEDURE
-- JUSTIFICATIVA: Lógica complexa com múltiplas regras (faixas de comissão, bônus, penalidades), parâmetros de entrada, saída de valores calculados
CREATE PROCEDURE sp_calcular_comissao_mensal(
    IN p_mes INT,
    IN p_ano INT,
    IN p_vendedor_id INT
)
BEGIN
    DECLARE v_faturamento DECIMAL(10,2);
    DECLARE v_comissao DECIMAL(10,2);
    DECLARE v_bonus DECIMAL(10,2) DEFAULT 0;

    SELECT COALESCE(SUM(valor_total), 0) INTO v_faturamento
    FROM pedidos
    WHERE vendedor_id = p_vendedor_id
    AND MONTH(data_pedido) = p_mes
    AND YEAR(data_pedido) = p_ano
    AND status = 'entregue';

    IF v_faturamento > 50000 THEN
        SET v_comissao = v_faturamento * 0.08;
        SET v_bonus = 1000;
    ELSEIF v_faturamento > 20000 THEN
        SET v_comissao = v_faturamento * 0.06;
    ELSE
        SET v_comissao = v_faturamento * 0.04;
    END IF;

    INSERT INTO comissoes (vendedor_id, mes, ano, faturamento, comissao, bonus, data_calculo)
    VALUES (p_vendedor_id, p_mes, p_ano, v_faturamento, v_comissao, v_bonus, CURDATE());

    SELECT v_faturamento, v_comissao, v_bonus, (v_comissao + v_bonus) AS total;
END;

-- CENÁRIO 5: Dashboard de clientes VIP (filtro dinâmico, apenas leitura)
-- DECISÃO: VIEW
-- JUSTIFICATIVA: Agregação de dados para exibição, filtros aplicados na query externa, performance com índice
CREATE VIEW vw_clientes_vip AS
SELECT
    c.id,
    c.nome,
    c.email,
    COUNT(p.id) AS total_pedidos,
    SUM(p.valor_total) AS lifetime_value,
    AVG(p.valor_total) AS ticket_medio,
    MAX(p.data_pedido) AS ultima_compra,
    DATEDIFF(CURDATE(), MAX(p.data_pedido)) AS dias_sem_comprar
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.status = 'entregue'
GROUP BY c.id, c.nome, c.email
HAVING SUM(p.valor_total) > 10000;

-- Exemplo de uso da view com filtro dinâmico:
-- SELECT * FROM vw_clientes_vip WHERE dias_sem_comprar <= 30 ORDER BY lifetime_value DESC;