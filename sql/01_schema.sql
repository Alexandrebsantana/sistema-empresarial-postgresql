--
-- PostgreSQL database dump
--

\restrict aK4Vs9eKYsHRMxcH89omIYP70jqUvSFBWFgn8EJDCpZS5GOg5ozSebaKOvuWzYH

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-10-25 18:39:56

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 233 (class 1255 OID 16533)
-- Name: atualizar_status_pedido(integer, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.atualizar_status_pedido(IN p_id_pedido integer, IN p_novo_status character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_status_atual VARCHAR(20);
BEGIN

    IF p_novo_status IS NULL OR
       p_novo_status NOT IN (
           'PENDENTE', 'PAGO', 'ENVIADO', 'CANCELADO'
       ) THEN
        RAISE EXCEPTION 'Status inválido: %', p_novo_status;
    END IF;

    SELECT status
    INTO v_status_atual
    FROM pedidos
    WHERE id_pedido = p_id_pedido
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não encontrado', p_id_pedido;
    END IF;

    IF v_status_atual = p_novo_status THEN
        RETURN;
    END IF;

    IF NOT (
        (v_status_atual = 'PENDENTE'
         AND p_novo_status IN ('PAGO', 'CANCELADO'))
        OR
        (v_status_atual = 'PAGO'
         AND p_novo_status = 'ENVIADO')
    ) THEN
        RAISE EXCEPTION
            'Transição inválida: % para %',
            v_status_atual, p_novo_status;
    END IF;

    UPDATE pedidos
    SET status = p_novo_status
    WHERE id_pedido = p_id_pedido;

END;
$$;


--
-- TOC entry 232 (class 1255 OID 16532)
-- Name: calcular_total_pedido(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calcular_total_pedido(p_id_pedido integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_total NUMERIC(12,2);
BEGIN		

	IF NOT EXISTS (
	SELECT 1
	FROM pedidos
	WHERE id_pedido = p_id_pedido
	) THEN
		RAISE EXCEPTION 'Pedido % não encontrado', p_id_pedido;
		END IF;

		SELECT COALESCE(
SUM(quantidade * preco_unitario), 0
)
INTO v_total
FROM itens_pedido
WHERE id_pedido = p_id_pedido;
		
		
	RETURN v_total;
	
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16422)
-- Name: clientes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clientes (
    id_cliente integer NOT NULL,
    nome character varying(150) NOT NULL,
    email character varying(150) NOT NULL,
    telefone character varying(20),
    data_cadastro date DEFAULT CURRENT_DATE NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 16421)
-- Name: clientes_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.clientes ALTER COLUMN id_cliente ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.clientes_id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 16390)
-- Name: departamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departamentos (
    id_departamento integer NOT NULL,
    nome character varying(100) NOT NULL,
    localizacao character varying(100) NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 16389)
-- Name: departamentos_id_departamento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.departamentos ALTER COLUMN id_departamento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.departamentos_id_departamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 16401)
-- Name: funcionarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funcionarios (
    id_funcionario integer NOT NULL,
    nome character varying(150) NOT NULL,
    email character varying(150) NOT NULL,
    cargo character varying(100) NOT NULL,
    salario numeric(10,2) NOT NULL,
    data_admissao date NOT NULL,
    id_departamento integer NOT NULL,
    CONSTRAINT funcionarios_salario_check CHECK ((salario >= (0)::numeric))
);


--
-- TOC entry 221 (class 1259 OID 16400)
-- Name: funcionarios_id_funcionario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.funcionarios ALTER COLUMN id_funcionario ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.funcionarios_id_funcionario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 16500)
-- Name: itens_pedido; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.itens_pedido (
    id_item integer NOT NULL,
    id_pedido integer NOT NULL,
    id_produto integer NOT NULL,
    quantidade integer NOT NULL,
    preco_unitario numeric(10,2) NOT NULL,
    CONSTRAINT itens_pedido_preco_unitario_check CHECK ((preco_unitario >= (0)::numeric)),
    CONSTRAINT itens_pedido_quantidade_check CHECK ((quantidade > 0))
);


--
-- TOC entry 229 (class 1259 OID 16499)
-- Name: itens_pedido_id_item_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.itens_pedido ALTER COLUMN id_item ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.itens_pedido_id_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 16462)
-- Name: pedidos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pedidos (
    id_pedido integer NOT NULL,
    id_cliente integer NOT NULL,
    data_pedido timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status character varying(20) DEFAULT 'PENDENTE'::character varying NOT NULL,
    CONSTRAINT chk_status_pedido CHECK (((status)::text = ANY ((ARRAY['PENDENTE'::character varying, 'PAGO'::character varying, 'ENVIADO'::character varying, 'CANCELADO'::character varying])::text[])))
);


--
-- TOC entry 227 (class 1259 OID 16461)
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.pedidos ALTER COLUMN id_pedido ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pedidos_id_pedido_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 16442)
-- Name: produtos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.produtos (
    id_produto integer NOT NULL,
    sku character varying(30) NOT NULL,
    descricao text,
    preco numeric(10,2) NOT NULL,
    estoque integer DEFAULT 0 NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    nome character varying(150) NOT NULL,
    CONSTRAINT produtos_estoque_check CHECK ((estoque >= 0)),
    CONSTRAINT produtos_preco_check CHECK ((preco >= (0)::numeric))
);


--
-- TOC entry 225 (class 1259 OID 16441)
-- Name: produtos_id_produto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.produtos ALTER COLUMN id_produto ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.produtos_id_produto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 16524)
-- Name: vw_resumo_pedidos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_resumo_pedidos AS
 SELECT p.id_pedido,
    c.nome AS cliente,
    p.data_pedido,
    p.status,
    COALESCE(sum(((i.quantidade)::numeric * i.preco_unitario)), (0)::numeric) AS valor_total
   FROM ((public.pedidos p
     JOIN public.clientes c ON ((p.id_cliente = c.id_cliente)))
     LEFT JOIN public.itens_pedido i ON ((p.id_pedido = i.id_pedido)))
  GROUP BY p.id_pedido, c.nome, p.data_pedido, p.status;


--
-- TOC entry 4907 (class 2606 OID 16433)
-- Name: clientes clientes_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_email_key UNIQUE (email);


--
-- TOC entry 4909 (class 2606 OID 16431)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 4899 (class 2606 OID 16399)
-- Name: departamentos departamentos_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_nome_key UNIQUE (nome);


--
-- TOC entry 4901 (class 2606 OID 16397)
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id_departamento);


--
-- TOC entry 4903 (class 2606 OID 16415)
-- Name: funcionarios funcionarios_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_email_key UNIQUE (email);


--
-- TOC entry 4905 (class 2606 OID 16413)
-- Name: funcionarios funcionarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_pkey PRIMARY KEY (id_funcionario);


--
-- TOC entry 4920 (class 2606 OID 16511)
-- Name: itens_pedido itens_pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT itens_pedido_pkey PRIMARY KEY (id_item);


--
-- TOC entry 4916 (class 2606 OID 16473)
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id_pedido);


--
-- TOC entry 4911 (class 2606 OID 16457)
-- Name: produtos produtos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_pkey PRIMARY KEY (id_produto);


--
-- TOC entry 4913 (class 2606 OID 16459)
-- Name: produtos produtos_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_sku_key UNIQUE (sku);


--
-- TOC entry 4922 (class 2606 OID 16513)
-- Name: itens_pedido uq_pedido_produto; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT uq_pedido_produto UNIQUE (id_pedido, id_produto);


--
-- TOC entry 4917 (class 1259 OID 16530)
-- Name: idx_itens_pedido; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_itens_pedido ON public.itens_pedido USING btree (id_pedido);


--
-- TOC entry 4918 (class 1259 OID 16531)
-- Name: idx_itens_produto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_itens_produto ON public.itens_pedido USING btree (id_produto);


--
-- TOC entry 4914 (class 1259 OID 16529)
-- Name: idx_pedidos_cliente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pedidos_cliente ON public.pedidos USING btree (id_cliente);


--
-- TOC entry 4923 (class 2606 OID 16416)
-- Name: funcionarios fk_funcionarios_departamento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT fk_funcionarios_departamento FOREIGN KEY (id_departamento) REFERENCES public.departamentos(id_departamento);


--
-- TOC entry 4925 (class 2606 OID 16514)
-- Name: itens_pedido fk_item_pedido; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido) REFERENCES public.pedidos(id_pedido);


--
-- TOC entry 4926 (class 2606 OID 16519)
-- Name: itens_pedido fk_item_produto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) REFERENCES public.produtos(id_produto);


--
-- TOC entry 4924 (class 2606 OID 16474)
-- Name: pedidos fk_pedido_cliente; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


-- Completed on 2026-10-25 18:39:56

--
-- PostgreSQL database dump complete
--

\unrestrict aK4Vs9eKYsHRMxcH89omIYP70jqUvSFBWFgn8EJDCpZS5GOg5ozSebaKOvuWzYH

