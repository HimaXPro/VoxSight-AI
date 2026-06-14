--
-- PostgreSQL database dump
--

\restrict M3WqnThmCRngDfJLIgL6ymWk4nb3YfZrc7iaBlCsUvh17gozGbax6IVhghMXOlJ

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

-- Started on 2026-06-14 08:58:14

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16391)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    phone character varying(20),
    address character varying(255),
    device_id character varying(50),
    role character varying(30) DEFAULT 'Pendamping'::character varying NOT NULL,
    password character varying(255) NOT NULL,
    avatar_url character varying(255),
    email_verified boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16390)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4856 (class 2604 OID 16394)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5030 (class 0 OID 16391)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, full_name, email, phone, address, device_id, role, password, avatar_url, email_verified, is_active, created_at, updated_at) FROM stdin;
2	User VoxSight	user@voxsight.com	+62 813-0000-0000	Surabaya	\N	Pengguna (Netra)	$2a$10$BSKN7y4gO/gr9rS9dStIwe9VPo7Kbhu7vy/wuFCmJUkUDMys4zqY6	\N	t	t	2026-06-14 08:08:22.676+07	2026-06-14 08:08:22.676+07
3	Ibu Siti Rahmawati	siti.guru@slb-ypab.sch.id	+62 815-9876-5432	Jl. Raya Darmo No.55, Surabaya	\N	Guru	$2a$10$qNX6Ruj62UApxNDzBWCMDuq0EP1IUEEFYTgi1udcF7SnB24FXD7Ye	\N	t	t	2026-06-14 08:08:22.768+07	2026-06-14 08:08:22.768+07
4	Test Mahasiswa	test@mahasiswa.com	081234567890	\N	VS-TEST-001	Pendamping	$2a$10$Jzrv0fO5pCWMMWOjsH3cmOd4bxnLx68OuuH8Yp8ICT/C5L8nwI5Gm	\N	f	t	2026-06-14 08:09:14.191+07	2026-06-14 08:09:14.191+07
1	Ahmad Faruq Updated	ahmad.faruq@slb-ypab.sch.id	+62 812-9999-8888	Jl. Baru No.99, Surabaya	VS-2024-001X	Pendamping	$2a$10$tYtiEUCIgtmrRH24h0aTheX6BHxOaonMiFlT4zkdRcCMCx4SktMqS	\N	t	t	2026-06-14 08:08:22.548+07	2026-06-14 08:10:50.811+07
\.


--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- TOC entry 4861 (class 2606 OID 16617)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4863 (class 2606 OID 16619)
-- Name: users users_email_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key1 UNIQUE (email);


--
-- TOC entry 4865 (class 2606 OID 16615)
-- Name: users users_email_key2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key2 UNIQUE (email);


--
-- TOC entry 4867 (class 2606 OID 16621)
-- Name: users users_email_key3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key3 UNIQUE (email);


--
-- TOC entry 4869 (class 2606 OID 16623)
-- Name: users users_email_key4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key4 UNIQUE (email);


--
-- TOC entry 4871 (class 2606 OID 16625)
-- Name: users users_email_key5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key5 UNIQUE (email);


--
-- TOC entry 4873 (class 2606 OID 16627)
-- Name: users users_email_key6; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key6 UNIQUE (email);


--
-- TOC entry 4875 (class 2606 OID 16629)
-- Name: users users_email_key7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key7 UNIQUE (email);


--
-- TOC entry 4877 (class 2606 OID 16631)
-- Name: users users_email_key8; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key8 UNIQUE (email);


--
-- TOC entry 4879 (class 2606 OID 16633)
-- Name: users users_email_key9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key9 UNIQUE (email);


--
-- TOC entry 4881 (class 2606 OID 16408)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


-- Completed on 2026-06-14 08:58:14

--
-- PostgreSQL database dump complete
--

\unrestrict M3WqnThmCRngDfJLIgL6ymWk4nb3YfZrc7iaBlCsUvh17gozGbax6IVhghMXOlJ

