-- Referências: IA, w3schools, stack overflow
-- Bloco 2: Stored Procedures

DELIMITER //

-- 2.1 Procedure para inserir cliente
CREATE PROCEDURE sp_inserir_cliente(
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefone VARCHAR(20),
    IN p_endereco TEXT
)
BEGIN
    INSERT INTO clientes (nome, email, telefone, endereco, data_cadastro)
    VALUES (p_nome, p_email, p_telefone, p_endereco, CURDATE());
    SELECT LAST_INSERT_ID() AS cliente_id;
END //

-- 2.2 Procedure para inserir pedido
CREATE PROCEDURE sp_inserir_pedido(
    IN p_cliente_id INT,
    IN p_itens JSON,
    OUT p_pedido_id INT
)
BEGIN
    DECLARE v_valor_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_item_count INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_produto_id INT;
    DECLARE v_quantidade INT;
    DECLARE v_preco DECIMAL(10,2);

    INSERT INTO pedidos (cliente_id, data_pedido, valor_total, status)
    VALUES (p_cliente_id, CURDATE(), 0, 'pendente');
    SET p_pedido_id = LAST_INSERT_ID();

    SET v_item_count = JSON_LENGTH(p_itens);
    WHILE v_i < v_item_count DO
        SET v_produto_id = JSON_EXTRACT(p_itens, CONCAT('$[', v_i, '].produto_id'));
        SET v_quantidade = JSON_EXTRACT(p_itens, CONCAT('$[', v_i, '].quantidade'));
        SET v_preco = (SELECT preco FROM produtos WHERE id = v_produto_id);

        INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
        VALUES (p_pedido_id, v_produto_id, v_quantidade, v_preco);

        SET v_valor_total = v_valor_total + (v_quantidade * v_preco);
        SET v_i = v_i + 1;
    END WHILE;

    UPDATE pedidos SET valor_total = v_valor_total WHERE id = p_pedido_id;
END //

-- 2.3 Procedure para atualizar estoque
CREATE PROCEDURE sp_atualizar_estoque(
    IN p_produto_id INT,
    IN p_quantidade INT,
    IN p_tipo ENUM('entrada', 'saida')
)
BEGIN
    DECLARE v_estoque_atual INT;

    SELECT estoque INTO v_estoque_atual FROM produtos WHERE id = p_produto_id;

    IF p_tipo = 'entrada' THEN
        UPDATE produtos SET estoque = estoque + p_quantidade WHERE id = p_produto_id;
    ELSEIF p_tipo = 'saida' THEN
        IF v_estoque_atual >= p_quantidade THEN
            UPDATE produtos SET estoque = estoque - p_quantidade WHERE id = p_produto_id;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente';
        END IF;
    END IF;
END //

-- 2.4 Procedure para relatório de vendas por período
CREATE PROCEDURE sp_relatorio_vendas_periodo(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT
        p.id AS pedido_id,
        p.data_pedido,
        c.nome AS cliente,
        c.email,
        p.valor_total,
        p.status
    FROM pedidos p
    JOIN clientes c ON p.cliente_id = c.id
    WHERE p.data_pedido BETWEEN p_data_inicio AND p_data_fim
    ORDER BY p.data_pedido DESC;
END //

-- 2.5 Procedure para cancelar pedido e restaurar estoque
CREATE PROCEDURE sp_cancelar_pedido(
    IN p_pedido_id INT
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_produto_id INT;
    DECLARE v_quantidade INT;

    DECLARE cur CURSOR FOR
        SELECT produto_id, quantidade FROM itens_pedido WHERE pedido_id = p_pedido_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT status INTO v_status FROM pedidos WHERE id = p_pedido_id;

    IF v_status = 'cancelado' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido já cancelado';
    END IF;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_produto_id, v_quantidade;
        IF done THEN LEAVE read_loop; END IF;
        UPDATE produtos SET estoque = estoque + v_quantidade WHERE id = v_produto_id;
    END LOOP;
    CLOSE cur;

    UPDATE pedidos SET status = 'cancelado' WHERE id = p_pedido_id;
END //

-- 2.6 Procedure para calcular comissão de vendedor
CREATE PROCEDURE sp_calcular_comissao(
    IN p_vendedor_id INT,
    IN p_data_inicio DATE,
    IN p_data_fim DATE,
    OUT p_comissao_total DECIMAL(10,2)
)
BEGIN
    SELECT COALESCE(SUM(p.valor_total * 0.05), 0) INTO p_comissao_total
    FROM pedidos p
    WHERE p.vendedor_id = p_vendedor_id
    AND p.data_pedido BETWEEN p_data_inicio AND p_data_fim
    AND p.status = 'entregue';
END //

-- 2.7 Procedure para buscar cliente por documento
CREATE PROCEDURE sp_buscar_cliente_documento(
    IN p_documento VARCHAR(20)
)
BEGIN
    SELECT * FROM clientes WHERE cpf_cnpj = p_documento OR rg = p_documento;
END //

-- 2.8 Procedure para listar produtos com estoque baixo
CREATE PROCEDURE sp_produtos_estoque_baixo(
    IN p_limite INT
)
BEGIN
    SELECT id, nome, estoque, preco
    FROM produtos
    WHERE estoque <= p_limite
    ORDER BY estoque ASC;
END //

DELIMITER ;