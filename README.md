# Sistema Empresarial com PostgreSQL

Projeto de banco de dados relacional desenvolvido em PostgreSQL com foco em modelagem de dados, integridade referencial, consultas SQL, transações, views, índices, funções e procedures.

## Objetivo

Este projeto simula um sistema empresarial com controle de:

- departamentos
- funcionários
- clientes
- produtos
- pedidos
- itens de pedido

O objetivo é demonstrar conhecimentos práticos em banco de dados relacional, sendo um projeto de portfólio voltado para áreas como Dados, Engenharia de Dados e Desenvolvimento Backend.

## Tecnologias utilizadas

- PostgreSQL
- pgAdmin 4
- SQL
- PL/pgSQL

## Estrutura do banco

O banco possui as seguintes tabelas:

- `departamentos`
- `funcionarios`
- `clientes`
- `produtos`
- `pedidos`
- `itens_pedido`

## Relacionamentos

- Um departamento pode ter vários funcionários
- Um cliente pode ter vários pedidos
- Um pedido pode ter vários itens
- Um produto pode aparecer em vários itens de pedido

## Recursos implementados

- Criação de tabelas com chaves primárias e estrangeiras
- Restrições `NOT NULL`, `UNIQUE` e `CHECK`
- Inserção e consulta de dados
- `INNER JOIN` e `LEFT JOIN`
- Agregações com `SUM()` e `COUNT()`
- Controle de estoque com transações
- View para resumo de pedidos
- Índices para otimização de consultas
- Function para cálculo do total do pedido
- Procedure para atualização de status do pedido

## View criada

- `vw_resumo_pedidos`

## Function criada

- `calcular_total_pedido(integer)`

## Procedure criada

- `atualizar_status_pedido(integer, varchar)`

## Diagrama do projeto

O diagrama entidade-relacionamento está disponível em:

`docs/diagrama_er.png`

## Como executar o projeto

1. Instale o PostgreSQL e o pgAdmin 4
2. Crie um banco de dados vazio
3. Execute o script `sql/01_schema.sql`
4. Utilize o banco para testes e consultas

## Autor

Alexandre Barros Santana  
[LinkedIn](https://www.linkedin.com/in/alexandre-barros-santana/)  
[GitHub](https://github.com/Alexandrebsantana)