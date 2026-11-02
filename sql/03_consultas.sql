-- ============================================================
-- PROJETO: SISTEMA EMPRESARIAL COM POSTGRESQL
-- ARQUIVO: 03_consultas.sql
-- OBJETIVO: CONSULTAS SQL PARA RELATORIOS E ANALISES
-- Execute no banco empresa_teste, apos 01_schema.sql e
-- 02_dados_exemplo.sql. Todas as instrucoes sao de leitura.
-- ============================================================

-- 01. DETALHES DE CADA ITEM VENDIDO (INNER JOIN)
SELECT
    p.id_pedido,
    c.nome AS cliente,
    pr.nome AS produto,
    i.quantidade,
    i.preco_unitario,
    i.quantidade * i.preco_unitario AS subtotal,
    p.status
FROM pedidos p
INNER JOIN clientes c ON c.id_cliente = p.id_cliente
INNER JOIN itens_pedido i ON i.id_pedido = p.id_pedido
INNER JOIN produtos pr ON pr.id_produto = i.id_produto
ORDER BY p.id_pedido, pr.nome;

-- 02. QUANTIDADE DE PEDIDOS POR CLIENTE, INCLUSIVE ZERO (LEFT JOIN)
SELECT
    c.id_cliente,
    c.nome AS cliente,
    COUNT(p.id_pedido) AS quantidade_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY quantidade_pedidos DESC, c.nome;

-- 03. QUANTIDADE E VALOR DOS PEDIDOS POR STATUS (AGREGACAO)
-- O valor de pedidos pendentes nao e faturamento recebido.
SELECT
    p.status,
    COUNT(DISTINCT p.id_pedido) AS quantidade_pedidos,
    COALESCE(SUM(i.quantidade * i.preco_unitario), 0) AS valor_pedidos
FROM pedidos p
LEFT JOIN itens_pedido i ON i.id_pedido = p.id_pedido
GROUP BY p.status
ORDER BY p.status;

-- 04. GASTO POR CLIENTE EM PEDIDOS CONFIRMADOS (CTE)
WITH pedidos_confirmados AS (
    SELECT
        p.id_pedido,
        p.id_cliente,
        SUM(i.quantidade * i.preco_unitario) AS total_pedido
    FROM pedidos p
    INNER JOIN itens_pedido i ON i.id_pedido = p.id_pedido
    WHERE p.status IN ('PAGO', 'ENVIADO')
    GROUP BY p.id_pedido, p.id_cliente
)
SELECT
    c.nome AS cliente,
    COUNT(pc.id_pedido) AS pedidos_confirmados,
    SUM(pc.total_pedido) AS total_confirmado
FROM pedidos_confirmados pc
INNER JOIN clientes c ON c.id_cliente = pc.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY total_confirmado DESC, c.nome;

-- 05. FUNCIONARIOS COM SALARIO ACIMA DA MEDIA (SUBCONSULTA)
SELECT
    f.nome,
    f.cargo,
    f.salario
FROM funcionarios f
WHERE f.salario > (
    SELECT AVG(salario)
    FROM funcionarios
)
ORDER BY f.salario DESC;

-- 06. CLASSIFICACAO SALARIAL POR DEPARTAMENTO (ROW_NUMBER)
SELECT
    d.nome AS departamento,
    f.nome AS funcionario,
    f.salario,
    ROW_NUMBER() OVER (
        PARTITION BY f.id_departamento
        ORDER BY f.salario DESC, f.id_funcionario
    ) AS posicao_departamento
FROM funcionarios f
INNER JOIN departamentos d ON d.id_departamento = f.id_departamento
ORDER BY d.nome, posicao_departamento;

-- 07. RANKING DE PRODUTOS EM PEDIDOS CONFIRMADOS (DENSE_RANK)
WITH vendas_produto AS (
    SELECT
        pr.id_produto,
        pr.nome AS produto,
        SUM(i.quantidade) AS unidades,
        SUM(i.quantidade * i.preco_unitario) AS valor_confirmado
    FROM produtos pr
    INNER JOIN itens_pedido i ON i.id_produto = pr.id_produto
    INNER JOIN pedidos p ON p.id_pedido = i.id_pedido
    WHERE p.status IN ('PAGO', 'ENVIADO')
    GROUP BY pr.id_produto, pr.nome
)
SELECT
    produto,
    unidades,
    valor_confirmado,
    DENSE_RANK() OVER (ORDER BY valor_confirmado DESC) AS posicao
FROM vendas_produto
ORDER BY posicao, produto;

-- 08. COMPARACAO COM O PEDIDO CONFIRMADO ANTERIOR (LAG)
WITH totais_pedidos AS (
    SELECT
        p.id_pedido,
        p.data_pedido,
        SUM(i.quantidade * i.preco_unitario) AS valor_pedido
    FROM pedidos p
    INNER JOIN itens_pedido i ON i.id_pedido = p.id_pedido
    WHERE p.status IN ('PAGO', 'ENVIADO')
    GROUP BY p.id_pedido, p.data_pedido
),
comparacao AS (
    SELECT
        id_pedido,
        data_pedido,
        valor_pedido,
        LAG(valor_pedido) OVER (
            ORDER BY data_pedido, id_pedido
        ) AS valor_pedido_anterior
    FROM totais_pedidos
)
SELECT
    id_pedido,
    data_pedido,
    valor_pedido,
    valor_pedido_anterior,
    valor_pedido - valor_pedido_anterior AS diferenca
FROM comparacao
ORDER BY data_pedido, id_pedido;

-- 09. RELATORIO DE ESTOQUE E VALOR IMOBILIZADO (CASE)
-- Limite de 20 unidades escolhido somente para demonstracao.
SELECT
    sku,
    nome AS produto,
    estoque,
    preco,
    estoque * preco AS valor_estimado_estoque,
    CASE
        WHEN estoque <= 20 THEN 'ATENCAO'
        ELSE 'OK'
    END AS situacao_estoque
FROM produtos
ORDER BY estoque ASC, nome;
