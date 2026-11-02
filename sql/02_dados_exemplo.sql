-- =========================================
-- PROJETO: SISTEMA EMPRESARIAL POSTGRESQL
-- ARQUIVO: 02_dados_exemplo.sql
-- DESCRICAO: INSERCAO DE DADOS FICTICIOS
-- =========================================

BEGIN;

-- 1. DEPARTAMENTOS

INSERT INTO departamentos (nome, localizacao)
VALUES
('Tecnologia', 'São Paulo'),
('Financeiro', 'São Paulo'),
('Recursos Humanos', 'Campinas'),
('Comercial', 'Rio de Janeiro'),
('Logística', 'Curitiba');


-- 2. FUNCIONARIOS

INSERT INTO funcionarios
(nome, email, cargo, salario, data_admissao, id_departamento)

SELECT
    f.nome,
    f.email,
    f.cargo,
    f.salario,
    f.data_admissao,
    d.id_departamento
FROM (
    VALUES
    ('Ana Souza', 'ana@exemplo.com',
     'Analista de Dados', 5500.00,
     DATE '2025-03-10', 'Tecnologia'),

    ('Carlos Lima', 'carlos@exemplo.com',
     'Desenvolvedor Backend', 6200.00,
     DATE '2024-08-15', 'Tecnologia'),

    ('Mariana Costa', 'mariana@exemplo.com',
     'Analista Financeiro', 4800.00,
     DATE '2025-01-20', 'Financeiro'),

    ('Pedro Santos', 'pedro@exemplo.com',
     'Recrutador', 4200.00,
     DATE '2024-11-05', 'Recursos Humanos'),

    ('Juliana Ferreira', 'juliana@exemplo.com',
     'Executiva de Vendas', 5100.00,
     DATE '2025-06-02', 'Comercial')

) AS f(nome, email, cargo, salario, data_admissao, departamento)

INNER JOIN departamentos d
    ON f.departamento = d.nome;


-- 3. CLIENTES

INSERT INTO clientes (nome, email, telefone)
VALUES
('Lucas Almeida', 'lucas@example.com', '11987654321'),
('Fernanda Rocha', 'fernanda@example.com', '11976543210'),
('Ricardo Mendes', 'ricardo@example.com', '21998765432'),
('Beatriz Oliveira', 'beatriz@example.com', '31987654321'),
('Gabriel Martins', 'gabriel@example.com', '41976543210');


-- 4. PRODUTOS

INSERT INTO produtos
(sku, nome, descricao, preco, estoque)
VALUES
('NOTE001', 'Notebook Dell',
 'Notebook com 16GB RAM e SSD 512GB', 4500.00, 15),

('MOUSE001', 'Mouse Logitech',
 'Mouse sem fio', 150.00, 50),

('TECL001', 'Teclado Mecânico',
 'Teclado RGB ABNT2', 350.00, 25),

('MONI001', 'Monitor Samsung',
 'Monitor Full HD 24 polegadas', 900.00, 20),

('HEAD001', 'Headset Gamer',
 'Headset com microfone', 250.00, 30);


-- 5. PEDIDOS

INSERT INTO pedidos (id_cliente, status)

SELECT
    c.id_cliente,
    v.status
FROM (
    VALUES
    ('lucas@example.com', 'PENDENTE'),
    ('fernanda@example.com', 'PAGO'),
    ('ricardo@example.com', 'PAGO')
) AS v(email, status)

INNER JOIN clientes c
    ON c.email = v.email;


-- 6. ITENS DOS PEDIDOS

INSERT INTO itens_pedido
(id_pedido, id_produto, quantidade, preco_unitario)

SELECT
    p.id_pedido,
    pr.id_produto,
    v.quantidade,
    pr.preco
FROM (
    VALUES
    ('lucas@example.com', 'NOTE001', 1),
    ('lucas@example.com', 'MOUSE001', 2),
    ('fernanda@example.com', 'MONI001', 1),
    ('ricardo@example.com', 'TECL001', 1),
    ('ricardo@example.com', 'HEAD001', 1)

) AS v(email, sku, quantidade)

INNER JOIN clientes c
    ON c.email = v.email

INNER JOIN pedidos p
    ON p.id_cliente = c.id_cliente

INNER JOIN produtos pr
    ON pr.sku = v.sku;


COMMIT;