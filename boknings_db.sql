--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--



ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: plpgsql_call_handler(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION plpgsql_call_handler() RETURNS language_handler
    LANGUAGE c
    AS '$libdir/plpgsql', 'plpgsql_call_handler';


ALTER FUNCTION public.plpgsql_call_handler() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = true;


-- Name: bokning; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE bokning (
    obj_id integer NOT NULL,
    typ integer NOT NULL,
    dag date,
    start numeric(4,2) NOT NULL,
    slut numeric(4,2) NOT NULL,
    bokad boolean DEFAULT false,
    bokad_barcode character varying(14),
    status integer DEFAULT 1,
    kommentar character varying(100)
);


ALTER TABLE public.bokning OWNER TO postgres;

--
-- Name: bokning_backup; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE bokning_backup (
    obj_id integer NOT NULL,
    typ integer NOT NULL,
    dag date,
    start numeric(4,2) NOT NULL,
    slut numeric(4,2) NOT NULL,
    bokad boolean DEFAULT false,
    bokad_barcode character varying(14),
    status integer DEFAULT 1,
    kommentar character varying(100)
);


ALTER TABLE public.bokning_backup OWNER TO postgres;

--
-- Name: boknings_objekt; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE boknings_objekt (
    obj_id integer NOT NULL,
    typ integer NOT NULL,
    lokal_id integer NOT NULL,
    namn character varying(100) NOT NULL,
    plats character varying(30) NOT NULL,
    ska_kvitteras boolean,
    kommentar character varying(200),
    aktiv boolean DEFAULT true,
    intern_bruk boolean DEFAULT false
);


ALTER TABLE public.boknings_objekt OWNER TO postgres;

--
-- Name: typ_1_grupprum; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE typ_1_grupprum (
    obj_id integer NOT NULL,
    antal_platser numeric(3,0),
    finns_dator boolean,
    finns_tavla boolean,
    kommentar character varying(200)
);


ALTER TABLE public.typ_1_grupprum OWNER TO postgres;

--
-- Name: booking_objects; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW booking_objects AS
    SELECT bo.obj_id AS id, bo.typ AS object_type, bo.lokal_id AS location_id, bo.namn AS name, bo.plats AS place, bo.ska_kvitteras AS require_confirmation, bo.kommentar AS comment, bo.aktiv AS active, bo.intern_bruk AS internal, t.antal_platser AS seats, t.finns_dator AS has_computer, t.finns_tavla AS has_whiteboard FROM (boknings_objekt bo JOIN typ_1_grupprum t ON ((t.obj_id = bo.obj_id)));


ALTER TABLE public.booking_objects OWNER TO postgres;

--
-- Name: bookings; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW bookings AS
    SELECT bokning.oid AS id, bokning.obj_id AS booking_object_id, bokning.dag AS pass_day, bokning.start AS pass_start, bokning.slut AS pass_stop, bokning.bokad AS booked, bokning.bokad_barcode AS booked_by, bokning.status, bokning.kommentar AS display_name FROM bokning WHERE (bokning.obj_id IN (SELECT typ_1_grupprum.obj_id FROM typ_1_grupprum));


ALTER TABLE public.bookings OWNER TO postgres;

--
-- Name: dag_ordning; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dag_ordning (
    day character(10),
    ordning numeric(1,0),
    dag character(20)
);


ALTER TABLE public.dag_ordning OWNER TO postgres;

--
-- Name: dagar; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dagar (
    dag character varying(10),
    ordning numeric(1,0)
);


ALTER TABLE public.dagar OWNER TO postgres;

--
-- Name: gamla_bokningar; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE gamla_bokningar (
    obj_id integer NOT NULL,
    typ integer NOT NULL,
    dag date,
    start numeric(4,2) NOT NULL,
    slut numeric(4,2) NOT NULL,
    bokad boolean DEFAULT false,
    bokad_barcode character varying(14),
    status integer DEFAULT 1,
    kommentar character varying(100),
    old_oid oid
);


ALTER TABLE public.gamla_bokningar OWNER TO postgres;

--
-- Name: gamla_openhours; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE gamla_openhours (
    lokal_id integer NOT NULL,
    day character(10) NOT NULL,
    open numeric(4,2) NOT NULL,
    close numeric(4,2) NOT NULL,
    prioritet numeric(1,0) DEFAULT 2 NOT NULL,
    from_dag date,
    nummer numeric(1,0)
);


ALTER TABLE public.gamla_openhours OWNER TO postgres;

--
-- Name: lokal; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE lokal (
    id integer NOT NULL,
    namn character varying(100) NOT NULL,
    name text
);


ALTER TABLE public.lokal OWNER TO postgres;

--
-- Name: lokal_sort; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE lokal_sort (
    id integer,
    sort_order integer
);


ALTER TABLE public.lokal_sort OWNER TO postgres;

--
-- Name: locations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW locations AS
    SELECT l.id, l.name AS english_name, l.namn AS swedish_name, ls.sort_order FROM (lokal l JOIN lokal_sort ls ON ((l.id = ls.id)));


ALTER TABLE public.locations OWNER TO postgres;

--
-- Name: obj_id; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE obj_id
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 99999
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.obj_id OWNER TO postgres;

--
-- Name: obj_id; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('obj_id', 314, true);


--
-- Name: openhours; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE openhours (
    lokal_id integer NOT NULL,
    day character(10) NOT NULL,
    open numeric(4,2) NOT NULL,
    close numeric(4,2) NOT NULL,
    prioritet numeric(1,0) DEFAULT 2 NOT NULL,
    from_dag date
);


ALTER TABLE public.openhours OWNER TO postgres;

--
-- Name: pga_diagrams; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pga_diagrams (
    diagramname character varying(64) NOT NULL,
    diagramtables text,
    diagramlinks text
);


ALTER TABLE public.pga_diagrams OWNER TO postgres;

--
-- Name: pga_forms; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pga_forms (
    formname character varying(64) NOT NULL,
    formsource text
);


ALTER TABLE public.pga_forms OWNER TO postgres;

--
-- Name: pga_graphs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pga_graphs (
    graphname character varying(64) NOT NULL,
    graphsource text,
    graphcode text
);


ALTER TABLE public.pga_graphs OWNER TO postgres;

--
-- Name: pga_images; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pga_images (
    imagename character varying(64) NOT NULL,
    imagesource text
);


ALTER TABLE public.pga_images OWNER TO postgres;

--
-- Name: pga_layout; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pga_layout (
    tablename character varying(64) NOT NULL,
    nrcols smallint,
    colnames text,
    colwidth text
);


ALTER TABLE public.pga_layout OWNER TO postgres;

--
-- Name: pga_queries; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pga_queries (
    queryname character varying(64) NOT NULL,
    querytype character(1),
    querycommand text,
    querytables text,
    querylinks text,
    queryresults text,
    querycomments text
);


ALTER TABLE public.pga_queries OWNER TO postgres;

--
-- Name: pga_reports; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pga_reports (
    reportname character varying(64) NOT NULL,
    reportsource text,
    reportbody text,
    reportprocs text,
    reportoptions text
);


ALTER TABLE public.pga_reports OWNER TO postgres;

--
-- Name: pga_scripts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pga_scripts (
    scriptname character varying(64) NOT NULL,
    scriptsource text
);


ALTER TABLE public.pga_scripts OWNER TO postgres;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: typ_info; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE typ_info (
    typ integer,
    typ_namn character varying(100),
    timmar_pass integer,
    antal_pass integer,
    dagar_fram integer,
    typ_namn_stor character varying(100),
    from_dag date,
    type_name text,
    type_name_heading text
);


ALTER TABLE public.typ_info OWNER TO postgres;

--
-- Name: stat2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW stat2 AS
    SELECT b.dag, b.start, b.slut, b.status, bo.namn AS objekt, bo.lokal_id AS bib, l.namn AS bibliotek, t.typ_namn AS typ FROM (((gamla_bokningar b JOIN boknings_objekt bo ON ((b.obj_id = bo.obj_id))) JOIN lokal l ON ((bo.lokal_id = l.id))) JOIN typ_info t ON ((t.typ = b.typ))) WHERE ((b.dag >= '2006-01-01'::date) AND (b.dag <= '2006-12-31'::date));


ALTER TABLE public.stat2 OWNER TO postgres;

--
-- Name: stat_2006; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW stat_2006 AS
    SELECT b.dag, b.start, b.slut, b.status, bo.namn AS objekt, l.namn AS bibliotek, t.typ_namn AS typ FROM (((gamla_bokningar b JOIN boknings_objekt bo ON ((b.obj_id = bo.obj_id))) JOIN lokal l ON ((bo.lokal_id = l.id))) JOIN typ_info t ON ((t.typ = b.typ))) WHERE ((b.dag >= '2006-01-01'::date) AND (b.dag <= '2006-12-31'::date));


ALTER TABLE public.stat_2006 OWNER TO postgres;

--
-- Name: typ_2_datorer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE typ_2_datorer (
    obj_id integer NOT NULL,
    webb boolean,
    ordbehandling boolean,
    skrivare boolean,
    kommentar character varying(200),
    extra_tangentbord integer,
    diskettstation integer DEFAULT 1
);


ALTER TABLE public.typ_2_datorer OWNER TO postgres;

--
-- Name: typ_3_lasstudio; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE typ_3_lasstudio (
    obj_id integer,
    braille boolean,
    kommentar character varying(200)
);


ALTER TABLE public.typ_3_lasstudio OWNER TO postgres;

--
-- Data for Name: bokning; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY bokning (obj_id, typ, dag, start, slut, bokad, bokad_barcode, status, kommentar) FROM stdin;
103	1	2020-11-26	14.00	16.00	f	\N	1	\N
104	1	2020-11-26	10.00	12.00	f	\N	1	\N
285	3	2020-11-23	10.00	12.00	t	8281053738	2	As
104	1	2020-11-26	12.00	14.00	f	\N	1	\N
166	1	2020-11-20	10.00	12.00	f	\N	1	\N
104	1	2020-11-26	14.00	16.00	f	\N	1	\N
307	1	2020-11-26	10.00	12.00	f	\N	1	\N
166	1	2020-11-20	12.00	14.00	f	\N	1	\N
307	1	2020-11-26	12.00	14.00	f	\N	1	\N
307	1	2020-11-26	14.00	16.00	f	\N	1	\N
312	1	2020-11-26	10.00	12.00	f	\N	1	\N
312	1	2020-11-26	12.00	14.00	f	\N	1	\N
312	1	2020-11-26	14.00	16.00	f	\N	1	\N
308	1	2020-11-26	10.00	12.00	f	\N	1	\N
166	1	2020-11-23	10.00	12.00	f	\N	1	\N
166	1	2020-11-23	12.00	14.00	f	\N	1	\N
166	1	2020-11-20	14.00	16.00	f	\N	1	\N
166	1	2020-11-23	14.00	16.00	f	\N	1	\N
166	1	2020-11-20	16.00	18.00	f	\N	1	\N
166	1	2020-11-23	16.00	18.00	f	\N	1	\N
168	1	2020-11-23	10.00	12.00	f	\N	1	\N
168	1	2020-11-23	12.00	14.00	f	\N	1	\N
168	1	2020-11-23	14.00	16.00	f	\N	1	\N
168	1	2020-11-23	16.00	18.00	f	\N	1	\N
165	1	2020-11-23	10.00	12.00	f	\N	1	\N
165	1	2020-11-23	12.00	14.00	f	\N	1	\N
165	1	2020-11-23	14.00	16.00	f	\N	1	\N
165	1	2020-11-23	16.00	18.00	f	\N	1	\N
167	1	2020-11-23	10.00	12.00	f	\N	1	\N
167	1	2020-11-23	12.00	14.00	f	\N	1	\N
167	1	2020-11-23	14.00	16.00	f	\N	1	\N
168	1	2020-11-20	10.00	12.00	f	\N	1	\N
167	1	2020-11-23	16.00	18.00	f	\N	1	\N
289	1	2020-11-23	10.00	12.00	f	\N	1	\N
289	1	2020-11-23	12.00	14.00	f	\N	1	\N
289	1	2020-11-23	14.00	16.00	f	\N	1	\N
289	1	2020-11-23	16.00	18.00	f	\N	1	\N
168	1	2020-11-20	12.00	14.00	f	\N	1	\N
297	2	2020-11-23	10.00	12.00	f	\N	1	\N
297	2	2020-11-23	12.00	14.00	f	\N	1	\N
297	2	2020-11-23	14.00	16.00	f	\N	1	\N
168	1	2020-11-20	14.00	16.00	f	\N	1	\N
297	2	2020-11-23	16.00	18.00	f	\N	1	\N
285	3	2020-11-23	14.00	16.00	f	\N	1	\N
285	3	2020-11-23	16.00	18.00	f	\N	1	\N
204	1	2020-11-23	9.00	11.00	f	\N	1	\N
204	1	2020-11-23	11.00	13.00	f	\N	1	\N
204	1	2020-11-23	13.00	15.00	f	\N	1	\N
204	1	2020-11-23	15.00	17.00	f	\N	1	\N
204	1	2020-11-23	17.00	18.00	f	\N	1	\N
203	1	2020-11-23	9.00	11.00	f	\N	1	\N
203	1	2020-11-23	11.00	13.00	f	\N	1	\N
203	1	2020-11-23	13.00	15.00	f	\N	1	\N
203	1	2020-11-23	15.00	17.00	f	\N	1	\N
203	1	2020-11-23	17.00	18.00	f	\N	1	\N
205	1	2020-11-23	9.00	11.00	f	\N	1	\N
205	1	2020-11-23	11.00	13.00	f	\N	1	\N
205	1	2020-11-23	13.00	15.00	f	\N	1	\N
205	1	2020-11-23	15.00	17.00	f	\N	1	\N
205	1	2020-11-23	17.00	18.00	f	\N	1	\N
202	1	2020-11-23	9.00	11.00	f	\N	1	\N
168	1	2020-11-20	16.00	18.00	f	\N	1	\N
202	1	2020-11-23	11.00	13.00	f	\N	1	\N
202	1	2020-11-23	13.00	15.00	f	\N	1	\N
202	1	2020-11-23	15.00	17.00	f	\N	1	\N
202	1	2020-11-23	17.00	18.00	f	\N	1	\N
214	1	2020-11-23	9.00	11.00	f	\N	1	\N
214	1	2020-11-23	11.00	13.00	f	\N	1	\N
214	1	2020-11-23	13.00	15.00	f	\N	1	\N
214	1	2020-11-23	15.00	17.00	f	\N	1	\N
214	1	2020-11-23	17.00	18.00	f	\N	1	\N
213	1	2020-11-23	9.00	11.00	f	\N	1	\N
213	1	2020-11-23	11.00	13.00	f	\N	1	\N
213	1	2020-11-23	13.00	15.00	f	\N	1	\N
213	1	2020-11-23	15.00	17.00	f	\N	1	\N
213	1	2020-11-23	17.00	18.00	f	\N	1	\N
208	2	2020-11-23	9.00	11.00	f	\N	1	\N
208	2	2020-11-23	11.00	13.00	f	\N	1	\N
208	2	2020-11-23	13.00	15.00	f	\N	1	\N
208	2	2020-11-23	15.00	17.00	f	\N	1	\N
208	2	2020-11-23	17.00	18.00	f	\N	1	\N
244	2	2020-11-23	9.00	11.00	f	\N	1	\N
244	2	2020-11-23	11.00	13.00	f	\N	1	\N
244	2	2020-11-23	13.00	15.00	f	\N	1	\N
244	2	2020-11-23	15.00	17.00	f	\N	1	\N
244	2	2020-11-23	17.00	18.00	f	\N	1	\N
209	2	2020-11-23	9.00	11.00	f	\N	1	\N
308	1	2020-11-26	12.00	14.00	f	\N	1	\N
308	1	2020-11-26	14.00	16.00	f	\N	1	\N
122	2	2020-11-26	10.00	12.00	f	\N	1	\N
166	1	2020-11-30	10.00	12.00	f	\N	1	\N
166	1	2020-11-30	12.00	14.00	f	\N	1	\N
166	1	2020-11-30	14.00	16.00	f	\N	1	\N
166	1	2020-11-30	16.00	18.00	f	\N	1	\N
168	1	2020-11-30	10.00	12.00	f	\N	1	\N
168	1	2020-11-30	12.00	14.00	f	\N	1	\N
168	1	2020-11-30	14.00	16.00	f	\N	1	\N
168	1	2020-11-30	16.00	18.00	f	\N	1	\N
165	1	2020-11-30	10.00	12.00	f	\N	1	\N
165	1	2020-11-30	12.00	14.00	f	\N	1	\N
283	3	2020-11-18	11.00	13.00	f	\N	1	\N
285	3	2020-11-23	12.00	14.00	t	8281053738	2	As
285	3	2020-11-20	16.00	18.00	t	8415238690	2	N
165	1	2020-11-20	10.00	12.00	f	\N	1	\N
165	1	2020-11-20	12.00	14.00	f	\N	1	\N
165	1	2020-11-20	14.00	16.00	f	\N	1	\N
165	1	2020-11-20	16.00	18.00	f	\N	1	\N
283	3	2020-11-19	11.00	13.00	t	5081048035	3	V
167	1	2020-11-20	10.00	12.00	f	\N	1	\N
167	1	2020-11-20	12.00	14.00	f	\N	1	\N
167	1	2020-11-20	14.00	16.00	f	\N	1	\N
167	1	2020-11-20	16.00	18.00	f	\N	1	\N
289	1	2020-11-20	10.00	12.00	f	\N	1	\N
289	1	2020-11-20	12.00	14.00	f	\N	1	\N
289	1	2020-11-20	14.00	16.00	f	\N	1	\N
289	1	2020-11-20	16.00	18.00	f	\N	1	\N
297	2	2020-11-20	10.00	12.00	f	\N	1	\N
297	2	2020-11-20	12.00	14.00	f	\N	1	\N
297	2	2020-11-20	14.00	16.00	f	\N	1	\N
297	2	2020-11-20	16.00	18.00	f	\N	1	\N
285	3	2020-11-20	10.00	12.00	f	\N	1	\N
285	3	2020-11-20	12.00	14.00	f	\N	1	\N
285	3	2020-11-20	14.00	16.00	f	\N	1	\N
204	1	2020-11-20	9.00	11.00	f	\N	1	\N
204	1	2020-11-20	11.00	13.00	f	\N	1	\N
204	1	2020-11-20	13.00	15.00	f	\N	1	\N
204	1	2020-11-20	15.00	17.00	f	\N	1	\N
204	1	2020-11-20	17.00	18.00	f	\N	1	\N
203	1	2020-11-20	9.00	11.00	f	\N	1	\N
203	1	2020-11-20	11.00	13.00	f	\N	1	\N
203	1	2020-11-20	13.00	15.00	f	\N	1	\N
203	1	2020-11-20	15.00	17.00	f	\N	1	\N
203	1	2020-11-20	17.00	18.00	f	\N	1	\N
205	1	2020-11-20	9.00	11.00	f	\N	1	\N
205	1	2020-11-20	11.00	13.00	f	\N	1	\N
205	1	2020-11-20	13.00	15.00	f	\N	1	\N
205	1	2020-11-20	15.00	17.00	f	\N	1	\N
205	1	2020-11-20	17.00	18.00	f	\N	1	\N
202	1	2020-11-20	9.00	11.00	f	\N	1	\N
165	1	2020-11-30	14.00	16.00	f	\N	1	\N
122	2	2020-11-26	12.00	14.00	f	\N	1	\N
122	2	2020-11-26	14.00	16.00	f	\N	1	\N
165	1	2020-11-30	16.00	18.00	f	\N	1	\N
209	2	2020-11-23	11.00	13.00	f	\N	1	\N
209	2	2020-11-23	13.00	15.00	f	\N	1	\N
167	1	2020-11-30	10.00	12.00	f	\N	1	\N
202	1	2020-11-20	11.00	13.00	f	\N	1	\N
209	2	2020-11-23	15.00	17.00	f	\N	1	\N
167	1	2020-11-30	12.00	14.00	f	\N	1	\N
167	1	2020-11-30	14.00	16.00	f	\N	1	\N
209	2	2020-11-23	17.00	18.00	f	\N	1	\N
245	2	2020-11-23	9.00	11.00	f	\N	1	\N
245	2	2020-11-23	11.00	13.00	f	\N	1	\N
245	2	2020-11-23	13.00	15.00	f	\N	1	\N
167	1	2020-11-30	16.00	18.00	f	\N	1	\N
289	1	2020-11-30	10.00	12.00	f	\N	1	\N
289	1	2020-11-30	12.00	14.00	f	\N	1	\N
202	1	2020-11-20	13.00	15.00	f	\N	1	\N
289	1	2020-11-30	14.00	16.00	f	\N	1	\N
289	1	2020-11-30	16.00	18.00	f	\N	1	\N
297	2	2020-11-30	10.00	12.00	f	\N	1	\N
202	1	2020-11-20	15.00	17.00	f	\N	1	\N
202	1	2020-11-20	17.00	18.00	f	\N	1	\N
214	1	2020-11-20	9.00	11.00	f	\N	1	\N
214	1	2020-11-20	11.00	13.00	f	\N	1	\N
214	1	2020-11-20	13.00	15.00	f	\N	1	\N
214	1	2020-11-20	15.00	17.00	f	\N	1	\N
214	1	2020-11-20	17.00	18.00	f	\N	1	\N
213	1	2020-11-20	9.00	11.00	f	\N	1	\N
213	1	2020-11-20	11.00	13.00	f	\N	1	\N
213	1	2020-11-20	13.00	15.00	f	\N	1	\N
213	1	2020-11-20	15.00	17.00	f	\N	1	\N
213	1	2020-11-20	17.00	18.00	f	\N	1	\N
208	2	2020-11-20	9.00	11.00	f	\N	1	\N
208	2	2020-11-20	11.00	13.00	f	\N	1	\N
208	2	2020-11-20	13.00	15.00	f	\N	1	\N
208	2	2020-11-20	15.00	17.00	f	\N	1	\N
208	2	2020-11-20	17.00	18.00	f	\N	1	\N
244	2	2020-11-20	9.00	11.00	f	\N	1	\N
244	2	2020-11-20	11.00	13.00	f	\N	1	\N
244	2	2020-11-20	13.00	15.00	f	\N	1	\N
244	2	2020-11-20	15.00	17.00	f	\N	1	\N
244	2	2020-11-20	17.00	18.00	f	\N	1	\N
209	2	2020-11-20	9.00	11.00	f	\N	1	\N
209	2	2020-11-20	11.00	13.00	f	\N	1	\N
297	2	2020-11-30	12.00	14.00	f	\N	1	\N
297	2	2020-11-30	14.00	16.00	f	\N	1	\N
105	2	2020-11-26	10.00	12.00	f	\N	1	\N
105	2	2020-11-26	12.00	14.00	f	\N	1	\N
105	2	2020-11-26	14.00	16.00	f	\N	1	\N
112	2	2020-11-26	10.00	12.00	f	\N	1	\N
245	2	2020-11-23	15.00	17.00	f	\N	1	\N
245	2	2020-11-23	17.00	18.00	f	\N	1	\N
247	2	2020-11-23	9.00	11.00	f	\N	1	\N
247	2	2020-11-23	11.00	13.00	f	\N	1	\N
247	2	2020-11-23	13.00	15.00	f	\N	1	\N
247	2	2020-11-23	15.00	17.00	f	\N	1	\N
247	2	2020-11-23	17.00	18.00	f	\N	1	\N
207	2	2020-11-23	9.00	11.00	f	\N	1	\N
207	2	2020-11-23	11.00	13.00	f	\N	1	\N
207	2	2020-11-23	13.00	15.00	f	\N	1	\N
207	2	2020-11-23	15.00	17.00	f	\N	1	\N
207	2	2020-11-23	17.00	18.00	f	\N	1	\N
212	2	2020-11-23	9.00	11.00	f	\N	1	\N
212	2	2020-11-23	11.00	13.00	f	\N	1	\N
212	2	2020-11-23	13.00	15.00	f	\N	1	\N
212	2	2020-11-23	15.00	17.00	f	\N	1	\N
212	2	2020-11-23	17.00	18.00	f	\N	1	\N
217	2	2020-11-23	9.00	11.00	f	\N	1	\N
217	2	2020-11-23	11.00	13.00	f	\N	1	\N
217	2	2020-11-23	13.00	15.00	f	\N	1	\N
217	2	2020-11-23	15.00	17.00	f	\N	1	\N
217	2	2020-11-23	17.00	18.00	f	\N	1	\N
246	2	2020-11-23	9.00	11.00	f	\N	1	\N
246	2	2020-11-23	11.00	13.00	f	\N	1	\N
246	2	2020-11-23	13.00	15.00	f	\N	1	\N
246	2	2020-11-23	15.00	17.00	f	\N	1	\N
246	2	2020-11-23	17.00	18.00	f	\N	1	\N
210	2	2020-11-23	9.00	11.00	f	\N	1	\N
210	2	2020-11-23	11.00	13.00	f	\N	1	\N
210	2	2020-11-23	13.00	15.00	f	\N	1	\N
210	2	2020-11-23	15.00	17.00	f	\N	1	\N
210	2	2020-11-23	17.00	18.00	f	\N	1	\N
206	2	2020-11-23	9.00	11.00	f	\N	1	\N
206	2	2020-11-23	11.00	13.00	f	\N	1	\N
206	2	2020-11-23	13.00	15.00	f	\N	1	\N
206	2	2020-11-23	15.00	17.00	f	\N	1	\N
206	2	2020-11-23	17.00	18.00	f	\N	1	\N
288	3	2020-11-23	9.00	11.00	f	\N	1	\N
288	3	2020-11-23	11.00	13.00	f	\N	1	\N
288	3	2020-11-23	13.00	15.00	f	\N	1	\N
288	3	2020-11-23	15.00	17.00	f	\N	1	\N
288	3	2020-11-23	17.00	18.00	f	\N	1	\N
287	3	2020-11-23	9.00	11.00	f	\N	1	\N
287	3	2020-11-23	11.00	13.00	f	\N	1	\N
287	3	2020-11-23	13.00	15.00	f	\N	1	\N
287	3	2020-11-23	15.00	17.00	f	\N	1	\N
287	3	2020-11-23	17.00	18.00	f	\N	1	\N
196	1	2020-11-23	9.00	11.00	f	\N	1	\N
196	1	2020-11-23	11.00	13.00	f	\N	1	\N
196	1	2020-11-23	13.00	15.00	f	\N	1	\N
196	1	2020-11-23	15.00	17.00	f	\N	1	\N
196	1	2020-11-23	17.00	18.00	f	\N	1	\N
97	1	2020-11-23	9.00	11.00	f	\N	1	\N
97	1	2020-11-23	11.00	13.00	f	\N	1	\N
97	1	2020-11-23	13.00	15.00	f	\N	1	\N
97	1	2020-11-23	15.00	17.00	f	\N	1	\N
97	1	2020-11-23	17.00	18.00	f	\N	1	\N
197	1	2020-11-23	9.00	11.00	f	\N	1	\N
197	1	2020-11-23	11.00	13.00	f	\N	1	\N
197	1	2020-11-23	13.00	15.00	f	\N	1	\N
197	1	2020-11-23	15.00	17.00	f	\N	1	\N
197	1	2020-11-23	17.00	18.00	f	\N	1	\N
135	1	2020-11-23	9.00	11.00	f	\N	1	\N
135	1	2020-11-23	11.00	13.00	f	\N	1	\N
135	1	2020-11-23	13.00	15.00	f	\N	1	\N
135	1	2020-11-23	15.00	17.00	f	\N	1	\N
135	1	2020-11-23	17.00	18.00	f	\N	1	\N
136	1	2020-11-23	9.00	11.00	f	\N	1	\N
136	1	2020-11-23	11.00	13.00	f	\N	1	\N
307	1	2020-11-19	12.00	14.00	t	5151498445	2	Martiti
136	1	2020-11-23	13.00	15.00	f	\N	1	\N
136	1	2020-11-23	15.00	17.00	f	\N	1	\N
209	2	2020-11-20	13.00	15.00	f	\N	1	\N
190	1	2020-11-19	12.00	14.00	t	8430049282	2	C. D.
190	1	2020-11-20	12.00	14.00	f	\N	1	\N
297	2	2020-11-30	16.00	18.00	f	\N	1	\N
285	3	2020-11-30	10.00	12.00	f	\N	1	\N
136	1	2020-11-23	17.00	18.00	f	\N	1	\N
137	1	2020-11-23	9.00	11.00	f	\N	1	\N
137	1	2020-11-23	11.00	13.00	f	\N	1	\N
137	1	2020-11-23	13.00	15.00	f	\N	1	\N
137	1	2020-11-23	15.00	17.00	f	\N	1	\N
137	1	2020-11-23	17.00	18.00	f	\N	1	\N
195	1	2020-11-23	9.00	11.00	f	\N	1	\N
195	1	2020-11-23	11.00	13.00	f	\N	1	\N
195	1	2020-11-23	13.00	15.00	f	\N	1	\N
195	1	2020-11-23	15.00	17.00	f	\N	1	\N
195	1	2020-11-23	17.00	18.00	f	\N	1	\N
138	1	2020-11-23	9.00	11.00	f	\N	1	\N
112	2	2020-11-26	12.00	14.00	f	\N	1	\N
112	2	2020-11-26	14.00	16.00	f	\N	1	\N
209	2	2020-11-20	15.00	17.00	f	\N	1	\N
209	2	2020-11-20	17.00	18.00	f	\N	1	\N
245	2	2020-11-20	9.00	11.00	f	\N	1	\N
245	2	2020-11-20	11.00	13.00	f	\N	1	\N
245	2	2020-11-20	13.00	15.00	f	\N	1	\N
245	2	2020-11-20	15.00	17.00	f	\N	1	\N
245	2	2020-11-20	17.00	18.00	f	\N	1	\N
247	2	2020-11-20	9.00	11.00	f	\N	1	\N
247	2	2020-11-20	11.00	13.00	f	\N	1	\N
138	1	2020-11-23	11.00	13.00	f	\N	1	\N
138	1	2020-11-23	13.00	15.00	f	\N	1	\N
247	2	2020-11-20	13.00	15.00	f	\N	1	\N
247	2	2020-11-20	15.00	17.00	f	\N	1	\N
247	2	2020-11-20	17.00	18.00	f	\N	1	\N
285	3	2020-11-30	12.00	14.00	f	\N	1	\N
207	2	2020-11-20	9.00	11.00	f	\N	1	\N
285	3	2020-11-30	14.00	16.00	f	\N	1	\N
207	2	2020-11-20	11.00	13.00	f	\N	1	\N
207	2	2020-11-20	13.00	15.00	f	\N	1	\N
207	2	2020-11-20	15.00	17.00	f	\N	1	\N
207	2	2020-11-20	17.00	18.00	f	\N	1	\N
212	2	2020-11-20	9.00	11.00	f	\N	1	\N
212	2	2020-11-20	11.00	13.00	f	\N	1	\N
212	2	2020-11-20	13.00	15.00	f	\N	1	\N
212	2	2020-11-20	15.00	17.00	f	\N	1	\N
212	2	2020-11-20	17.00	18.00	f	\N	1	\N
217	2	2020-11-20	9.00	11.00	f	\N	1	\N
217	2	2020-11-20	11.00	13.00	f	\N	1	\N
217	2	2020-11-20	13.00	15.00	f	\N	1	\N
217	2	2020-11-20	15.00	17.00	f	\N	1	\N
217	2	2020-11-20	17.00	18.00	f	\N	1	\N
246	2	2020-11-20	9.00	11.00	f	\N	1	\N
246	2	2020-11-20	11.00	13.00	f	\N	1	\N
246	2	2020-11-20	13.00	15.00	f	\N	1	\N
246	2	2020-11-20	15.00	17.00	f	\N	1	\N
246	2	2020-11-20	17.00	18.00	f	\N	1	\N
210	2	2020-11-20	9.00	11.00	f	\N	1	\N
210	2	2020-11-20	11.00	13.00	f	\N	1	\N
210	2	2020-11-20	13.00	15.00	f	\N	1	\N
210	2	2020-11-20	15.00	17.00	f	\N	1	\N
210	2	2020-11-20	17.00	18.00	f	\N	1	\N
206	2	2020-11-20	9.00	11.00	f	\N	1	\N
206	2	2020-11-20	11.00	13.00	f	\N	1	\N
206	2	2020-11-20	13.00	15.00	f	\N	1	\N
206	2	2020-11-20	15.00	17.00	f	\N	1	\N
206	2	2020-11-20	17.00	18.00	f	\N	1	\N
288	3	2020-11-20	9.00	11.00	f	\N	1	\N
288	3	2020-11-20	11.00	13.00	f	\N	1	\N
138	1	2020-11-23	15.00	17.00	f	\N	1	\N
138	1	2020-11-23	17.00	18.00	f	\N	1	\N
139	1	2020-11-23	9.00	11.00	f	\N	1	\N
139	1	2020-11-23	11.00	13.00	f	\N	1	\N
139	1	2020-11-23	13.00	15.00	f	\N	1	\N
139	1	2020-11-23	15.00	17.00	f	\N	1	\N
139	1	2020-11-23	17.00	18.00	f	\N	1	\N
140	1	2020-11-23	9.00	11.00	f	\N	1	\N
140	1	2020-11-23	11.00	13.00	f	\N	1	\N
140	1	2020-11-23	13.00	15.00	f	\N	1	\N
140	1	2020-11-23	15.00	17.00	f	\N	1	\N
285	3	2020-11-30	16.00	18.00	f	\N	1	\N
140	1	2020-11-23	17.00	18.00	f	\N	1	\N
141	1	2020-11-23	9.00	11.00	f	\N	1	\N
141	1	2020-11-23	11.00	13.00	f	\N	1	\N
141	1	2020-11-23	13.00	15.00	f	\N	1	\N
141	1	2020-11-23	15.00	17.00	f	\N	1	\N
141	1	2020-11-23	17.00	18.00	f	\N	1	\N
188	2	2020-11-23	9.00	11.00	f	\N	1	\N
188	2	2020-11-23	11.00	13.00	f	\N	1	\N
188	2	2020-11-23	13.00	15.00	f	\N	1	\N
188	2	2020-11-23	15.00	17.00	f	\N	1	\N
188	2	2020-11-23	17.00	18.00	f	\N	1	\N
248	2	2020-11-23	9.00	11.00	f	\N	1	\N
248	2	2020-11-23	11.00	13.00	f	\N	1	\N
248	2	2020-11-23	13.00	15.00	f	\N	1	\N
248	2	2020-11-23	15.00	17.00	f	\N	1	\N
248	2	2020-11-23	17.00	18.00	f	\N	1	\N
182	2	2020-11-23	9.00	11.00	f	\N	1	\N
182	2	2020-11-23	11.00	13.00	f	\N	1	\N
182	2	2020-11-23	13.00	15.00	f	\N	1	\N
182	2	2020-11-23	15.00	17.00	f	\N	1	\N
182	2	2020-11-23	17.00	18.00	f	\N	1	\N
183	2	2020-11-23	9.00	11.00	f	\N	1	\N
183	2	2020-11-23	11.00	13.00	f	\N	1	\N
183	2	2020-11-23	13.00	15.00	f	\N	1	\N
183	2	2020-11-23	15.00	17.00	f	\N	1	\N
183	2	2020-11-23	17.00	18.00	f	\N	1	\N
181	2	2020-11-23	9.00	11.00	f	\N	1	\N
181	2	2020-11-23	11.00	13.00	f	\N	1	\N
181	2	2020-11-23	13.00	15.00	f	\N	1	\N
181	2	2020-11-23	15.00	17.00	f	\N	1	\N
181	2	2020-11-23	17.00	18.00	f	\N	1	\N
187	2	2020-11-23	9.00	11.00	f	\N	1	\N
187	2	2020-11-23	11.00	13.00	f	\N	1	\N
187	2	2020-11-23	13.00	15.00	f	\N	1	\N
187	2	2020-11-23	15.00	17.00	f	\N	1	\N
187	2	2020-11-23	17.00	18.00	f	\N	1	\N
184	2	2020-11-23	9.00	11.00	f	\N	1	\N
184	2	2020-11-23	11.00	13.00	f	\N	1	\N
184	2	2020-11-23	13.00	15.00	f	\N	1	\N
184	2	2020-11-23	15.00	17.00	f	\N	1	\N
184	2	2020-11-23	17.00	18.00	f	\N	1	\N
249	2	2020-11-23	9.00	11.00	f	\N	1	\N
249	2	2020-11-23	11.00	13.00	f	\N	1	\N
249	2	2020-11-23	13.00	15.00	f	\N	1	\N
249	2	2020-11-23	15.00	17.00	f	\N	1	\N
249	2	2020-11-23	17.00	18.00	f	\N	1	\N
186	2	2020-11-23	9.00	11.00	f	\N	1	\N
186	2	2020-11-23	11.00	13.00	f	\N	1	\N
186	2	2020-11-23	13.00	15.00	f	\N	1	\N
186	2	2020-11-23	15.00	17.00	f	\N	1	\N
186	2	2020-11-23	17.00	18.00	f	\N	1	\N
285	3	2020-11-19	10.00	12.00	t	8426789416	4	AM
180	2	2020-11-23	9.00	11.00	f	\N	1	\N
180	2	2020-11-23	11.00	13.00	f	\N	1	\N
180	2	2020-11-23	13.00	15.00	f	\N	1	\N
180	2	2020-11-23	15.00	17.00	f	\N	1	\N
180	2	2020-11-23	17.00	18.00	f	\N	1	\N
185	2	2020-11-23	9.00	11.00	f	\N	1	\N
185	2	2020-11-23	11.00	13.00	f	\N	1	\N
185	2	2020-11-23	13.00	15.00	f	\N	1	\N
185	2	2020-11-23	15.00	17.00	f	\N	1	\N
185	2	2020-11-23	17.00	18.00	f	\N	1	\N
283	3	2020-11-23	9.00	11.00	f	\N	1	\N
283	3	2020-11-23	11.00	13.00	f	\N	1	\N
283	3	2020-11-23	13.00	15.00	f	\N	1	\N
283	3	2020-11-23	15.00	17.00	f	\N	1	\N
283	3	2020-11-23	17.00	18.00	f	\N	1	\N
284	3	2020-11-23	9.00	11.00	f	\N	1	\N
284	3	2020-11-23	11.00	13.00	f	\N	1	\N
284	3	2020-11-23	13.00	15.00	f	\N	1	\N
284	3	2020-11-23	15.00	17.00	f	\N	1	\N
284	3	2020-11-23	17.00	18.00	f	\N	1	\N
189	1	2020-11-23	10.00	12.00	f	\N	1	\N
189	1	2020-11-23	12.00	14.00	f	\N	1	\N
189	1	2020-11-23	14.00	16.00	f	\N	1	\N
256	1	2020-11-23	10.00	12.00	f	\N	1	\N
256	1	2020-11-23	12.00	14.00	f	\N	1	\N
256	1	2020-11-23	14.00	16.00	f	\N	1	\N
98	1	2020-11-23	10.00	12.00	f	\N	1	\N
98	1	2020-11-23	12.00	14.00	f	\N	1	\N
98	1	2020-11-23	14.00	16.00	f	\N	1	\N
101	1	2020-11-23	10.00	12.00	f	\N	1	\N
101	1	2020-11-23	12.00	14.00	f	\N	1	\N
101	1	2020-11-23	14.00	16.00	f	\N	1	\N
309	1	2020-11-23	10.00	12.00	f	\N	1	\N
309	1	2020-11-23	12.00	14.00	f	\N	1	\N
309	1	2020-11-23	14.00	16.00	f	\N	1	\N
311	1	2020-11-23	10.00	12.00	f	\N	1	\N
311	1	2020-11-23	12.00	14.00	f	\N	1	\N
311	1	2020-11-23	14.00	16.00	f	\N	1	\N
190	1	2020-11-23	10.00	12.00	f	\N	1	\N
190	1	2020-11-23	12.00	14.00	f	\N	1	\N
288	3	2020-11-20	13.00	15.00	f	\N	1	\N
190	1	2020-11-23	14.00	16.00	f	\N	1	\N
99	1	2020-11-23	10.00	12.00	f	\N	1	\N
99	1	2020-11-23	12.00	14.00	f	\N	1	\N
99	1	2020-11-23	14.00	16.00	f	\N	1	\N
288	3	2020-11-20	15.00	17.00	f	\N	1	\N
100	1	2020-11-23	12.00	14.00	f	\N	1	\N
100	1	2020-11-23	14.00	16.00	f	\N	1	\N
102	1	2020-11-23	10.00	12.00	f	\N	1	\N
102	1	2020-11-23	12.00	14.00	f	\N	1	\N
102	1	2020-11-23	14.00	16.00	f	\N	1	\N
103	1	2020-11-23	10.00	12.00	f	\N	1	\N
103	1	2020-11-23	12.00	14.00	f	\N	1	\N
103	1	2020-11-23	14.00	16.00	f	\N	1	\N
104	1	2020-11-23	10.00	12.00	f	\N	1	\N
104	1	2020-11-23	12.00	14.00	f	\N	1	\N
104	1	2020-11-23	14.00	16.00	f	\N	1	\N
307	1	2020-11-23	10.00	12.00	f	\N	1	\N
307	1	2020-11-23	12.00	14.00	f	\N	1	\N
307	1	2020-11-23	14.00	16.00	f	\N	1	\N
312	1	2020-11-23	10.00	12.00	f	\N	1	\N
312	1	2020-11-23	12.00	14.00	f	\N	1	\N
312	1	2020-11-23	14.00	16.00	f	\N	1	\N
308	1	2020-11-23	10.00	12.00	f	\N	1	\N
308	1	2020-11-23	12.00	14.00	f	\N	1	\N
308	1	2020-11-23	14.00	16.00	f	\N	1	\N
122	2	2020-11-23	10.00	12.00	f	\N	1	\N
122	2	2020-11-23	12.00	14.00	f	\N	1	\N
122	2	2020-11-23	14.00	16.00	f	\N	1	\N
105	2	2020-11-23	10.00	12.00	f	\N	1	\N
105	2	2020-11-23	12.00	14.00	f	\N	1	\N
105	2	2020-11-23	14.00	16.00	f	\N	1	\N
112	2	2020-11-23	10.00	12.00	f	\N	1	\N
112	2	2020-11-23	12.00	14.00	f	\N	1	\N
112	2	2020-11-23	14.00	16.00	f	\N	1	\N
111	2	2020-11-23	10.00	12.00	f	\N	1	\N
111	2	2020-11-23	12.00	14.00	f	\N	1	\N
111	2	2020-11-23	14.00	16.00	f	\N	1	\N
106	2	2020-11-23	10.00	12.00	f	\N	1	\N
106	2	2020-11-23	12.00	14.00	f	\N	1	\N
106	2	2020-11-23	14.00	16.00	f	\N	1	\N
107	2	2020-11-23	10.00	12.00	f	\N	1	\N
107	2	2020-11-23	12.00	14.00	f	\N	1	\N
107	2	2020-11-23	14.00	16.00	f	\N	1	\N
109	2	2020-11-23	10.00	12.00	f	\N	1	\N
109	2	2020-11-23	12.00	14.00	f	\N	1	\N
109	2	2020-11-23	14.00	16.00	f	\N	1	\N
133	2	2020-11-23	10.00	12.00	f	\N	1	\N
133	2	2020-11-23	12.00	14.00	f	\N	1	\N
133	2	2020-11-23	14.00	16.00	f	\N	1	\N
134	2	2020-11-23	10.00	12.00	f	\N	1	\N
134	2	2020-11-23	12.00	14.00	f	\N	1	\N
134	2	2020-11-23	14.00	16.00	f	\N	1	\N
128	2	2020-11-23	10.00	12.00	f	\N	1	\N
128	2	2020-11-23	12.00	14.00	f	\N	1	\N
128	2	2020-11-23	14.00	16.00	f	\N	1	\N
127	2	2020-11-23	10.00	12.00	f	\N	1	\N
127	2	2020-11-23	12.00	14.00	f	\N	1	\N
127	2	2020-11-23	14.00	16.00	f	\N	1	\N
126	2	2020-11-23	10.00	12.00	f	\N	1	\N
126	2	2020-11-23	12.00	14.00	f	\N	1	\N
126	2	2020-11-23	14.00	16.00	f	\N	1	\N
125	2	2020-11-23	10.00	12.00	f	\N	1	\N
125	2	2020-11-23	12.00	14.00	f	\N	1	\N
125	2	2020-11-23	14.00	16.00	f	\N	1	\N
132	2	2020-11-23	10.00	12.00	f	\N	1	\N
132	2	2020-11-23	12.00	14.00	f	\N	1	\N
310	1	2020-11-23	12.00	14.00	t	8334666274	2	Maja
310	1	2020-11-23	14.00	16.00	t	5151498445	2	Martiti
100	1	2020-11-23	10.00	12.00	t	8404912680	2	Viktor
288	3	2020-11-20	17.00	18.00	f	\N	1	\N
132	2	2020-11-23	14.00	16.00	f	\N	1	\N
131	2	2020-11-23	10.00	12.00	f	\N	1	\N
131	2	2020-11-23	12.00	14.00	f	\N	1	\N
131	2	2020-11-23	14.00	16.00	f	\N	1	\N
130	2	2020-11-23	10.00	12.00	f	\N	1	\N
130	2	2020-11-23	12.00	14.00	f	\N	1	\N
130	2	2020-11-23	14.00	16.00	f	\N	1	\N
129	2	2020-11-23	10.00	12.00	f	\N	1	\N
129	2	2020-11-23	12.00	14.00	f	\N	1	\N
129	2	2020-11-23	14.00	16.00	f	\N	1	\N
124	2	2020-11-23	10.00	12.00	f	\N	1	\N
124	2	2020-11-23	12.00	14.00	f	\N	1	\N
124	2	2020-11-23	14.00	16.00	f	\N	1	\N
117	2	2020-11-23	10.00	12.00	f	\N	1	\N
117	2	2020-11-23	12.00	14.00	f	\N	1	\N
117	2	2020-11-23	14.00	16.00	f	\N	1	\N
123	2	2020-11-23	10.00	12.00	f	\N	1	\N
123	2	2020-11-23	12.00	14.00	f	\N	1	\N
123	2	2020-11-23	14.00	16.00	f	\N	1	\N
121	2	2020-11-23	10.00	12.00	f	\N	1	\N
121	2	2020-11-23	12.00	14.00	f	\N	1	\N
121	2	2020-11-23	14.00	16.00	f	\N	1	\N
119	2	2020-11-23	10.00	12.00	f	\N	1	\N
119	2	2020-11-23	12.00	14.00	f	\N	1	\N
119	2	2020-11-23	14.00	16.00	f	\N	1	\N
118	2	2020-11-23	10.00	12.00	f	\N	1	\N
118	2	2020-11-23	12.00	14.00	f	\N	1	\N
118	2	2020-11-23	14.00	16.00	f	\N	1	\N
110	2	2020-11-23	10.00	12.00	f	\N	1	\N
110	2	2020-11-23	12.00	14.00	f	\N	1	\N
111	2	2020-11-26	10.00	12.00	f	\N	1	\N
110	2	2020-11-23	14.00	16.00	f	\N	1	\N
204	1	2020-11-30	9.00	11.00	f	\N	1	\N
204	1	2020-11-30	11.00	13.00	f	\N	1	\N
204	1	2020-11-30	13.00	15.00	f	\N	1	\N
204	1	2020-11-30	15.00	17.00	f	\N	1	\N
204	1	2020-11-30	17.00	18.00	f	\N	1	\N
203	1	2020-11-30	9.00	11.00	f	\N	1	\N
203	1	2020-11-30	11.00	13.00	f	\N	1	\N
203	1	2020-11-30	13.00	15.00	f	\N	1	\N
203	1	2020-11-30	15.00	17.00	f	\N	1	\N
203	1	2020-11-30	17.00	18.00	f	\N	1	\N
205	1	2020-11-30	9.00	11.00	f	\N	1	\N
205	1	2020-11-30	11.00	13.00	f	\N	1	\N
205	1	2020-11-30	13.00	15.00	f	\N	1	\N
205	1	2020-11-30	15.00	17.00	f	\N	1	\N
205	1	2020-11-30	17.00	18.00	f	\N	1	\N
202	1	2020-11-30	9.00	11.00	f	\N	1	\N
202	1	2020-11-30	11.00	13.00	f	\N	1	\N
202	1	2020-11-30	13.00	15.00	f	\N	1	\N
202	1	2020-11-30	15.00	17.00	f	\N	1	\N
202	1	2020-11-30	17.00	18.00	f	\N	1	\N
214	1	2020-11-30	9.00	11.00	f	\N	1	\N
214	1	2020-11-30	11.00	13.00	f	\N	1	\N
214	1	2020-11-30	13.00	15.00	f	\N	1	\N
214	1	2020-11-30	15.00	17.00	f	\N	1	\N
214	1	2020-11-30	17.00	18.00	f	\N	1	\N
213	1	2020-11-30	9.00	11.00	f	\N	1	\N
213	1	2020-11-30	11.00	13.00	f	\N	1	\N
213	1	2020-11-30	13.00	15.00	f	\N	1	\N
213	1	2020-11-30	15.00	17.00	f	\N	1	\N
213	1	2020-11-30	17.00	18.00	f	\N	1	\N
208	2	2020-11-30	9.00	11.00	f	\N	1	\N
208	2	2020-11-30	11.00	13.00	f	\N	1	\N
208	2	2020-11-30	13.00	15.00	f	\N	1	\N
208	2	2020-11-30	15.00	17.00	f	\N	1	\N
208	2	2020-11-30	17.00	18.00	f	\N	1	\N
244	2	2020-11-30	9.00	11.00	f	\N	1	\N
244	2	2020-11-30	11.00	13.00	f	\N	1	\N
244	2	2020-11-30	13.00	15.00	f	\N	1	\N
244	2	2020-11-30	15.00	17.00	f	\N	1	\N
244	2	2020-11-30	17.00	18.00	f	\N	1	\N
209	2	2020-11-30	9.00	11.00	f	\N	1	\N
209	2	2020-11-30	11.00	13.00	f	\N	1	\N
209	2	2020-11-30	13.00	15.00	f	\N	1	\N
209	2	2020-11-30	15.00	17.00	f	\N	1	\N
209	2	2020-11-30	17.00	18.00	f	\N	1	\N
245	2	2020-11-30	9.00	11.00	f	\N	1	\N
245	2	2020-11-30	11.00	13.00	f	\N	1	\N
245	2	2020-11-30	13.00	15.00	f	\N	1	\N
245	2	2020-11-30	15.00	17.00	f	\N	1	\N
245	2	2020-11-30	17.00	18.00	f	\N	1	\N
247	2	2020-11-30	9.00	11.00	f	\N	1	\N
247	2	2020-11-30	11.00	13.00	f	\N	1	\N
247	2	2020-11-30	13.00	15.00	f	\N	1	\N
247	2	2020-11-30	15.00	17.00	f	\N	1	\N
247	2	2020-11-30	17.00	18.00	f	\N	1	\N
207	2	2020-11-30	9.00	11.00	f	\N	1	\N
207	2	2020-11-30	11.00	13.00	f	\N	1	\N
207	2	2020-11-30	13.00	15.00	f	\N	1	\N
207	2	2020-11-30	15.00	17.00	f	\N	1	\N
207	2	2020-11-30	17.00	18.00	f	\N	1	\N
212	2	2020-11-30	9.00	11.00	f	\N	1	\N
108	2	2020-11-23	10.00	12.00	f	\N	1	\N
108	2	2020-11-23	12.00	14.00	f	\N	1	\N
108	2	2020-11-23	14.00	16.00	f	\N	1	\N
116	2	2020-11-23	10.00	12.00	f	\N	1	\N
116	2	2020-11-23	12.00	14.00	f	\N	1	\N
116	2	2020-11-23	14.00	16.00	f	\N	1	\N
115	2	2020-11-23	10.00	12.00	f	\N	1	\N
212	2	2020-11-30	11.00	13.00	f	\N	1	\N
212	2	2020-11-30	13.00	15.00	f	\N	1	\N
212	2	2020-11-30	15.00	17.00	f	\N	1	\N
212	2	2020-11-30	17.00	18.00	f	\N	1	\N
217	2	2020-11-30	9.00	11.00	f	\N	1	\N
217	2	2020-11-30	11.00	13.00	f	\N	1	\N
217	2	2020-11-30	13.00	15.00	f	\N	1	\N
217	2	2020-11-30	15.00	17.00	f	\N	1	\N
217	2	2020-11-30	17.00	18.00	f	\N	1	\N
246	2	2020-11-30	9.00	11.00	f	\N	1	\N
246	2	2020-11-30	11.00	13.00	f	\N	1	\N
246	2	2020-11-30	13.00	15.00	f	\N	1	\N
246	2	2020-11-30	15.00	17.00	f	\N	1	\N
246	2	2020-11-30	17.00	18.00	f	\N	1	\N
210	2	2020-11-30	9.00	11.00	f	\N	1	\N
210	2	2020-11-30	11.00	13.00	f	\N	1	\N
210	2	2020-11-30	13.00	15.00	f	\N	1	\N
210	2	2020-11-30	15.00	17.00	f	\N	1	\N
210	2	2020-11-30	17.00	18.00	f	\N	1	\N
206	2	2020-11-30	9.00	11.00	f	\N	1	\N
206	2	2020-11-30	11.00	13.00	f	\N	1	\N
206	2	2020-11-30	13.00	15.00	f	\N	1	\N
206	2	2020-11-30	15.00	17.00	f	\N	1	\N
206	2	2020-11-30	17.00	18.00	f	\N	1	\N
288	3	2020-11-30	9.00	11.00	f	\N	1	\N
288	3	2020-11-30	11.00	13.00	f	\N	1	\N
288	3	2020-11-30	13.00	15.00	f	\N	1	\N
288	3	2020-11-30	15.00	17.00	f	\N	1	\N
288	3	2020-11-30	17.00	18.00	f	\N	1	\N
287	3	2020-11-30	9.00	11.00	f	\N	1	\N
287	3	2020-11-30	11.00	13.00	f	\N	1	\N
287	3	2020-11-30	13.00	15.00	f	\N	1	\N
287	3	2020-11-30	15.00	17.00	f	\N	1	\N
287	3	2020-11-30	17.00	18.00	f	\N	1	\N
196	1	2020-11-30	9.00	11.00	f	\N	1	\N
196	1	2020-11-30	11.00	13.00	f	\N	1	\N
196	1	2020-11-30	13.00	15.00	f	\N	1	\N
196	1	2020-11-30	15.00	17.00	f	\N	1	\N
196	1	2020-11-30	17.00	18.00	f	\N	1	\N
97	1	2020-11-30	9.00	11.00	f	\N	1	\N
97	1	2020-11-30	11.00	13.00	f	\N	1	\N
97	1	2020-11-30	13.00	15.00	f	\N	1	\N
97	1	2020-11-30	15.00	17.00	f	\N	1	\N
97	1	2020-11-30	17.00	18.00	f	\N	1	\N
197	1	2020-11-30	9.00	11.00	f	\N	1	\N
197	1	2020-11-30	11.00	13.00	f	\N	1	\N
197	1	2020-11-30	13.00	15.00	f	\N	1	\N
197	1	2020-11-30	15.00	17.00	f	\N	1	\N
197	1	2020-11-30	17.00	18.00	f	\N	1	\N
135	1	2020-11-30	9.00	11.00	f	\N	1	\N
135	1	2020-11-30	11.00	13.00	f	\N	1	\N
135	1	2020-11-30	13.00	15.00	f	\N	1	\N
135	1	2020-11-30	15.00	17.00	f	\N	1	\N
111	2	2020-11-26	12.00	14.00	f	\N	1	\N
135	1	2020-11-30	17.00	18.00	f	\N	1	\N
136	1	2020-11-30	9.00	11.00	f	\N	1	\N
136	1	2020-11-30	11.00	13.00	f	\N	1	\N
136	1	2020-11-30	13.00	15.00	f	\N	1	\N
136	1	2020-11-30	15.00	17.00	f	\N	1	\N
136	1	2020-11-30	17.00	18.00	f	\N	1	\N
137	1	2020-11-30	9.00	11.00	f	\N	1	\N
137	1	2020-11-30	11.00	13.00	f	\N	1	\N
137	1	2020-11-30	13.00	15.00	f	\N	1	\N
137	1	2020-11-30	15.00	17.00	f	\N	1	\N
137	1	2020-11-30	17.00	18.00	f	\N	1	\N
195	1	2020-11-30	9.00	11.00	f	\N	1	\N
195	1	2020-11-30	11.00	13.00	f	\N	1	\N
195	1	2020-11-30	13.00	15.00	f	\N	1	\N
195	1	2020-11-30	15.00	17.00	f	\N	1	\N
195	1	2020-11-30	17.00	18.00	f	\N	1	\N
138	1	2020-11-30	9.00	11.00	f	\N	1	\N
138	1	2020-11-30	11.00	13.00	f	\N	1	\N
138	1	2020-11-30	13.00	15.00	f	\N	1	\N
138	1	2020-11-30	15.00	17.00	f	\N	1	\N
138	1	2020-11-30	17.00	18.00	f	\N	1	\N
139	1	2020-11-30	9.00	11.00	f	\N	1	\N
139	1	2020-11-30	11.00	13.00	f	\N	1	\N
139	1	2020-11-30	13.00	15.00	f	\N	1	\N
139	1	2020-11-30	15.00	17.00	f	\N	1	\N
139	1	2020-11-30	17.00	18.00	f	\N	1	\N
140	1	2020-11-30	9.00	11.00	f	\N	1	\N
140	1	2020-11-30	11.00	13.00	f	\N	1	\N
140	1	2020-11-30	13.00	15.00	f	\N	1	\N
140	1	2020-11-30	15.00	17.00	f	\N	1	\N
140	1	2020-11-30	17.00	18.00	f	\N	1	\N
141	1	2020-11-30	9.00	11.00	f	\N	1	\N
141	1	2020-11-30	11.00	13.00	f	\N	1	\N
141	1	2020-11-30	13.00	15.00	f	\N	1	\N
141	1	2020-11-30	15.00	17.00	f	\N	1	\N
141	1	2020-11-30	17.00	18.00	f	\N	1	\N
188	2	2020-11-30	9.00	11.00	f	\N	1	\N
188	2	2020-11-30	11.00	13.00	f	\N	1	\N
188	2	2020-11-30	13.00	15.00	f	\N	1	\N
188	2	2020-11-30	15.00	17.00	f	\N	1	\N
188	2	2020-11-30	17.00	18.00	f	\N	1	\N
111	2	2020-11-26	14.00	16.00	f	\N	1	\N
115	2	2020-11-23	12.00	14.00	f	\N	1	\N
115	2	2020-11-23	14.00	16.00	f	\N	1	\N
114	2	2020-11-23	10.00	12.00	f	\N	1	\N
114	2	2020-11-23	12.00	14.00	f	\N	1	\N
114	2	2020-11-23	14.00	16.00	f	\N	1	\N
113	2	2020-11-23	10.00	12.00	f	\N	1	\N
113	2	2020-11-23	12.00	14.00	f	\N	1	\N
113	2	2020-11-23	14.00	16.00	f	\N	1	\N
120	2	2020-11-23	10.00	12.00	f	\N	1	\N
120	2	2020-11-23	12.00	14.00	f	\N	1	\N
120	2	2020-11-23	14.00	16.00	f	\N	1	\N
286	3	2020-11-23	10.00	12.00	f	\N	1	\N
286	3	2020-11-23	12.00	14.00	f	\N	1	\N
286	3	2020-11-23	14.00	16.00	f	\N	1	\N
89	1	2020-11-23	9.00	11.00	f	\N	1	\N
89	1	2020-11-23	11.00	13.00	f	\N	1	\N
89	1	2020-11-23	13.00	15.00	f	\N	1	\N
287	3	2020-11-20	9.00	11.00	f	\N	1	\N
106	2	2020-11-26	10.00	12.00	f	\N	1	\N
106	2	2020-11-26	12.00	14.00	f	\N	1	\N
106	2	2020-11-26	14.00	16.00	f	\N	1	\N
107	2	2020-11-26	10.00	12.00	f	\N	1	\N
287	3	2020-11-20	11.00	13.00	f	\N	1	\N
107	2	2020-11-26	12.00	14.00	f	\N	1	\N
107	2	2020-11-26	14.00	16.00	f	\N	1	\N
109	2	2020-11-26	10.00	12.00	f	\N	1	\N
109	2	2020-11-26	12.00	14.00	f	\N	1	\N
287	3	2020-11-20	13.00	15.00	f	\N	1	\N
109	2	2020-11-26	14.00	16.00	f	\N	1	\N
133	2	2020-11-26	10.00	12.00	f	\N	1	\N
133	2	2020-11-26	12.00	14.00	f	\N	1	\N
133	2	2020-11-26	14.00	16.00	f	\N	1	\N
287	3	2020-11-20	15.00	17.00	f	\N	1	\N
134	2	2020-11-26	10.00	12.00	f	\N	1	\N
134	2	2020-11-26	12.00	14.00	f	\N	1	\N
134	2	2020-11-26	14.00	16.00	f	\N	1	\N
128	2	2020-11-26	10.00	12.00	f	\N	1	\N
287	3	2020-11-20	17.00	18.00	f	\N	1	\N
128	2	2020-11-26	12.00	14.00	f	\N	1	\N
128	2	2020-11-26	14.00	16.00	f	\N	1	\N
127	2	2020-11-26	10.00	12.00	f	\N	1	\N
127	2	2020-11-26	12.00	14.00	f	\N	1	\N
196	1	2020-11-20	9.00	11.00	f	\N	1	\N
127	2	2020-11-26	14.00	16.00	f	\N	1	\N
126	2	2020-11-26	10.00	12.00	f	\N	1	\N
126	2	2020-11-26	12.00	14.00	f	\N	1	\N
126	2	2020-11-26	14.00	16.00	f	\N	1	\N
196	1	2020-11-20	11.00	13.00	f	\N	1	\N
125	2	2020-11-26	10.00	12.00	f	\N	1	\N
125	2	2020-11-26	12.00	14.00	f	\N	1	\N
125	2	2020-11-26	14.00	16.00	f	\N	1	\N
132	2	2020-11-26	10.00	12.00	f	\N	1	\N
132	2	2020-11-26	12.00	14.00	f	\N	1	\N
132	2	2020-11-26	14.00	16.00	f	\N	1	\N
131	2	2020-11-26	10.00	12.00	f	\N	1	\N
131	2	2020-11-26	12.00	14.00	f	\N	1	\N
131	2	2020-11-26	14.00	16.00	f	\N	1	\N
130	2	2020-11-26	10.00	12.00	f	\N	1	\N
130	2	2020-11-26	12.00	14.00	f	\N	1	\N
130	2	2020-11-26	14.00	16.00	f	\N	1	\N
129	2	2020-11-26	10.00	12.00	f	\N	1	\N
129	2	2020-11-26	12.00	14.00	f	\N	1	\N
129	2	2020-11-26	14.00	16.00	f	\N	1	\N
124	2	2020-11-26	10.00	12.00	f	\N	1	\N
124	2	2020-11-26	12.00	14.00	f	\N	1	\N
89	1	2020-11-23	15.00	17.00	f	\N	1	\N
89	1	2020-11-23	17.00	18.00	f	\N	1	\N
124	2	2020-11-26	14.00	16.00	f	\N	1	\N
117	2	2020-11-26	10.00	12.00	f	\N	1	\N
117	2	2020-11-26	12.00	14.00	f	\N	1	\N
117	2	2020-11-26	14.00	16.00	f	\N	1	\N
123	2	2020-11-26	10.00	12.00	f	\N	1	\N
123	2	2020-11-26	12.00	14.00	f	\N	1	\N
123	2	2020-11-26	14.00	16.00	f	\N	1	\N
121	2	2020-11-26	10.00	12.00	f	\N	1	\N
300	1	2020-11-23	9.00	11.00	f	\N	1	\N
121	2	2020-11-26	12.00	14.00	f	\N	1	\N
300	1	2020-11-23	11.00	13.00	f	\N	1	\N
300	1	2020-11-23	13.00	15.00	f	\N	1	\N
300	1	2020-11-23	15.00	17.00	f	\N	1	\N
300	1	2020-11-23	17.00	18.00	f	\N	1	\N
298	1	2020-11-23	9.00	11.00	f	\N	1	\N
298	1	2020-11-23	11.00	13.00	f	\N	1	\N
298	1	2020-11-23	13.00	15.00	f	\N	1	\N
298	1	2020-11-23	15.00	17.00	f	\N	1	\N
298	1	2020-11-23	17.00	18.00	f	\N	1	\N
95	1	2020-11-23	9.00	11.00	f	\N	1	\N
95	1	2020-11-23	11.00	13.00	f	\N	1	\N
95	1	2020-11-23	13.00	15.00	f	\N	1	\N
95	1	2020-11-23	15.00	17.00	f	\N	1	\N
95	1	2020-11-23	17.00	18.00	f	\N	1	\N
90	1	2020-11-23	9.00	11.00	f	\N	1	\N
90	1	2020-11-23	11.00	13.00	f	\N	1	\N
90	1	2020-11-23	13.00	15.00	f	\N	1	\N
90	1	2020-11-23	15.00	17.00	f	\N	1	\N
90	1	2020-11-23	17.00	18.00	f	\N	1	\N
94	1	2020-11-23	9.00	11.00	f	\N	1	\N
94	1	2020-11-23	11.00	13.00	f	\N	1	\N
94	1	2020-11-23	13.00	15.00	f	\N	1	\N
94	1	2020-11-23	15.00	17.00	f	\N	1	\N
94	1	2020-11-23	17.00	18.00	f	\N	1	\N
92	1	2020-11-23	9.00	11.00	f	\N	1	\N
92	1	2020-11-23	11.00	13.00	f	\N	1	\N
92	1	2020-11-23	13.00	15.00	f	\N	1	\N
92	1	2020-11-23	15.00	17.00	f	\N	1	\N
92	1	2020-11-23	17.00	18.00	f	\N	1	\N
93	1	2020-11-23	9.00	11.00	f	\N	1	\N
93	1	2020-11-23	11.00	13.00	f	\N	1	\N
93	1	2020-11-23	13.00	15.00	f	\N	1	\N
93	1	2020-11-23	15.00	17.00	f	\N	1	\N
93	1	2020-11-23	17.00	18.00	f	\N	1	\N
96	1	2020-11-23	9.00	11.00	f	\N	1	\N
96	1	2020-11-23	11.00	13.00	f	\N	1	\N
96	1	2020-11-23	13.00	15.00	f	\N	1	\N
96	1	2020-11-23	15.00	17.00	f	\N	1	\N
96	1	2020-11-23	17.00	18.00	f	\N	1	\N
91	1	2020-11-23	9.00	11.00	f	\N	1	\N
91	1	2020-11-23	11.00	13.00	f	\N	1	\N
91	1	2020-11-23	13.00	15.00	f	\N	1	\N
91	1	2020-11-23	15.00	17.00	f	\N	1	\N
91	1	2020-11-23	17.00	18.00	f	\N	1	\N
301	1	2020-11-23	9.00	11.00	f	\N	1	\N
301	1	2020-11-23	11.00	13.00	f	\N	1	\N
301	1	2020-11-23	13.00	15.00	f	\N	1	\N
301	1	2020-11-23	15.00	17.00	f	\N	1	\N
301	1	2020-11-23	17.00	18.00	f	\N	1	\N
299	1	2020-11-23	9.00	11.00	f	\N	1	\N
299	1	2020-11-23	11.00	13.00	f	\N	1	\N
121	2	2020-11-26	14.00	16.00	f	\N	1	\N
119	2	2020-11-26	10.00	12.00	f	\N	1	\N
119	2	2020-11-26	12.00	14.00	f	\N	1	\N
119	2	2020-11-26	14.00	16.00	f	\N	1	\N
118	2	2020-11-26	10.00	12.00	f	\N	1	\N
118	2	2020-11-26	12.00	14.00	f	\N	1	\N
118	2	2020-11-26	14.00	16.00	f	\N	1	\N
110	2	2020-11-26	10.00	12.00	f	\N	1	\N
110	2	2020-11-26	12.00	14.00	f	\N	1	\N
110	2	2020-11-26	14.00	16.00	f	\N	1	\N
108	2	2020-11-26	10.00	12.00	f	\N	1	\N
108	2	2020-11-26	12.00	14.00	f	\N	1	\N
108	2	2020-11-26	14.00	16.00	f	\N	1	\N
116	2	2020-11-26	10.00	12.00	f	\N	1	\N
116	2	2020-11-26	12.00	14.00	f	\N	1	\N
116	2	2020-11-26	14.00	16.00	f	\N	1	\N
115	2	2020-11-26	10.00	12.00	f	\N	1	\N
115	2	2020-11-26	12.00	14.00	f	\N	1	\N
115	2	2020-11-26	14.00	16.00	f	\N	1	\N
114	2	2020-11-26	10.00	12.00	f	\N	1	\N
114	2	2020-11-26	12.00	14.00	f	\N	1	\N
114	2	2020-11-26	14.00	16.00	f	\N	1	\N
113	2	2020-11-26	10.00	12.00	f	\N	1	\N
113	2	2020-11-26	12.00	14.00	f	\N	1	\N
113	2	2020-11-26	14.00	16.00	f	\N	1	\N
120	2	2020-11-26	10.00	12.00	f	\N	1	\N
120	2	2020-11-26	12.00	14.00	f	\N	1	\N
120	2	2020-11-26	14.00	16.00	f	\N	1	\N
286	3	2020-11-26	10.00	12.00	f	\N	1	\N
286	3	2020-11-26	12.00	14.00	f	\N	1	\N
286	3	2020-11-26	14.00	16.00	f	\N	1	\N
89	1	2020-11-26	9.00	11.00	f	\N	1	\N
89	1	2020-11-26	11.00	13.00	f	\N	1	\N
89	1	2020-11-26	13.00	15.00	f	\N	1	\N
89	1	2020-11-26	15.00	17.00	f	\N	1	\N
89	1	2020-11-26	17.00	18.00	f	\N	1	\N
300	1	2020-11-26	9.00	11.00	f	\N	1	\N
300	1	2020-11-26	11.00	13.00	f	\N	1	\N
300	1	2020-11-26	13.00	15.00	f	\N	1	\N
300	1	2020-11-26	15.00	17.00	f	\N	1	\N
299	1	2020-11-23	13.00	15.00	f	\N	1	\N
299	1	2020-11-23	15.00	17.00	f	\N	1	\N
299	1	2020-11-23	17.00	18.00	f	\N	1	\N
196	1	2020-11-20	13.00	15.00	f	\N	1	\N
300	1	2020-11-26	17.00	18.00	f	\N	1	\N
298	1	2020-11-26	9.00	11.00	f	\N	1	\N
176	2	2020-11-23	9.00	11.00	f	\N	1	\N
196	1	2020-11-20	15.00	17.00	f	\N	1	\N
298	1	2020-11-26	11.00	13.00	f	\N	1	\N
298	1	2020-11-26	13.00	15.00	f	\N	1	\N
298	1	2020-11-26	15.00	17.00	f	\N	1	\N
298	1	2020-11-26	17.00	18.00	f	\N	1	\N
95	1	2020-11-26	9.00	11.00	f	\N	1	\N
95	1	2020-11-26	11.00	13.00	f	\N	1	\N
95	1	2020-11-26	13.00	15.00	f	\N	1	\N
95	1	2020-11-26	15.00	17.00	f	\N	1	\N
95	1	2020-11-26	17.00	18.00	f	\N	1	\N
90	1	2020-11-26	9.00	11.00	f	\N	1	\N
90	1	2020-11-26	11.00	13.00	f	\N	1	\N
90	1	2020-11-26	13.00	15.00	f	\N	1	\N
90	1	2020-11-26	15.00	17.00	f	\N	1	\N
90	1	2020-11-26	17.00	18.00	f	\N	1	\N
94	1	2020-11-26	9.00	11.00	f	\N	1	\N
94	1	2020-11-26	11.00	13.00	f	\N	1	\N
94	1	2020-11-26	13.00	15.00	f	\N	1	\N
94	1	2020-11-26	15.00	17.00	f	\N	1	\N
94	1	2020-11-26	17.00	18.00	f	\N	1	\N
92	1	2020-11-26	9.00	11.00	f	\N	1	\N
92	1	2020-11-26	11.00	13.00	f	\N	1	\N
92	1	2020-11-26	13.00	15.00	f	\N	1	\N
92	1	2020-11-26	15.00	17.00	f	\N	1	\N
92	1	2020-11-26	17.00	18.00	f	\N	1	\N
93	1	2020-11-26	9.00	11.00	f	\N	1	\N
93	1	2020-11-26	11.00	13.00	f	\N	1	\N
93	1	2020-11-26	13.00	15.00	f	\N	1	\N
93	1	2020-11-26	15.00	17.00	f	\N	1	\N
93	1	2020-11-26	17.00	18.00	f	\N	1	\N
96	1	2020-11-26	9.00	11.00	f	\N	1	\N
96	1	2020-11-26	11.00	13.00	f	\N	1	\N
96	1	2020-11-26	13.00	15.00	f	\N	1	\N
96	1	2020-11-26	15.00	17.00	f	\N	1	\N
96	1	2020-11-26	17.00	18.00	f	\N	1	\N
91	1	2020-11-26	9.00	11.00	f	\N	1	\N
91	1	2020-11-26	11.00	13.00	f	\N	1	\N
91	1	2020-11-26	13.00	15.00	f	\N	1	\N
91	1	2020-11-26	15.00	17.00	f	\N	1	\N
91	1	2020-11-26	17.00	18.00	f	\N	1	\N
301	1	2020-11-26	9.00	11.00	f	\N	1	\N
301	1	2020-11-26	11.00	13.00	f	\N	1	\N
301	1	2020-11-26	13.00	15.00	f	\N	1	\N
301	1	2020-11-26	15.00	17.00	f	\N	1	\N
301	1	2020-11-26	17.00	18.00	f	\N	1	\N
299	1	2020-11-26	9.00	11.00	f	\N	1	\N
196	1	2020-11-20	17.00	18.00	f	\N	1	\N
299	1	2020-11-26	11.00	13.00	f	\N	1	\N
97	1	2020-11-20	9.00	11.00	f	\N	1	\N
299	1	2020-11-26	13.00	15.00	f	\N	1	\N
299	1	2020-11-26	15.00	17.00	f	\N	1	\N
299	1	2020-11-26	17.00	18.00	f	\N	1	\N
176	2	2020-11-26	9.00	11.00	f	\N	1	\N
176	2	2020-11-23	11.00	13.00	f	\N	1	\N
176	2	2020-11-23	13.00	15.00	f	\N	1	\N
176	2	2020-11-23	15.00	17.00	f	\N	1	\N
176	2	2020-11-23	17.00	18.00	f	\N	1	\N
175	2	2020-11-23	9.00	11.00	f	\N	1	\N
175	2	2020-11-23	11.00	13.00	f	\N	1	\N
97	1	2020-11-20	11.00	13.00	f	\N	1	\N
175	2	2020-11-23	13.00	15.00	f	\N	1	\N
175	2	2020-11-23	15.00	17.00	f	\N	1	\N
175	2	2020-11-23	17.00	18.00	f	\N	1	\N
97	1	2020-11-20	13.00	15.00	f	\N	1	\N
97	1	2020-11-20	15.00	17.00	f	\N	1	\N
97	1	2020-11-20	17.00	18.00	f	\N	1	\N
197	1	2020-11-20	9.00	11.00	f	\N	1	\N
174	2	2020-11-23	9.00	11.00	f	\N	1	\N
174	2	2020-11-23	11.00	13.00	f	\N	1	\N
174	2	2020-11-23	13.00	15.00	f	\N	1	\N
174	2	2020-11-23	15.00	17.00	f	\N	1	\N
174	2	2020-11-23	17.00	18.00	f	\N	1	\N
179	2	2020-11-23	9.00	11.00	f	\N	1	\N
179	2	2020-11-23	11.00	13.00	f	\N	1	\N
179	2	2020-11-23	13.00	15.00	f	\N	1	\N
179	2	2020-11-23	15.00	17.00	f	\N	1	\N
179	2	2020-11-23	17.00	18.00	f	\N	1	\N
178	2	2020-11-23	9.00	11.00	f	\N	1	\N
197	1	2020-11-20	11.00	13.00	f	\N	1	\N
176	2	2020-11-26	11.00	13.00	f	\N	1	\N
176	2	2020-11-26	13.00	15.00	f	\N	1	\N
176	2	2020-11-26	15.00	17.00	f	\N	1	\N
176	2	2020-11-26	17.00	18.00	f	\N	1	\N
175	2	2020-11-26	9.00	11.00	f	\N	1	\N
175	2	2020-11-26	11.00	13.00	f	\N	1	\N
175	2	2020-11-26	13.00	15.00	f	\N	1	\N
175	2	2020-11-26	15.00	17.00	f	\N	1	\N
175	2	2020-11-26	17.00	18.00	f	\N	1	\N
174	2	2020-11-26	9.00	11.00	f	\N	1	\N
174	2	2020-11-26	11.00	13.00	f	\N	1	\N
174	2	2020-11-26	13.00	15.00	f	\N	1	\N
174	2	2020-11-26	15.00	17.00	f	\N	1	\N
174	2	2020-11-26	17.00	18.00	f	\N	1	\N
179	2	2020-11-26	9.00	11.00	f	\N	1	\N
179	2	2020-11-26	11.00	13.00	f	\N	1	\N
179	2	2020-11-26	13.00	15.00	f	\N	1	\N
179	2	2020-11-26	15.00	17.00	f	\N	1	\N
179	2	2020-11-26	17.00	18.00	f	\N	1	\N
178	2	2020-11-26	9.00	11.00	f	\N	1	\N
178	2	2020-11-26	11.00	13.00	f	\N	1	\N
178	2	2020-11-26	13.00	15.00	f	\N	1	\N
178	2	2020-11-26	15.00	17.00	f	\N	1	\N
178	2	2020-11-26	17.00	18.00	f	\N	1	\N
177	2	2020-11-26	9.00	11.00	f	\N	1	\N
197	1	2020-11-20	13.00	15.00	f	\N	1	\N
177	2	2020-11-26	11.00	13.00	f	\N	1	\N
177	2	2020-11-26	13.00	15.00	f	\N	1	\N
177	2	2020-11-26	15.00	17.00	f	\N	1	\N
177	2	2020-11-26	17.00	18.00	f	\N	1	\N
192	2	2020-11-26	9.00	11.00	f	\N	1	\N
192	2	2020-11-26	11.00	13.00	f	\N	1	\N
192	2	2020-11-26	13.00	15.00	f	\N	1	\N
192	2	2020-11-26	15.00	17.00	f	\N	1	\N
192	2	2020-11-26	17.00	18.00	f	\N	1	\N
197	1	2020-11-20	15.00	17.00	f	\N	1	\N
197	1	2020-11-20	17.00	18.00	f	\N	1	\N
135	1	2020-11-20	9.00	11.00	f	\N	1	\N
135	1	2020-11-20	11.00	13.00	f	\N	1	\N
135	1	2020-11-20	13.00	15.00	f	\N	1	\N
135	1	2020-11-20	15.00	17.00	f	\N	1	\N
135	1	2020-11-20	17.00	18.00	f	\N	1	\N
136	1	2020-11-20	9.00	11.00	f	\N	1	\N
136	1	2020-11-20	11.00	13.00	f	\N	1	\N
136	1	2020-11-20	13.00	15.00	f	\N	1	\N
136	1	2020-11-20	15.00	17.00	f	\N	1	\N
136	1	2020-11-20	17.00	18.00	f	\N	1	\N
137	1	2020-11-20	9.00	11.00	f	\N	1	\N
137	1	2020-11-20	11.00	13.00	f	\N	1	\N
137	1	2020-11-20	13.00	15.00	f	\N	1	\N
137	1	2020-11-20	15.00	17.00	f	\N	1	\N
137	1	2020-11-20	17.00	18.00	f	\N	1	\N
195	1	2020-11-20	9.00	11.00	f	\N	1	\N
195	1	2020-11-20	11.00	13.00	f	\N	1	\N
195	1	2020-11-20	13.00	15.00	f	\N	1	\N
195	1	2020-11-20	15.00	17.00	f	\N	1	\N
195	1	2020-11-20	17.00	18.00	f	\N	1	\N
138	1	2020-11-20	9.00	11.00	f	\N	1	\N
138	1	2020-11-20	11.00	13.00	f	\N	1	\N
138	1	2020-11-20	13.00	15.00	f	\N	1	\N
138	1	2020-11-20	15.00	17.00	f	\N	1	\N
138	1	2020-11-20	17.00	18.00	f	\N	1	\N
139	1	2020-11-20	9.00	11.00	f	\N	1	\N
139	1	2020-11-20	11.00	13.00	f	\N	1	\N
139	1	2020-11-20	13.00	15.00	f	\N	1	\N
139	1	2020-11-20	15.00	17.00	f	\N	1	\N
139	1	2020-11-20	17.00	18.00	f	\N	1	\N
140	1	2020-11-20	9.00	11.00	f	\N	1	\N
140	1	2020-11-20	11.00	13.00	f	\N	1	\N
140	1	2020-11-20	13.00	15.00	f	\N	1	\N
140	1	2020-11-20	15.00	17.00	f	\N	1	\N
140	1	2020-11-20	17.00	18.00	f	\N	1	\N
141	1	2020-11-20	9.00	11.00	f	\N	1	\N
141	1	2020-11-20	11.00	13.00	f	\N	1	\N
141	1	2020-11-20	13.00	15.00	f	\N	1	\N
141	1	2020-11-20	15.00	17.00	f	\N	1	\N
141	1	2020-11-20	17.00	18.00	f	\N	1	\N
178	2	2020-11-23	11.00	13.00	f	\N	1	\N
188	2	2020-11-20	9.00	11.00	f	\N	1	\N
188	2	2020-11-20	11.00	13.00	f	\N	1	\N
188	2	2020-11-20	13.00	15.00	f	\N	1	\N
188	2	2020-11-20	15.00	17.00	f	\N	1	\N
188	2	2020-11-20	17.00	18.00	f	\N	1	\N
248	2	2020-11-20	9.00	11.00	f	\N	1	\N
248	2	2020-11-20	11.00	13.00	f	\N	1	\N
248	2	2020-11-20	13.00	15.00	f	\N	1	\N
248	2	2020-11-20	15.00	17.00	f	\N	1	\N
248	2	2020-11-20	17.00	18.00	f	\N	1	\N
182	2	2020-11-20	9.00	11.00	f	\N	1	\N
182	2	2020-11-20	11.00	13.00	f	\N	1	\N
182	2	2020-11-20	13.00	15.00	f	\N	1	\N
182	2	2020-11-20	15.00	17.00	f	\N	1	\N
182	2	2020-11-20	17.00	18.00	f	\N	1	\N
183	2	2020-11-20	9.00	11.00	f	\N	1	\N
183	2	2020-11-20	11.00	13.00	f	\N	1	\N
183	2	2020-11-20	13.00	15.00	f	\N	1	\N
183	2	2020-11-20	15.00	17.00	f	\N	1	\N
183	2	2020-11-20	17.00	18.00	f	\N	1	\N
181	2	2020-11-20	9.00	11.00	f	\N	1	\N
178	2	2020-11-23	13.00	15.00	f	\N	1	\N
178	2	2020-11-23	15.00	17.00	f	\N	1	\N
178	2	2020-11-23	17.00	18.00	f	\N	1	\N
177	2	2020-11-23	9.00	11.00	f	\N	1	\N
181	2	2020-11-20	11.00	13.00	f	\N	1	\N
181	2	2020-11-20	13.00	15.00	f	\N	1	\N
181	2	2020-11-20	15.00	17.00	f	\N	1	\N
181	2	2020-11-20	17.00	18.00	f	\N	1	\N
187	2	2020-11-20	9.00	11.00	f	\N	1	\N
187	2	2020-11-20	11.00	13.00	f	\N	1	\N
187	2	2020-11-20	13.00	15.00	f	\N	1	\N
187	2	2020-11-20	15.00	17.00	f	\N	1	\N
187	2	2020-11-20	17.00	18.00	f	\N	1	\N
184	2	2020-11-20	9.00	11.00	f	\N	1	\N
184	2	2020-11-20	11.00	13.00	f	\N	1	\N
184	2	2020-11-20	13.00	15.00	f	\N	1	\N
177	2	2020-11-23	11.00	13.00	f	\N	1	\N
184	2	2020-11-20	15.00	17.00	f	\N	1	\N
184	2	2020-11-20	17.00	18.00	f	\N	1	\N
249	2	2020-11-20	9.00	11.00	f	\N	1	\N
249	2	2020-11-20	11.00	13.00	f	\N	1	\N
249	2	2020-11-20	13.00	15.00	f	\N	1	\N
249	2	2020-11-20	15.00	17.00	f	\N	1	\N
249	2	2020-11-20	17.00	18.00	f	\N	1	\N
186	2	2020-11-20	9.00	11.00	f	\N	1	\N
186	2	2020-11-20	11.00	13.00	f	\N	1	\N
186	2	2020-11-20	13.00	15.00	f	\N	1	\N
186	2	2020-11-20	15.00	17.00	f	\N	1	\N
186	2	2020-11-20	17.00	18.00	f	\N	1	\N
180	2	2020-11-20	9.00	11.00	f	\N	1	\N
180	2	2020-11-20	11.00	13.00	f	\N	1	\N
180	2	2020-11-20	13.00	15.00	f	\N	1	\N
180	2	2020-11-20	15.00	17.00	f	\N	1	\N
180	2	2020-11-20	17.00	18.00	f	\N	1	\N
185	2	2020-11-20	9.00	11.00	f	\N	1	\N
185	2	2020-11-20	11.00	13.00	f	\N	1	\N
185	2	2020-11-20	13.00	15.00	f	\N	1	\N
185	2	2020-11-20	15.00	17.00	f	\N	1	\N
185	2	2020-11-20	17.00	18.00	f	\N	1	\N
283	3	2020-11-20	9.00	11.00	f	\N	1	\N
283	3	2020-11-20	17.00	18.00	f	\N	1	\N
284	3	2020-11-20	9.00	11.00	f	\N	1	\N
284	3	2020-11-20	11.00	13.00	f	\N	1	\N
284	3	2020-11-20	13.00	15.00	f	\N	1	\N
284	3	2020-11-20	15.00	17.00	f	\N	1	\N
284	3	2020-11-20	17.00	18.00	f	\N	1	\N
189	1	2020-11-20	10.00	12.00	f	\N	1	\N
189	1	2020-11-20	12.00	14.00	f	\N	1	\N
189	1	2020-11-20	14.00	16.00	f	\N	1	\N
256	1	2020-11-20	10.00	12.00	f	\N	1	\N
256	1	2020-11-20	12.00	14.00	f	\N	1	\N
256	1	2020-11-20	14.00	16.00	f	\N	1	\N
98	1	2020-11-20	10.00	12.00	f	\N	1	\N
98	1	2020-11-20	12.00	14.00	f	\N	1	\N
98	1	2020-11-20	14.00	16.00	f	\N	1	\N
101	1	2020-11-20	14.00	16.00	f	\N	1	\N
283	3	2020-11-20	15.00	17.00	t	5081048035	2	V
283	3	2020-11-20	13.00	15.00	t	5081048035	2	V
311	1	2020-11-20	10.00	12.00	f	\N	1	\N
311	1	2020-11-20	12.00	14.00	f	\N	1	\N
311	1	2020-11-20	14.00	16.00	f	\N	1	\N
177	2	2020-11-23	13.00	15.00	f	\N	1	\N
193	2	2020-11-26	9.00	11.00	f	\N	1	\N
193	2	2020-11-26	11.00	13.00	f	\N	1	\N
193	2	2020-11-26	13.00	15.00	f	\N	1	\N
193	2	2020-11-26	15.00	17.00	f	\N	1	\N
193	2	2020-11-26	17.00	18.00	f	\N	1	\N
302	3	2020-11-26	9.00	11.00	f	\N	1	\N
302	3	2020-11-26	11.00	13.00	f	\N	1	\N
302	3	2020-11-26	13.00	15.00	f	\N	1	\N
302	3	2020-11-26	15.00	17.00	f	\N	1	\N
302	3	2020-11-26	17.00	18.00	f	\N	1	\N
305	3	2020-11-26	9.00	11.00	f	\N	1	\N
305	3	2020-11-26	11.00	13.00	f	\N	1	\N
305	3	2020-11-26	13.00	15.00	f	\N	1	\N
305	3	2020-11-26	15.00	17.00	f	\N	1	\N
305	3	2020-11-26	17.00	18.00	f	\N	1	\N
314	3	2020-11-26	9.00	11.00	f	\N	1	\N
314	3	2020-11-26	11.00	13.00	f	\N	1	\N
314	3	2020-11-26	13.00	15.00	f	\N	1	\N
314	3	2020-11-26	15.00	17.00	f	\N	1	\N
314	3	2020-11-26	17.00	18.00	f	\N	1	\N
306	3	2020-11-26	9.00	11.00	f	\N	1	\N
306	3	2020-11-26	11.00	13.00	f	\N	1	\N
306	3	2020-11-26	13.00	15.00	f	\N	1	\N
306	3	2020-11-26	15.00	17.00	f	\N	1	\N
306	3	2020-11-26	17.00	18.00	f	\N	1	\N
215	1	2020-11-26	6.00	8.00	f	\N	1	\N
215	1	2020-11-26	8.00	10.00	f	\N	1	\N
215	1	2020-11-26	10.00	12.00	f	\N	1	\N
215	1	2020-11-26	12.00	14.00	f	\N	1	\N
215	1	2020-11-26	14.00	16.00	f	\N	1	\N
215	1	2020-11-26	16.00	18.00	f	\N	1	\N
215	1	2020-11-26	18.00	20.00	f	\N	1	\N
283	3	2020-11-20	11.00	13.00	f	\N	1	\N
309	1	2020-11-20	14.00	16.00	t	8270580258	2	Ellen
248	2	2020-11-30	9.00	11.00	f	\N	1	\N
190	1	2020-11-20	10.00	12.00	f	\N	1	\N
101	1	2020-11-20	10.00	12.00	t	8328392746	2	tobbe
101	1	2020-11-20	12.00	14.00	t	8328392746	2	tobbe
215	1	2020-11-26	20.00	22.00	f	\N	1	\N
215	1	2020-11-26	22.00	23.00	f	\N	1	\N
231	1	2020-11-26	6.00	8.00	f	\N	1	\N
231	1	2020-11-26	8.00	10.00	f	\N	1	\N
231	1	2020-11-26	10.00	12.00	f	\N	1	\N
231	1	2020-11-26	12.00	14.00	f	\N	1	\N
231	1	2020-11-26	14.00	16.00	f	\N	1	\N
231	1	2020-11-26	16.00	18.00	f	\N	1	\N
231	1	2020-11-26	18.00	20.00	f	\N	1	\N
231	1	2020-11-26	20.00	22.00	f	\N	1	\N
231	1	2020-11-26	22.00	23.00	f	\N	1	\N
88	1	2020-11-26	6.00	8.00	f	\N	1	\N
88	1	2020-11-26	8.00	10.00	f	\N	1	\N
88	1	2020-11-26	10.00	12.00	f	\N	1	\N
88	1	2020-11-26	12.00	14.00	f	\N	1	\N
88	1	2020-11-26	14.00	16.00	f	\N	1	\N
88	1	2020-11-26	16.00	18.00	f	\N	1	\N
88	1	2020-11-26	18.00	20.00	f	\N	1	\N
88	1	2020-11-26	20.00	22.00	f	\N	1	\N
88	1	2020-11-26	22.00	23.00	f	\N	1	\N
80	1	2020-11-26	6.00	8.00	f	\N	1	\N
80	1	2020-11-26	8.00	10.00	f	\N	1	\N
80	1	2020-11-26	10.00	12.00	f	\N	1	\N
80	1	2020-11-26	12.00	14.00	f	\N	1	\N
80	1	2020-11-26	14.00	16.00	f	\N	1	\N
80	1	2020-11-26	16.00	18.00	f	\N	1	\N
80	1	2020-11-26	18.00	20.00	f	\N	1	\N
80	1	2020-11-26	20.00	22.00	f	\N	1	\N
80	1	2020-11-26	22.00	23.00	f	\N	1	\N
216	1	2020-11-26	6.00	8.00	f	\N	1	\N
216	1	2020-11-26	8.00	10.00	f	\N	1	\N
216	1	2020-11-26	10.00	12.00	f	\N	1	\N
216	1	2020-11-26	12.00	14.00	f	\N	1	\N
216	1	2020-11-26	14.00	16.00	f	\N	1	\N
216	1	2020-11-26	16.00	18.00	f	\N	1	\N
216	1	2020-11-26	18.00	20.00	f	\N	1	\N
216	1	2020-11-26	20.00	22.00	f	\N	1	\N
216	1	2020-11-26	22.00	23.00	f	\N	1	\N
191	1	2020-11-26	6.00	8.00	f	\N	1	\N
191	1	2020-11-26	8.00	10.00	f	\N	1	\N
191	1	2020-11-26	10.00	12.00	f	\N	1	\N
191	1	2020-11-26	12.00	14.00	f	\N	1	\N
191	1	2020-11-26	14.00	16.00	f	\N	1	\N
191	1	2020-11-26	16.00	18.00	f	\N	1	\N
191	1	2020-11-26	18.00	20.00	f	\N	1	\N
191	1	2020-11-26	20.00	22.00	f	\N	1	\N
191	1	2020-11-26	22.00	23.00	f	\N	1	\N
81	1	2020-11-26	6.00	8.00	f	\N	1	\N
81	1	2020-11-26	8.00	10.00	f	\N	1	\N
81	1	2020-11-26	10.00	12.00	f	\N	1	\N
81	1	2020-11-26	12.00	14.00	f	\N	1	\N
81	1	2020-11-26	14.00	16.00	f	\N	1	\N
81	1	2020-11-26	16.00	18.00	f	\N	1	\N
81	1	2020-11-26	18.00	20.00	f	\N	1	\N
81	1	2020-11-26	20.00	22.00	f	\N	1	\N
81	1	2020-11-26	22.00	23.00	f	\N	1	\N
82	1	2020-11-26	6.00	8.00	f	\N	1	\N
82	1	2020-11-26	8.00	10.00	f	\N	1	\N
82	1	2020-11-26	10.00	12.00	f	\N	1	\N
82	1	2020-11-26	12.00	14.00	f	\N	1	\N
82	1	2020-11-26	14.00	16.00	f	\N	1	\N
82	1	2020-11-26	16.00	18.00	f	\N	1	\N
82	1	2020-11-26	18.00	20.00	f	\N	1	\N
82	1	2020-11-26	20.00	22.00	f	\N	1	\N
82	1	2020-11-26	22.00	23.00	f	\N	1	\N
87	1	2020-11-26	6.00	8.00	f	\N	1	\N
87	1	2020-11-26	8.00	10.00	f	\N	1	\N
87	1	2020-11-26	10.00	12.00	f	\N	1	\N
87	1	2020-11-26	12.00	14.00	f	\N	1	\N
87	1	2020-11-26	14.00	16.00	f	\N	1	\N
87	1	2020-11-26	16.00	18.00	f	\N	1	\N
87	1	2020-11-26	18.00	20.00	f	\N	1	\N
87	1	2020-11-26	20.00	22.00	f	\N	1	\N
87	1	2020-11-26	22.00	23.00	f	\N	1	\N
86	1	2020-11-26	6.00	8.00	f	\N	1	\N
86	1	2020-11-26	8.00	10.00	f	\N	1	\N
86	1	2020-11-26	10.00	12.00	f	\N	1	\N
86	1	2020-11-26	12.00	14.00	f	\N	1	\N
86	1	2020-11-26	14.00	16.00	f	\N	1	\N
86	1	2020-11-26	16.00	18.00	f	\N	1	\N
86	1	2020-11-26	18.00	20.00	f	\N	1	\N
86	1	2020-11-26	20.00	22.00	f	\N	1	\N
86	1	2020-11-26	22.00	23.00	f	\N	1	\N
201	1	2020-11-26	6.00	8.00	f	\N	1	\N
201	1	2020-11-26	8.00	10.00	f	\N	1	\N
201	1	2020-11-26	10.00	12.00	f	\N	1	\N
201	1	2020-11-26	12.00	14.00	f	\N	1	\N
201	1	2020-11-26	14.00	16.00	f	\N	1	\N
201	1	2020-11-26	16.00	18.00	f	\N	1	\N
201	1	2020-11-26	18.00	20.00	f	\N	1	\N
201	1	2020-11-26	20.00	22.00	f	\N	1	\N
201	1	2020-11-26	22.00	23.00	f	\N	1	\N
83	1	2020-11-26	6.00	8.00	f	\N	1	\N
83	1	2020-11-26	8.00	10.00	f	\N	1	\N
83	1	2020-11-26	10.00	12.00	f	\N	1	\N
83	1	2020-11-26	12.00	14.00	f	\N	1	\N
83	1	2020-11-26	14.00	16.00	f	\N	1	\N
83	1	2020-11-26	16.00	18.00	f	\N	1	\N
83	1	2020-11-26	18.00	20.00	f	\N	1	\N
83	1	2020-11-26	20.00	22.00	f	\N	1	\N
83	1	2020-11-26	22.00	23.00	f	\N	1	\N
84	1	2020-11-26	6.00	8.00	f	\N	1	\N
177	2	2020-11-23	15.00	17.00	f	\N	1	\N
190	1	2020-11-20	14.00	16.00	f	\N	1	\N
99	1	2020-11-20	10.00	12.00	f	\N	1	\N
99	1	2020-11-20	12.00	14.00	f	\N	1	\N
177	2	2020-11-23	17.00	18.00	f	\N	1	\N
192	2	2020-11-23	9.00	11.00	f	\N	1	\N
192	2	2020-11-23	11.00	13.00	f	\N	1	\N
192	2	2020-11-23	13.00	15.00	f	\N	1	\N
192	2	2020-11-23	15.00	17.00	f	\N	1	\N
192	2	2020-11-23	17.00	18.00	f	\N	1	\N
193	2	2020-11-23	9.00	11.00	f	\N	1	\N
84	1	2020-11-26	8.00	10.00	f	\N	1	\N
99	1	2020-11-20	14.00	16.00	f	\N	1	\N
84	1	2020-11-26	10.00	12.00	f	\N	1	\N
84	1	2020-11-26	12.00	14.00	f	\N	1	\N
84	1	2020-11-26	14.00	16.00	f	\N	1	\N
100	1	2020-11-20	12.00	14.00	f	\N	1	\N
100	1	2020-11-20	14.00	16.00	f	\N	1	\N
102	1	2020-11-20	10.00	12.00	f	\N	1	\N
102	1	2020-11-20	12.00	14.00	f	\N	1	\N
102	1	2020-11-20	14.00	16.00	f	\N	1	\N
84	1	2020-11-26	16.00	18.00	f	\N	1	\N
84	1	2020-11-26	18.00	20.00	f	\N	1	\N
84	1	2020-11-26	20.00	22.00	f	\N	1	\N
84	1	2020-11-26	22.00	23.00	f	\N	1	\N
194	1	2020-11-26	6.00	8.00	f	\N	1	\N
194	1	2020-11-26	8.00	10.00	f	\N	1	\N
194	1	2020-11-26	10.00	12.00	f	\N	1	\N
194	1	2020-11-26	12.00	14.00	f	\N	1	\N
194	1	2020-11-26	14.00	16.00	f	\N	1	\N
194	1	2020-11-26	16.00	18.00	f	\N	1	\N
194	1	2020-11-26	18.00	20.00	f	\N	1	\N
194	1	2020-11-26	20.00	22.00	f	\N	1	\N
194	1	2020-11-26	22.00	23.00	f	\N	1	\N
85	1	2020-11-26	6.00	8.00	f	\N	1	\N
85	1	2020-11-26	8.00	10.00	f	\N	1	\N
103	1	2020-11-20	10.00	12.00	f	\N	1	\N
85	1	2020-11-26	10.00	12.00	f	\N	1	\N
85	1	2020-11-26	12.00	14.00	f	\N	1	\N
85	1	2020-11-26	14.00	16.00	f	\N	1	\N
85	1	2020-11-26	16.00	18.00	f	\N	1	\N
85	1	2020-11-26	18.00	20.00	f	\N	1	\N
85	1	2020-11-26	20.00	22.00	f	\N	1	\N
85	1	2020-11-26	22.00	23.00	f	\N	1	\N
303	1	2020-11-26	6.00	8.00	f	\N	1	\N
303	1	2020-11-26	8.00	10.00	f	\N	1	\N
303	1	2020-11-26	10.00	12.00	f	\N	1	\N
303	1	2020-11-26	12.00	14.00	f	\N	1	\N
303	1	2020-11-26	14.00	16.00	f	\N	1	\N
303	1	2020-11-26	16.00	18.00	f	\N	1	\N
303	1	2020-11-26	18.00	20.00	f	\N	1	\N
303	1	2020-11-26	20.00	22.00	f	\N	1	\N
303	1	2020-11-26	22.00	23.00	f	\N	1	\N
304	1	2020-11-26	6.00	8.00	f	\N	1	\N
304	1	2020-11-26	8.00	10.00	f	\N	1	\N
304	1	2020-11-26	10.00	12.00	f	\N	1	\N
304	1	2020-11-26	12.00	14.00	f	\N	1	\N
304	1	2020-11-26	14.00	16.00	f	\N	1	\N
304	1	2020-11-26	16.00	18.00	f	\N	1	\N
304	1	2020-11-26	18.00	20.00	f	\N	1	\N
304	1	2020-11-26	20.00	22.00	f	\N	1	\N
304	1	2020-11-26	22.00	23.00	f	\N	1	\N
268	2	2020-11-26	6.00	8.00	f	\N	1	\N
268	2	2020-11-26	8.00	10.00	f	\N	1	\N
268	2	2020-11-26	10.00	12.00	f	\N	1	\N
268	2	2020-11-26	12.00	14.00	f	\N	1	\N
268	2	2020-11-26	14.00	16.00	f	\N	1	\N
268	2	2020-11-26	16.00	18.00	f	\N	1	\N
268	2	2020-11-26	18.00	20.00	f	\N	1	\N
268	2	2020-11-26	20.00	22.00	f	\N	1	\N
268	2	2020-11-26	22.00	23.00	f	\N	1	\N
313	3	2020-11-26	10.00	12.00	f	\N	1	\N
310	1	2020-11-20	10.00	12.00	t	8334666274	2	Maja
310	1	2020-11-20	12.00	14.00	t	8334666274	2	Maja
310	1	2020-11-20	14.00	16.00	t	5151498445	2	Malena 
314	3	2020-11-19	13.00	15.00	t	8306227208	2	N
313	3	2020-11-26	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-26	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-26	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-26	14.00	16.00	t	1122334455	5	Stängt
248	2	2020-11-30	11.00	13.00	f	\N	1	\N
103	1	2020-11-20	12.00	14.00	f	\N	1	\N
248	2	2020-11-30	13.00	15.00	f	\N	1	\N
248	2	2020-11-30	15.00	17.00	f	\N	1	\N
248	2	2020-11-30	17.00	18.00	f	\N	1	\N
182	2	2020-11-30	9.00	11.00	f	\N	1	\N
182	2	2020-11-30	11.00	13.00	f	\N	1	\N
182	2	2020-11-30	13.00	15.00	f	\N	1	\N
193	2	2020-11-23	11.00	13.00	f	\N	1	\N
308	1	2020-11-20	10.00	12.00	t	8276844584	2	Sarah 
308	1	2020-11-20	12.00	14.00	t	8276844584	2	Sarah 
308	1	2020-11-20	14.00	16.00	t	8424864264	2	M&S
182	2	2020-11-30	15.00	17.00	f	\N	1	\N
313	3	2020-11-26	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-26	18.00	20.00	t	1122334455	5	Stängt
103	1	2020-11-20	14.00	16.00	f	\N	1	\N
104	1	2020-11-20	10.00	12.00	f	\N	1	\N
312	1	2020-11-20	10.00	12.00	f	\N	1	\N
312	1	2020-11-20	12.00	14.00	f	\N	1	\N
312	1	2020-11-20	14.00	16.00	f	\N	1	\N
122	2	2020-11-20	10.00	12.00	f	\N	1	\N
122	2	2020-11-20	12.00	14.00	f	\N	1	\N
122	2	2020-11-20	14.00	16.00	f	\N	1	\N
105	2	2020-11-20	10.00	12.00	f	\N	1	\N
105	2	2020-11-20	12.00	14.00	f	\N	1	\N
105	2	2020-11-20	14.00	16.00	f	\N	1	\N
112	2	2020-11-20	10.00	12.00	f	\N	1	\N
112	2	2020-11-20	12.00	14.00	f	\N	1	\N
112	2	2020-11-20	14.00	16.00	f	\N	1	\N
111	2	2020-11-20	10.00	12.00	f	\N	1	\N
111	2	2020-11-20	12.00	14.00	f	\N	1	\N
111	2	2020-11-20	14.00	16.00	f	\N	1	\N
106	2	2020-11-20	10.00	12.00	f	\N	1	\N
106	2	2020-11-20	12.00	14.00	f	\N	1	\N
106	2	2020-11-20	14.00	16.00	f	\N	1	\N
107	2	2020-11-20	10.00	12.00	f	\N	1	\N
107	2	2020-11-20	12.00	14.00	f	\N	1	\N
107	2	2020-11-20	14.00	16.00	f	\N	1	\N
109	2	2020-11-20	10.00	12.00	f	\N	1	\N
109	2	2020-11-20	12.00	14.00	f	\N	1	\N
109	2	2020-11-20	14.00	16.00	f	\N	1	\N
133	2	2020-11-20	10.00	12.00	f	\N	1	\N
133	2	2020-11-20	12.00	14.00	f	\N	1	\N
313	3	2020-11-26	20.00	22.00	t	1122334455	5	Stängt
182	2	2020-11-30	17.00	18.00	f	\N	1	\N
133	2	2020-11-20	14.00	16.00	f	\N	1	\N
313	3	2020-11-26	22.00	23.00	t	1122334455	5	Stängt
307	1	2020-11-20	14.00	16.00	t	8427950090	2	JU
183	2	2020-11-30	9.00	11.00	f	\N	1	\N
307	1	2020-11-20	12.00	14.00	t	8427950090	2	JU
307	1	2020-11-20	10.00	12.00	f	\N	1	\N
183	2	2020-11-30	11.00	13.00	f	\N	1	\N
183	2	2020-11-30	13.00	15.00	f	\N	1	\N
183	2	2020-11-30	15.00	17.00	f	\N	1	\N
183	2	2020-11-30	17.00	18.00	f	\N	1	\N
181	2	2020-11-30	9.00	11.00	f	\N	1	\N
181	2	2020-11-30	11.00	13.00	f	\N	1	\N
181	2	2020-11-30	13.00	15.00	f	\N	1	\N
181	2	2020-11-30	15.00	17.00	f	\N	1	\N
181	2	2020-11-30	17.00	18.00	f	\N	1	\N
187	2	2020-11-30	9.00	11.00	f	\N	1	\N
187	2	2020-11-30	11.00	13.00	f	\N	1	\N
187	2	2020-11-30	13.00	15.00	f	\N	1	\N
134	2	2020-11-20	10.00	12.00	f	\N	1	\N
187	2	2020-11-30	15.00	17.00	f	\N	1	\N
187	2	2020-11-30	17.00	18.00	f	\N	1	\N
184	2	2020-11-30	9.00	11.00	f	\N	1	\N
184	2	2020-11-30	11.00	13.00	f	\N	1	\N
134	2	2020-11-20	12.00	14.00	f	\N	1	\N
184	2	2020-11-30	13.00	15.00	f	\N	1	\N
184	2	2020-11-30	15.00	17.00	f	\N	1	\N
184	2	2020-11-30	17.00	18.00	f	\N	1	\N
249	2	2020-11-30	9.00	11.00	f	\N	1	\N
134	2	2020-11-20	14.00	16.00	f	\N	1	\N
249	2	2020-11-30	11.00	13.00	f	\N	1	\N
249	2	2020-11-30	13.00	15.00	f	\N	1	\N
249	2	2020-11-30	15.00	17.00	f	\N	1	\N
249	2	2020-11-30	17.00	18.00	f	\N	1	\N
186	2	2020-11-30	9.00	11.00	f	\N	1	\N
128	2	2020-11-20	10.00	12.00	f	\N	1	\N
186	2	2020-11-30	11.00	13.00	f	\N	1	\N
186	2	2020-11-30	13.00	15.00	f	\N	1	\N
186	2	2020-11-30	15.00	17.00	f	\N	1	\N
186	2	2020-11-30	17.00	18.00	f	\N	1	\N
193	2	2020-11-23	13.00	15.00	f	\N	1	\N
180	2	2020-11-30	9.00	11.00	f	\N	1	\N
180	2	2020-11-30	11.00	13.00	f	\N	1	\N
180	2	2020-11-30	13.00	15.00	f	\N	1	\N
180	2	2020-11-30	15.00	17.00	f	\N	1	\N
180	2	2020-11-30	17.00	18.00	f	\N	1	\N
185	2	2020-11-30	9.00	11.00	f	\N	1	\N
185	2	2020-11-30	11.00	13.00	f	\N	1	\N
185	2	2020-11-30	13.00	15.00	f	\N	1	\N
185	2	2020-11-30	15.00	17.00	f	\N	1	\N
185	2	2020-11-30	17.00	18.00	f	\N	1	\N
283	3	2020-11-30	9.00	11.00	f	\N	1	\N
283	3	2020-11-30	11.00	13.00	f	\N	1	\N
283	3	2020-11-30	13.00	15.00	f	\N	1	\N
283	3	2020-11-30	15.00	17.00	f	\N	1	\N
283	3	2020-11-30	17.00	18.00	f	\N	1	\N
284	3	2020-11-30	9.00	11.00	f	\N	1	\N
284	3	2020-11-30	11.00	13.00	f	\N	1	\N
284	3	2020-11-30	13.00	15.00	f	\N	1	\N
284	3	2020-11-30	15.00	17.00	f	\N	1	\N
284	3	2020-11-30	17.00	18.00	f	\N	1	\N
189	1	2020-11-30	10.00	12.00	f	\N	1	\N
189	1	2020-11-30	12.00	14.00	f	\N	1	\N
189	1	2020-11-30	14.00	16.00	f	\N	1	\N
256	1	2020-11-30	10.00	12.00	f	\N	1	\N
256	1	2020-11-30	12.00	14.00	f	\N	1	\N
256	1	2020-11-30	14.00	16.00	f	\N	1	\N
193	2	2020-11-23	15.00	17.00	f	\N	1	\N
193	2	2020-11-23	17.00	18.00	f	\N	1	\N
104	1	2020-11-20	14.00	16.00	f	\N	1	\N
302	3	2020-11-23	9.00	11.00	f	\N	1	\N
104	1	2020-11-20	12.00	14.00	f	\N	1	\N
302	3	2020-11-23	11.00	13.00	f	\N	1	\N
302	3	2020-11-23	13.00	15.00	f	\N	1	\N
302	3	2020-11-23	15.00	17.00	f	\N	1	\N
302	3	2020-11-23	17.00	18.00	f	\N	1	\N
305	3	2020-11-23	9.00	11.00	f	\N	1	\N
305	3	2020-11-23	11.00	13.00	f	\N	1	\N
98	1	2020-11-30	10.00	12.00	f	\N	1	\N
305	3	2020-11-23	13.00	15.00	f	\N	1	\N
305	3	2020-11-23	15.00	17.00	f	\N	1	\N
305	3	2020-11-23	17.00	18.00	f	\N	1	\N
314	3	2020-11-23	17.00	18.00	f	\N	1	\N
306	3	2020-11-23	9.00	11.00	f	\N	1	\N
306	3	2020-11-23	11.00	13.00	f	\N	1	\N
306	3	2020-11-23	13.00	15.00	f	\N	1	\N
306	3	2020-11-23	15.00	17.00	f	\N	1	\N
306	3	2020-11-23	17.00	18.00	f	\N	1	\N
215	1	2020-11-23	6.00	8.00	f	\N	1	\N
215	1	2020-11-23	8.00	10.00	f	\N	1	\N
215	1	2020-11-23	10.00	12.00	f	\N	1	\N
98	1	2020-11-30	12.00	14.00	f	\N	1	\N
98	1	2020-11-30	14.00	16.00	f	\N	1	\N
101	1	2020-11-30	10.00	12.00	f	\N	1	\N
215	1	2020-11-23	12.00	14.00	f	\N	1	\N
215	1	2020-11-23	14.00	16.00	f	\N	1	\N
215	1	2020-11-23	16.00	18.00	f	\N	1	\N
215	1	2020-11-23	18.00	20.00	f	\N	1	\N
215	1	2020-11-23	20.00	22.00	f	\N	1	\N
215	1	2020-11-23	22.00	23.00	f	\N	1	\N
231	1	2020-11-23	6.00	8.00	f	\N	1	\N
231	1	2020-11-23	8.00	10.00	f	\N	1	\N
231	1	2020-11-23	10.00	12.00	f	\N	1	\N
231	1	2020-11-23	12.00	14.00	f	\N	1	\N
231	1	2020-11-23	14.00	16.00	f	\N	1	\N
231	1	2020-11-23	16.00	18.00	f	\N	1	\N
231	1	2020-11-23	18.00	20.00	f	\N	1	\N
231	1	2020-11-23	20.00	22.00	f	\N	1	\N
231	1	2020-11-23	22.00	23.00	f	\N	1	\N
88	1	2020-11-23	6.00	8.00	f	\N	1	\N
88	1	2020-11-23	8.00	10.00	f	\N	1	\N
88	1	2020-11-23	10.00	12.00	f	\N	1	\N
88	1	2020-11-23	12.00	14.00	f	\N	1	\N
88	1	2020-11-23	14.00	16.00	f	\N	1	\N
88	1	2020-11-23	16.00	18.00	f	\N	1	\N
88	1	2020-11-23	18.00	20.00	f	\N	1	\N
88	1	2020-11-23	20.00	22.00	f	\N	1	\N
88	1	2020-11-23	22.00	23.00	f	\N	1	\N
80	1	2020-11-23	6.00	8.00	f	\N	1	\N
80	1	2020-11-23	8.00	10.00	f	\N	1	\N
80	1	2020-11-23	10.00	12.00	f	\N	1	\N
80	1	2020-11-23	12.00	14.00	f	\N	1	\N
80	1	2020-11-23	14.00	16.00	f	\N	1	\N
80	1	2020-11-23	16.00	18.00	f	\N	1	\N
80	1	2020-11-23	18.00	20.00	f	\N	1	\N
80	1	2020-11-23	20.00	22.00	f	\N	1	\N
80	1	2020-11-23	22.00	23.00	f	\N	1	\N
216	1	2020-11-23	6.00	8.00	f	\N	1	\N
216	1	2020-11-23	8.00	10.00	f	\N	1	\N
216	1	2020-11-23	10.00	12.00	f	\N	1	\N
216	1	2020-11-23	12.00	14.00	f	\N	1	\N
216	1	2020-11-23	14.00	16.00	f	\N	1	\N
216	1	2020-11-23	16.00	18.00	f	\N	1	\N
216	1	2020-11-23	18.00	20.00	f	\N	1	\N
101	1	2020-11-30	12.00	14.00	f	\N	1	\N
101	1	2020-11-30	14.00	16.00	f	\N	1	\N
309	1	2020-11-30	10.00	12.00	f	\N	1	\N
309	1	2020-11-30	12.00	14.00	f	\N	1	\N
309	1	2020-11-30	14.00	16.00	f	\N	1	\N
311	1	2020-11-30	10.00	12.00	f	\N	1	\N
311	1	2020-11-30	12.00	14.00	f	\N	1	\N
311	1	2020-11-30	14.00	16.00	f	\N	1	\N
190	1	2020-11-30	10.00	12.00	f	\N	1	\N
190	1	2020-11-30	12.00	14.00	f	\N	1	\N
190	1	2020-11-30	14.00	16.00	f	\N	1	\N
99	1	2020-11-30	10.00	12.00	f	\N	1	\N
99	1	2020-11-30	12.00	14.00	f	\N	1	\N
216	1	2020-11-23	20.00	22.00	f	\N	1	\N
216	1	2020-11-23	22.00	23.00	f	\N	1	\N
191	1	2020-11-23	6.00	8.00	f	\N	1	\N
191	1	2020-11-23	8.00	10.00	f	\N	1	\N
191	1	2020-11-23	10.00	12.00	f	\N	1	\N
191	1	2020-11-23	12.00	14.00	f	\N	1	\N
191	1	2020-11-23	14.00	16.00	f	\N	1	\N
191	1	2020-11-23	16.00	18.00	f	\N	1	\N
191	1	2020-11-23	18.00	20.00	f	\N	1	\N
191	1	2020-11-23	20.00	22.00	f	\N	1	\N
191	1	2020-11-23	22.00	23.00	f	\N	1	\N
314	3	2020-11-23	15.00	17.00	t	8306227208	2	H
314	3	2020-11-23	9.00	11.00	t	8403704328	2	NH
314	3	2020-11-23	11.00	13.00	t	8403704328	2	NH
128	2	2020-11-20	12.00	14.00	f	\N	1	\N
128	2	2020-11-20	14.00	16.00	f	\N	1	\N
127	2	2020-11-20	10.00	12.00	f	\N	1	\N
127	2	2020-11-20	12.00	14.00	f	\N	1	\N
127	2	2020-11-20	14.00	16.00	f	\N	1	\N
126	2	2020-11-20	10.00	12.00	f	\N	1	\N
126	2	2020-11-20	12.00	14.00	f	\N	1	\N
126	2	2020-11-20	14.00	16.00	f	\N	1	\N
125	2	2020-11-20	10.00	12.00	f	\N	1	\N
125	2	2020-11-20	12.00	14.00	f	\N	1	\N
125	2	2020-11-20	14.00	16.00	f	\N	1	\N
132	2	2020-11-20	10.00	12.00	f	\N	1	\N
132	2	2020-11-20	12.00	14.00	f	\N	1	\N
132	2	2020-11-20	14.00	16.00	f	\N	1	\N
131	2	2020-11-20	10.00	12.00	f	\N	1	\N
131	2	2020-11-20	12.00	14.00	f	\N	1	\N
131	2	2020-11-20	14.00	16.00	f	\N	1	\N
130	2	2020-11-20	10.00	12.00	f	\N	1	\N
130	2	2020-11-20	12.00	14.00	f	\N	1	\N
130	2	2020-11-20	14.00	16.00	f	\N	1	\N
309	1	2020-11-20	10.00	12.00	t	5131633737	2	Lise
129	2	2020-11-20	10.00	12.00	f	\N	1	\N
309	1	2020-11-20	12.00	14.00	t	5131633737	2	Lise
99	1	2020-11-30	14.00	16.00	f	\N	1	\N
129	2	2020-11-20	12.00	14.00	f	\N	1	\N
100	1	2020-11-30	10.00	12.00	f	\N	1	\N
129	2	2020-11-20	14.00	16.00	f	\N	1	\N
124	2	2020-11-20	10.00	12.00	f	\N	1	\N
124	2	2020-11-20	12.00	14.00	f	\N	1	\N
100	1	2020-11-30	12.00	14.00	f	\N	1	\N
124	2	2020-11-20	14.00	16.00	f	\N	1	\N
81	1	2020-11-23	6.00	8.00	f	\N	1	\N
100	1	2020-11-30	14.00	16.00	f	\N	1	\N
117	2	2020-11-20	10.00	12.00	f	\N	1	\N
117	2	2020-11-20	12.00	14.00	f	\N	1	\N
117	2	2020-11-20	14.00	16.00	f	\N	1	\N
123	2	2020-11-20	10.00	12.00	f	\N	1	\N
123	2	2020-11-20	12.00	14.00	f	\N	1	\N
123	2	2020-11-20	14.00	16.00	f	\N	1	\N
121	2	2020-11-20	10.00	12.00	f	\N	1	\N
121	2	2020-11-20	12.00	14.00	f	\N	1	\N
121	2	2020-11-20	14.00	16.00	f	\N	1	\N
119	2	2020-11-20	10.00	12.00	f	\N	1	\N
119	2	2020-11-20	12.00	14.00	f	\N	1	\N
119	2	2020-11-20	14.00	16.00	f	\N	1	\N
310	1	2020-11-30	10.00	12.00	f	\N	1	\N
310	1	2020-11-30	12.00	14.00	f	\N	1	\N
310	1	2020-11-30	14.00	16.00	f	\N	1	\N
102	1	2020-11-30	10.00	12.00	f	\N	1	\N
102	1	2020-11-30	12.00	14.00	f	\N	1	\N
102	1	2020-11-30	14.00	16.00	f	\N	1	\N
103	1	2020-11-30	10.00	12.00	f	\N	1	\N
103	1	2020-11-30	12.00	14.00	f	\N	1	\N
103	1	2020-11-30	14.00	16.00	f	\N	1	\N
104	1	2020-11-30	10.00	12.00	f	\N	1	\N
104	1	2020-11-30	12.00	14.00	f	\N	1	\N
104	1	2020-11-30	14.00	16.00	f	\N	1	\N
307	1	2020-11-30	10.00	12.00	f	\N	1	\N
307	1	2020-11-30	12.00	14.00	f	\N	1	\N
307	1	2020-11-30	14.00	16.00	f	\N	1	\N
312	1	2020-11-30	10.00	12.00	f	\N	1	\N
312	1	2020-11-30	12.00	14.00	f	\N	1	\N
312	1	2020-11-30	14.00	16.00	f	\N	1	\N
308	1	2020-11-30	10.00	12.00	f	\N	1	\N
308	1	2020-11-30	12.00	14.00	f	\N	1	\N
308	1	2020-11-30	14.00	16.00	f	\N	1	\N
122	2	2020-11-30	10.00	12.00	f	\N	1	\N
122	2	2020-11-30	12.00	14.00	f	\N	1	\N
122	2	2020-11-30	14.00	16.00	f	\N	1	\N
105	2	2020-11-30	10.00	12.00	f	\N	1	\N
105	2	2020-11-30	12.00	14.00	f	\N	1	\N
105	2	2020-11-30	14.00	16.00	f	\N	1	\N
112	2	2020-11-30	10.00	12.00	f	\N	1	\N
112	2	2020-11-30	12.00	14.00	f	\N	1	\N
112	2	2020-11-30	14.00	16.00	f	\N	1	\N
111	2	2020-11-30	10.00	12.00	f	\N	1	\N
111	2	2020-11-30	12.00	14.00	f	\N	1	\N
111	2	2020-11-30	14.00	16.00	f	\N	1	\N
106	2	2020-11-30	10.00	12.00	f	\N	1	\N
106	2	2020-11-30	12.00	14.00	f	\N	1	\N
106	2	2020-11-30	14.00	16.00	f	\N	1	\N
107	2	2020-11-30	10.00	12.00	f	\N	1	\N
107	2	2020-11-30	12.00	14.00	f	\N	1	\N
107	2	2020-11-30	14.00	16.00	f	\N	1	\N
109	2	2020-11-30	10.00	12.00	f	\N	1	\N
109	2	2020-11-30	12.00	14.00	f	\N	1	\N
109	2	2020-11-30	14.00	16.00	f	\N	1	\N
133	2	2020-11-30	10.00	12.00	f	\N	1	\N
133	2	2020-11-30	12.00	14.00	f	\N	1	\N
133	2	2020-11-30	14.00	16.00	f	\N	1	\N
134	2	2020-11-30	10.00	12.00	f	\N	1	\N
134	2	2020-11-30	12.00	14.00	f	\N	1	\N
134	2	2020-11-30	14.00	16.00	f	\N	1	\N
128	2	2020-11-30	10.00	12.00	f	\N	1	\N
128	2	2020-11-30	12.00	14.00	f	\N	1	\N
128	2	2020-11-30	14.00	16.00	f	\N	1	\N
127	2	2020-11-30	10.00	12.00	f	\N	1	\N
127	2	2020-11-30	12.00	14.00	f	\N	1	\N
127	2	2020-11-30	14.00	16.00	f	\N	1	\N
126	2	2020-11-30	10.00	12.00	f	\N	1	\N
126	2	2020-11-30	12.00	14.00	f	\N	1	\N
126	2	2020-11-30	14.00	16.00	f	\N	1	\N
125	2	2020-11-30	10.00	12.00	f	\N	1	\N
125	2	2020-11-30	12.00	14.00	f	\N	1	\N
125	2	2020-11-30	14.00	16.00	f	\N	1	\N
132	2	2020-11-30	10.00	12.00	f	\N	1	\N
132	2	2020-11-30	12.00	14.00	f	\N	1	\N
132	2	2020-11-30	14.00	16.00	f	\N	1	\N
81	1	2020-11-23	8.00	10.00	f	\N	1	\N
81	1	2020-11-23	10.00	12.00	f	\N	1	\N
131	2	2020-11-30	10.00	12.00	f	\N	1	\N
81	1	2020-11-23	12.00	14.00	f	\N	1	\N
81	1	2020-11-23	14.00	16.00	f	\N	1	\N
81	1	2020-11-23	16.00	18.00	f	\N	1	\N
81	1	2020-11-23	18.00	20.00	f	\N	1	\N
81	1	2020-11-23	20.00	22.00	f	\N	1	\N
81	1	2020-11-23	22.00	23.00	f	\N	1	\N
82	1	2020-11-23	6.00	8.00	f	\N	1	\N
82	1	2020-11-23	8.00	10.00	f	\N	1	\N
82	1	2020-11-23	10.00	12.00	f	\N	1	\N
82	1	2020-11-23	12.00	14.00	f	\N	1	\N
118	2	2020-11-20	10.00	12.00	f	\N	1	\N
118	2	2020-11-20	12.00	14.00	f	\N	1	\N
118	2	2020-11-20	14.00	16.00	f	\N	1	\N
110	2	2020-11-20	10.00	12.00	f	\N	1	\N
110	2	2020-11-20	12.00	14.00	f	\N	1	\N
110	2	2020-11-20	14.00	16.00	f	\N	1	\N
108	2	2020-11-20	10.00	12.00	f	\N	1	\N
108	2	2020-11-20	12.00	14.00	f	\N	1	\N
108	2	2020-11-20	14.00	16.00	f	\N	1	\N
116	2	2020-11-20	10.00	12.00	f	\N	1	\N
116	2	2020-11-20	12.00	14.00	f	\N	1	\N
116	2	2020-11-20	14.00	16.00	f	\N	1	\N
115	2	2020-11-20	10.00	12.00	f	\N	1	\N
115	2	2020-11-20	12.00	14.00	f	\N	1	\N
115	2	2020-11-20	14.00	16.00	f	\N	1	\N
114	2	2020-11-20	10.00	12.00	f	\N	1	\N
114	2	2020-11-20	12.00	14.00	f	\N	1	\N
114	2	2020-11-20	14.00	16.00	f	\N	1	\N
113	2	2020-11-20	10.00	12.00	f	\N	1	\N
113	2	2020-11-20	12.00	14.00	f	\N	1	\N
113	2	2020-11-20	14.00	16.00	f	\N	1	\N
120	2	2020-11-20	10.00	12.00	f	\N	1	\N
120	2	2020-11-20	12.00	14.00	f	\N	1	\N
120	2	2020-11-20	14.00	16.00	f	\N	1	\N
286	3	2020-11-20	10.00	12.00	f	\N	1	\N
286	3	2020-11-20	12.00	14.00	f	\N	1	\N
286	3	2020-11-20	14.00	16.00	f	\N	1	\N
89	1	2020-11-20	9.00	11.00	f	\N	1	\N
89	1	2020-11-20	11.00	13.00	f	\N	1	\N
89	1	2020-11-20	13.00	15.00	f	\N	1	\N
89	1	2020-11-20	15.00	17.00	f	\N	1	\N
89	1	2020-11-20	17.00	18.00	f	\N	1	\N
300	1	2020-11-20	9.00	11.00	f	\N	1	\N
300	1	2020-11-20	11.00	13.00	f	\N	1	\N
300	1	2020-11-20	13.00	15.00	f	\N	1	\N
300	1	2020-11-20	15.00	17.00	f	\N	1	\N
300	1	2020-11-20	17.00	18.00	f	\N	1	\N
298	1	2020-11-20	9.00	11.00	f	\N	1	\N
298	1	2020-11-20	11.00	13.00	f	\N	1	\N
298	1	2020-11-20	13.00	15.00	f	\N	1	\N
298	1	2020-11-20	15.00	17.00	f	\N	1	\N
298	1	2020-11-20	17.00	18.00	f	\N	1	\N
95	1	2020-11-20	9.00	11.00	f	\N	1	\N
95	1	2020-11-20	11.00	13.00	f	\N	1	\N
95	1	2020-11-20	13.00	15.00	f	\N	1	\N
95	1	2020-11-20	15.00	17.00	f	\N	1	\N
95	1	2020-11-20	17.00	18.00	f	\N	1	\N
90	1	2020-11-20	9.00	11.00	f	\N	1	\N
90	1	2020-11-20	11.00	13.00	f	\N	1	\N
90	1	2020-11-20	13.00	15.00	f	\N	1	\N
90	1	2020-11-20	15.00	17.00	f	\N	1	\N
90	1	2020-11-20	17.00	18.00	f	\N	1	\N
94	1	2020-11-20	9.00	11.00	f	\N	1	\N
94	1	2020-11-20	11.00	13.00	f	\N	1	\N
94	1	2020-11-20	13.00	15.00	f	\N	1	\N
94	1	2020-11-20	15.00	17.00	f	\N	1	\N
94	1	2020-11-20	17.00	18.00	f	\N	1	\N
92	1	2020-11-20	9.00	11.00	f	\N	1	\N
92	1	2020-11-20	11.00	13.00	f	\N	1	\N
92	1	2020-11-20	13.00	15.00	f	\N	1	\N
92	1	2020-11-20	15.00	17.00	f	\N	1	\N
92	1	2020-11-20	17.00	18.00	f	\N	1	\N
93	1	2020-11-20	9.00	11.00	f	\N	1	\N
93	1	2020-11-20	11.00	13.00	f	\N	1	\N
93	1	2020-11-20	13.00	15.00	f	\N	1	\N
93	1	2020-11-20	15.00	17.00	f	\N	1	\N
93	1	2020-11-20	17.00	18.00	f	\N	1	\N
96	1	2020-11-20	9.00	11.00	f	\N	1	\N
96	1	2020-11-20	11.00	13.00	f	\N	1	\N
96	1	2020-11-20	13.00	15.00	f	\N	1	\N
96	1	2020-11-20	15.00	17.00	f	\N	1	\N
96	1	2020-11-20	17.00	18.00	f	\N	1	\N
91	1	2020-11-20	9.00	11.00	f	\N	1	\N
91	1	2020-11-20	11.00	13.00	f	\N	1	\N
91	1	2020-11-20	13.00	15.00	f	\N	1	\N
91	1	2020-11-20	15.00	17.00	f	\N	1	\N
91	1	2020-11-20	17.00	18.00	f	\N	1	\N
301	1	2020-11-20	9.00	11.00	f	\N	1	\N
301	1	2020-11-20	11.00	13.00	f	\N	1	\N
301	1	2020-11-20	13.00	15.00	f	\N	1	\N
301	1	2020-11-20	15.00	17.00	f	\N	1	\N
301	1	2020-11-20	17.00	18.00	f	\N	1	\N
299	1	2020-11-20	9.00	11.00	f	\N	1	\N
299	1	2020-11-20	11.00	13.00	f	\N	1	\N
299	1	2020-11-20	13.00	15.00	f	\N	1	\N
299	1	2020-11-20	15.00	17.00	f	\N	1	\N
82	1	2020-11-23	14.00	16.00	f	\N	1	\N
82	1	2020-11-23	16.00	18.00	f	\N	1	\N
82	1	2020-11-23	18.00	20.00	f	\N	1	\N
82	1	2020-11-23	20.00	22.00	f	\N	1	\N
82	1	2020-11-23	22.00	23.00	f	\N	1	\N
87	1	2020-11-23	6.00	8.00	f	\N	1	\N
87	1	2020-11-23	8.00	10.00	f	\N	1	\N
87	1	2020-11-23	10.00	12.00	f	\N	1	\N
131	2	2020-11-30	12.00	14.00	f	\N	1	\N
87	1	2020-11-23	12.00	14.00	f	\N	1	\N
131	2	2020-11-30	14.00	16.00	f	\N	1	\N
87	1	2020-11-23	14.00	16.00	f	\N	1	\N
87	1	2020-11-23	16.00	18.00	f	\N	1	\N
299	1	2020-11-20	17.00	18.00	f	\N	1	\N
176	2	2020-11-20	9.00	11.00	f	\N	1	\N
176	2	2020-11-20	11.00	13.00	f	\N	1	\N
176	2	2020-11-20	13.00	15.00	f	\N	1	\N
176	2	2020-11-20	15.00	17.00	f	\N	1	\N
130	2	2020-11-30	10.00	12.00	f	\N	1	\N
176	2	2020-11-20	17.00	18.00	f	\N	1	\N
87	1	2020-11-23	18.00	20.00	f	\N	1	\N
175	2	2020-11-20	9.00	11.00	f	\N	1	\N
175	2	2020-11-20	11.00	13.00	f	\N	1	\N
175	2	2020-11-20	13.00	15.00	f	\N	1	\N
175	2	2020-11-20	15.00	17.00	f	\N	1	\N
175	2	2020-11-20	17.00	18.00	f	\N	1	\N
174	2	2020-11-20	9.00	11.00	f	\N	1	\N
174	2	2020-11-20	11.00	13.00	f	\N	1	\N
174	2	2020-11-20	13.00	15.00	f	\N	1	\N
174	2	2020-11-20	15.00	17.00	f	\N	1	\N
174	2	2020-11-20	17.00	18.00	f	\N	1	\N
179	2	2020-11-20	9.00	11.00	f	\N	1	\N
179	2	2020-11-20	11.00	13.00	f	\N	1	\N
179	2	2020-11-20	13.00	15.00	f	\N	1	\N
179	2	2020-11-20	15.00	17.00	f	\N	1	\N
179	2	2020-11-20	17.00	18.00	f	\N	1	\N
178	2	2020-11-20	9.00	11.00	f	\N	1	\N
178	2	2020-11-20	11.00	13.00	f	\N	1	\N
178	2	2020-11-20	13.00	15.00	f	\N	1	\N
178	2	2020-11-20	15.00	17.00	f	\N	1	\N
178	2	2020-11-20	17.00	18.00	f	\N	1	\N
177	2	2020-11-20	9.00	11.00	f	\N	1	\N
177	2	2020-11-20	11.00	13.00	f	\N	1	\N
177	2	2020-11-20	13.00	15.00	f	\N	1	\N
177	2	2020-11-20	15.00	17.00	f	\N	1	\N
177	2	2020-11-20	17.00	18.00	f	\N	1	\N
192	2	2020-11-20	9.00	11.00	f	\N	1	\N
192	2	2020-11-20	11.00	13.00	f	\N	1	\N
192	2	2020-11-20	13.00	15.00	f	\N	1	\N
192	2	2020-11-20	15.00	17.00	f	\N	1	\N
192	2	2020-11-20	17.00	18.00	f	\N	1	\N
193	2	2020-11-20	9.00	11.00	f	\N	1	\N
193	2	2020-11-20	11.00	13.00	f	\N	1	\N
193	2	2020-11-20	13.00	15.00	f	\N	1	\N
193	2	2020-11-20	15.00	17.00	f	\N	1	\N
193	2	2020-11-20	17.00	18.00	f	\N	1	\N
302	3	2020-11-20	9.00	11.00	f	\N	1	\N
302	3	2020-11-20	11.00	13.00	f	\N	1	\N
302	3	2020-11-20	13.00	15.00	f	\N	1	\N
302	3	2020-11-20	15.00	17.00	f	\N	1	\N
302	3	2020-11-20	17.00	18.00	f	\N	1	\N
305	3	2020-11-20	9.00	11.00	f	\N	1	\N
305	3	2020-11-20	11.00	13.00	f	\N	1	\N
305	3	2020-11-20	13.00	15.00	f	\N	1	\N
305	3	2020-11-20	15.00	17.00	f	\N	1	\N
305	3	2020-11-20	17.00	18.00	f	\N	1	\N
130	2	2020-11-30	12.00	14.00	f	\N	1	\N
314	3	2020-11-20	17.00	18.00	f	\N	1	\N
306	3	2020-11-20	9.00	11.00	f	\N	1	\N
306	3	2020-11-20	11.00	13.00	f	\N	1	\N
306	3	2020-11-20	13.00	15.00	f	\N	1	\N
306	3	2020-11-20	15.00	17.00	f	\N	1	\N
306	3	2020-11-20	17.00	18.00	f	\N	1	\N
215	1	2020-11-20	6.00	8.00	f	\N	1	\N
215	1	2020-11-20	8.00	10.00	f	\N	1	\N
215	1	2020-11-20	10.00	12.00	f	\N	1	\N
215	1	2020-11-20	12.00	14.00	f	\N	1	\N
215	1	2020-11-20	14.00	16.00	f	\N	1	\N
215	1	2020-11-20	16.00	18.00	f	\N	1	\N
215	1	2020-11-20	18.00	20.00	f	\N	1	\N
215	1	2020-11-20	20.00	22.00	f	\N	1	\N
215	1	2020-11-20	22.00	23.00	f	\N	1	\N
231	1	2020-11-20	6.00	8.00	f	\N	1	\N
231	1	2020-11-20	8.00	10.00	f	\N	1	\N
231	1	2020-11-20	10.00	12.00	f	\N	1	\N
231	1	2020-11-20	12.00	14.00	f	\N	1	\N
231	1	2020-11-20	14.00	16.00	f	\N	1	\N
231	1	2020-11-20	16.00	18.00	f	\N	1	\N
231	1	2020-11-20	18.00	20.00	f	\N	1	\N
231	1	2020-11-20	20.00	22.00	f	\N	1	\N
231	1	2020-11-20	22.00	23.00	f	\N	1	\N
88	1	2020-11-20	6.00	8.00	f	\N	1	\N
88	1	2020-11-20	8.00	10.00	f	\N	1	\N
88	1	2020-11-20	10.00	12.00	f	\N	1	\N
88	1	2020-11-20	12.00	14.00	f	\N	1	\N
88	1	2020-11-20	14.00	16.00	f	\N	1	\N
88	1	2020-11-20	16.00	18.00	f	\N	1	\N
88	1	2020-11-20	18.00	20.00	f	\N	1	\N
88	1	2020-11-20	20.00	22.00	f	\N	1	\N
88	1	2020-11-20	22.00	23.00	f	\N	1	\N
80	1	2020-11-20	6.00	8.00	f	\N	1	\N
80	1	2020-11-20	8.00	10.00	f	\N	1	\N
80	1	2020-11-20	10.00	12.00	f	\N	1	\N
80	1	2020-11-20	12.00	14.00	f	\N	1	\N
80	1	2020-11-20	14.00	16.00	f	\N	1	\N
80	1	2020-11-20	16.00	18.00	f	\N	1	\N
80	1	2020-11-20	18.00	20.00	f	\N	1	\N
80	1	2020-11-20	20.00	22.00	f	\N	1	\N
80	1	2020-11-20	22.00	23.00	f	\N	1	\N
216	1	2020-11-20	6.00	8.00	f	\N	1	\N
216	1	2020-11-20	8.00	10.00	f	\N	1	\N
216	1	2020-11-20	10.00	12.00	f	\N	1	\N
216	1	2020-11-20	12.00	14.00	f	\N	1	\N
216	1	2020-11-20	14.00	16.00	f	\N	1	\N
216	1	2020-11-20	16.00	18.00	f	\N	1	\N
216	1	2020-11-20	18.00	20.00	f	\N	1	\N
216	1	2020-11-20	20.00	22.00	f	\N	1	\N
216	1	2020-11-20	22.00	23.00	f	\N	1	\N
191	1	2020-11-20	6.00	8.00	f	\N	1	\N
191	1	2020-11-20	8.00	10.00	f	\N	1	\N
191	1	2020-11-20	10.00	12.00	f	\N	1	\N
191	1	2020-11-20	12.00	14.00	f	\N	1	\N
314	3	2020-11-20	15.00	17.00	t	8306227208	2	Vv 
314	3	2020-11-20	9.00	11.00	t	8459305474	2	Hellman
314	3	2020-11-20	11.00	13.00	t	8459305474	2	Hellman
87	1	2020-11-23	20.00	22.00	f	\N	1	\N
87	1	2020-11-23	22.00	23.00	f	\N	1	\N
86	1	2020-11-23	6.00	8.00	f	\N	1	\N
86	1	2020-11-23	8.00	10.00	f	\N	1	\N
86	1	2020-11-23	10.00	12.00	f	\N	1	\N
191	1	2020-11-20	14.00	16.00	f	\N	1	\N
191	1	2020-11-20	16.00	18.00	f	\N	1	\N
191	1	2020-11-20	18.00	20.00	f	\N	1	\N
191	1	2020-11-20	20.00	22.00	f	\N	1	\N
191	1	2020-11-20	22.00	23.00	f	\N	1	\N
81	1	2020-11-20	6.00	8.00	f	\N	1	\N
81	1	2020-11-20	8.00	10.00	f	\N	1	\N
81	1	2020-11-20	10.00	12.00	f	\N	1	\N
81	1	2020-11-20	12.00	14.00	f	\N	1	\N
81	1	2020-11-20	14.00	16.00	f	\N	1	\N
81	1	2020-11-20	16.00	18.00	f	\N	1	\N
81	1	2020-11-20	18.00	20.00	f	\N	1	\N
81	1	2020-11-20	20.00	22.00	f	\N	1	\N
81	1	2020-11-20	22.00	23.00	f	\N	1	\N
82	1	2020-11-20	6.00	8.00	f	\N	1	\N
82	1	2020-11-20	8.00	10.00	f	\N	1	\N
82	1	2020-11-20	10.00	12.00	f	\N	1	\N
82	1	2020-11-20	12.00	14.00	f	\N	1	\N
82	1	2020-11-20	14.00	16.00	f	\N	1	\N
82	1	2020-11-20	16.00	18.00	f	\N	1	\N
82	1	2020-11-20	18.00	20.00	f	\N	1	\N
82	1	2020-11-20	20.00	22.00	f	\N	1	\N
82	1	2020-11-20	22.00	23.00	f	\N	1	\N
87	1	2020-11-20	6.00	8.00	f	\N	1	\N
87	1	2020-11-20	8.00	10.00	f	\N	1	\N
87	1	2020-11-20	10.00	12.00	f	\N	1	\N
87	1	2020-11-20	12.00	14.00	f	\N	1	\N
87	1	2020-11-20	14.00	16.00	f	\N	1	\N
87	1	2020-11-20	16.00	18.00	f	\N	1	\N
87	1	2020-11-20	18.00	20.00	f	\N	1	\N
87	1	2020-11-20	20.00	22.00	f	\N	1	\N
87	1	2020-11-20	22.00	23.00	f	\N	1	\N
86	1	2020-11-20	6.00	8.00	f	\N	1	\N
86	1	2020-11-20	8.00	10.00	f	\N	1	\N
86	1	2020-11-20	10.00	12.00	f	\N	1	\N
86	1	2020-11-20	12.00	14.00	f	\N	1	\N
86	1	2020-11-20	14.00	16.00	f	\N	1	\N
86	1	2020-11-20	16.00	18.00	f	\N	1	\N
86	1	2020-11-20	18.00	20.00	f	\N	1	\N
86	1	2020-11-20	20.00	22.00	f	\N	1	\N
86	1	2020-11-20	22.00	23.00	f	\N	1	\N
201	1	2020-11-20	6.00	8.00	f	\N	1	\N
201	1	2020-11-20	8.00	10.00	f	\N	1	\N
201	1	2020-11-20	10.00	12.00	f	\N	1	\N
201	1	2020-11-20	12.00	14.00	f	\N	1	\N
201	1	2020-11-20	14.00	16.00	f	\N	1	\N
201	1	2020-11-20	16.00	18.00	f	\N	1	\N
201	1	2020-11-20	18.00	20.00	f	\N	1	\N
201	1	2020-11-20	20.00	22.00	f	\N	1	\N
86	1	2020-11-23	12.00	14.00	f	\N	1	\N
86	1	2020-11-23	14.00	16.00	f	\N	1	\N
86	1	2020-11-23	16.00	18.00	f	\N	1	\N
86	1	2020-11-23	18.00	20.00	f	\N	1	\N
86	1	2020-11-23	20.00	22.00	f	\N	1	\N
86	1	2020-11-23	22.00	23.00	f	\N	1	\N
201	1	2020-11-23	6.00	8.00	f	\N	1	\N
201	1	2020-11-23	8.00	10.00	f	\N	1	\N
201	1	2020-11-23	10.00	12.00	f	\N	1	\N
201	1	2020-11-23	12.00	14.00	f	\N	1	\N
201	1	2020-11-23	14.00	16.00	f	\N	1	\N
201	1	2020-11-23	16.00	18.00	f	\N	1	\N
201	1	2020-11-23	18.00	20.00	f	\N	1	\N
201	1	2020-11-23	20.00	22.00	f	\N	1	\N
201	1	2020-11-23	22.00	23.00	f	\N	1	\N
83	1	2020-11-23	6.00	8.00	f	\N	1	\N
83	1	2020-11-23	8.00	10.00	f	\N	1	\N
83	1	2020-11-23	10.00	12.00	f	\N	1	\N
83	1	2020-11-23	12.00	14.00	f	\N	1	\N
83	1	2020-11-23	14.00	16.00	f	\N	1	\N
83	1	2020-11-23	16.00	18.00	f	\N	1	\N
83	1	2020-11-23	18.00	20.00	f	\N	1	\N
83	1	2020-11-23	20.00	22.00	f	\N	1	\N
83	1	2020-11-23	22.00	23.00	f	\N	1	\N
130	2	2020-11-30	14.00	16.00	f	\N	1	\N
129	2	2020-11-30	10.00	12.00	f	\N	1	\N
129	2	2020-11-30	12.00	14.00	f	\N	1	\N
129	2	2020-11-30	14.00	16.00	f	\N	1	\N
124	2	2020-11-30	10.00	12.00	f	\N	1	\N
124	2	2020-11-30	12.00	14.00	f	\N	1	\N
124	2	2020-11-30	14.00	16.00	f	\N	1	\N
117	2	2020-11-30	10.00	12.00	f	\N	1	\N
117	2	2020-11-30	12.00	14.00	f	\N	1	\N
84	1	2020-11-23	6.00	8.00	f	\N	1	\N
84	1	2020-11-23	8.00	10.00	f	\N	1	\N
84	1	2020-11-23	10.00	12.00	f	\N	1	\N
84	1	2020-11-23	12.00	14.00	f	\N	1	\N
84	1	2020-11-23	14.00	16.00	f	\N	1	\N
84	1	2020-11-23	16.00	18.00	f	\N	1	\N
84	1	2020-11-23	18.00	20.00	f	\N	1	\N
84	1	2020-11-23	20.00	22.00	f	\N	1	\N
84	1	2020-11-23	22.00	23.00	f	\N	1	\N
194	1	2020-11-23	6.00	8.00	f	\N	1	\N
194	1	2020-11-23	8.00	10.00	f	\N	1	\N
194	1	2020-11-23	10.00	12.00	f	\N	1	\N
194	1	2020-11-23	12.00	14.00	f	\N	1	\N
194	1	2020-11-23	14.00	16.00	f	\N	1	\N
194	1	2020-11-23	16.00	18.00	f	\N	1	\N
194	1	2020-11-23	18.00	20.00	f	\N	1	\N
194	1	2020-11-23	20.00	22.00	f	\N	1	\N
194	1	2020-11-23	22.00	23.00	f	\N	1	\N
85	1	2020-11-23	6.00	8.00	f	\N	1	\N
85	1	2020-11-23	8.00	10.00	f	\N	1	\N
85	1	2020-11-23	10.00	12.00	f	\N	1	\N
85	1	2020-11-23	12.00	14.00	f	\N	1	\N
85	1	2020-11-23	14.00	16.00	f	\N	1	\N
85	1	2020-11-23	16.00	18.00	f	\N	1	\N
85	1	2020-11-23	18.00	20.00	f	\N	1	\N
85	1	2020-11-23	20.00	22.00	f	\N	1	\N
85	1	2020-11-23	22.00	23.00	f	\N	1	\N
117	2	2020-11-30	14.00	16.00	f	\N	1	\N
123	2	2020-11-30	10.00	12.00	f	\N	1	\N
166	1	2020-11-27	10.00	12.00	f	\N	1	\N
123	2	2020-11-30	12.00	14.00	f	\N	1	\N
303	1	2020-11-23	6.00	8.00	f	\N	1	\N
303	1	2020-11-23	8.00	10.00	f	\N	1	\N
166	1	2020-11-27	12.00	14.00	f	\N	1	\N
303	1	2020-11-23	10.00	12.00	f	\N	1	\N
303	1	2020-11-23	12.00	14.00	f	\N	1	\N
303	1	2020-11-23	14.00	16.00	f	\N	1	\N
303	1	2020-11-23	16.00	18.00	f	\N	1	\N
303	1	2020-11-23	18.00	20.00	f	\N	1	\N
166	1	2020-11-27	14.00	16.00	f	\N	1	\N
166	1	2020-11-27	16.00	18.00	f	\N	1	\N
123	2	2020-11-30	14.00	16.00	f	\N	1	\N
201	1	2020-11-20	22.00	23.00	f	\N	1	\N
121	2	2020-11-30	10.00	12.00	f	\N	1	\N
83	1	2020-11-20	6.00	8.00	f	\N	1	\N
83	1	2020-11-20	8.00	10.00	f	\N	1	\N
83	1	2020-11-20	10.00	12.00	f	\N	1	\N
83	1	2020-11-20	12.00	14.00	f	\N	1	\N
83	1	2020-11-20	14.00	16.00	f	\N	1	\N
83	1	2020-11-20	16.00	18.00	f	\N	1	\N
83	1	2020-11-20	18.00	20.00	f	\N	1	\N
83	1	2020-11-20	20.00	22.00	f	\N	1	\N
83	1	2020-11-20	22.00	23.00	f	\N	1	\N
84	1	2020-11-20	6.00	8.00	f	\N	1	\N
84	1	2020-11-20	8.00	10.00	f	\N	1	\N
84	1	2020-11-20	10.00	12.00	f	\N	1	\N
84	1	2020-11-20	12.00	14.00	f	\N	1	\N
84	1	2020-11-20	14.00	16.00	f	\N	1	\N
84	1	2020-11-20	16.00	18.00	f	\N	1	\N
84	1	2020-11-20	18.00	20.00	f	\N	1	\N
84	1	2020-11-20	20.00	22.00	f	\N	1	\N
84	1	2020-11-20	22.00	23.00	f	\N	1	\N
194	1	2020-11-20	6.00	8.00	f	\N	1	\N
194	1	2020-11-20	8.00	10.00	f	\N	1	\N
194	1	2020-11-20	10.00	12.00	f	\N	1	\N
194	1	2020-11-20	12.00	14.00	f	\N	1	\N
194	1	2020-11-20	14.00	16.00	f	\N	1	\N
194	1	2020-11-20	16.00	18.00	f	\N	1	\N
194	1	2020-11-20	18.00	20.00	f	\N	1	\N
194	1	2020-11-20	20.00	22.00	f	\N	1	\N
194	1	2020-11-20	22.00	23.00	f	\N	1	\N
85	1	2020-11-20	6.00	8.00	f	\N	1	\N
85	1	2020-11-20	8.00	10.00	f	\N	1	\N
85	1	2020-11-20	10.00	12.00	f	\N	1	\N
85	1	2020-11-20	12.00	14.00	f	\N	1	\N
85	1	2020-11-20	14.00	16.00	f	\N	1	\N
85	1	2020-11-20	16.00	18.00	f	\N	1	\N
85	1	2020-11-20	18.00	20.00	f	\N	1	\N
85	1	2020-11-20	20.00	22.00	f	\N	1	\N
85	1	2020-11-20	22.00	23.00	f	\N	1	\N
303	1	2020-11-20	6.00	8.00	f	\N	1	\N
303	1	2020-11-20	8.00	10.00	f	\N	1	\N
303	1	2020-11-20	10.00	12.00	f	\N	1	\N
303	1	2020-11-20	12.00	14.00	f	\N	1	\N
303	1	2020-11-20	14.00	16.00	f	\N	1	\N
303	1	2020-11-20	16.00	18.00	f	\N	1	\N
303	1	2020-11-20	18.00	20.00	f	\N	1	\N
303	1	2020-11-20	20.00	22.00	f	\N	1	\N
303	1	2020-11-20	22.00	23.00	f	\N	1	\N
304	1	2020-11-20	6.00	8.00	f	\N	1	\N
304	1	2020-11-20	8.00	10.00	f	\N	1	\N
304	1	2020-11-20	10.00	12.00	f	\N	1	\N
304	1	2020-11-20	12.00	14.00	f	\N	1	\N
304	1	2020-11-20	14.00	16.00	f	\N	1	\N
304	1	2020-11-20	16.00	18.00	f	\N	1	\N
304	1	2020-11-20	18.00	20.00	f	\N	1	\N
304	1	2020-11-20	20.00	22.00	f	\N	1	\N
304	1	2020-11-20	22.00	23.00	f	\N	1	\N
268	2	2020-11-20	6.00	8.00	f	\N	1	\N
303	1	2020-11-23	20.00	22.00	f	\N	1	\N
268	2	2020-11-20	8.00	10.00	f	\N	1	\N
268	2	2020-11-20	10.00	12.00	f	\N	1	\N
268	2	2020-11-20	12.00	14.00	f	\N	1	\N
268	2	2020-11-20	14.00	16.00	f	\N	1	\N
268	2	2020-11-20	16.00	18.00	f	\N	1	\N
268	2	2020-11-20	18.00	20.00	f	\N	1	\N
268	2	2020-11-20	20.00	22.00	f	\N	1	\N
268	2	2020-11-20	22.00	23.00	f	\N	1	\N
313	3	2020-11-20	10.00	12.00	f	\N	1	\N
313	3	2020-11-20	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-20	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-20	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-20	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-20	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-20	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-20	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-20	22.00	23.00	t	1122334455	5	Stängt
303	1	2020-11-23	22.00	23.00	f	\N	1	\N
304	1	2020-11-23	6.00	8.00	f	\N	1	\N
304	1	2020-11-23	8.00	10.00	f	\N	1	\N
304	1	2020-11-23	10.00	12.00	f	\N	1	\N
304	1	2020-11-23	12.00	14.00	f	\N	1	\N
304	1	2020-11-23	14.00	16.00	f	\N	1	\N
304	1	2020-11-23	16.00	18.00	f	\N	1	\N
304	1	2020-11-23	18.00	20.00	f	\N	1	\N
304	1	2020-11-23	20.00	22.00	f	\N	1	\N
304	1	2020-11-23	22.00	23.00	f	\N	1	\N
268	2	2020-11-23	6.00	8.00	f	\N	1	\N
268	2	2020-11-23	8.00	10.00	f	\N	1	\N
268	2	2020-11-23	10.00	12.00	f	\N	1	\N
268	2	2020-11-23	12.00	14.00	f	\N	1	\N
268	2	2020-11-23	14.00	16.00	f	\N	1	\N
268	2	2020-11-23	16.00	18.00	f	\N	1	\N
168	1	2020-11-27	10.00	12.00	f	\N	1	\N
268	2	2020-11-23	18.00	20.00	f	\N	1	\N
268	2	2020-11-23	20.00	22.00	f	\N	1	\N
268	2	2020-11-23	22.00	23.00	f	\N	1	\N
168	1	2020-11-27	12.00	14.00	f	\N	1	\N
168	1	2020-11-27	14.00	16.00	f	\N	1	\N
168	1	2020-11-27	16.00	18.00	f	\N	1	\N
121	2	2020-11-30	12.00	14.00	f	\N	1	\N
313	3	2020-11-23	10.00	12.00	f	\N	1	\N
165	1	2020-11-27	10.00	12.00	f	\N	1	\N
165	1	2020-11-27	12.00	14.00	f	\N	1	\N
165	1	2020-11-27	14.00	16.00	f	\N	1	\N
121	2	2020-11-30	14.00	16.00	f	\N	1	\N
313	3	2020-11-23	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-23	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-23	22.00	23.00	t	1122334455	5	Stängt
165	1	2020-11-27	16.00	18.00	f	\N	1	\N
167	1	2020-11-27	10.00	12.00	f	\N	1	\N
119	2	2020-11-30	10.00	12.00	f	\N	1	\N
167	1	2020-11-27	12.00	14.00	f	\N	1	\N
167	1	2020-11-27	14.00	16.00	f	\N	1	\N
167	1	2020-11-27	16.00	18.00	f	\N	1	\N
289	1	2020-11-27	10.00	12.00	f	\N	1	\N
289	1	2020-11-27	12.00	14.00	f	\N	1	\N
289	1	2020-11-27	14.00	16.00	f	\N	1	\N
289	1	2020-11-27	16.00	18.00	f	\N	1	\N
297	2	2020-11-27	10.00	12.00	f	\N	1	\N
297	2	2020-11-27	12.00	14.00	f	\N	1	\N
297	2	2020-11-27	14.00	16.00	f	\N	1	\N
297	2	2020-11-27	16.00	18.00	f	\N	1	\N
285	3	2020-11-27	10.00	12.00	f	\N	1	\N
285	3	2020-11-27	12.00	14.00	f	\N	1	\N
285	3	2020-11-27	14.00	16.00	f	\N	1	\N
285	3	2020-11-27	16.00	18.00	f	\N	1	\N
204	1	2020-11-27	9.00	11.00	f	\N	1	\N
204	1	2020-11-27	11.00	13.00	f	\N	1	\N
204	1	2020-11-27	13.00	15.00	f	\N	1	\N
204	1	2020-11-27	15.00	17.00	f	\N	1	\N
204	1	2020-11-27	17.00	18.00	f	\N	1	\N
203	1	2020-11-27	9.00	11.00	f	\N	1	\N
203	1	2020-11-27	11.00	13.00	f	\N	1	\N
203	1	2020-11-27	13.00	15.00	f	\N	1	\N
203	1	2020-11-27	15.00	17.00	f	\N	1	\N
203	1	2020-11-27	17.00	18.00	f	\N	1	\N
205	1	2020-11-27	9.00	11.00	f	\N	1	\N
205	1	2020-11-27	11.00	13.00	f	\N	1	\N
205	1	2020-11-27	13.00	15.00	f	\N	1	\N
205	1	2020-11-27	15.00	17.00	f	\N	1	\N
205	1	2020-11-27	17.00	18.00	f	\N	1	\N
202	1	2020-11-27	9.00	11.00	f	\N	1	\N
202	1	2020-11-27	11.00	13.00	f	\N	1	\N
202	1	2020-11-27	13.00	15.00	f	\N	1	\N
202	1	2020-11-27	15.00	17.00	f	\N	1	\N
202	1	2020-11-27	17.00	18.00	f	\N	1	\N
214	1	2020-11-27	9.00	11.00	f	\N	1	\N
214	1	2020-11-27	11.00	13.00	f	\N	1	\N
214	1	2020-11-27	13.00	15.00	f	\N	1	\N
214	1	2020-11-27	15.00	17.00	f	\N	1	\N
214	1	2020-11-27	17.00	18.00	f	\N	1	\N
213	1	2020-11-27	9.00	11.00	f	\N	1	\N
213	1	2020-11-27	11.00	13.00	f	\N	1	\N
213	1	2020-11-27	13.00	15.00	f	\N	1	\N
213	1	2020-11-27	15.00	17.00	f	\N	1	\N
213	1	2020-11-27	17.00	18.00	f	\N	1	\N
208	2	2020-11-27	9.00	11.00	f	\N	1	\N
208	2	2020-11-27	11.00	13.00	f	\N	1	\N
208	2	2020-11-27	13.00	15.00	f	\N	1	\N
208	2	2020-11-27	15.00	17.00	f	\N	1	\N
208	2	2020-11-27	17.00	18.00	f	\N	1	\N
244	2	2020-11-27	9.00	11.00	f	\N	1	\N
244	2	2020-11-27	11.00	13.00	f	\N	1	\N
244	2	2020-11-27	13.00	15.00	f	\N	1	\N
244	2	2020-11-27	15.00	17.00	f	\N	1	\N
244	2	2020-11-27	17.00	18.00	f	\N	1	\N
209	2	2020-11-27	9.00	11.00	f	\N	1	\N
209	2	2020-11-27	11.00	13.00	f	\N	1	\N
209	2	2020-11-27	13.00	15.00	f	\N	1	\N
209	2	2020-11-27	15.00	17.00	f	\N	1	\N
209	2	2020-11-27	17.00	18.00	f	\N	1	\N
245	2	2020-11-27	9.00	11.00	f	\N	1	\N
245	2	2020-11-27	11.00	13.00	f	\N	1	\N
245	2	2020-11-27	13.00	15.00	f	\N	1	\N
245	2	2020-11-27	15.00	17.00	f	\N	1	\N
245	2	2020-11-27	17.00	18.00	f	\N	1	\N
247	2	2020-11-27	9.00	11.00	f	\N	1	\N
247	2	2020-11-27	11.00	13.00	f	\N	1	\N
247	2	2020-11-27	13.00	15.00	f	\N	1	\N
247	2	2020-11-27	15.00	17.00	f	\N	1	\N
247	2	2020-11-27	17.00	18.00	f	\N	1	\N
207	2	2020-11-27	9.00	11.00	f	\N	1	\N
207	2	2020-11-27	11.00	13.00	f	\N	1	\N
207	2	2020-11-27	13.00	15.00	f	\N	1	\N
207	2	2020-11-27	15.00	17.00	f	\N	1	\N
207	2	2020-11-27	17.00	18.00	f	\N	1	\N
212	2	2020-11-27	9.00	11.00	f	\N	1	\N
212	2	2020-11-27	11.00	13.00	f	\N	1	\N
212	2	2020-11-27	13.00	15.00	f	\N	1	\N
212	2	2020-11-27	15.00	17.00	f	\N	1	\N
212	2	2020-11-27	17.00	18.00	f	\N	1	\N
217	2	2020-11-27	9.00	11.00	f	\N	1	\N
217	2	2020-11-27	11.00	13.00	f	\N	1	\N
217	2	2020-11-27	13.00	15.00	f	\N	1	\N
217	2	2020-11-27	15.00	17.00	f	\N	1	\N
217	2	2020-11-27	17.00	18.00	f	\N	1	\N
246	2	2020-11-27	9.00	11.00	f	\N	1	\N
246	2	2020-11-27	11.00	13.00	f	\N	1	\N
246	2	2020-11-27	13.00	15.00	f	\N	1	\N
246	2	2020-11-27	15.00	17.00	f	\N	1	\N
246	2	2020-11-27	17.00	18.00	f	\N	1	\N
210	2	2020-11-27	9.00	11.00	f	\N	1	\N
210	2	2020-11-27	11.00	13.00	f	\N	1	\N
210	2	2020-11-27	13.00	15.00	f	\N	1	\N
210	2	2020-11-27	15.00	17.00	f	\N	1	\N
210	2	2020-11-27	17.00	18.00	f	\N	1	\N
206	2	2020-11-27	9.00	11.00	f	\N	1	\N
206	2	2020-11-27	11.00	13.00	f	\N	1	\N
206	2	2020-11-27	13.00	15.00	f	\N	1	\N
119	2	2020-11-30	12.00	14.00	f	\N	1	\N
206	2	2020-11-27	15.00	17.00	f	\N	1	\N
119	2	2020-11-30	14.00	16.00	f	\N	1	\N
206	2	2020-11-27	17.00	18.00	f	\N	1	\N
118	2	2020-11-30	10.00	12.00	f	\N	1	\N
288	3	2020-11-27	9.00	11.00	f	\N	1	\N
196	1	2020-11-21	10.00	12.00	f	\N	1	\N
196	1	2020-11-21	12.00	14.00	f	\N	1	\N
196	1	2020-11-21	14.00	16.00	f	\N	1	\N
97	1	2020-11-21	10.00	12.00	f	\N	1	\N
97	1	2020-11-21	12.00	14.00	f	\N	1	\N
97	1	2020-11-21	14.00	16.00	f	\N	1	\N
288	3	2020-11-27	11.00	13.00	f	\N	1	\N
288	3	2020-11-27	13.00	15.00	f	\N	1	\N
313	3	2020-11-23	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-23	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-23	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-23	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-23	16.00	18.00	t	1122334455	5	Stängt
283	3	2020-11-21	10.00	12.00	t	5081048035	2	V
288	3	2020-11-27	15.00	17.00	f	\N	1	\N
288	3	2020-11-27	17.00	18.00	f	\N	1	\N
287	3	2020-11-27	9.00	11.00	f	\N	1	\N
166	1	2020-11-24	10.00	12.00	f	\N	1	\N
197	1	2020-11-21	10.00	12.00	f	\N	1	\N
197	1	2020-11-21	12.00	14.00	f	\N	1	\N
197	1	2020-11-21	14.00	16.00	f	\N	1	\N
135	1	2020-11-21	10.00	12.00	f	\N	1	\N
135	1	2020-11-21	12.00	14.00	f	\N	1	\N
135	1	2020-11-21	14.00	16.00	f	\N	1	\N
136	1	2020-11-21	10.00	12.00	f	\N	1	\N
136	1	2020-11-21	12.00	14.00	f	\N	1	\N
136	1	2020-11-21	14.00	16.00	f	\N	1	\N
137	1	2020-11-21	10.00	12.00	f	\N	1	\N
137	1	2020-11-21	12.00	14.00	f	\N	1	\N
137	1	2020-11-21	14.00	16.00	f	\N	1	\N
195	1	2020-11-21	10.00	12.00	f	\N	1	\N
195	1	2020-11-21	12.00	14.00	f	\N	1	\N
195	1	2020-11-21	14.00	16.00	f	\N	1	\N
138	1	2020-11-21	10.00	12.00	f	\N	1	\N
138	1	2020-11-21	12.00	14.00	f	\N	1	\N
138	1	2020-11-21	14.00	16.00	f	\N	1	\N
139	1	2020-11-21	10.00	12.00	f	\N	1	\N
139	1	2020-11-21	12.00	14.00	f	\N	1	\N
139	1	2020-11-21	14.00	16.00	f	\N	1	\N
140	1	2020-11-21	10.00	12.00	f	\N	1	\N
140	1	2020-11-21	12.00	14.00	f	\N	1	\N
140	1	2020-11-21	14.00	16.00	f	\N	1	\N
141	1	2020-11-21	10.00	12.00	f	\N	1	\N
141	1	2020-11-21	12.00	14.00	f	\N	1	\N
141	1	2020-11-21	14.00	16.00	f	\N	1	\N
188	2	2020-11-21	10.00	12.00	f	\N	1	\N
188	2	2020-11-21	12.00	14.00	f	\N	1	\N
188	2	2020-11-21	14.00	16.00	f	\N	1	\N
248	2	2020-11-21	10.00	12.00	f	\N	1	\N
248	2	2020-11-21	12.00	14.00	f	\N	1	\N
248	2	2020-11-21	14.00	16.00	f	\N	1	\N
182	2	2020-11-21	10.00	12.00	f	\N	1	\N
182	2	2020-11-21	12.00	14.00	f	\N	1	\N
182	2	2020-11-21	14.00	16.00	f	\N	1	\N
183	2	2020-11-21	10.00	12.00	f	\N	1	\N
183	2	2020-11-21	12.00	14.00	f	\N	1	\N
183	2	2020-11-21	14.00	16.00	f	\N	1	\N
181	2	2020-11-21	10.00	12.00	f	\N	1	\N
181	2	2020-11-21	12.00	14.00	f	\N	1	\N
181	2	2020-11-21	14.00	16.00	f	\N	1	\N
187	2	2020-11-21	10.00	12.00	f	\N	1	\N
187	2	2020-11-21	12.00	14.00	f	\N	1	\N
187	2	2020-11-21	14.00	16.00	f	\N	1	\N
184	2	2020-11-21	10.00	12.00	f	\N	1	\N
184	2	2020-11-21	12.00	14.00	f	\N	1	\N
184	2	2020-11-21	14.00	16.00	f	\N	1	\N
249	2	2020-11-21	10.00	12.00	f	\N	1	\N
249	2	2020-11-21	12.00	14.00	f	\N	1	\N
249	2	2020-11-21	14.00	16.00	f	\N	1	\N
186	2	2020-11-21	10.00	12.00	f	\N	1	\N
186	2	2020-11-21	12.00	14.00	f	\N	1	\N
186	2	2020-11-21	14.00	16.00	f	\N	1	\N
180	2	2020-11-21	10.00	12.00	f	\N	1	\N
180	2	2020-11-21	12.00	14.00	f	\N	1	\N
180	2	2020-11-21	14.00	16.00	f	\N	1	\N
185	2	2020-11-21	10.00	12.00	f	\N	1	\N
185	2	2020-11-21	12.00	14.00	f	\N	1	\N
185	2	2020-11-21	14.00	16.00	f	\N	1	\N
283	3	2020-11-21	14.00	16.00	f	\N	1	\N
284	3	2020-11-21	10.00	12.00	f	\N	1	\N
284	3	2020-11-21	12.00	14.00	f	\N	1	\N
284	3	2020-11-21	14.00	16.00	f	\N	1	\N
189	1	2020-11-21	10.00	12.00	f	\N	1	\N
189	1	2020-11-21	12.00	14.00	f	\N	1	\N
189	1	2020-11-21	14.00	16.00	f	\N	1	\N
98	1	2020-11-21	10.00	12.00	f	\N	1	\N
98	1	2020-11-21	12.00	14.00	f	\N	1	\N
98	1	2020-11-21	14.00	16.00	f	\N	1	\N
101	1	2020-11-21	10.00	12.00	f	\N	1	\N
101	1	2020-11-21	12.00	14.00	f	\N	1	\N
101	1	2020-11-21	14.00	16.00	f	\N	1	\N
309	1	2020-11-21	10.00	12.00	f	\N	1	\N
309	1	2020-11-21	12.00	14.00	f	\N	1	\N
309	1	2020-11-21	14.00	16.00	f	\N	1	\N
166	1	2020-11-24	12.00	14.00	f	\N	1	\N
166	1	2020-11-24	14.00	16.00	f	\N	1	\N
166	1	2020-11-24	16.00	18.00	f	\N	1	\N
168	1	2020-11-24	10.00	12.00	f	\N	1	\N
168	1	2020-11-24	12.00	14.00	f	\N	1	\N
168	1	2020-11-24	14.00	16.00	f	\N	1	\N
168	1	2020-11-24	16.00	18.00	f	\N	1	\N
165	1	2020-11-24	10.00	12.00	f	\N	1	\N
165	1	2020-11-24	12.00	14.00	f	\N	1	\N
165	1	2020-11-24	14.00	16.00	f	\N	1	\N
165	1	2020-11-24	16.00	18.00	f	\N	1	\N
167	1	2020-11-24	10.00	12.00	f	\N	1	\N
167	1	2020-11-24	12.00	14.00	f	\N	1	\N
167	1	2020-11-24	14.00	16.00	f	\N	1	\N
283	3	2020-11-21	12.00	14.00	t	5081048035	2	V
256	1	2020-11-21	12.00	14.00	t	5091031735	2	KL
256	1	2020-11-21	10.00	12.00	t	5091031735	2	KL
256	1	2020-11-21	14.00	16.00	f	\N	1	\N
118	2	2020-11-30	12.00	14.00	f	\N	1	\N
287	3	2020-11-27	11.00	13.00	f	\N	1	\N
287	3	2020-11-27	13.00	15.00	f	\N	1	\N
287	3	2020-11-27	15.00	17.00	f	\N	1	\N
287	3	2020-11-27	17.00	18.00	f	\N	1	\N
167	1	2020-11-24	16.00	18.00	f	\N	1	\N
289	1	2020-11-24	10.00	12.00	f	\N	1	\N
289	1	2020-11-24	12.00	14.00	f	\N	1	\N
289	1	2020-11-24	14.00	16.00	f	\N	1	\N
289	1	2020-11-24	16.00	18.00	f	\N	1	\N
297	2	2020-11-24	10.00	12.00	f	\N	1	\N
297	2	2020-11-24	12.00	14.00	f	\N	1	\N
297	2	2020-11-24	14.00	16.00	f	\N	1	\N
297	2	2020-11-24	16.00	18.00	f	\N	1	\N
285	3	2020-11-24	10.00	12.00	f	\N	1	\N
285	3	2020-11-24	12.00	14.00	f	\N	1	\N
285	3	2020-11-24	14.00	16.00	f	\N	1	\N
285	3	2020-11-24	16.00	18.00	f	\N	1	\N
204	1	2020-11-24	9.00	11.00	f	\N	1	\N
204	1	2020-11-24	11.00	13.00	f	\N	1	\N
204	1	2020-11-24	13.00	15.00	f	\N	1	\N
204	1	2020-11-24	15.00	17.00	f	\N	1	\N
204	1	2020-11-24	17.00	18.00	f	\N	1	\N
203	1	2020-11-24	9.00	11.00	f	\N	1	\N
203	1	2020-11-24	11.00	13.00	f	\N	1	\N
203	1	2020-11-24	13.00	15.00	f	\N	1	\N
203	1	2020-11-24	15.00	17.00	f	\N	1	\N
203	1	2020-11-24	17.00	18.00	f	\N	1	\N
205	1	2020-11-24	9.00	11.00	f	\N	1	\N
205	1	2020-11-24	11.00	13.00	f	\N	1	\N
205	1	2020-11-24	13.00	15.00	f	\N	1	\N
205	1	2020-11-24	15.00	17.00	f	\N	1	\N
205	1	2020-11-24	17.00	18.00	f	\N	1	\N
202	1	2020-11-24	9.00	11.00	f	\N	1	\N
202	1	2020-11-24	11.00	13.00	f	\N	1	\N
202	1	2020-11-24	13.00	15.00	f	\N	1	\N
202	1	2020-11-24	15.00	17.00	f	\N	1	\N
202	1	2020-11-24	17.00	18.00	f	\N	1	\N
214	1	2020-11-24	9.00	11.00	f	\N	1	\N
214	1	2020-11-24	11.00	13.00	f	\N	1	\N
214	1	2020-11-24	13.00	15.00	f	\N	1	\N
214	1	2020-11-24	15.00	17.00	f	\N	1	\N
214	1	2020-11-24	17.00	18.00	f	\N	1	\N
213	1	2020-11-24	9.00	11.00	f	\N	1	\N
213	1	2020-11-24	11.00	13.00	f	\N	1	\N
213	1	2020-11-24	13.00	15.00	f	\N	1	\N
213	1	2020-11-24	15.00	17.00	f	\N	1	\N
213	1	2020-11-24	17.00	18.00	f	\N	1	\N
208	2	2020-11-24	9.00	11.00	f	\N	1	\N
208	2	2020-11-24	11.00	13.00	f	\N	1	\N
208	2	2020-11-24	13.00	15.00	f	\N	1	\N
208	2	2020-11-24	15.00	17.00	f	\N	1	\N
208	2	2020-11-24	17.00	18.00	f	\N	1	\N
244	2	2020-11-24	9.00	11.00	f	\N	1	\N
244	2	2020-11-24	11.00	13.00	f	\N	1	\N
244	2	2020-11-24	13.00	15.00	f	\N	1	\N
244	2	2020-11-24	15.00	17.00	f	\N	1	\N
244	2	2020-11-24	17.00	18.00	f	\N	1	\N
209	2	2020-11-24	9.00	11.00	f	\N	1	\N
209	2	2020-11-24	11.00	13.00	f	\N	1	\N
209	2	2020-11-24	13.00	15.00	f	\N	1	\N
209	2	2020-11-24	15.00	17.00	f	\N	1	\N
209	2	2020-11-24	17.00	18.00	f	\N	1	\N
245	2	2020-11-24	9.00	11.00	f	\N	1	\N
245	2	2020-11-24	11.00	13.00	f	\N	1	\N
245	2	2020-11-24	13.00	15.00	f	\N	1	\N
245	2	2020-11-24	15.00	17.00	f	\N	1	\N
245	2	2020-11-24	17.00	18.00	f	\N	1	\N
247	2	2020-11-24	9.00	11.00	f	\N	1	\N
247	2	2020-11-24	11.00	13.00	f	\N	1	\N
247	2	2020-11-24	13.00	15.00	f	\N	1	\N
247	2	2020-11-24	15.00	17.00	f	\N	1	\N
247	2	2020-11-24	17.00	18.00	f	\N	1	\N
207	2	2020-11-24	9.00	11.00	f	\N	1	\N
207	2	2020-11-24	11.00	13.00	f	\N	1	\N
207	2	2020-11-24	13.00	15.00	f	\N	1	\N
207	2	2020-11-24	15.00	17.00	f	\N	1	\N
207	2	2020-11-24	17.00	18.00	f	\N	1	\N
212	2	2020-11-24	9.00	11.00	f	\N	1	\N
212	2	2020-11-24	11.00	13.00	f	\N	1	\N
212	2	2020-11-24	13.00	15.00	f	\N	1	\N
212	2	2020-11-24	15.00	17.00	f	\N	1	\N
212	2	2020-11-24	17.00	18.00	f	\N	1	\N
217	2	2020-11-24	9.00	11.00	f	\N	1	\N
217	2	2020-11-24	11.00	13.00	f	\N	1	\N
217	2	2020-11-24	13.00	15.00	f	\N	1	\N
217	2	2020-11-24	15.00	17.00	f	\N	1	\N
217	2	2020-11-24	17.00	18.00	f	\N	1	\N
246	2	2020-11-24	9.00	11.00	f	\N	1	\N
246	2	2020-11-24	11.00	13.00	f	\N	1	\N
246	2	2020-11-24	13.00	15.00	f	\N	1	\N
246	2	2020-11-24	15.00	17.00	f	\N	1	\N
246	2	2020-11-24	17.00	18.00	f	\N	1	\N
210	2	2020-11-24	9.00	11.00	f	\N	1	\N
210	2	2020-11-24	11.00	13.00	f	\N	1	\N
210	2	2020-11-24	13.00	15.00	f	\N	1	\N
210	2	2020-11-24	15.00	17.00	f	\N	1	\N
210	2	2020-11-24	17.00	18.00	f	\N	1	\N
206	2	2020-11-24	9.00	11.00	f	\N	1	\N
206	2	2020-11-24	11.00	13.00	f	\N	1	\N
206	2	2020-11-24	13.00	15.00	f	\N	1	\N
206	2	2020-11-24	15.00	17.00	f	\N	1	\N
206	2	2020-11-24	17.00	18.00	f	\N	1	\N
288	3	2020-11-24	9.00	11.00	f	\N	1	\N
288	3	2020-11-24	11.00	13.00	f	\N	1	\N
288	3	2020-11-24	13.00	15.00	f	\N	1	\N
288	3	2020-11-24	15.00	17.00	f	\N	1	\N
288	3	2020-11-24	17.00	18.00	f	\N	1	\N
287	3	2020-11-24	9.00	11.00	f	\N	1	\N
287	3	2020-11-24	11.00	13.00	f	\N	1	\N
311	1	2020-11-21	10.00	12.00	f	\N	1	\N
311	1	2020-11-21	12.00	14.00	f	\N	1	\N
311	1	2020-11-21	14.00	16.00	f	\N	1	\N
190	1	2020-11-21	10.00	12.00	f	\N	1	\N
190	1	2020-11-21	12.00	14.00	f	\N	1	\N
190	1	2020-11-21	14.00	16.00	f	\N	1	\N
99	1	2020-11-21	10.00	12.00	f	\N	1	\N
196	1	2020-11-27	9.00	11.00	f	\N	1	\N
196	1	2020-11-27	11.00	13.00	f	\N	1	\N
196	1	2020-11-27	13.00	15.00	f	\N	1	\N
118	2	2020-11-30	14.00	16.00	f	\N	1	\N
196	1	2020-11-27	15.00	17.00	f	\N	1	\N
196	1	2020-11-27	17.00	18.00	f	\N	1	\N
97	1	2020-11-27	9.00	11.00	f	\N	1	\N
97	1	2020-11-27	11.00	13.00	f	\N	1	\N
97	1	2020-11-27	13.00	15.00	f	\N	1	\N
97	1	2020-11-27	15.00	17.00	f	\N	1	\N
97	1	2020-11-27	17.00	18.00	f	\N	1	\N
197	1	2020-11-27	9.00	11.00	f	\N	1	\N
287	3	2020-11-24	13.00	15.00	f	\N	1	\N
287	3	2020-11-24	15.00	17.00	f	\N	1	\N
197	1	2020-11-27	11.00	13.00	f	\N	1	\N
197	1	2020-11-27	13.00	15.00	f	\N	1	\N
197	1	2020-11-27	15.00	17.00	f	\N	1	\N
197	1	2020-11-27	17.00	18.00	f	\N	1	\N
135	1	2020-11-27	9.00	11.00	f	\N	1	\N
287	3	2020-11-24	17.00	18.00	f	\N	1	\N
196	1	2020-11-24	9.00	11.00	f	\N	1	\N
196	1	2020-11-24	11.00	13.00	f	\N	1	\N
196	1	2020-11-24	13.00	15.00	f	\N	1	\N
196	1	2020-11-24	15.00	17.00	f	\N	1	\N
196	1	2020-11-24	17.00	18.00	f	\N	1	\N
97	1	2020-11-24	9.00	11.00	f	\N	1	\N
97	1	2020-11-24	11.00	13.00	f	\N	1	\N
97	1	2020-11-24	13.00	15.00	f	\N	1	\N
97	1	2020-11-24	15.00	17.00	f	\N	1	\N
97	1	2020-11-24	17.00	18.00	f	\N	1	\N
197	1	2020-11-24	9.00	11.00	f	\N	1	\N
197	1	2020-11-24	11.00	13.00	f	\N	1	\N
197	1	2020-11-24	13.00	15.00	f	\N	1	\N
197	1	2020-11-24	15.00	17.00	f	\N	1	\N
197	1	2020-11-24	17.00	18.00	f	\N	1	\N
135	1	2020-11-24	9.00	11.00	f	\N	1	\N
135	1	2020-11-24	11.00	13.00	f	\N	1	\N
135	1	2020-11-24	13.00	15.00	f	\N	1	\N
135	1	2020-11-27	11.00	13.00	f	\N	1	\N
135	1	2020-11-27	13.00	15.00	f	\N	1	\N
135	1	2020-11-27	15.00	17.00	f	\N	1	\N
135	1	2020-11-27	17.00	18.00	f	\N	1	\N
136	1	2020-11-27	9.00	11.00	f	\N	1	\N
136	1	2020-11-27	11.00	13.00	f	\N	1	\N
136	1	2020-11-27	13.00	15.00	f	\N	1	\N
136	1	2020-11-27	15.00	17.00	f	\N	1	\N
136	1	2020-11-27	17.00	18.00	f	\N	1	\N
137	1	2020-11-27	9.00	11.00	f	\N	1	\N
137	1	2020-11-27	11.00	13.00	f	\N	1	\N
137	1	2020-11-27	13.00	15.00	f	\N	1	\N
137	1	2020-11-27	15.00	17.00	f	\N	1	\N
137	1	2020-11-27	17.00	18.00	f	\N	1	\N
195	1	2020-11-27	9.00	11.00	f	\N	1	\N
195	1	2020-11-27	11.00	13.00	f	\N	1	\N
195	1	2020-11-27	13.00	15.00	f	\N	1	\N
195	1	2020-11-27	15.00	17.00	f	\N	1	\N
195	1	2020-11-27	17.00	18.00	f	\N	1	\N
138	1	2020-11-27	9.00	11.00	f	\N	1	\N
135	1	2020-11-24	15.00	17.00	f	\N	1	\N
138	1	2020-11-27	11.00	13.00	f	\N	1	\N
99	1	2020-11-21	12.00	14.00	f	\N	1	\N
138	1	2020-11-27	13.00	15.00	f	\N	1	\N
138	1	2020-11-27	15.00	17.00	f	\N	1	\N
138	1	2020-11-27	17.00	18.00	f	\N	1	\N
139	1	2020-11-27	9.00	11.00	f	\N	1	\N
139	1	2020-11-27	11.00	13.00	f	\N	1	\N
139	1	2020-11-27	13.00	15.00	f	\N	1	\N
139	1	2020-11-27	15.00	17.00	f	\N	1	\N
139	1	2020-11-27	17.00	18.00	f	\N	1	\N
140	1	2020-11-27	9.00	11.00	f	\N	1	\N
140	1	2020-11-27	11.00	13.00	f	\N	1	\N
140	1	2020-11-27	13.00	15.00	f	\N	1	\N
140	1	2020-11-27	15.00	17.00	f	\N	1	\N
140	1	2020-11-27	17.00	18.00	f	\N	1	\N
141	1	2020-11-27	9.00	11.00	f	\N	1	\N
141	1	2020-11-27	11.00	13.00	f	\N	1	\N
141	1	2020-11-27	13.00	15.00	f	\N	1	\N
141	1	2020-11-27	15.00	17.00	f	\N	1	\N
141	1	2020-11-27	17.00	18.00	f	\N	1	\N
188	2	2020-11-27	9.00	11.00	f	\N	1	\N
188	2	2020-11-27	11.00	13.00	f	\N	1	\N
188	2	2020-11-27	13.00	15.00	f	\N	1	\N
188	2	2020-11-27	15.00	17.00	f	\N	1	\N
188	2	2020-11-27	17.00	18.00	f	\N	1	\N
248	2	2020-11-27	9.00	11.00	f	\N	1	\N
248	2	2020-11-27	11.00	13.00	f	\N	1	\N
248	2	2020-11-27	13.00	15.00	f	\N	1	\N
248	2	2020-11-27	15.00	17.00	f	\N	1	\N
248	2	2020-11-27	17.00	18.00	f	\N	1	\N
182	2	2020-11-27	9.00	11.00	f	\N	1	\N
182	2	2020-11-27	11.00	13.00	f	\N	1	\N
182	2	2020-11-27	13.00	15.00	f	\N	1	\N
182	2	2020-11-27	15.00	17.00	f	\N	1	\N
182	2	2020-11-27	17.00	18.00	f	\N	1	\N
183	2	2020-11-27	9.00	11.00	f	\N	1	\N
183	2	2020-11-27	11.00	13.00	f	\N	1	\N
183	2	2020-11-27	13.00	15.00	f	\N	1	\N
183	2	2020-11-27	15.00	17.00	f	\N	1	\N
183	2	2020-11-27	17.00	18.00	f	\N	1	\N
181	2	2020-11-27	9.00	11.00	f	\N	1	\N
181	2	2020-11-27	11.00	13.00	f	\N	1	\N
181	2	2020-11-27	13.00	15.00	f	\N	1	\N
181	2	2020-11-27	15.00	17.00	f	\N	1	\N
181	2	2020-11-27	17.00	18.00	f	\N	1	\N
187	2	2020-11-27	9.00	11.00	f	\N	1	\N
187	2	2020-11-27	11.00	13.00	f	\N	1	\N
187	2	2020-11-27	13.00	15.00	f	\N	1	\N
187	2	2020-11-27	15.00	17.00	f	\N	1	\N
187	2	2020-11-27	17.00	18.00	f	\N	1	\N
184	2	2020-11-27	9.00	11.00	f	\N	1	\N
184	2	2020-11-27	11.00	13.00	f	\N	1	\N
184	2	2020-11-27	13.00	15.00	f	\N	1	\N
184	2	2020-11-27	15.00	17.00	f	\N	1	\N
99	1	2020-11-21	14.00	16.00	f	\N	1	\N
100	1	2020-11-21	10.00	12.00	f	\N	1	\N
100	1	2020-11-21	12.00	14.00	f	\N	1	\N
100	1	2020-11-21	14.00	16.00	f	\N	1	\N
184	2	2020-11-27	17.00	18.00	f	\N	1	\N
249	2	2020-11-27	9.00	11.00	f	\N	1	\N
249	2	2020-11-27	11.00	13.00	f	\N	1	\N
249	2	2020-11-27	13.00	15.00	f	\N	1	\N
249	2	2020-11-27	15.00	17.00	f	\N	1	\N
249	2	2020-11-27	17.00	18.00	f	\N	1	\N
186	2	2020-11-27	9.00	11.00	f	\N	1	\N
186	2	2020-11-27	11.00	13.00	f	\N	1	\N
310	1	2020-11-21	10.00	12.00	t	8334666274	2	Maja 
186	2	2020-11-27	13.00	15.00	f	\N	1	\N
186	2	2020-11-27	15.00	17.00	f	\N	1	\N
186	2	2020-11-27	17.00	18.00	f	\N	1	\N
180	2	2020-11-27	9.00	11.00	f	\N	1	\N
180	2	2020-11-27	11.00	13.00	f	\N	1	\N
180	2	2020-11-27	13.00	15.00	f	\N	1	\N
135	1	2020-11-24	17.00	18.00	f	\N	1	\N
136	1	2020-11-24	9.00	11.00	f	\N	1	\N
136	1	2020-11-24	11.00	13.00	f	\N	1	\N
136	1	2020-11-24	13.00	15.00	f	\N	1	\N
136	1	2020-11-24	15.00	17.00	f	\N	1	\N
136	1	2020-11-24	17.00	18.00	f	\N	1	\N
137	1	2020-11-24	9.00	11.00	f	\N	1	\N
137	1	2020-11-24	11.00	13.00	f	\N	1	\N
137	1	2020-11-24	13.00	15.00	f	\N	1	\N
137	1	2020-11-24	15.00	17.00	f	\N	1	\N
137	1	2020-11-24	17.00	18.00	f	\N	1	\N
195	1	2020-11-24	9.00	11.00	f	\N	1	\N
195	1	2020-11-24	11.00	13.00	f	\N	1	\N
195	1	2020-11-24	13.00	15.00	f	\N	1	\N
195	1	2020-11-24	15.00	17.00	f	\N	1	\N
195	1	2020-11-24	17.00	18.00	f	\N	1	\N
138	1	2020-11-24	9.00	11.00	f	\N	1	\N
138	1	2020-11-24	11.00	13.00	f	\N	1	\N
138	1	2020-11-24	13.00	15.00	f	\N	1	\N
138	1	2020-11-24	15.00	17.00	f	\N	1	\N
138	1	2020-11-24	17.00	18.00	f	\N	1	\N
139	1	2020-11-24	9.00	11.00	f	\N	1	\N
139	1	2020-11-24	11.00	13.00	f	\N	1	\N
139	1	2020-11-24	13.00	15.00	f	\N	1	\N
139	1	2020-11-24	15.00	17.00	f	\N	1	\N
139	1	2020-11-24	17.00	18.00	f	\N	1	\N
140	1	2020-11-24	9.00	11.00	f	\N	1	\N
140	1	2020-11-24	11.00	13.00	f	\N	1	\N
140	1	2020-11-24	13.00	15.00	f	\N	1	\N
140	1	2020-11-24	15.00	17.00	f	\N	1	\N
140	1	2020-11-24	17.00	18.00	f	\N	1	\N
141	1	2020-11-24	9.00	11.00	f	\N	1	\N
141	1	2020-11-24	11.00	13.00	f	\N	1	\N
141	1	2020-11-24	13.00	15.00	f	\N	1	\N
141	1	2020-11-24	15.00	17.00	f	\N	1	\N
141	1	2020-11-24	17.00	18.00	f	\N	1	\N
188	2	2020-11-24	9.00	11.00	f	\N	1	\N
188	2	2020-11-24	11.00	13.00	f	\N	1	\N
188	2	2020-11-24	13.00	15.00	f	\N	1	\N
188	2	2020-11-24	15.00	17.00	f	\N	1	\N
188	2	2020-11-24	17.00	18.00	f	\N	1	\N
248	2	2020-11-24	9.00	11.00	f	\N	1	\N
248	2	2020-11-24	11.00	13.00	f	\N	1	\N
248	2	2020-11-24	13.00	15.00	f	\N	1	\N
248	2	2020-11-24	15.00	17.00	f	\N	1	\N
248	2	2020-11-24	17.00	18.00	f	\N	1	\N
182	2	2020-11-24	9.00	11.00	f	\N	1	\N
180	2	2020-11-27	15.00	17.00	f	\N	1	\N
180	2	2020-11-27	17.00	18.00	f	\N	1	\N
185	2	2020-11-27	9.00	11.00	f	\N	1	\N
185	2	2020-11-27	11.00	13.00	f	\N	1	\N
185	2	2020-11-27	13.00	15.00	f	\N	1	\N
185	2	2020-11-27	15.00	17.00	f	\N	1	\N
185	2	2020-11-27	17.00	18.00	f	\N	1	\N
310	1	2020-11-21	12.00	14.00	t	8334666274	2	Maja 
110	2	2020-11-30	10.00	12.00	f	\N	1	\N
110	2	2020-11-30	12.00	14.00	f	\N	1	\N
110	2	2020-11-30	14.00	16.00	f	\N	1	\N
108	2	2020-11-30	10.00	12.00	f	\N	1	\N
108	2	2020-11-30	12.00	14.00	f	\N	1	\N
108	2	2020-11-30	14.00	16.00	f	\N	1	\N
116	2	2020-11-30	10.00	12.00	f	\N	1	\N
116	2	2020-11-30	12.00	14.00	f	\N	1	\N
116	2	2020-11-30	14.00	16.00	f	\N	1	\N
115	2	2020-11-30	10.00	12.00	f	\N	1	\N
115	2	2020-11-30	12.00	14.00	f	\N	1	\N
115	2	2020-11-30	14.00	16.00	f	\N	1	\N
114	2	2020-11-30	10.00	12.00	f	\N	1	\N
114	2	2020-11-30	12.00	14.00	f	\N	1	\N
114	2	2020-11-30	14.00	16.00	f	\N	1	\N
283	3	2020-11-27	9.00	11.00	f	\N	1	\N
283	3	2020-11-27	11.00	13.00	f	\N	1	\N
283	3	2020-11-27	13.00	15.00	f	\N	1	\N
283	3	2020-11-27	15.00	17.00	f	\N	1	\N
283	3	2020-11-27	17.00	18.00	f	\N	1	\N
284	3	2020-11-27	9.00	11.00	f	\N	1	\N
284	3	2020-11-27	11.00	13.00	f	\N	1	\N
284	3	2020-11-27	13.00	15.00	f	\N	1	\N
284	3	2020-11-27	15.00	17.00	f	\N	1	\N
284	3	2020-11-27	17.00	18.00	f	\N	1	\N
189	1	2020-11-27	10.00	12.00	f	\N	1	\N
189	1	2020-11-27	12.00	14.00	f	\N	1	\N
189	1	2020-11-27	14.00	16.00	f	\N	1	\N
256	1	2020-11-27	10.00	12.00	f	\N	1	\N
256	1	2020-11-27	12.00	14.00	f	\N	1	\N
256	1	2020-11-27	14.00	16.00	f	\N	1	\N
98	1	2020-11-27	10.00	12.00	f	\N	1	\N
98	1	2020-11-27	12.00	14.00	f	\N	1	\N
98	1	2020-11-27	14.00	16.00	f	\N	1	\N
101	1	2020-11-27	10.00	12.00	f	\N	1	\N
101	1	2020-11-27	12.00	14.00	f	\N	1	\N
101	1	2020-11-27	14.00	16.00	f	\N	1	\N
309	1	2020-11-27	10.00	12.00	f	\N	1	\N
309	1	2020-11-27	12.00	14.00	f	\N	1	\N
309	1	2020-11-27	14.00	16.00	f	\N	1	\N
311	1	2020-11-27	10.00	12.00	f	\N	1	\N
311	1	2020-11-27	12.00	14.00	f	\N	1	\N
113	2	2020-11-30	10.00	12.00	f	\N	1	\N
311	1	2020-11-27	14.00	16.00	f	\N	1	\N
310	1	2020-11-21	14.00	16.00	f	\N	1	\N
102	1	2020-11-21	10.00	12.00	f	\N	1	\N
113	2	2020-11-30	12.00	14.00	f	\N	1	\N
113	2	2020-11-30	14.00	16.00	f	\N	1	\N
120	2	2020-11-30	10.00	12.00	f	\N	1	\N
190	1	2020-11-27	10.00	12.00	f	\N	1	\N
120	2	2020-11-30	12.00	14.00	f	\N	1	\N
190	1	2020-11-27	12.00	14.00	f	\N	1	\N
190	1	2020-11-27	14.00	16.00	f	\N	1	\N
182	2	2020-11-24	11.00	13.00	f	\N	1	\N
182	2	2020-11-24	13.00	15.00	f	\N	1	\N
182	2	2020-11-24	15.00	17.00	f	\N	1	\N
182	2	2020-11-24	17.00	18.00	f	\N	1	\N
183	2	2020-11-24	9.00	11.00	f	\N	1	\N
183	2	2020-11-24	11.00	13.00	f	\N	1	\N
183	2	2020-11-24	13.00	15.00	f	\N	1	\N
183	2	2020-11-24	15.00	17.00	f	\N	1	\N
183	2	2020-11-24	17.00	18.00	f	\N	1	\N
181	2	2020-11-24	9.00	11.00	f	\N	1	\N
181	2	2020-11-24	11.00	13.00	f	\N	1	\N
181	2	2020-11-24	13.00	15.00	f	\N	1	\N
181	2	2020-11-24	15.00	17.00	f	\N	1	\N
181	2	2020-11-24	17.00	18.00	f	\N	1	\N
187	2	2020-11-24	9.00	11.00	f	\N	1	\N
187	2	2020-11-24	11.00	13.00	f	\N	1	\N
187	2	2020-11-24	13.00	15.00	f	\N	1	\N
187	2	2020-11-24	15.00	17.00	f	\N	1	\N
187	2	2020-11-24	17.00	18.00	f	\N	1	\N
184	2	2020-11-24	9.00	11.00	f	\N	1	\N
184	2	2020-11-24	11.00	13.00	f	\N	1	\N
184	2	2020-11-24	13.00	15.00	f	\N	1	\N
184	2	2020-11-24	15.00	17.00	f	\N	1	\N
184	2	2020-11-24	17.00	18.00	f	\N	1	\N
249	2	2020-11-24	9.00	11.00	f	\N	1	\N
249	2	2020-11-24	11.00	13.00	f	\N	1	\N
249	2	2020-11-24	13.00	15.00	f	\N	1	\N
249	2	2020-11-24	15.00	17.00	f	\N	1	\N
249	2	2020-11-24	17.00	18.00	f	\N	1	\N
186	2	2020-11-24	9.00	11.00	f	\N	1	\N
186	2	2020-11-24	11.00	13.00	f	\N	1	\N
186	2	2020-11-24	13.00	15.00	f	\N	1	\N
186	2	2020-11-24	15.00	17.00	f	\N	1	\N
186	2	2020-11-24	17.00	18.00	f	\N	1	\N
180	2	2020-11-24	9.00	11.00	f	\N	1	\N
180	2	2020-11-24	11.00	13.00	f	\N	1	\N
180	2	2020-11-24	13.00	15.00	f	\N	1	\N
180	2	2020-11-24	15.00	17.00	f	\N	1	\N
180	2	2020-11-24	17.00	18.00	f	\N	1	\N
185	2	2020-11-24	9.00	11.00	f	\N	1	\N
185	2	2020-11-24	11.00	13.00	f	\N	1	\N
185	2	2020-11-24	13.00	15.00	f	\N	1	\N
185	2	2020-11-24	15.00	17.00	f	\N	1	\N
185	2	2020-11-24	17.00	18.00	f	\N	1	\N
283	3	2020-11-24	9.00	11.00	f	\N	1	\N
283	3	2020-11-24	11.00	13.00	f	\N	1	\N
283	3	2020-11-24	13.00	15.00	f	\N	1	\N
283	3	2020-11-24	15.00	17.00	f	\N	1	\N
283	3	2020-11-24	17.00	18.00	f	\N	1	\N
284	3	2020-11-24	9.00	11.00	f	\N	1	\N
284	3	2020-11-24	11.00	13.00	f	\N	1	\N
284	3	2020-11-24	13.00	15.00	f	\N	1	\N
284	3	2020-11-24	15.00	17.00	f	\N	1	\N
284	3	2020-11-24	17.00	18.00	f	\N	1	\N
189	1	2020-11-24	10.00	12.00	f	\N	1	\N
189	1	2020-11-24	12.00	14.00	f	\N	1	\N
189	1	2020-11-24	14.00	16.00	f	\N	1	\N
256	1	2020-11-24	10.00	12.00	f	\N	1	\N
256	1	2020-11-24	12.00	14.00	f	\N	1	\N
256	1	2020-11-24	14.00	16.00	f	\N	1	\N
98	1	2020-11-24	10.00	12.00	f	\N	1	\N
99	1	2020-11-27	10.00	12.00	f	\N	1	\N
98	1	2020-11-24	12.00	14.00	f	\N	1	\N
98	1	2020-11-24	14.00	16.00	f	\N	1	\N
101	1	2020-11-24	14.00	16.00	f	\N	1	\N
309	1	2020-11-24	10.00	12.00	f	\N	1	\N
309	1	2020-11-24	12.00	14.00	f	\N	1	\N
309	1	2020-11-24	14.00	16.00	f	\N	1	\N
311	1	2020-11-24	10.00	12.00	f	\N	1	\N
311	1	2020-11-24	12.00	14.00	f	\N	1	\N
311	1	2020-11-24	14.00	16.00	f	\N	1	\N
190	1	2020-11-24	10.00	12.00	f	\N	1	\N
190	1	2020-11-24	12.00	14.00	f	\N	1	\N
190	1	2020-11-24	14.00	16.00	f	\N	1	\N
99	1	2020-11-24	10.00	12.00	f	\N	1	\N
99	1	2020-11-24	12.00	14.00	f	\N	1	\N
99	1	2020-11-24	14.00	16.00	f	\N	1	\N
100	1	2020-11-24	10.00	12.00	f	\N	1	\N
100	1	2020-11-24	12.00	14.00	f	\N	1	\N
100	1	2020-11-24	14.00	16.00	f	\N	1	\N
310	1	2020-11-24	10.00	12.00	f	\N	1	\N
310	1	2020-11-24	12.00	14.00	f	\N	1	\N
310	1	2020-11-24	14.00	16.00	f	\N	1	\N
102	1	2020-11-24	10.00	12.00	f	\N	1	\N
102	1	2020-11-24	12.00	14.00	f	\N	1	\N
102	1	2020-11-24	14.00	16.00	f	\N	1	\N
103	1	2020-11-24	10.00	12.00	f	\N	1	\N
103	1	2020-11-24	12.00	14.00	f	\N	1	\N
103	1	2020-11-24	14.00	16.00	f	\N	1	\N
104	1	2020-11-24	10.00	12.00	f	\N	1	\N
312	1	2020-11-24	10.00	12.00	f	\N	1	\N
312	1	2020-11-24	12.00	14.00	f	\N	1	\N
99	1	2020-11-27	12.00	14.00	f	\N	1	\N
99	1	2020-11-27	14.00	16.00	f	\N	1	\N
100	1	2020-11-27	10.00	12.00	f	\N	1	\N
104	1	2020-11-24	14.00	16.00	t	8320864778	2	Idil
307	1	2020-11-24	10.00	12.00	t	8334666274	2	Maja
307	1	2020-11-24	12.00	14.00	t	8334666274	2	Maja
307	1	2020-11-24	14.00	16.00	t	5151498445	2	Martiti
101	1	2020-11-24	10.00	12.00	t	8283295744	2	hhh
101	1	2020-11-24	12.00	14.00	t	8283295744	2	hhh
104	1	2020-11-24	12.00	14.00	t	8320864778	2	Idil
102	1	2020-11-21	12.00	14.00	f	\N	1	\N
102	1	2020-11-21	14.00	16.00	f	\N	1	\N
103	1	2020-11-21	10.00	12.00	f	\N	1	\N
103	1	2020-11-21	12.00	14.00	f	\N	1	\N
103	1	2020-11-21	14.00	16.00	f	\N	1	\N
104	1	2020-11-21	10.00	12.00	f	\N	1	\N
104	1	2020-11-21	12.00	14.00	f	\N	1	\N
120	2	2020-11-30	14.00	16.00	f	\N	1	\N
286	3	2020-11-30	10.00	12.00	f	\N	1	\N
104	1	2020-11-21	14.00	16.00	f	\N	1	\N
100	1	2020-11-27	12.00	14.00	f	\N	1	\N
307	1	2020-11-21	10.00	12.00	f	\N	1	\N
100	1	2020-11-27	14.00	16.00	f	\N	1	\N
310	1	2020-11-27	10.00	12.00	f	\N	1	\N
310	1	2020-11-27	12.00	14.00	f	\N	1	\N
310	1	2020-11-27	14.00	16.00	f	\N	1	\N
102	1	2020-11-27	10.00	12.00	f	\N	1	\N
102	1	2020-11-27	12.00	14.00	f	\N	1	\N
102	1	2020-11-27	14.00	16.00	f	\N	1	\N
103	1	2020-11-27	10.00	12.00	f	\N	1	\N
307	1	2020-11-21	12.00	14.00	f	\N	1	\N
103	1	2020-11-27	12.00	14.00	f	\N	1	\N
103	1	2020-11-27	14.00	16.00	f	\N	1	\N
104	1	2020-11-27	10.00	12.00	f	\N	1	\N
104	1	2020-11-27	12.00	14.00	f	\N	1	\N
104	1	2020-11-27	14.00	16.00	f	\N	1	\N
307	1	2020-11-27	10.00	12.00	f	\N	1	\N
307	1	2020-11-27	12.00	14.00	f	\N	1	\N
307	1	2020-11-27	14.00	16.00	f	\N	1	\N
307	1	2020-11-21	14.00	16.00	f	\N	1	\N
312	1	2020-11-21	10.00	12.00	f	\N	1	\N
312	1	2020-11-27	10.00	12.00	f	\N	1	\N
312	1	2020-11-27	12.00	14.00	f	\N	1	\N
312	1	2020-11-27	14.00	16.00	f	\N	1	\N
308	1	2020-11-27	10.00	12.00	f	\N	1	\N
308	1	2020-11-27	12.00	14.00	f	\N	1	\N
308	1	2020-11-27	14.00	16.00	f	\N	1	\N
286	3	2020-11-30	12.00	14.00	f	\N	1	\N
286	3	2020-11-30	14.00	16.00	f	\N	1	\N
312	1	2020-11-24	14.00	16.00	f	\N	1	\N
308	1	2020-11-24	10.00	12.00	f	\N	1	\N
308	1	2020-11-24	12.00	14.00	f	\N	1	\N
308	1	2020-11-24	14.00	16.00	f	\N	1	\N
122	2	2020-11-24	10.00	12.00	f	\N	1	\N
122	2	2020-11-24	12.00	14.00	f	\N	1	\N
122	2	2020-11-24	14.00	16.00	f	\N	1	\N
105	2	2020-11-24	10.00	12.00	f	\N	1	\N
105	2	2020-11-24	12.00	14.00	f	\N	1	\N
105	2	2020-11-24	14.00	16.00	f	\N	1	\N
112	2	2020-11-24	10.00	12.00	f	\N	1	\N
112	2	2020-11-24	12.00	14.00	f	\N	1	\N
112	2	2020-11-24	14.00	16.00	f	\N	1	\N
122	2	2020-11-27	10.00	12.00	f	\N	1	\N
122	2	2020-11-27	12.00	14.00	f	\N	1	\N
122	2	2020-11-27	14.00	16.00	f	\N	1	\N
105	2	2020-11-27	10.00	12.00	f	\N	1	\N
105	2	2020-11-27	12.00	14.00	f	\N	1	\N
105	2	2020-11-27	14.00	16.00	f	\N	1	\N
112	2	2020-11-27	10.00	12.00	f	\N	1	\N
112	2	2020-11-27	12.00	14.00	f	\N	1	\N
112	2	2020-11-27	14.00	16.00	f	\N	1	\N
111	2	2020-11-27	10.00	12.00	f	\N	1	\N
111	2	2020-11-27	12.00	14.00	f	\N	1	\N
111	2	2020-11-27	14.00	16.00	f	\N	1	\N
106	2	2020-11-27	10.00	12.00	f	\N	1	\N
106	2	2020-11-27	12.00	14.00	f	\N	1	\N
106	2	2020-11-27	14.00	16.00	f	\N	1	\N
107	2	2020-11-27	10.00	12.00	f	\N	1	\N
107	2	2020-11-27	12.00	14.00	f	\N	1	\N
107	2	2020-11-27	14.00	16.00	f	\N	1	\N
109	2	2020-11-27	10.00	12.00	f	\N	1	\N
109	2	2020-11-27	12.00	14.00	f	\N	1	\N
109	2	2020-11-27	14.00	16.00	f	\N	1	\N
133	2	2020-11-27	10.00	12.00	f	\N	1	\N
133	2	2020-11-27	12.00	14.00	f	\N	1	\N
133	2	2020-11-27	14.00	16.00	f	\N	1	\N
134	2	2020-11-27	10.00	12.00	f	\N	1	\N
134	2	2020-11-27	12.00	14.00	f	\N	1	\N
134	2	2020-11-27	14.00	16.00	f	\N	1	\N
128	2	2020-11-27	10.00	12.00	f	\N	1	\N
128	2	2020-11-27	12.00	14.00	f	\N	1	\N
128	2	2020-11-27	14.00	16.00	f	\N	1	\N
127	2	2020-11-27	10.00	12.00	f	\N	1	\N
127	2	2020-11-27	12.00	14.00	f	\N	1	\N
127	2	2020-11-27	14.00	16.00	f	\N	1	\N
126	2	2020-11-27	10.00	12.00	f	\N	1	\N
126	2	2020-11-27	12.00	14.00	f	\N	1	\N
126	2	2020-11-27	14.00	16.00	f	\N	1	\N
125	2	2020-11-27	10.00	12.00	f	\N	1	\N
125	2	2020-11-27	12.00	14.00	f	\N	1	\N
125	2	2020-11-27	14.00	16.00	f	\N	1	\N
132	2	2020-11-27	10.00	12.00	f	\N	1	\N
132	2	2020-11-27	12.00	14.00	f	\N	1	\N
132	2	2020-11-27	14.00	16.00	f	\N	1	\N
131	2	2020-11-27	10.00	12.00	f	\N	1	\N
131	2	2020-11-27	12.00	14.00	f	\N	1	\N
131	2	2020-11-27	14.00	16.00	f	\N	1	\N
130	2	2020-11-27	10.00	12.00	f	\N	1	\N
89	1	2020-11-30	9.00	11.00	f	\N	1	\N
89	1	2020-11-30	11.00	13.00	f	\N	1	\N
89	1	2020-11-30	13.00	15.00	f	\N	1	\N
89	1	2020-11-30	15.00	17.00	f	\N	1	\N
89	1	2020-11-30	17.00	18.00	f	\N	1	\N
312	1	2020-11-21	12.00	14.00	f	\N	1	\N
312	1	2020-11-21	14.00	16.00	f	\N	1	\N
300	1	2020-11-30	9.00	11.00	f	\N	1	\N
300	1	2020-11-30	11.00	13.00	f	\N	1	\N
300	1	2020-11-30	13.00	15.00	f	\N	1	\N
308	1	2020-11-21	10.00	12.00	f	\N	1	\N
308	1	2020-11-21	12.00	14.00	f	\N	1	\N
300	1	2020-11-30	15.00	17.00	f	\N	1	\N
111	2	2020-11-24	10.00	12.00	f	\N	1	\N
300	1	2020-11-30	17.00	18.00	f	\N	1	\N
298	1	2020-11-30	9.00	11.00	f	\N	1	\N
298	1	2020-11-30	11.00	13.00	f	\N	1	\N
298	1	2020-11-30	13.00	15.00	f	\N	1	\N
298	1	2020-11-30	15.00	17.00	f	\N	1	\N
298	1	2020-11-30	17.00	18.00	f	\N	1	\N
95	1	2020-11-30	9.00	11.00	f	\N	1	\N
95	1	2020-11-30	11.00	13.00	f	\N	1	\N
95	1	2020-11-30	13.00	15.00	f	\N	1	\N
95	1	2020-11-30	15.00	17.00	f	\N	1	\N
95	1	2020-11-30	17.00	18.00	f	\N	1	\N
90	1	2020-11-30	9.00	11.00	f	\N	1	\N
90	1	2020-11-30	11.00	13.00	f	\N	1	\N
90	1	2020-11-30	13.00	15.00	f	\N	1	\N
90	1	2020-11-30	15.00	17.00	f	\N	1	\N
90	1	2020-11-30	17.00	18.00	f	\N	1	\N
94	1	2020-11-30	9.00	11.00	f	\N	1	\N
94	1	2020-11-30	11.00	13.00	f	\N	1	\N
94	1	2020-11-30	13.00	15.00	f	\N	1	\N
94	1	2020-11-30	15.00	17.00	f	\N	1	\N
94	1	2020-11-30	17.00	18.00	f	\N	1	\N
92	1	2020-11-30	9.00	11.00	f	\N	1	\N
92	1	2020-11-30	11.00	13.00	f	\N	1	\N
92	1	2020-11-30	13.00	15.00	f	\N	1	\N
92	1	2020-11-30	15.00	17.00	f	\N	1	\N
92	1	2020-11-30	17.00	18.00	f	\N	1	\N
93	1	2020-11-30	9.00	11.00	f	\N	1	\N
93	1	2020-11-30	11.00	13.00	f	\N	1	\N
93	1	2020-11-30	13.00	15.00	f	\N	1	\N
93	1	2020-11-30	15.00	17.00	f	\N	1	\N
93	1	2020-11-30	17.00	18.00	f	\N	1	\N
96	1	2020-11-30	9.00	11.00	f	\N	1	\N
96	1	2020-11-30	11.00	13.00	f	\N	1	\N
96	1	2020-11-30	13.00	15.00	f	\N	1	\N
96	1	2020-11-30	15.00	17.00	f	\N	1	\N
96	1	2020-11-30	17.00	18.00	f	\N	1	\N
91	1	2020-11-30	9.00	11.00	f	\N	1	\N
91	1	2020-11-30	11.00	13.00	f	\N	1	\N
91	1	2020-11-30	13.00	15.00	f	\N	1	\N
91	1	2020-11-30	15.00	17.00	f	\N	1	\N
91	1	2020-11-30	17.00	18.00	f	\N	1	\N
301	1	2020-11-30	9.00	11.00	f	\N	1	\N
301	1	2020-11-30	11.00	13.00	f	\N	1	\N
301	1	2020-11-30	13.00	15.00	f	\N	1	\N
301	1	2020-11-30	15.00	17.00	f	\N	1	\N
301	1	2020-11-30	17.00	18.00	f	\N	1	\N
299	1	2020-11-30	9.00	11.00	f	\N	1	\N
299	1	2020-11-30	11.00	13.00	f	\N	1	\N
299	1	2020-11-30	13.00	15.00	f	\N	1	\N
299	1	2020-11-30	15.00	17.00	f	\N	1	\N
299	1	2020-11-30	17.00	18.00	f	\N	1	\N
176	2	2020-11-30	9.00	11.00	f	\N	1	\N
176	2	2020-11-30	11.00	13.00	f	\N	1	\N
176	2	2020-11-30	13.00	15.00	f	\N	1	\N
176	2	2020-11-30	15.00	17.00	f	\N	1	\N
176	2	2020-11-30	17.00	18.00	f	\N	1	\N
175	2	2020-11-30	9.00	11.00	f	\N	1	\N
175	2	2020-11-30	11.00	13.00	f	\N	1	\N
175	2	2020-11-30	13.00	15.00	f	\N	1	\N
175	2	2020-11-30	15.00	17.00	f	\N	1	\N
175	2	2020-11-30	17.00	18.00	f	\N	1	\N
174	2	2020-11-30	9.00	11.00	f	\N	1	\N
174	2	2020-11-30	11.00	13.00	f	\N	1	\N
174	2	2020-11-30	13.00	15.00	f	\N	1	\N
130	2	2020-11-27	12.00	14.00	f	\N	1	\N
174	2	2020-11-30	15.00	17.00	f	\N	1	\N
174	2	2020-11-30	17.00	18.00	f	\N	1	\N
179	2	2020-11-30	9.00	11.00	f	\N	1	\N
179	2	2020-11-30	11.00	13.00	f	\N	1	\N
179	2	2020-11-30	13.00	15.00	f	\N	1	\N
179	2	2020-11-30	15.00	17.00	f	\N	1	\N
179	2	2020-11-30	17.00	18.00	f	\N	1	\N
130	2	2020-11-27	14.00	16.00	f	\N	1	\N
178	2	2020-11-30	9.00	11.00	f	\N	1	\N
178	2	2020-11-30	11.00	13.00	f	\N	1	\N
178	2	2020-11-30	13.00	15.00	f	\N	1	\N
178	2	2020-11-30	15.00	17.00	f	\N	1	\N
178	2	2020-11-30	17.00	18.00	f	\N	1	\N
129	2	2020-11-27	10.00	12.00	f	\N	1	\N
177	2	2020-11-30	9.00	11.00	f	\N	1	\N
177	2	2020-11-30	11.00	13.00	f	\N	1	\N
177	2	2020-11-30	13.00	15.00	f	\N	1	\N
177	2	2020-11-30	15.00	17.00	f	\N	1	\N
177	2	2020-11-30	17.00	18.00	f	\N	1	\N
192	2	2020-11-30	9.00	11.00	f	\N	1	\N
129	2	2020-11-27	12.00	14.00	f	\N	1	\N
192	2	2020-11-30	11.00	13.00	f	\N	1	\N
129	2	2020-11-27	14.00	16.00	f	\N	1	\N
124	2	2020-11-27	10.00	12.00	f	\N	1	\N
192	2	2020-11-30	13.00	15.00	f	\N	1	\N
192	2	2020-11-30	15.00	17.00	f	\N	1	\N
124	2	2020-11-27	12.00	14.00	f	\N	1	\N
192	2	2020-11-30	17.00	18.00	f	\N	1	\N
124	2	2020-11-27	14.00	16.00	f	\N	1	\N
193	2	2020-11-30	9.00	11.00	f	\N	1	\N
193	2	2020-11-30	11.00	13.00	f	\N	1	\N
193	2	2020-11-30	13.00	15.00	f	\N	1	\N
193	2	2020-11-30	15.00	17.00	f	\N	1	\N
193	2	2020-11-30	17.00	18.00	f	\N	1	\N
117	2	2020-11-27	10.00	12.00	f	\N	1	\N
117	2	2020-11-27	12.00	14.00	f	\N	1	\N
302	3	2020-11-30	9.00	11.00	f	\N	1	\N
302	3	2020-11-30	11.00	13.00	f	\N	1	\N
302	3	2020-11-30	13.00	15.00	f	\N	1	\N
302	3	2020-11-30	15.00	17.00	f	\N	1	\N
302	3	2020-11-30	17.00	18.00	f	\N	1	\N
305	3	2020-11-30	9.00	11.00	f	\N	1	\N
305	3	2020-11-30	11.00	13.00	f	\N	1	\N
305	3	2020-11-30	13.00	15.00	f	\N	1	\N
305	3	2020-11-30	15.00	17.00	f	\N	1	\N
308	1	2020-11-21	14.00	16.00	f	\N	1	\N
117	2	2020-11-27	14.00	16.00	f	\N	1	\N
111	2	2020-11-24	12.00	14.00	f	\N	1	\N
111	2	2020-11-24	14.00	16.00	f	\N	1	\N
106	2	2020-11-24	10.00	12.00	f	\N	1	\N
106	2	2020-11-24	12.00	14.00	f	\N	1	\N
106	2	2020-11-24	14.00	16.00	f	\N	1	\N
107	2	2020-11-24	10.00	12.00	f	\N	1	\N
107	2	2020-11-24	12.00	14.00	f	\N	1	\N
107	2	2020-11-24	14.00	16.00	f	\N	1	\N
109	2	2020-11-24	10.00	12.00	f	\N	1	\N
109	2	2020-11-24	12.00	14.00	f	\N	1	\N
109	2	2020-11-24	14.00	16.00	f	\N	1	\N
305	3	2020-11-30	17.00	18.00	f	\N	1	\N
314	3	2020-11-30	9.00	11.00	f	\N	1	\N
122	2	2020-11-21	10.00	12.00	f	\N	1	\N
123	2	2020-11-27	10.00	12.00	f	\N	1	\N
123	2	2020-11-27	12.00	14.00	f	\N	1	\N
123	2	2020-11-27	14.00	16.00	f	\N	1	\N
121	2	2020-11-27	10.00	12.00	f	\N	1	\N
122	2	2020-11-21	12.00	14.00	f	\N	1	\N
121	2	2020-11-27	12.00	14.00	f	\N	1	\N
121	2	2020-11-27	14.00	16.00	f	\N	1	\N
119	2	2020-11-27	10.00	12.00	f	\N	1	\N
119	2	2020-11-27	12.00	14.00	f	\N	1	\N
122	2	2020-11-21	14.00	16.00	f	\N	1	\N
119	2	2020-11-27	14.00	16.00	f	\N	1	\N
118	2	2020-11-27	10.00	12.00	f	\N	1	\N
118	2	2020-11-27	12.00	14.00	f	\N	1	\N
118	2	2020-11-27	14.00	16.00	f	\N	1	\N
105	2	2020-11-21	10.00	12.00	f	\N	1	\N
110	2	2020-11-27	10.00	12.00	f	\N	1	\N
110	2	2020-11-27	12.00	14.00	f	\N	1	\N
110	2	2020-11-27	14.00	16.00	f	\N	1	\N
108	2	2020-11-27	10.00	12.00	f	\N	1	\N
105	2	2020-11-21	12.00	14.00	f	\N	1	\N
108	2	2020-11-27	12.00	14.00	f	\N	1	\N
108	2	2020-11-27	14.00	16.00	f	\N	1	\N
133	2	2020-11-24	10.00	12.00	f	\N	1	\N
133	2	2020-11-24	12.00	14.00	f	\N	1	\N
133	2	2020-11-24	14.00	16.00	f	\N	1	\N
134	2	2020-11-24	10.00	12.00	f	\N	1	\N
134	2	2020-11-24	12.00	14.00	f	\N	1	\N
134	2	2020-11-24	14.00	16.00	f	\N	1	\N
128	2	2020-11-24	10.00	12.00	f	\N	1	\N
128	2	2020-11-24	12.00	14.00	f	\N	1	\N
128	2	2020-11-24	14.00	16.00	f	\N	1	\N
127	2	2020-11-24	10.00	12.00	f	\N	1	\N
127	2	2020-11-24	12.00	14.00	f	\N	1	\N
127	2	2020-11-24	14.00	16.00	f	\N	1	\N
126	2	2020-11-24	10.00	12.00	f	\N	1	\N
126	2	2020-11-24	12.00	14.00	f	\N	1	\N
126	2	2020-11-24	14.00	16.00	f	\N	1	\N
125	2	2020-11-24	10.00	12.00	f	\N	1	\N
125	2	2020-11-24	12.00	14.00	f	\N	1	\N
125	2	2020-11-24	14.00	16.00	f	\N	1	\N
132	2	2020-11-24	10.00	12.00	f	\N	1	\N
132	2	2020-11-24	12.00	14.00	f	\N	1	\N
132	2	2020-11-24	14.00	16.00	f	\N	1	\N
131	2	2020-11-24	10.00	12.00	f	\N	1	\N
131	2	2020-11-24	12.00	14.00	f	\N	1	\N
131	2	2020-11-24	14.00	16.00	f	\N	1	\N
130	2	2020-11-24	10.00	12.00	f	\N	1	\N
130	2	2020-11-24	12.00	14.00	f	\N	1	\N
130	2	2020-11-24	14.00	16.00	f	\N	1	\N
129	2	2020-11-24	10.00	12.00	f	\N	1	\N
129	2	2020-11-24	12.00	14.00	f	\N	1	\N
129	2	2020-11-24	14.00	16.00	f	\N	1	\N
124	2	2020-11-24	10.00	12.00	f	\N	1	\N
124	2	2020-11-24	12.00	14.00	f	\N	1	\N
124	2	2020-11-24	14.00	16.00	f	\N	1	\N
117	2	2020-11-24	10.00	12.00	f	\N	1	\N
117	2	2020-11-24	12.00	14.00	f	\N	1	\N
117	2	2020-11-24	14.00	16.00	f	\N	1	\N
105	2	2020-11-21	14.00	16.00	f	\N	1	\N
112	2	2020-11-21	10.00	12.00	f	\N	1	\N
123	2	2020-11-24	10.00	12.00	f	\N	1	\N
123	2	2020-11-24	12.00	14.00	f	\N	1	\N
123	2	2020-11-24	14.00	16.00	f	\N	1	\N
121	2	2020-11-24	10.00	12.00	f	\N	1	\N
121	2	2020-11-24	12.00	14.00	f	\N	1	\N
121	2	2020-11-24	14.00	16.00	f	\N	1	\N
119	2	2020-11-24	10.00	12.00	f	\N	1	\N
119	2	2020-11-24	12.00	14.00	f	\N	1	\N
119	2	2020-11-24	14.00	16.00	f	\N	1	\N
118	2	2020-11-24	10.00	12.00	f	\N	1	\N
118	2	2020-11-24	12.00	14.00	f	\N	1	\N
118	2	2020-11-24	14.00	16.00	f	\N	1	\N
110	2	2020-11-24	10.00	12.00	f	\N	1	\N
110	2	2020-11-24	12.00	14.00	f	\N	1	\N
110	2	2020-11-24	14.00	16.00	f	\N	1	\N
108	2	2020-11-24	10.00	12.00	f	\N	1	\N
108	2	2020-11-24	12.00	14.00	f	\N	1	\N
108	2	2020-11-24	14.00	16.00	f	\N	1	\N
116	2	2020-11-24	10.00	12.00	f	\N	1	\N
116	2	2020-11-24	12.00	14.00	f	\N	1	\N
116	2	2020-11-24	14.00	16.00	f	\N	1	\N
115	2	2020-11-24	10.00	12.00	f	\N	1	\N
115	2	2020-11-24	12.00	14.00	f	\N	1	\N
115	2	2020-11-24	14.00	16.00	f	\N	1	\N
114	2	2020-11-24	10.00	12.00	f	\N	1	\N
114	2	2020-11-24	12.00	14.00	f	\N	1	\N
114	2	2020-11-24	14.00	16.00	f	\N	1	\N
113	2	2020-11-24	10.00	12.00	f	\N	1	\N
113	2	2020-11-24	12.00	14.00	f	\N	1	\N
113	2	2020-11-24	14.00	16.00	f	\N	1	\N
120	2	2020-11-24	10.00	12.00	f	\N	1	\N
120	2	2020-11-24	12.00	14.00	f	\N	1	\N
120	2	2020-11-24	14.00	16.00	f	\N	1	\N
286	3	2020-11-24	10.00	12.00	f	\N	1	\N
286	3	2020-11-24	12.00	14.00	f	\N	1	\N
286	3	2020-11-24	14.00	16.00	f	\N	1	\N
89	1	2020-11-24	9.00	11.00	f	\N	1	\N
89	1	2020-11-24	11.00	13.00	f	\N	1	\N
89	1	2020-11-24	13.00	15.00	f	\N	1	\N
116	2	2020-11-27	10.00	12.00	f	\N	1	\N
116	2	2020-11-27	12.00	14.00	f	\N	1	\N
112	2	2020-11-21	12.00	14.00	f	\N	1	\N
314	3	2020-11-30	11.00	13.00	f	\N	1	\N
112	2	2020-11-21	14.00	16.00	f	\N	1	\N
111	2	2020-11-21	10.00	12.00	f	\N	1	\N
111	2	2020-11-21	12.00	14.00	f	\N	1	\N
111	2	2020-11-21	14.00	16.00	f	\N	1	\N
106	2	2020-11-21	10.00	12.00	f	\N	1	\N
106	2	2020-11-21	12.00	14.00	f	\N	1	\N
106	2	2020-11-21	14.00	16.00	f	\N	1	\N
107	2	2020-11-21	10.00	12.00	f	\N	1	\N
107	2	2020-11-21	12.00	14.00	f	\N	1	\N
107	2	2020-11-21	14.00	16.00	f	\N	1	\N
89	1	2020-11-24	15.00	17.00	f	\N	1	\N
89	1	2020-11-24	17.00	18.00	f	\N	1	\N
300	1	2020-11-24	9.00	11.00	f	\N	1	\N
300	1	2020-11-24	11.00	13.00	f	\N	1	\N
300	1	2020-11-24	13.00	15.00	f	\N	1	\N
300	1	2020-11-24	15.00	17.00	f	\N	1	\N
314	3	2020-11-30	13.00	15.00	f	\N	1	\N
300	1	2020-11-24	17.00	18.00	f	\N	1	\N
298	1	2020-11-24	9.00	11.00	f	\N	1	\N
298	1	2020-11-24	11.00	13.00	f	\N	1	\N
298	1	2020-11-24	13.00	15.00	f	\N	1	\N
298	1	2020-11-24	15.00	17.00	f	\N	1	\N
298	1	2020-11-24	17.00	18.00	f	\N	1	\N
95	1	2020-11-24	9.00	11.00	f	\N	1	\N
95	1	2020-11-24	11.00	13.00	f	\N	1	\N
95	1	2020-11-24	13.00	15.00	f	\N	1	\N
95	1	2020-11-24	15.00	17.00	f	\N	1	\N
95	1	2020-11-24	17.00	18.00	f	\N	1	\N
90	1	2020-11-24	9.00	11.00	f	\N	1	\N
90	1	2020-11-24	11.00	13.00	f	\N	1	\N
90	1	2020-11-24	13.00	15.00	f	\N	1	\N
90	1	2020-11-24	15.00	17.00	f	\N	1	\N
90	1	2020-11-24	17.00	18.00	f	\N	1	\N
109	2	2020-11-21	10.00	12.00	f	\N	1	\N
94	1	2020-11-24	9.00	11.00	f	\N	1	\N
94	1	2020-11-24	11.00	13.00	f	\N	1	\N
94	1	2020-11-24	13.00	15.00	f	\N	1	\N
94	1	2020-11-24	15.00	17.00	f	\N	1	\N
94	1	2020-11-24	17.00	18.00	f	\N	1	\N
92	1	2020-11-24	9.00	11.00	f	\N	1	\N
92	1	2020-11-24	11.00	13.00	f	\N	1	\N
92	1	2020-11-24	13.00	15.00	f	\N	1	\N
92	1	2020-11-24	15.00	17.00	f	\N	1	\N
92	1	2020-11-24	17.00	18.00	f	\N	1	\N
93	1	2020-11-24	9.00	11.00	f	\N	1	\N
93	1	2020-11-24	11.00	13.00	f	\N	1	\N
93	1	2020-11-24	13.00	15.00	f	\N	1	\N
93	1	2020-11-24	15.00	17.00	f	\N	1	\N
93	1	2020-11-24	17.00	18.00	f	\N	1	\N
96	1	2020-11-24	9.00	11.00	f	\N	1	\N
96	1	2020-11-24	11.00	13.00	f	\N	1	\N
96	1	2020-11-24	13.00	15.00	f	\N	1	\N
96	1	2020-11-24	15.00	17.00	f	\N	1	\N
96	1	2020-11-24	17.00	18.00	f	\N	1	\N
91	1	2020-11-24	9.00	11.00	f	\N	1	\N
91	1	2020-11-24	11.00	13.00	f	\N	1	\N
91	1	2020-11-24	13.00	15.00	f	\N	1	\N
91	1	2020-11-24	15.00	17.00	f	\N	1	\N
91	1	2020-11-24	17.00	18.00	f	\N	1	\N
301	1	2020-11-24	9.00	11.00	f	\N	1	\N
301	1	2020-11-24	11.00	13.00	f	\N	1	\N
301	1	2020-11-24	13.00	15.00	f	\N	1	\N
301	1	2020-11-24	15.00	17.00	f	\N	1	\N
301	1	2020-11-24	17.00	18.00	f	\N	1	\N
299	1	2020-11-24	9.00	11.00	f	\N	1	\N
299	1	2020-11-24	11.00	13.00	f	\N	1	\N
299	1	2020-11-24	13.00	15.00	f	\N	1	\N
299	1	2020-11-24	15.00	17.00	f	\N	1	\N
299	1	2020-11-24	17.00	18.00	f	\N	1	\N
176	2	2020-11-24	9.00	11.00	f	\N	1	\N
176	2	2020-11-24	11.00	13.00	f	\N	1	\N
176	2	2020-11-24	13.00	15.00	f	\N	1	\N
176	2	2020-11-24	15.00	17.00	f	\N	1	\N
176	2	2020-11-24	17.00	18.00	f	\N	1	\N
175	2	2020-11-24	9.00	11.00	f	\N	1	\N
175	2	2020-11-24	11.00	13.00	f	\N	1	\N
175	2	2020-11-24	13.00	15.00	f	\N	1	\N
175	2	2020-11-24	15.00	17.00	f	\N	1	\N
175	2	2020-11-24	17.00	18.00	f	\N	1	\N
174	2	2020-11-24	9.00	11.00	f	\N	1	\N
174	2	2020-11-24	11.00	13.00	f	\N	1	\N
174	2	2020-11-24	13.00	15.00	f	\N	1	\N
174	2	2020-11-24	15.00	17.00	f	\N	1	\N
174	2	2020-11-24	17.00	18.00	f	\N	1	\N
179	2	2020-11-24	9.00	11.00	f	\N	1	\N
179	2	2020-11-24	11.00	13.00	f	\N	1	\N
179	2	2020-11-24	13.00	15.00	f	\N	1	\N
179	2	2020-11-24	15.00	17.00	f	\N	1	\N
179	2	2020-11-24	17.00	18.00	f	\N	1	\N
178	2	2020-11-24	9.00	11.00	f	\N	1	\N
178	2	2020-11-24	11.00	13.00	f	\N	1	\N
178	2	2020-11-24	13.00	15.00	f	\N	1	\N
178	2	2020-11-24	15.00	17.00	f	\N	1	\N
178	2	2020-11-24	17.00	18.00	f	\N	1	\N
177	2	2020-11-24	9.00	11.00	f	\N	1	\N
177	2	2020-11-24	11.00	13.00	f	\N	1	\N
177	2	2020-11-24	13.00	15.00	f	\N	1	\N
177	2	2020-11-24	15.00	17.00	f	\N	1	\N
177	2	2020-11-24	17.00	18.00	f	\N	1	\N
192	2	2020-11-24	9.00	11.00	f	\N	1	\N
192	2	2020-11-24	11.00	13.00	f	\N	1	\N
192	2	2020-11-24	13.00	15.00	f	\N	1	\N
192	2	2020-11-24	15.00	17.00	f	\N	1	\N
192	2	2020-11-24	17.00	18.00	f	\N	1	\N
193	2	2020-11-24	9.00	11.00	f	\N	1	\N
193	2	2020-11-24	11.00	13.00	f	\N	1	\N
193	2	2020-11-24	13.00	15.00	f	\N	1	\N
193	2	2020-11-24	15.00	17.00	f	\N	1	\N
193	2	2020-11-24	17.00	18.00	f	\N	1	\N
302	3	2020-11-24	9.00	11.00	f	\N	1	\N
302	3	2020-11-24	11.00	13.00	f	\N	1	\N
302	3	2020-11-24	13.00	15.00	f	\N	1	\N
302	3	2020-11-24	15.00	17.00	f	\N	1	\N
302	3	2020-11-24	17.00	18.00	f	\N	1	\N
305	3	2020-11-24	9.00	11.00	f	\N	1	\N
116	2	2020-11-27	14.00	16.00	f	\N	1	\N
115	2	2020-11-27	10.00	12.00	f	\N	1	\N
115	2	2020-11-27	12.00	14.00	f	\N	1	\N
314	3	2020-11-30	15.00	17.00	f	\N	1	\N
109	2	2020-11-21	12.00	14.00	f	\N	1	\N
109	2	2020-11-21	14.00	16.00	f	\N	1	\N
133	2	2020-11-21	10.00	12.00	f	\N	1	\N
133	2	2020-11-21	12.00	14.00	f	\N	1	\N
133	2	2020-11-21	14.00	16.00	f	\N	1	\N
134	2	2020-11-21	10.00	12.00	f	\N	1	\N
134	2	2020-11-21	12.00	14.00	f	\N	1	\N
134	2	2020-11-21	14.00	16.00	f	\N	1	\N
314	3	2020-11-30	17.00	18.00	f	\N	1	\N
306	3	2020-11-30	9.00	11.00	f	\N	1	\N
306	3	2020-11-30	11.00	13.00	f	\N	1	\N
306	3	2020-11-30	13.00	15.00	f	\N	1	\N
115	2	2020-11-27	14.00	16.00	f	\N	1	\N
128	2	2020-11-21	10.00	12.00	f	\N	1	\N
114	2	2020-11-27	10.00	12.00	f	\N	1	\N
114	2	2020-11-27	12.00	14.00	f	\N	1	\N
114	2	2020-11-27	14.00	16.00	f	\N	1	\N
113	2	2020-11-27	10.00	12.00	f	\N	1	\N
113	2	2020-11-27	12.00	14.00	f	\N	1	\N
113	2	2020-11-27	14.00	16.00	f	\N	1	\N
120	2	2020-11-27	10.00	12.00	f	\N	1	\N
120	2	2020-11-27	12.00	14.00	f	\N	1	\N
120	2	2020-11-27	14.00	16.00	f	\N	1	\N
286	3	2020-11-27	10.00	12.00	f	\N	1	\N
286	3	2020-11-27	12.00	14.00	f	\N	1	\N
286	3	2020-11-27	14.00	16.00	f	\N	1	\N
89	1	2020-11-27	9.00	11.00	f	\N	1	\N
89	1	2020-11-27	11.00	13.00	f	\N	1	\N
89	1	2020-11-27	13.00	15.00	f	\N	1	\N
89	1	2020-11-27	15.00	17.00	f	\N	1	\N
305	3	2020-11-24	11.00	13.00	f	\N	1	\N
305	3	2020-11-24	13.00	15.00	f	\N	1	\N
305	3	2020-11-24	15.00	17.00	f	\N	1	\N
305	3	2020-11-24	17.00	18.00	f	\N	1	\N
314	3	2020-11-24	17.00	18.00	f	\N	1	\N
306	3	2020-11-24	9.00	11.00	f	\N	1	\N
306	3	2020-11-24	11.00	13.00	f	\N	1	\N
306	3	2020-11-24	13.00	15.00	f	\N	1	\N
306	3	2020-11-24	15.00	17.00	f	\N	1	\N
306	3	2020-11-24	17.00	18.00	f	\N	1	\N
215	1	2020-11-24	6.00	8.00	f	\N	1	\N
215	1	2020-11-24	8.00	10.00	f	\N	1	\N
215	1	2020-11-24	10.00	12.00	f	\N	1	\N
215	1	2020-11-24	12.00	14.00	f	\N	1	\N
89	1	2020-11-27	17.00	18.00	f	\N	1	\N
215	1	2020-11-24	14.00	16.00	f	\N	1	\N
215	1	2020-11-24	16.00	18.00	f	\N	1	\N
215	1	2020-11-24	18.00	20.00	f	\N	1	\N
300	1	2020-11-27	9.00	11.00	f	\N	1	\N
215	1	2020-11-24	20.00	22.00	f	\N	1	\N
215	1	2020-11-24	22.00	23.00	f	\N	1	\N
231	1	2020-11-24	6.00	8.00	f	\N	1	\N
231	1	2020-11-24	8.00	10.00	f	\N	1	\N
231	1	2020-11-24	10.00	12.00	f	\N	1	\N
231	1	2020-11-24	12.00	14.00	f	\N	1	\N
231	1	2020-11-24	14.00	16.00	f	\N	1	\N
231	1	2020-11-24	16.00	18.00	f	\N	1	\N
231	1	2020-11-24	18.00	20.00	f	\N	1	\N
231	1	2020-11-24	20.00	22.00	f	\N	1	\N
231	1	2020-11-24	22.00	23.00	f	\N	1	\N
88	1	2020-11-24	6.00	8.00	f	\N	1	\N
88	1	2020-11-24	8.00	10.00	f	\N	1	\N
88	1	2020-11-24	10.00	12.00	f	\N	1	\N
88	1	2020-11-24	12.00	14.00	f	\N	1	\N
88	1	2020-11-24	14.00	16.00	f	\N	1	\N
300	1	2020-11-27	11.00	13.00	f	\N	1	\N
88	1	2020-11-24	16.00	18.00	f	\N	1	\N
88	1	2020-11-24	18.00	20.00	f	\N	1	\N
88	1	2020-11-24	20.00	22.00	f	\N	1	\N
88	1	2020-11-24	22.00	23.00	f	\N	1	\N
300	1	2020-11-27	13.00	15.00	f	\N	1	\N
300	1	2020-11-27	15.00	17.00	f	\N	1	\N
300	1	2020-11-27	17.00	18.00	f	\N	1	\N
298	1	2020-11-27	9.00	11.00	f	\N	1	\N
298	1	2020-11-27	11.00	13.00	f	\N	1	\N
298	1	2020-11-27	13.00	15.00	f	\N	1	\N
298	1	2020-11-27	15.00	17.00	f	\N	1	\N
298	1	2020-11-27	17.00	18.00	f	\N	1	\N
95	1	2020-11-27	9.00	11.00	f	\N	1	\N
95	1	2020-11-27	11.00	13.00	f	\N	1	\N
95	1	2020-11-27	13.00	15.00	f	\N	1	\N
95	1	2020-11-27	15.00	17.00	f	\N	1	\N
95	1	2020-11-27	17.00	18.00	f	\N	1	\N
90	1	2020-11-27	9.00	11.00	f	\N	1	\N
90	1	2020-11-27	11.00	13.00	f	\N	1	\N
90	1	2020-11-27	13.00	15.00	f	\N	1	\N
90	1	2020-11-27	15.00	17.00	f	\N	1	\N
90	1	2020-11-27	17.00	18.00	f	\N	1	\N
94	1	2020-11-27	9.00	11.00	f	\N	1	\N
94	1	2020-11-27	11.00	13.00	f	\N	1	\N
94	1	2020-11-27	13.00	15.00	f	\N	1	\N
94	1	2020-11-27	15.00	17.00	f	\N	1	\N
94	1	2020-11-27	17.00	18.00	f	\N	1	\N
92	1	2020-11-27	9.00	11.00	f	\N	1	\N
92	1	2020-11-27	11.00	13.00	f	\N	1	\N
92	1	2020-11-27	13.00	15.00	f	\N	1	\N
92	1	2020-11-27	15.00	17.00	f	\N	1	\N
92	1	2020-11-27	17.00	18.00	f	\N	1	\N
93	1	2020-11-27	9.00	11.00	f	\N	1	\N
93	1	2020-11-27	11.00	13.00	f	\N	1	\N
93	1	2020-11-27	13.00	15.00	f	\N	1	\N
93	1	2020-11-27	15.00	17.00	f	\N	1	\N
93	1	2020-11-27	17.00	18.00	f	\N	1	\N
80	1	2020-11-24	6.00	8.00	f	\N	1	\N
96	1	2020-11-27	9.00	11.00	f	\N	1	\N
80	1	2020-11-24	8.00	10.00	f	\N	1	\N
80	1	2020-11-24	10.00	12.00	f	\N	1	\N
80	1	2020-11-24	12.00	14.00	f	\N	1	\N
80	1	2020-11-24	14.00	16.00	f	\N	1	\N
80	1	2020-11-24	16.00	18.00	f	\N	1	\N
128	2	2020-11-21	12.00	14.00	f	\N	1	\N
96	1	2020-11-27	11.00	13.00	f	\N	1	\N
96	1	2020-11-27	13.00	15.00	f	\N	1	\N
128	2	2020-11-21	14.00	16.00	f	\N	1	\N
127	2	2020-11-21	10.00	12.00	f	\N	1	\N
127	2	2020-11-21	12.00	14.00	f	\N	1	\N
127	2	2020-11-21	14.00	16.00	f	\N	1	\N
126	2	2020-11-21	10.00	12.00	f	\N	1	\N
126	2	2020-11-21	12.00	14.00	f	\N	1	\N
126	2	2020-11-21	14.00	16.00	f	\N	1	\N
314	3	2020-11-24	13.00	15.00	t	8306227208	2	G
314	3	2020-11-24	15.00	17.00	t	8306227208	2	D
314	3	2020-11-24	9.00	11.00	t	8403704328	2	NH
314	3	2020-11-24	11.00	13.00	t	8403704328	2	NH
306	3	2020-11-30	15.00	17.00	f	\N	1	\N
306	3	2020-11-30	17.00	18.00	f	\N	1	\N
215	1	2020-11-30	6.00	8.00	f	\N	1	\N
215	1	2020-11-30	8.00	10.00	f	\N	1	\N
215	1	2020-11-30	10.00	12.00	f	\N	1	\N
215	1	2020-11-30	12.00	14.00	f	\N	1	\N
215	1	2020-11-30	14.00	16.00	f	\N	1	\N
215	1	2020-11-30	16.00	18.00	f	\N	1	\N
215	1	2020-11-30	18.00	20.00	f	\N	1	\N
215	1	2020-11-30	20.00	22.00	f	\N	1	\N
96	1	2020-11-27	15.00	17.00	f	\N	1	\N
96	1	2020-11-27	17.00	18.00	f	\N	1	\N
80	1	2020-11-24	18.00	20.00	f	\N	1	\N
91	1	2020-11-27	9.00	11.00	f	\N	1	\N
80	1	2020-11-24	20.00	22.00	f	\N	1	\N
91	1	2020-11-27	11.00	13.00	f	\N	1	\N
91	1	2020-11-27	13.00	15.00	f	\N	1	\N
80	1	2020-11-24	22.00	23.00	f	\N	1	\N
216	1	2020-11-24	6.00	8.00	f	\N	1	\N
91	1	2020-11-27	15.00	17.00	f	\N	1	\N
91	1	2020-11-27	17.00	18.00	f	\N	1	\N
301	1	2020-11-27	9.00	11.00	f	\N	1	\N
301	1	2020-11-27	11.00	13.00	f	\N	1	\N
301	1	2020-11-27	13.00	15.00	f	\N	1	\N
301	1	2020-11-27	15.00	17.00	f	\N	1	\N
301	1	2020-11-27	17.00	18.00	f	\N	1	\N
299	1	2020-11-27	9.00	11.00	f	\N	1	\N
299	1	2020-11-27	11.00	13.00	f	\N	1	\N
299	1	2020-11-27	13.00	15.00	f	\N	1	\N
299	1	2020-11-27	15.00	17.00	f	\N	1	\N
299	1	2020-11-27	17.00	18.00	f	\N	1	\N
176	2	2020-11-27	9.00	11.00	f	\N	1	\N
176	2	2020-11-27	11.00	13.00	f	\N	1	\N
176	2	2020-11-27	13.00	15.00	f	\N	1	\N
176	2	2020-11-27	15.00	17.00	f	\N	1	\N
176	2	2020-11-27	17.00	18.00	f	\N	1	\N
175	2	2020-11-27	9.00	11.00	f	\N	1	\N
175	2	2020-11-27	11.00	13.00	f	\N	1	\N
175	2	2020-11-27	13.00	15.00	f	\N	1	\N
175	2	2020-11-27	15.00	17.00	f	\N	1	\N
175	2	2020-11-27	17.00	18.00	f	\N	1	\N
174	2	2020-11-27	9.00	11.00	f	\N	1	\N
174	2	2020-11-27	11.00	13.00	f	\N	1	\N
174	2	2020-11-27	13.00	15.00	f	\N	1	\N
174	2	2020-11-27	15.00	17.00	f	\N	1	\N
174	2	2020-11-27	17.00	18.00	f	\N	1	\N
179	2	2020-11-27	9.00	11.00	f	\N	1	\N
179	2	2020-11-27	11.00	13.00	f	\N	1	\N
179	2	2020-11-27	13.00	15.00	f	\N	1	\N
179	2	2020-11-27	15.00	17.00	f	\N	1	\N
179	2	2020-11-27	17.00	18.00	f	\N	1	\N
178	2	2020-11-27	9.00	11.00	f	\N	1	\N
178	2	2020-11-27	11.00	13.00	f	\N	1	\N
178	2	2020-11-27	13.00	15.00	f	\N	1	\N
178	2	2020-11-27	15.00	17.00	f	\N	1	\N
178	2	2020-11-27	17.00	18.00	f	\N	1	\N
177	2	2020-11-27	9.00	11.00	f	\N	1	\N
177	2	2020-11-27	11.00	13.00	f	\N	1	\N
177	2	2020-11-27	13.00	15.00	f	\N	1	\N
177	2	2020-11-27	15.00	17.00	f	\N	1	\N
177	2	2020-11-27	17.00	18.00	f	\N	1	\N
192	2	2020-11-27	9.00	11.00	f	\N	1	\N
192	2	2020-11-27	11.00	13.00	f	\N	1	\N
192	2	2020-11-27	13.00	15.00	f	\N	1	\N
216	1	2020-11-24	8.00	10.00	f	\N	1	\N
216	1	2020-11-24	10.00	12.00	f	\N	1	\N
192	2	2020-11-27	15.00	17.00	f	\N	1	\N
192	2	2020-11-27	17.00	18.00	f	\N	1	\N
193	2	2020-11-27	9.00	11.00	f	\N	1	\N
193	2	2020-11-27	11.00	13.00	f	\N	1	\N
193	2	2020-11-27	13.00	15.00	f	\N	1	\N
193	2	2020-11-27	15.00	17.00	f	\N	1	\N
193	2	2020-11-27	17.00	18.00	f	\N	1	\N
302	3	2020-11-27	9.00	11.00	f	\N	1	\N
302	3	2020-11-27	11.00	13.00	f	\N	1	\N
302	3	2020-11-27	13.00	15.00	f	\N	1	\N
302	3	2020-11-27	15.00	17.00	f	\N	1	\N
302	3	2020-11-27	17.00	18.00	f	\N	1	\N
305	3	2020-11-27	9.00	11.00	f	\N	1	\N
216	1	2020-11-24	12.00	14.00	f	\N	1	\N
216	1	2020-11-24	14.00	16.00	f	\N	1	\N
305	3	2020-11-27	11.00	13.00	f	\N	1	\N
305	3	2020-11-27	13.00	15.00	f	\N	1	\N
305	3	2020-11-27	15.00	17.00	f	\N	1	\N
305	3	2020-11-27	17.00	18.00	f	\N	1	\N
314	3	2020-11-27	9.00	11.00	f	\N	1	\N
216	1	2020-11-24	16.00	18.00	f	\N	1	\N
314	3	2020-11-27	11.00	13.00	f	\N	1	\N
314	3	2020-11-27	13.00	15.00	f	\N	1	\N
314	3	2020-11-27	15.00	17.00	f	\N	1	\N
314	3	2020-11-27	17.00	18.00	f	\N	1	\N
306	3	2020-11-27	9.00	11.00	f	\N	1	\N
306	3	2020-11-27	11.00	13.00	f	\N	1	\N
306	3	2020-11-27	13.00	15.00	f	\N	1	\N
306	3	2020-11-27	15.00	17.00	f	\N	1	\N
306	3	2020-11-27	17.00	18.00	f	\N	1	\N
215	1	2020-11-27	6.00	8.00	f	\N	1	\N
215	1	2020-11-27	8.00	10.00	f	\N	1	\N
215	1	2020-11-27	10.00	12.00	f	\N	1	\N
215	1	2020-11-27	12.00	14.00	f	\N	1	\N
215	1	2020-11-27	14.00	16.00	f	\N	1	\N
215	1	2020-11-27	16.00	18.00	f	\N	1	\N
215	1	2020-11-27	18.00	20.00	f	\N	1	\N
215	1	2020-11-27	20.00	22.00	f	\N	1	\N
215	1	2020-11-30	22.00	23.00	f	\N	1	\N
231	1	2020-11-30	6.00	8.00	f	\N	1	\N
125	2	2020-11-21	10.00	12.00	f	\N	1	\N
216	1	2020-11-24	18.00	20.00	f	\N	1	\N
216	1	2020-11-24	20.00	22.00	f	\N	1	\N
216	1	2020-11-24	22.00	23.00	f	\N	1	\N
191	1	2020-11-24	6.00	8.00	f	\N	1	\N
191	1	2020-11-24	8.00	10.00	f	\N	1	\N
191	1	2020-11-24	10.00	12.00	f	\N	1	\N
231	1	2020-11-30	8.00	10.00	f	\N	1	\N
231	1	2020-11-30	10.00	12.00	f	\N	1	\N
215	1	2020-11-27	22.00	23.00	f	\N	1	\N
231	1	2020-11-27	6.00	8.00	f	\N	1	\N
231	1	2020-11-27	8.00	10.00	f	\N	1	\N
231	1	2020-11-27	10.00	12.00	f	\N	1	\N
231	1	2020-11-27	12.00	14.00	f	\N	1	\N
231	1	2020-11-27	14.00	16.00	f	\N	1	\N
231	1	2020-11-27	16.00	18.00	f	\N	1	\N
231	1	2020-11-27	18.00	20.00	f	\N	1	\N
231	1	2020-11-27	20.00	22.00	f	\N	1	\N
231	1	2020-11-27	22.00	23.00	f	\N	1	\N
88	1	2020-11-27	6.00	8.00	f	\N	1	\N
88	1	2020-11-27	8.00	10.00	f	\N	1	\N
88	1	2020-11-27	10.00	12.00	f	\N	1	\N
88	1	2020-11-27	12.00	14.00	f	\N	1	\N
88	1	2020-11-27	14.00	16.00	f	\N	1	\N
88	1	2020-11-27	16.00	18.00	f	\N	1	\N
88	1	2020-11-27	18.00	20.00	f	\N	1	\N
88	1	2020-11-27	20.00	22.00	f	\N	1	\N
231	1	2020-11-30	12.00	14.00	f	\N	1	\N
88	1	2020-11-27	22.00	23.00	f	\N	1	\N
80	1	2020-11-27	6.00	8.00	f	\N	1	\N
80	1	2020-11-27	8.00	10.00	f	\N	1	\N
80	1	2020-11-27	10.00	12.00	f	\N	1	\N
80	1	2020-11-27	12.00	14.00	f	\N	1	\N
80	1	2020-11-27	14.00	16.00	f	\N	1	\N
80	1	2020-11-27	16.00	18.00	f	\N	1	\N
80	1	2020-11-27	18.00	20.00	f	\N	1	\N
80	1	2020-11-27	20.00	22.00	f	\N	1	\N
80	1	2020-11-27	22.00	23.00	f	\N	1	\N
216	1	2020-11-27	6.00	8.00	f	\N	1	\N
216	1	2020-11-27	8.00	10.00	f	\N	1	\N
216	1	2020-11-27	10.00	12.00	f	\N	1	\N
216	1	2020-11-27	12.00	14.00	f	\N	1	\N
216	1	2020-11-27	14.00	16.00	f	\N	1	\N
216	1	2020-11-27	16.00	18.00	f	\N	1	\N
216	1	2020-11-27	18.00	20.00	f	\N	1	\N
216	1	2020-11-27	20.00	22.00	f	\N	1	\N
216	1	2020-11-27	22.00	23.00	f	\N	1	\N
191	1	2020-11-27	6.00	8.00	f	\N	1	\N
191	1	2020-11-27	8.00	10.00	f	\N	1	\N
191	1	2020-11-27	10.00	12.00	f	\N	1	\N
191	1	2020-11-27	12.00	14.00	f	\N	1	\N
191	1	2020-11-27	14.00	16.00	f	\N	1	\N
191	1	2020-11-27	16.00	18.00	f	\N	1	\N
191	1	2020-11-27	18.00	20.00	f	\N	1	\N
191	1	2020-11-27	20.00	22.00	f	\N	1	\N
191	1	2020-11-27	22.00	23.00	f	\N	1	\N
81	1	2020-11-27	6.00	8.00	f	\N	1	\N
81	1	2020-11-27	8.00	10.00	f	\N	1	\N
81	1	2020-11-27	10.00	12.00	f	\N	1	\N
81	1	2020-11-27	12.00	14.00	f	\N	1	\N
81	1	2020-11-27	14.00	16.00	f	\N	1	\N
81	1	2020-11-27	16.00	18.00	f	\N	1	\N
81	1	2020-11-27	18.00	20.00	f	\N	1	\N
81	1	2020-11-27	20.00	22.00	f	\N	1	\N
81	1	2020-11-27	22.00	23.00	f	\N	1	\N
82	1	2020-11-27	6.00	8.00	f	\N	1	\N
82	1	2020-11-27	8.00	10.00	f	\N	1	\N
82	1	2020-11-27	10.00	12.00	f	\N	1	\N
82	1	2020-11-27	12.00	14.00	f	\N	1	\N
82	1	2020-11-27	14.00	16.00	f	\N	1	\N
82	1	2020-11-27	16.00	18.00	f	\N	1	\N
82	1	2020-11-27	18.00	20.00	f	\N	1	\N
82	1	2020-11-27	20.00	22.00	f	\N	1	\N
82	1	2020-11-27	22.00	23.00	f	\N	1	\N
87	1	2020-11-27	6.00	8.00	f	\N	1	\N
87	1	2020-11-27	8.00	10.00	f	\N	1	\N
87	1	2020-11-27	10.00	12.00	f	\N	1	\N
87	1	2020-11-27	12.00	14.00	f	\N	1	\N
87	1	2020-11-27	14.00	16.00	f	\N	1	\N
87	1	2020-11-27	16.00	18.00	f	\N	1	\N
87	1	2020-11-27	18.00	20.00	f	\N	1	\N
87	1	2020-11-27	20.00	22.00	f	\N	1	\N
87	1	2020-11-27	22.00	23.00	f	\N	1	\N
86	1	2020-11-27	6.00	8.00	f	\N	1	\N
86	1	2020-11-27	8.00	10.00	f	\N	1	\N
86	1	2020-11-27	10.00	12.00	f	\N	1	\N
86	1	2020-11-27	12.00	14.00	f	\N	1	\N
86	1	2020-11-27	14.00	16.00	f	\N	1	\N
86	1	2020-11-27	16.00	18.00	f	\N	1	\N
86	1	2020-11-27	18.00	20.00	f	\N	1	\N
86	1	2020-11-27	20.00	22.00	f	\N	1	\N
86	1	2020-11-27	22.00	23.00	f	\N	1	\N
201	1	2020-11-27	6.00	8.00	f	\N	1	\N
201	1	2020-11-27	8.00	10.00	f	\N	1	\N
201	1	2020-11-27	10.00	12.00	f	\N	1	\N
201	1	2020-11-27	12.00	14.00	f	\N	1	\N
201	1	2020-11-27	14.00	16.00	f	\N	1	\N
201	1	2020-11-27	16.00	18.00	f	\N	1	\N
201	1	2020-11-27	18.00	20.00	f	\N	1	\N
201	1	2020-11-27	20.00	22.00	f	\N	1	\N
201	1	2020-11-27	22.00	23.00	f	\N	1	\N
83	1	2020-11-27	6.00	8.00	f	\N	1	\N
83	1	2020-11-27	8.00	10.00	f	\N	1	\N
83	1	2020-11-27	10.00	12.00	f	\N	1	\N
83	1	2020-11-27	12.00	14.00	f	\N	1	\N
83	1	2020-11-27	14.00	16.00	f	\N	1	\N
83	1	2020-11-27	16.00	18.00	f	\N	1	\N
83	1	2020-11-27	18.00	20.00	f	\N	1	\N
83	1	2020-11-27	20.00	22.00	f	\N	1	\N
83	1	2020-11-27	22.00	23.00	f	\N	1	\N
84	1	2020-11-27	6.00	8.00	f	\N	1	\N
84	1	2020-11-27	8.00	10.00	f	\N	1	\N
84	1	2020-11-27	10.00	12.00	f	\N	1	\N
84	1	2020-11-27	12.00	14.00	f	\N	1	\N
125	2	2020-11-21	12.00	14.00	f	\N	1	\N
231	1	2020-11-30	14.00	16.00	f	\N	1	\N
231	1	2020-11-30	16.00	18.00	f	\N	1	\N
84	1	2020-11-27	14.00	16.00	f	\N	1	\N
84	1	2020-11-27	16.00	18.00	f	\N	1	\N
84	1	2020-11-27	18.00	20.00	f	\N	1	\N
84	1	2020-11-27	20.00	22.00	f	\N	1	\N
84	1	2020-11-27	22.00	23.00	f	\N	1	\N
194	1	2020-11-27	6.00	8.00	f	\N	1	\N
194	1	2020-11-27	8.00	10.00	f	\N	1	\N
194	1	2020-11-27	10.00	12.00	f	\N	1	\N
194	1	2020-11-27	12.00	14.00	f	\N	1	\N
194	1	2020-11-27	14.00	16.00	f	\N	1	\N
194	1	2020-11-27	16.00	18.00	f	\N	1	\N
194	1	2020-11-27	18.00	20.00	f	\N	1	\N
194	1	2020-11-27	20.00	22.00	f	\N	1	\N
194	1	2020-11-27	22.00	23.00	f	\N	1	\N
85	1	2020-11-27	6.00	8.00	f	\N	1	\N
85	1	2020-11-27	8.00	10.00	f	\N	1	\N
85	1	2020-11-27	10.00	12.00	f	\N	1	\N
85	1	2020-11-27	12.00	14.00	f	\N	1	\N
85	1	2020-11-27	14.00	16.00	f	\N	1	\N
85	1	2020-11-27	16.00	18.00	f	\N	1	\N
85	1	2020-11-27	18.00	20.00	f	\N	1	\N
85	1	2020-11-27	20.00	22.00	f	\N	1	\N
85	1	2020-11-27	22.00	23.00	f	\N	1	\N
303	1	2020-11-27	6.00	8.00	f	\N	1	\N
303	1	2020-11-27	8.00	10.00	f	\N	1	\N
303	1	2020-11-27	10.00	12.00	f	\N	1	\N
303	1	2020-11-27	12.00	14.00	f	\N	1	\N
303	1	2020-11-27	14.00	16.00	f	\N	1	\N
303	1	2020-11-27	16.00	18.00	f	\N	1	\N
303	1	2020-11-27	18.00	20.00	f	\N	1	\N
231	1	2020-11-30	18.00	20.00	f	\N	1	\N
231	1	2020-11-30	20.00	22.00	f	\N	1	\N
231	1	2020-11-30	22.00	23.00	f	\N	1	\N
88	1	2020-11-30	6.00	8.00	f	\N	1	\N
88	1	2020-11-30	8.00	10.00	f	\N	1	\N
88	1	2020-11-30	10.00	12.00	f	\N	1	\N
88	1	2020-11-30	12.00	14.00	f	\N	1	\N
88	1	2020-11-30	14.00	16.00	f	\N	1	\N
88	1	2020-11-30	16.00	18.00	f	\N	1	\N
88	1	2020-11-30	18.00	20.00	f	\N	1	\N
88	1	2020-11-30	20.00	22.00	f	\N	1	\N
88	1	2020-11-30	22.00	23.00	f	\N	1	\N
80	1	2020-11-30	6.00	8.00	f	\N	1	\N
80	1	2020-11-30	8.00	10.00	f	\N	1	\N
80	1	2020-11-30	10.00	12.00	f	\N	1	\N
80	1	2020-11-30	12.00	14.00	f	\N	1	\N
80	1	2020-11-30	14.00	16.00	f	\N	1	\N
80	1	2020-11-30	16.00	18.00	f	\N	1	\N
80	1	2020-11-30	18.00	20.00	f	\N	1	\N
80	1	2020-11-30	20.00	22.00	f	\N	1	\N
80	1	2020-11-30	22.00	23.00	f	\N	1	\N
216	1	2020-11-30	6.00	8.00	f	\N	1	\N
216	1	2020-11-30	8.00	10.00	f	\N	1	\N
216	1	2020-11-30	10.00	12.00	f	\N	1	\N
216	1	2020-11-30	12.00	14.00	f	\N	1	\N
216	1	2020-11-30	14.00	16.00	f	\N	1	\N
216	1	2020-11-30	16.00	18.00	f	\N	1	\N
216	1	2020-11-30	18.00	20.00	f	\N	1	\N
216	1	2020-11-30	20.00	22.00	f	\N	1	\N
216	1	2020-11-30	22.00	23.00	f	\N	1	\N
191	1	2020-11-30	6.00	8.00	f	\N	1	\N
191	1	2020-11-30	8.00	10.00	f	\N	1	\N
191	1	2020-11-30	10.00	12.00	f	\N	1	\N
191	1	2020-11-30	12.00	14.00	f	\N	1	\N
191	1	2020-11-30	14.00	16.00	f	\N	1	\N
191	1	2020-11-30	16.00	18.00	f	\N	1	\N
191	1	2020-11-30	18.00	20.00	f	\N	1	\N
191	1	2020-11-30	20.00	22.00	f	\N	1	\N
191	1	2020-11-30	22.00	23.00	f	\N	1	\N
81	1	2020-11-30	6.00	8.00	f	\N	1	\N
81	1	2020-11-30	8.00	10.00	f	\N	1	\N
81	1	2020-11-30	10.00	12.00	f	\N	1	\N
81	1	2020-11-30	12.00	14.00	f	\N	1	\N
81	1	2020-11-30	14.00	16.00	f	\N	1	\N
81	1	2020-11-30	16.00	18.00	f	\N	1	\N
81	1	2020-11-30	18.00	20.00	f	\N	1	\N
81	1	2020-11-30	20.00	22.00	f	\N	1	\N
81	1	2020-11-30	22.00	23.00	f	\N	1	\N
82	1	2020-11-30	6.00	8.00	f	\N	1	\N
82	1	2020-11-30	8.00	10.00	f	\N	1	\N
82	1	2020-11-30	10.00	12.00	f	\N	1	\N
82	1	2020-11-30	12.00	14.00	f	\N	1	\N
82	1	2020-11-30	14.00	16.00	f	\N	1	\N
82	1	2020-11-30	16.00	18.00	f	\N	1	\N
82	1	2020-11-30	18.00	20.00	f	\N	1	\N
82	1	2020-11-30	20.00	22.00	f	\N	1	\N
82	1	2020-11-30	22.00	23.00	f	\N	1	\N
87	1	2020-11-30	6.00	8.00	f	\N	1	\N
87	1	2020-11-30	8.00	10.00	f	\N	1	\N
87	1	2020-11-30	10.00	12.00	f	\N	1	\N
87	1	2020-11-30	12.00	14.00	f	\N	1	\N
87	1	2020-11-30	14.00	16.00	f	\N	1	\N
87	1	2020-11-30	16.00	18.00	f	\N	1	\N
87	1	2020-11-30	18.00	20.00	f	\N	1	\N
87	1	2020-11-30	20.00	22.00	f	\N	1	\N
87	1	2020-11-30	22.00	23.00	f	\N	1	\N
86	1	2020-11-30	6.00	8.00	f	\N	1	\N
86	1	2020-11-30	8.00	10.00	f	\N	1	\N
191	1	2020-11-24	12.00	14.00	f	\N	1	\N
125	2	2020-11-21	14.00	16.00	f	\N	1	\N
132	2	2020-11-21	10.00	12.00	f	\N	1	\N
132	2	2020-11-21	12.00	14.00	f	\N	1	\N
191	1	2020-11-24	14.00	16.00	f	\N	1	\N
191	1	2020-11-24	16.00	18.00	f	\N	1	\N
191	1	2020-11-24	18.00	20.00	f	\N	1	\N
191	1	2020-11-24	20.00	22.00	f	\N	1	\N
191	1	2020-11-24	22.00	23.00	f	\N	1	\N
86	1	2020-11-30	10.00	12.00	f	\N	1	\N
86	1	2020-11-30	12.00	14.00	f	\N	1	\N
86	1	2020-11-30	14.00	16.00	f	\N	1	\N
86	1	2020-11-30	16.00	18.00	f	\N	1	\N
132	2	2020-11-21	14.00	16.00	f	\N	1	\N
86	1	2020-11-30	18.00	20.00	f	\N	1	\N
86	1	2020-11-30	20.00	22.00	f	\N	1	\N
86	1	2020-11-30	22.00	23.00	f	\N	1	\N
201	1	2020-11-30	6.00	8.00	f	\N	1	\N
201	1	2020-11-30	8.00	10.00	f	\N	1	\N
201	1	2020-11-30	10.00	12.00	f	\N	1	\N
201	1	2020-11-30	12.00	14.00	f	\N	1	\N
201	1	2020-11-30	14.00	16.00	f	\N	1	\N
201	1	2020-11-30	16.00	18.00	f	\N	1	\N
201	1	2020-11-30	18.00	20.00	f	\N	1	\N
201	1	2020-11-30	20.00	22.00	f	\N	1	\N
201	1	2020-11-30	22.00	23.00	f	\N	1	\N
83	1	2020-11-30	6.00	8.00	f	\N	1	\N
83	1	2020-11-30	8.00	10.00	f	\N	1	\N
83	1	2020-11-30	10.00	12.00	f	\N	1	\N
83	1	2020-11-30	12.00	14.00	f	\N	1	\N
83	1	2020-11-30	14.00	16.00	f	\N	1	\N
83	1	2020-11-30	16.00	18.00	f	\N	1	\N
83	1	2020-11-30	18.00	20.00	f	\N	1	\N
83	1	2020-11-30	20.00	22.00	f	\N	1	\N
83	1	2020-11-30	22.00	23.00	f	\N	1	\N
84	1	2020-11-30	6.00	8.00	f	\N	1	\N
303	1	2020-11-27	20.00	22.00	f	\N	1	\N
303	1	2020-11-27	22.00	23.00	f	\N	1	\N
304	1	2020-11-27	6.00	8.00	f	\N	1	\N
304	1	2020-11-27	8.00	10.00	f	\N	1	\N
304	1	2020-11-27	10.00	12.00	f	\N	1	\N
304	1	2020-11-27	12.00	14.00	f	\N	1	\N
304	1	2020-11-27	14.00	16.00	f	\N	1	\N
304	1	2020-11-27	16.00	18.00	f	\N	1	\N
304	1	2020-11-27	18.00	20.00	f	\N	1	\N
304	1	2020-11-27	20.00	22.00	f	\N	1	\N
304	1	2020-11-27	22.00	23.00	f	\N	1	\N
268	2	2020-11-27	6.00	8.00	f	\N	1	\N
268	2	2020-11-27	8.00	10.00	f	\N	1	\N
268	2	2020-11-27	10.00	12.00	f	\N	1	\N
268	2	2020-11-27	12.00	14.00	f	\N	1	\N
268	2	2020-11-27	14.00	16.00	f	\N	1	\N
268	2	2020-11-27	16.00	18.00	f	\N	1	\N
268	2	2020-11-27	18.00	20.00	f	\N	1	\N
84	1	2020-11-30	8.00	10.00	f	\N	1	\N
268	2	2020-11-27	20.00	22.00	f	\N	1	\N
131	2	2020-11-21	10.00	12.00	f	\N	1	\N
268	2	2020-11-27	22.00	23.00	f	\N	1	\N
313	3	2020-11-27	10.00	12.00	f	\N	1	\N
313	3	2020-11-27	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-27	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-27	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-27	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-27	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-27	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-27	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-27	22.00	23.00	t	1122334455	5	Stängt
84	1	2020-11-30	10.00	12.00	f	\N	1	\N
84	1	2020-11-30	12.00	14.00	f	\N	1	\N
84	1	2020-11-30	14.00	16.00	f	\N	1	\N
84	1	2020-11-30	16.00	18.00	f	\N	1	\N
84	1	2020-11-30	18.00	20.00	f	\N	1	\N
84	1	2020-11-30	20.00	22.00	f	\N	1	\N
84	1	2020-11-30	22.00	23.00	f	\N	1	\N
194	1	2020-11-30	6.00	8.00	f	\N	1	\N
194	1	2020-11-30	8.00	10.00	f	\N	1	\N
194	1	2020-11-30	10.00	12.00	f	\N	1	\N
194	1	2020-11-30	12.00	14.00	f	\N	1	\N
194	1	2020-11-30	14.00	16.00	f	\N	1	\N
194	1	2020-11-30	16.00	18.00	f	\N	1	\N
194	1	2020-11-30	18.00	20.00	f	\N	1	\N
194	1	2020-11-30	20.00	22.00	f	\N	1	\N
194	1	2020-11-30	22.00	23.00	f	\N	1	\N
85	1	2020-11-30	6.00	8.00	f	\N	1	\N
85	1	2020-11-30	8.00	10.00	f	\N	1	\N
85	1	2020-11-30	10.00	12.00	f	\N	1	\N
85	1	2020-11-30	12.00	14.00	f	\N	1	\N
85	1	2020-11-30	14.00	16.00	f	\N	1	\N
85	1	2020-11-30	16.00	18.00	f	\N	1	\N
85	1	2020-11-30	18.00	20.00	f	\N	1	\N
85	1	2020-11-30	20.00	22.00	f	\N	1	\N
85	1	2020-11-30	22.00	23.00	f	\N	1	\N
303	1	2020-11-30	6.00	8.00	f	\N	1	\N
303	1	2020-11-30	8.00	10.00	f	\N	1	\N
303	1	2020-11-30	10.00	12.00	f	\N	1	\N
303	1	2020-11-30	12.00	14.00	f	\N	1	\N
303	1	2020-11-30	14.00	16.00	f	\N	1	\N
303	1	2020-11-30	16.00	18.00	f	\N	1	\N
303	1	2020-11-30	18.00	20.00	f	\N	1	\N
303	1	2020-11-30	20.00	22.00	f	\N	1	\N
303	1	2020-11-30	22.00	23.00	f	\N	1	\N
304	1	2020-11-30	6.00	8.00	f	\N	1	\N
304	1	2020-11-30	8.00	10.00	f	\N	1	\N
304	1	2020-11-30	10.00	12.00	f	\N	1	\N
304	1	2020-11-30	12.00	14.00	f	\N	1	\N
304	1	2020-11-30	14.00	16.00	f	\N	1	\N
304	1	2020-11-30	16.00	18.00	f	\N	1	\N
304	1	2020-11-30	18.00	20.00	f	\N	1	\N
131	2	2020-11-21	12.00	14.00	f	\N	1	\N
131	2	2020-11-21	14.00	16.00	f	\N	1	\N
304	1	2020-11-30	20.00	22.00	f	\N	1	\N
304	1	2020-11-30	22.00	23.00	f	\N	1	\N
81	1	2020-11-24	6.00	8.00	f	\N	1	\N
81	1	2020-11-24	8.00	10.00	f	\N	1	\N
81	1	2020-11-24	10.00	12.00	f	\N	1	\N
81	1	2020-11-24	12.00	14.00	f	\N	1	\N
81	1	2020-11-24	14.00	16.00	f	\N	1	\N
268	2	2020-11-30	6.00	8.00	f	\N	1	\N
268	2	2020-11-30	8.00	10.00	f	\N	1	\N
268	2	2020-11-30	10.00	12.00	f	\N	1	\N
268	2	2020-11-30	12.00	14.00	f	\N	1	\N
268	2	2020-11-30	14.00	16.00	f	\N	1	\N
268	2	2020-11-30	16.00	18.00	f	\N	1	\N
268	2	2020-11-30	18.00	20.00	f	\N	1	\N
268	2	2020-11-30	20.00	22.00	f	\N	1	\N
268	2	2020-11-30	22.00	23.00	f	\N	1	\N
313	3	2020-11-30	10.00	12.00	f	\N	1	\N
313	3	2020-11-30	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-30	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-30	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-30	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-30	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-30	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-30	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-30	22.00	23.00	t	1122334455	5	Stängt
130	2	2020-11-21	10.00	12.00	f	\N	1	\N
130	2	2020-11-21	12.00	14.00	f	\N	1	\N
314	3	2020-11-20	13.00	15.00	t	8306227208	2	K
81	1	2020-11-24	16.00	18.00	f	\N	1	\N
81	1	2020-11-24	18.00	20.00	f	\N	1	\N
196	1	2020-11-28	10.00	12.00	f	\N	1	\N
196	1	2020-11-28	12.00	14.00	f	\N	1	\N
196	1	2020-11-28	14.00	16.00	f	\N	1	\N
97	1	2020-11-28	10.00	12.00	f	\N	1	\N
97	1	2020-11-28	12.00	14.00	f	\N	1	\N
97	1	2020-11-28	14.00	16.00	f	\N	1	\N
197	1	2020-11-28	10.00	12.00	f	\N	1	\N
197	1	2020-11-28	12.00	14.00	f	\N	1	\N
197	1	2020-11-28	14.00	16.00	f	\N	1	\N
135	1	2020-11-28	10.00	12.00	f	\N	1	\N
135	1	2020-11-28	12.00	14.00	f	\N	1	\N
135	1	2020-11-28	14.00	16.00	f	\N	1	\N
136	1	2020-11-28	10.00	12.00	f	\N	1	\N
310	1	2020-11-23	10.00	12.00	t	8334666274	2	Maja
166	1	2020-12-01	10.00	12.00	f	\N	1	\N
166	1	2020-12-01	12.00	14.00	f	\N	1	\N
166	1	2020-12-01	14.00	16.00	f	\N	1	\N
166	1	2020-12-01	16.00	18.00	f	\N	1	\N
168	1	2020-12-01	10.00	12.00	f	\N	1	\N
168	1	2020-12-01	12.00	14.00	f	\N	1	\N
168	1	2020-12-01	14.00	16.00	f	\N	1	\N
168	1	2020-12-01	16.00	18.00	f	\N	1	\N
165	1	2020-12-01	10.00	12.00	f	\N	1	\N
165	1	2020-12-01	12.00	14.00	f	\N	1	\N
165	1	2020-12-01	14.00	16.00	f	\N	1	\N
165	1	2020-12-01	16.00	18.00	f	\N	1	\N
81	1	2020-11-24	20.00	22.00	f	\N	1	\N
167	1	2020-12-01	10.00	12.00	f	\N	1	\N
167	1	2020-12-01	12.00	14.00	f	\N	1	\N
167	1	2020-12-01	14.00	16.00	f	\N	1	\N
167	1	2020-12-01	16.00	18.00	f	\N	1	\N
289	1	2020-12-01	10.00	12.00	f	\N	1	\N
289	1	2020-12-01	12.00	14.00	f	\N	1	\N
289	1	2020-12-01	14.00	16.00	f	\N	1	\N
289	1	2020-12-01	16.00	18.00	f	\N	1	\N
297	2	2020-12-01	10.00	12.00	f	\N	1	\N
297	2	2020-12-01	12.00	14.00	f	\N	1	\N
297	2	2020-12-01	14.00	16.00	f	\N	1	\N
297	2	2020-12-01	16.00	18.00	f	\N	1	\N
285	3	2020-12-01	10.00	12.00	f	\N	1	\N
285	3	2020-12-01	12.00	14.00	f	\N	1	\N
285	3	2020-12-01	14.00	16.00	f	\N	1	\N
285	3	2020-12-01	16.00	18.00	f	\N	1	\N
204	1	2020-12-01	9.00	11.00	f	\N	1	\N
204	1	2020-12-01	11.00	13.00	f	\N	1	\N
204	1	2020-12-01	13.00	15.00	f	\N	1	\N
204	1	2020-12-01	15.00	17.00	f	\N	1	\N
204	1	2020-12-01	17.00	18.00	f	\N	1	\N
203	1	2020-12-01	9.00	11.00	f	\N	1	\N
203	1	2020-12-01	11.00	13.00	f	\N	1	\N
203	1	2020-12-01	13.00	15.00	f	\N	1	\N
203	1	2020-12-01	15.00	17.00	f	\N	1	\N
203	1	2020-12-01	17.00	18.00	f	\N	1	\N
205	1	2020-12-01	9.00	11.00	f	\N	1	\N
205	1	2020-12-01	11.00	13.00	f	\N	1	\N
205	1	2020-12-01	13.00	15.00	f	\N	1	\N
205	1	2020-12-01	15.00	17.00	f	\N	1	\N
205	1	2020-12-01	17.00	18.00	f	\N	1	\N
202	1	2020-12-01	9.00	11.00	f	\N	1	\N
202	1	2020-12-01	11.00	13.00	f	\N	1	\N
202	1	2020-12-01	13.00	15.00	f	\N	1	\N
202	1	2020-12-01	15.00	17.00	f	\N	1	\N
202	1	2020-12-01	17.00	18.00	f	\N	1	\N
214	1	2020-12-01	9.00	11.00	f	\N	1	\N
214	1	2020-12-01	11.00	13.00	f	\N	1	\N
214	1	2020-12-01	13.00	15.00	f	\N	1	\N
214	1	2020-12-01	15.00	17.00	f	\N	1	\N
214	1	2020-12-01	17.00	18.00	f	\N	1	\N
213	1	2020-12-01	9.00	11.00	f	\N	1	\N
213	1	2020-12-01	11.00	13.00	f	\N	1	\N
213	1	2020-12-01	13.00	15.00	f	\N	1	\N
213	1	2020-12-01	15.00	17.00	f	\N	1	\N
213	1	2020-12-01	17.00	18.00	f	\N	1	\N
208	2	2020-12-01	9.00	11.00	f	\N	1	\N
208	2	2020-12-01	11.00	13.00	f	\N	1	\N
208	2	2020-12-01	13.00	15.00	f	\N	1	\N
208	2	2020-12-01	15.00	17.00	f	\N	1	\N
208	2	2020-12-01	17.00	18.00	f	\N	1	\N
244	2	2020-12-01	9.00	11.00	f	\N	1	\N
244	2	2020-12-01	11.00	13.00	f	\N	1	\N
244	2	2020-12-01	13.00	15.00	f	\N	1	\N
244	2	2020-12-01	15.00	17.00	f	\N	1	\N
244	2	2020-12-01	17.00	18.00	f	\N	1	\N
136	1	2020-11-28	12.00	14.00	f	\N	1	\N
130	2	2020-11-21	14.00	16.00	f	\N	1	\N
129	2	2020-11-21	10.00	12.00	f	\N	1	\N
129	2	2020-11-21	12.00	14.00	f	\N	1	\N
129	2	2020-11-21	14.00	16.00	f	\N	1	\N
124	2	2020-11-21	10.00	12.00	f	\N	1	\N
124	2	2020-11-21	12.00	14.00	f	\N	1	\N
124	2	2020-11-21	14.00	16.00	f	\N	1	\N
117	2	2020-11-21	10.00	12.00	f	\N	1	\N
117	2	2020-11-21	12.00	14.00	f	\N	1	\N
117	2	2020-11-21	14.00	16.00	f	\N	1	\N
123	2	2020-11-21	10.00	12.00	f	\N	1	\N
123	2	2020-11-21	12.00	14.00	f	\N	1	\N
136	1	2020-11-28	14.00	16.00	f	\N	1	\N
137	1	2020-11-28	10.00	12.00	f	\N	1	\N
137	1	2020-11-28	12.00	14.00	f	\N	1	\N
137	1	2020-11-28	14.00	16.00	f	\N	1	\N
195	1	2020-11-28	10.00	12.00	f	\N	1	\N
195	1	2020-11-28	12.00	14.00	f	\N	1	\N
195	1	2020-11-28	14.00	16.00	f	\N	1	\N
138	1	2020-11-28	10.00	12.00	f	\N	1	\N
138	1	2020-11-28	12.00	14.00	f	\N	1	\N
138	1	2020-11-28	14.00	16.00	f	\N	1	\N
139	1	2020-11-28	10.00	12.00	f	\N	1	\N
139	1	2020-11-28	12.00	14.00	f	\N	1	\N
139	1	2020-11-28	14.00	16.00	f	\N	1	\N
123	2	2020-11-21	14.00	16.00	f	\N	1	\N
121	2	2020-11-21	10.00	12.00	f	\N	1	\N
102	1	2020-11-18	14.00	16.00	f	\N	1	\N
140	1	2020-11-28	10.00	12.00	f	\N	1	\N
140	1	2020-11-28	12.00	14.00	f	\N	1	\N
140	1	2020-11-28	14.00	16.00	f	\N	1	\N
141	1	2020-11-28	10.00	12.00	f	\N	1	\N
141	1	2020-11-28	12.00	14.00	f	\N	1	\N
141	1	2020-11-28	14.00	16.00	f	\N	1	\N
188	2	2020-11-28	10.00	12.00	f	\N	1	\N
188	2	2020-11-28	12.00	14.00	f	\N	1	\N
188	2	2020-11-28	14.00	16.00	f	\N	1	\N
248	2	2020-11-28	10.00	12.00	f	\N	1	\N
248	2	2020-11-28	12.00	14.00	f	\N	1	\N
248	2	2020-11-28	14.00	16.00	f	\N	1	\N
182	2	2020-11-28	10.00	12.00	f	\N	1	\N
182	2	2020-11-28	12.00	14.00	f	\N	1	\N
182	2	2020-11-28	14.00	16.00	f	\N	1	\N
183	2	2020-11-28	10.00	12.00	f	\N	1	\N
183	2	2020-11-28	12.00	14.00	f	\N	1	\N
183	2	2020-11-28	14.00	16.00	f	\N	1	\N
181	2	2020-11-28	10.00	12.00	f	\N	1	\N
181	2	2020-11-28	12.00	14.00	f	\N	1	\N
181	2	2020-11-28	14.00	16.00	f	\N	1	\N
187	2	2020-11-28	10.00	12.00	f	\N	1	\N
187	2	2020-11-28	12.00	14.00	f	\N	1	\N
187	2	2020-11-28	14.00	16.00	f	\N	1	\N
184	2	2020-11-28	10.00	12.00	f	\N	1	\N
184	2	2020-11-28	12.00	14.00	f	\N	1	\N
184	2	2020-11-28	14.00	16.00	f	\N	1	\N
249	2	2020-11-28	10.00	12.00	f	\N	1	\N
249	2	2020-11-28	12.00	14.00	f	\N	1	\N
249	2	2020-11-28	14.00	16.00	f	\N	1	\N
186	2	2020-11-28	10.00	12.00	f	\N	1	\N
186	2	2020-11-28	12.00	14.00	f	\N	1	\N
186	2	2020-11-28	14.00	16.00	f	\N	1	\N
180	2	2020-11-28	10.00	12.00	f	\N	1	\N
180	2	2020-11-28	12.00	14.00	f	\N	1	\N
180	2	2020-11-28	14.00	16.00	f	\N	1	\N
185	2	2020-11-28	10.00	12.00	f	\N	1	\N
185	2	2020-11-28	12.00	14.00	f	\N	1	\N
185	2	2020-11-28	14.00	16.00	f	\N	1	\N
283	3	2020-11-28	10.00	12.00	f	\N	1	\N
283	3	2020-11-28	12.00	14.00	f	\N	1	\N
283	3	2020-11-28	14.00	16.00	f	\N	1	\N
284	3	2020-11-28	10.00	12.00	f	\N	1	\N
284	3	2020-11-28	12.00	14.00	f	\N	1	\N
284	3	2020-11-28	14.00	16.00	f	\N	1	\N
189	1	2020-11-28	10.00	12.00	f	\N	1	\N
189	1	2020-11-28	12.00	14.00	f	\N	1	\N
189	1	2020-11-28	14.00	16.00	f	\N	1	\N
256	1	2020-11-28	10.00	12.00	f	\N	1	\N
256	1	2020-11-28	12.00	14.00	f	\N	1	\N
256	1	2020-11-28	14.00	16.00	f	\N	1	\N
98	1	2020-11-28	10.00	12.00	f	\N	1	\N
98	1	2020-11-28	12.00	14.00	f	\N	1	\N
98	1	2020-11-28	14.00	16.00	f	\N	1	\N
101	1	2020-11-28	10.00	12.00	f	\N	1	\N
101	1	2020-11-28	12.00	14.00	f	\N	1	\N
101	1	2020-11-28	14.00	16.00	f	\N	1	\N
309	1	2020-11-28	10.00	12.00	f	\N	1	\N
309	1	2020-11-28	12.00	14.00	f	\N	1	\N
309	1	2020-11-28	14.00	16.00	f	\N	1	\N
311	1	2020-11-28	10.00	12.00	f	\N	1	\N
311	1	2020-11-28	12.00	14.00	f	\N	1	\N
311	1	2020-11-28	14.00	16.00	f	\N	1	\N
190	1	2020-11-28	10.00	12.00	f	\N	1	\N
190	1	2020-11-28	12.00	14.00	f	\N	1	\N
190	1	2020-11-28	14.00	16.00	f	\N	1	\N
99	1	2020-11-28	10.00	12.00	f	\N	1	\N
99	1	2020-11-28	12.00	14.00	f	\N	1	\N
99	1	2020-11-28	14.00	16.00	f	\N	1	\N
100	1	2020-11-28	10.00	12.00	f	\N	1	\N
100	1	2020-11-28	12.00	14.00	f	\N	1	\N
100	1	2020-11-28	14.00	16.00	f	\N	1	\N
310	1	2020-11-28	10.00	12.00	f	\N	1	\N
310	1	2020-11-28	12.00	14.00	f	\N	1	\N
310	1	2020-11-28	14.00	16.00	f	\N	1	\N
102	1	2020-11-28	10.00	12.00	f	\N	1	\N
102	1	2020-11-28	12.00	14.00	f	\N	1	\N
102	1	2020-11-28	14.00	16.00	f	\N	1	\N
121	2	2020-11-21	12.00	14.00	f	\N	1	\N
121	2	2020-11-21	14.00	16.00	f	\N	1	\N
103	1	2020-11-28	10.00	12.00	f	\N	1	\N
103	1	2020-11-28	12.00	14.00	f	\N	1	\N
103	1	2020-11-28	14.00	16.00	f	\N	1	\N
104	1	2020-11-28	10.00	12.00	f	\N	1	\N
104	1	2020-11-28	12.00	14.00	f	\N	1	\N
104	1	2020-11-28	14.00	16.00	f	\N	1	\N
307	1	2020-11-28	10.00	12.00	f	\N	1	\N
307	1	2020-11-28	12.00	14.00	f	\N	1	\N
307	1	2020-11-28	14.00	16.00	f	\N	1	\N
119	2	2020-11-21	10.00	12.00	f	\N	1	\N
119	2	2020-11-21	12.00	14.00	f	\N	1	\N
312	1	2020-11-28	10.00	12.00	f	\N	1	\N
101	1	2020-11-19	12.00	14.00	t	8328392746	2	tobbe
100	1	2020-11-20	10.00	12.00	t	8404912680	2	Viktor
209	2	2020-12-01	9.00	11.00	f	\N	1	\N
81	1	2020-11-24	22.00	23.00	f	\N	1	\N
82	1	2020-11-24	6.00	8.00	f	\N	1	\N
119	2	2020-11-21	14.00	16.00	f	\N	1	\N
102	1	2020-11-18	12.00	14.00	f	\N	1	\N
314	3	2020-11-23	13.00	15.00	t	8306227208	2	Zozo 
82	1	2020-11-24	8.00	10.00	f	\N	1	\N
82	1	2020-11-24	10.00	12.00	f	\N	1	\N
82	1	2020-11-24	12.00	14.00	f	\N	1	\N
118	2	2020-11-21	10.00	12.00	f	\N	1	\N
209	2	2020-12-01	11.00	13.00	f	\N	1	\N
209	2	2020-12-01	13.00	15.00	f	\N	1	\N
209	2	2020-12-01	15.00	17.00	f	\N	1	\N
209	2	2020-12-01	17.00	18.00	f	\N	1	\N
245	2	2020-12-01	9.00	11.00	f	\N	1	\N
245	2	2020-12-01	11.00	13.00	f	\N	1	\N
245	2	2020-12-01	13.00	15.00	f	\N	1	\N
245	2	2020-12-01	15.00	17.00	f	\N	1	\N
245	2	2020-12-01	17.00	18.00	f	\N	1	\N
247	2	2020-12-01	9.00	11.00	f	\N	1	\N
247	2	2020-12-01	11.00	13.00	f	\N	1	\N
247	2	2020-12-01	13.00	15.00	f	\N	1	\N
247	2	2020-12-01	15.00	17.00	f	\N	1	\N
247	2	2020-12-01	17.00	18.00	f	\N	1	\N
207	2	2020-12-01	9.00	11.00	f	\N	1	\N
207	2	2020-12-01	11.00	13.00	f	\N	1	\N
207	2	2020-12-01	13.00	15.00	f	\N	1	\N
207	2	2020-12-01	15.00	17.00	f	\N	1	\N
207	2	2020-12-01	17.00	18.00	f	\N	1	\N
212	2	2020-12-01	9.00	11.00	f	\N	1	\N
212	2	2020-12-01	11.00	13.00	f	\N	1	\N
212	2	2020-12-01	13.00	15.00	f	\N	1	\N
212	2	2020-12-01	15.00	17.00	f	\N	1	\N
212	2	2020-12-01	17.00	18.00	f	\N	1	\N
217	2	2020-12-01	9.00	11.00	f	\N	1	\N
118	2	2020-11-21	12.00	14.00	f	\N	1	\N
118	2	2020-11-21	14.00	16.00	f	\N	1	\N
217	2	2020-12-01	11.00	13.00	f	\N	1	\N
217	2	2020-12-01	13.00	15.00	f	\N	1	\N
217	2	2020-12-01	15.00	17.00	f	\N	1	\N
217	2	2020-12-01	17.00	18.00	f	\N	1	\N
246	2	2020-12-01	9.00	11.00	f	\N	1	\N
82	1	2020-11-24	14.00	16.00	f	\N	1	\N
312	1	2020-11-28	12.00	14.00	f	\N	1	\N
312	1	2020-11-28	14.00	16.00	f	\N	1	\N
308	1	2020-11-28	10.00	12.00	f	\N	1	\N
308	1	2020-11-28	12.00	14.00	f	\N	1	\N
308	1	2020-11-28	14.00	16.00	f	\N	1	\N
122	2	2020-11-28	10.00	12.00	f	\N	1	\N
122	2	2020-11-28	12.00	14.00	f	\N	1	\N
122	2	2020-11-28	14.00	16.00	f	\N	1	\N
105	2	2020-11-28	10.00	12.00	f	\N	1	\N
105	2	2020-11-28	12.00	14.00	f	\N	1	\N
105	2	2020-11-28	14.00	16.00	f	\N	1	\N
112	2	2020-11-28	10.00	12.00	f	\N	1	\N
112	2	2020-11-28	12.00	14.00	f	\N	1	\N
112	2	2020-11-28	14.00	16.00	f	\N	1	\N
111	2	2020-11-28	10.00	12.00	f	\N	1	\N
111	2	2020-11-28	12.00	14.00	f	\N	1	\N
111	2	2020-11-28	14.00	16.00	f	\N	1	\N
106	2	2020-11-28	10.00	12.00	f	\N	1	\N
106	2	2020-11-28	12.00	14.00	f	\N	1	\N
106	2	2020-11-28	14.00	16.00	f	\N	1	\N
107	2	2020-11-28	10.00	12.00	f	\N	1	\N
107	2	2020-11-28	12.00	14.00	f	\N	1	\N
107	2	2020-11-28	14.00	16.00	f	\N	1	\N
109	2	2020-11-28	10.00	12.00	f	\N	1	\N
109	2	2020-11-28	12.00	14.00	f	\N	1	\N
109	2	2020-11-28	14.00	16.00	f	\N	1	\N
133	2	2020-11-28	10.00	12.00	f	\N	1	\N
133	2	2020-11-28	12.00	14.00	f	\N	1	\N
133	2	2020-11-28	14.00	16.00	f	\N	1	\N
134	2	2020-11-28	10.00	12.00	f	\N	1	\N
134	2	2020-11-28	12.00	14.00	f	\N	1	\N
134	2	2020-11-28	14.00	16.00	f	\N	1	\N
128	2	2020-11-28	10.00	12.00	f	\N	1	\N
128	2	2020-11-28	12.00	14.00	f	\N	1	\N
128	2	2020-11-28	14.00	16.00	f	\N	1	\N
127	2	2020-11-28	10.00	12.00	f	\N	1	\N
127	2	2020-11-28	12.00	14.00	f	\N	1	\N
127	2	2020-11-28	14.00	16.00	f	\N	1	\N
126	2	2020-11-28	10.00	12.00	f	\N	1	\N
126	2	2020-11-28	12.00	14.00	f	\N	1	\N
126	2	2020-11-28	14.00	16.00	f	\N	1	\N
125	2	2020-11-28	10.00	12.00	f	\N	1	\N
125	2	2020-11-28	12.00	14.00	f	\N	1	\N
125	2	2020-11-28	14.00	16.00	f	\N	1	\N
132	2	2020-11-28	10.00	12.00	f	\N	1	\N
132	2	2020-11-28	12.00	14.00	f	\N	1	\N
132	2	2020-11-28	14.00	16.00	f	\N	1	\N
131	2	2020-11-28	10.00	12.00	f	\N	1	\N
131	2	2020-11-28	12.00	14.00	f	\N	1	\N
131	2	2020-11-28	14.00	16.00	f	\N	1	\N
130	2	2020-11-28	10.00	12.00	f	\N	1	\N
130	2	2020-11-28	12.00	14.00	f	\N	1	\N
130	2	2020-11-28	14.00	16.00	f	\N	1	\N
129	2	2020-11-28	10.00	12.00	f	\N	1	\N
129	2	2020-11-28	12.00	14.00	f	\N	1	\N
129	2	2020-11-28	14.00	16.00	f	\N	1	\N
124	2	2020-11-28	10.00	12.00	f	\N	1	\N
124	2	2020-11-28	12.00	14.00	f	\N	1	\N
124	2	2020-11-28	14.00	16.00	f	\N	1	\N
117	2	2020-11-28	10.00	12.00	f	\N	1	\N
117	2	2020-11-28	12.00	14.00	f	\N	1	\N
117	2	2020-11-28	14.00	16.00	f	\N	1	\N
123	2	2020-11-28	10.00	12.00	f	\N	1	\N
123	2	2020-11-28	12.00	14.00	f	\N	1	\N
123	2	2020-11-28	14.00	16.00	f	\N	1	\N
121	2	2020-11-28	10.00	12.00	f	\N	1	\N
121	2	2020-11-28	12.00	14.00	f	\N	1	\N
121	2	2020-11-28	14.00	16.00	f	\N	1	\N
119	2	2020-11-28	10.00	12.00	f	\N	1	\N
119	2	2020-11-28	12.00	14.00	f	\N	1	\N
119	2	2020-11-28	14.00	16.00	f	\N	1	\N
118	2	2020-11-28	10.00	12.00	f	\N	1	\N
118	2	2020-11-28	12.00	14.00	f	\N	1	\N
118	2	2020-11-28	14.00	16.00	f	\N	1	\N
110	2	2020-11-28	10.00	12.00	f	\N	1	\N
110	2	2020-11-28	12.00	14.00	f	\N	1	\N
110	2	2020-11-28	14.00	16.00	f	\N	1	\N
246	2	2020-12-01	11.00	13.00	f	\N	1	\N
82	1	2020-11-24	16.00	18.00	f	\N	1	\N
108	2	2020-11-28	10.00	12.00	f	\N	1	\N
108	2	2020-11-28	12.00	14.00	f	\N	1	\N
108	2	2020-11-28	14.00	16.00	f	\N	1	\N
116	2	2020-11-28	10.00	12.00	f	\N	1	\N
116	2	2020-11-28	12.00	14.00	f	\N	1	\N
116	2	2020-11-28	14.00	16.00	f	\N	1	\N
115	2	2020-11-28	10.00	12.00	f	\N	1	\N
115	2	2020-11-28	12.00	14.00	f	\N	1	\N
115	2	2020-11-28	14.00	16.00	f	\N	1	\N
114	2	2020-11-28	10.00	12.00	f	\N	1	\N
114	2	2020-11-28	12.00	14.00	f	\N	1	\N
114	2	2020-11-28	14.00	16.00	f	\N	1	\N
113	2	2020-11-28	10.00	12.00	f	\N	1	\N
113	2	2020-11-28	12.00	14.00	f	\N	1	\N
113	2	2020-11-28	14.00	16.00	f	\N	1	\N
120	2	2020-11-28	10.00	12.00	f	\N	1	\N
120	2	2020-11-28	12.00	14.00	f	\N	1	\N
120	2	2020-11-28	14.00	16.00	f	\N	1	\N
286	3	2020-11-28	10.00	12.00	f	\N	1	\N
286	3	2020-11-28	12.00	14.00	f	\N	1	\N
286	3	2020-11-28	14.00	16.00	f	\N	1	\N
89	1	2020-11-28	10.00	12.00	f	\N	1	\N
89	1	2020-11-28	12.00	14.00	f	\N	1	\N
89	1	2020-11-28	14.00	16.00	f	\N	1	\N
300	1	2020-11-28	10.00	12.00	f	\N	1	\N
300	1	2020-11-28	12.00	14.00	f	\N	1	\N
300	1	2020-11-28	14.00	16.00	f	\N	1	\N
298	1	2020-11-28	10.00	12.00	f	\N	1	\N
298	1	2020-11-28	12.00	14.00	f	\N	1	\N
298	1	2020-11-28	14.00	16.00	f	\N	1	\N
95	1	2020-11-28	10.00	12.00	f	\N	1	\N
95	1	2020-11-28	12.00	14.00	f	\N	1	\N
95	1	2020-11-28	14.00	16.00	f	\N	1	\N
90	1	2020-11-28	10.00	12.00	f	\N	1	\N
90	1	2020-11-28	12.00	14.00	f	\N	1	\N
90	1	2020-11-28	14.00	16.00	f	\N	1	\N
94	1	2020-11-28	10.00	12.00	f	\N	1	\N
94	1	2020-11-28	12.00	14.00	f	\N	1	\N
94	1	2020-11-28	14.00	16.00	f	\N	1	\N
92	1	2020-11-28	10.00	12.00	f	\N	1	\N
92	1	2020-11-28	12.00	14.00	f	\N	1	\N
92	1	2020-11-28	14.00	16.00	f	\N	1	\N
93	1	2020-11-28	10.00	12.00	f	\N	1	\N
93	1	2020-11-28	12.00	14.00	f	\N	1	\N
93	1	2020-11-28	14.00	16.00	f	\N	1	\N
96	1	2020-11-28	10.00	12.00	f	\N	1	\N
96	1	2020-11-28	12.00	14.00	f	\N	1	\N
96	1	2020-11-28	14.00	16.00	f	\N	1	\N
91	1	2020-11-28	10.00	12.00	f	\N	1	\N
91	1	2020-11-28	12.00	14.00	f	\N	1	\N
91	1	2020-11-28	14.00	16.00	f	\N	1	\N
301	1	2020-11-28	10.00	12.00	f	\N	1	\N
301	1	2020-11-28	12.00	14.00	f	\N	1	\N
301	1	2020-11-28	14.00	16.00	f	\N	1	\N
299	1	2020-11-28	10.00	12.00	f	\N	1	\N
299	1	2020-11-28	12.00	14.00	f	\N	1	\N
299	1	2020-11-28	14.00	16.00	f	\N	1	\N
176	2	2020-11-28	10.00	12.00	f	\N	1	\N
176	2	2020-11-28	12.00	14.00	f	\N	1	\N
176	2	2020-11-28	14.00	16.00	f	\N	1	\N
175	2	2020-11-28	10.00	12.00	f	\N	1	\N
175	2	2020-11-28	12.00	14.00	f	\N	1	\N
175	2	2020-11-28	14.00	16.00	f	\N	1	\N
174	2	2020-11-28	10.00	12.00	f	\N	1	\N
174	2	2020-11-28	12.00	14.00	f	\N	1	\N
174	2	2020-11-28	14.00	16.00	f	\N	1	\N
179	2	2020-11-28	10.00	12.00	f	\N	1	\N
179	2	2020-11-28	12.00	14.00	f	\N	1	\N
179	2	2020-11-28	14.00	16.00	f	\N	1	\N
178	2	2020-11-28	10.00	12.00	f	\N	1	\N
178	2	2020-11-28	12.00	14.00	f	\N	1	\N
178	2	2020-11-28	14.00	16.00	f	\N	1	\N
177	2	2020-11-28	10.00	12.00	f	\N	1	\N
177	2	2020-11-28	12.00	14.00	f	\N	1	\N
177	2	2020-11-28	14.00	16.00	f	\N	1	\N
192	2	2020-11-28	10.00	12.00	f	\N	1	\N
192	2	2020-11-28	12.00	14.00	f	\N	1	\N
192	2	2020-11-28	14.00	16.00	f	\N	1	\N
193	2	2020-11-28	10.00	12.00	f	\N	1	\N
193	2	2020-11-28	12.00	14.00	f	\N	1	\N
193	2	2020-11-28	14.00	16.00	f	\N	1	\N
302	3	2020-11-28	10.00	12.00	f	\N	1	\N
302	3	2020-11-28	12.00	14.00	f	\N	1	\N
302	3	2020-11-28	14.00	16.00	f	\N	1	\N
305	3	2020-11-28	10.00	12.00	f	\N	1	\N
305	3	2020-11-28	12.00	14.00	f	\N	1	\N
110	2	2020-11-21	10.00	12.00	f	\N	1	\N
305	3	2020-11-28	14.00	16.00	f	\N	1	\N
314	3	2020-11-28	10.00	12.00	f	\N	1	\N
246	2	2020-12-01	13.00	15.00	f	\N	1	\N
246	2	2020-12-01	15.00	17.00	f	\N	1	\N
246	2	2020-12-01	17.00	18.00	f	\N	1	\N
210	2	2020-12-01	9.00	11.00	f	\N	1	\N
210	2	2020-12-01	11.00	13.00	f	\N	1	\N
210	2	2020-12-01	13.00	15.00	f	\N	1	\N
210	2	2020-12-01	15.00	17.00	f	\N	1	\N
210	2	2020-12-01	17.00	18.00	f	\N	1	\N
206	2	2020-12-01	9.00	11.00	f	\N	1	\N
206	2	2020-12-01	11.00	13.00	f	\N	1	\N
206	2	2020-12-01	13.00	15.00	f	\N	1	\N
206	2	2020-12-01	15.00	17.00	f	\N	1	\N
206	2	2020-12-01	17.00	18.00	f	\N	1	\N
288	3	2020-12-01	9.00	11.00	f	\N	1	\N
288	3	2020-12-01	11.00	13.00	f	\N	1	\N
288	3	2020-12-01	13.00	15.00	f	\N	1	\N
288	3	2020-12-01	15.00	17.00	f	\N	1	\N
288	3	2020-12-01	17.00	18.00	f	\N	1	\N
287	3	2020-12-01	9.00	11.00	f	\N	1	\N
287	3	2020-12-01	11.00	13.00	f	\N	1	\N
110	2	2020-11-21	12.00	14.00	f	\N	1	\N
82	1	2020-11-24	18.00	20.00	f	\N	1	\N
287	3	2020-12-01	13.00	15.00	f	\N	1	\N
287	3	2020-12-01	15.00	17.00	f	\N	1	\N
287	3	2020-12-01	17.00	18.00	f	\N	1	\N
196	1	2020-12-01	9.00	11.00	f	\N	1	\N
196	1	2020-12-01	11.00	13.00	f	\N	1	\N
196	1	2020-12-01	13.00	15.00	f	\N	1	\N
196	1	2020-12-01	15.00	17.00	f	\N	1	\N
196	1	2020-12-01	17.00	18.00	f	\N	1	\N
97	1	2020-12-01	9.00	11.00	f	\N	1	\N
97	1	2020-12-01	11.00	13.00	f	\N	1	\N
97	1	2020-12-01	13.00	15.00	f	\N	1	\N
97	1	2020-12-01	15.00	17.00	f	\N	1	\N
97	1	2020-12-01	17.00	18.00	f	\N	1	\N
197	1	2020-12-01	9.00	11.00	f	\N	1	\N
197	1	2020-12-01	11.00	13.00	f	\N	1	\N
197	1	2020-12-01	13.00	15.00	f	\N	1	\N
197	1	2020-12-01	15.00	17.00	f	\N	1	\N
197	1	2020-12-01	17.00	18.00	f	\N	1	\N
135	1	2020-12-01	9.00	11.00	f	\N	1	\N
135	1	2020-12-01	11.00	13.00	f	\N	1	\N
135	1	2020-12-01	13.00	15.00	f	\N	1	\N
135	1	2020-12-01	15.00	17.00	f	\N	1	\N
135	1	2020-12-01	17.00	18.00	f	\N	1	\N
136	1	2020-12-01	9.00	11.00	f	\N	1	\N
136	1	2020-12-01	11.00	13.00	f	\N	1	\N
136	1	2020-12-01	13.00	15.00	f	\N	1	\N
136	1	2020-12-01	15.00	17.00	f	\N	1	\N
136	1	2020-12-01	17.00	18.00	f	\N	1	\N
137	1	2020-12-01	9.00	11.00	f	\N	1	\N
137	1	2020-12-01	11.00	13.00	f	\N	1	\N
137	1	2020-12-01	13.00	15.00	f	\N	1	\N
137	1	2020-12-01	15.00	17.00	f	\N	1	\N
137	1	2020-12-01	17.00	18.00	f	\N	1	\N
195	1	2020-12-01	9.00	11.00	f	\N	1	\N
195	1	2020-12-01	11.00	13.00	f	\N	1	\N
195	1	2020-12-01	13.00	15.00	f	\N	1	\N
195	1	2020-12-01	15.00	17.00	f	\N	1	\N
195	1	2020-12-01	17.00	18.00	f	\N	1	\N
138	1	2020-12-01	9.00	11.00	f	\N	1	\N
138	1	2020-12-01	11.00	13.00	f	\N	1	\N
138	1	2020-12-01	13.00	15.00	f	\N	1	\N
138	1	2020-12-01	15.00	17.00	f	\N	1	\N
138	1	2020-12-01	17.00	18.00	f	\N	1	\N
139	1	2020-12-01	9.00	11.00	f	\N	1	\N
139	1	2020-12-01	11.00	13.00	f	\N	1	\N
139	1	2020-12-01	13.00	15.00	f	\N	1	\N
139	1	2020-12-01	15.00	17.00	f	\N	1	\N
139	1	2020-12-01	17.00	18.00	f	\N	1	\N
140	1	2020-12-01	9.00	11.00	f	\N	1	\N
140	1	2020-12-01	11.00	13.00	f	\N	1	\N
140	1	2020-12-01	13.00	15.00	f	\N	1	\N
140	1	2020-12-01	15.00	17.00	f	\N	1	\N
140	1	2020-12-01	17.00	18.00	f	\N	1	\N
141	1	2020-12-01	9.00	11.00	f	\N	1	\N
141	1	2020-12-01	11.00	13.00	f	\N	1	\N
141	1	2020-12-01	13.00	15.00	f	\N	1	\N
141	1	2020-12-01	15.00	17.00	f	\N	1	\N
141	1	2020-12-01	17.00	18.00	f	\N	1	\N
188	2	2020-12-01	9.00	11.00	f	\N	1	\N
188	2	2020-12-01	11.00	13.00	f	\N	1	\N
188	2	2020-12-01	13.00	15.00	f	\N	1	\N
188	2	2020-12-01	15.00	17.00	f	\N	1	\N
188	2	2020-12-01	17.00	18.00	f	\N	1	\N
248	2	2020-12-01	9.00	11.00	f	\N	1	\N
248	2	2020-12-01	11.00	13.00	f	\N	1	\N
248	2	2020-12-01	13.00	15.00	f	\N	1	\N
248	2	2020-12-01	15.00	17.00	f	\N	1	\N
248	2	2020-12-01	17.00	18.00	f	\N	1	\N
182	2	2020-12-01	9.00	11.00	f	\N	1	\N
182	2	2020-12-01	11.00	13.00	f	\N	1	\N
182	2	2020-12-01	13.00	15.00	f	\N	1	\N
182	2	2020-12-01	15.00	17.00	f	\N	1	\N
182	2	2020-12-01	17.00	18.00	f	\N	1	\N
183	2	2020-12-01	9.00	11.00	f	\N	1	\N
183	2	2020-12-01	11.00	13.00	f	\N	1	\N
183	2	2020-12-01	13.00	15.00	f	\N	1	\N
183	2	2020-12-01	15.00	17.00	f	\N	1	\N
183	2	2020-12-01	17.00	18.00	f	\N	1	\N
181	2	2020-12-01	9.00	11.00	f	\N	1	\N
181	2	2020-12-01	11.00	13.00	f	\N	1	\N
181	2	2020-12-01	13.00	15.00	f	\N	1	\N
181	2	2020-12-01	15.00	17.00	f	\N	1	\N
181	2	2020-12-01	17.00	18.00	f	\N	1	\N
187	2	2020-12-01	9.00	11.00	f	\N	1	\N
187	2	2020-12-01	11.00	13.00	f	\N	1	\N
187	2	2020-12-01	13.00	15.00	f	\N	1	\N
187	2	2020-12-01	15.00	17.00	f	\N	1	\N
187	2	2020-12-01	17.00	18.00	f	\N	1	\N
184	2	2020-12-01	9.00	11.00	f	\N	1	\N
184	2	2020-12-01	11.00	13.00	f	\N	1	\N
184	2	2020-12-01	13.00	15.00	f	\N	1	\N
184	2	2020-12-01	15.00	17.00	f	\N	1	\N
184	2	2020-12-01	17.00	18.00	f	\N	1	\N
249	2	2020-12-01	9.00	11.00	f	\N	1	\N
249	2	2020-12-01	11.00	13.00	f	\N	1	\N
249	2	2020-12-01	13.00	15.00	f	\N	1	\N
249	2	2020-12-01	15.00	17.00	f	\N	1	\N
249	2	2020-12-01	17.00	18.00	f	\N	1	\N
186	2	2020-12-01	9.00	11.00	f	\N	1	\N
186	2	2020-12-01	11.00	13.00	f	\N	1	\N
186	2	2020-12-01	13.00	15.00	f	\N	1	\N
186	2	2020-12-01	15.00	17.00	f	\N	1	\N
186	2	2020-12-01	17.00	18.00	f	\N	1	\N
180	2	2020-12-01	9.00	11.00	f	\N	1	\N
180	2	2020-12-01	11.00	13.00	f	\N	1	\N
180	2	2020-12-01	13.00	15.00	f	\N	1	\N
180	2	2020-12-01	15.00	17.00	f	\N	1	\N
180	2	2020-12-01	17.00	18.00	f	\N	1	\N
185	2	2020-12-01	9.00	11.00	f	\N	1	\N
110	2	2020-11-21	14.00	16.00	f	\N	1	\N
185	2	2020-12-01	11.00	13.00	f	\N	1	\N
185	2	2020-12-01	13.00	15.00	f	\N	1	\N
185	2	2020-12-01	15.00	17.00	f	\N	1	\N
185	2	2020-12-01	17.00	18.00	f	\N	1	\N
283	3	2020-12-01	9.00	11.00	f	\N	1	\N
283	3	2020-12-01	11.00	13.00	f	\N	1	\N
283	3	2020-12-01	13.00	15.00	f	\N	1	\N
283	3	2020-12-01	15.00	17.00	f	\N	1	\N
283	3	2020-12-01	17.00	18.00	f	\N	1	\N
284	3	2020-12-01	9.00	11.00	f	\N	1	\N
284	3	2020-12-01	11.00	13.00	f	\N	1	\N
284	3	2020-12-01	13.00	15.00	f	\N	1	\N
284	3	2020-12-01	15.00	17.00	f	\N	1	\N
284	3	2020-12-01	17.00	18.00	f	\N	1	\N
189	1	2020-12-01	10.00	12.00	f	\N	1	\N
189	1	2020-12-01	12.00	14.00	f	\N	1	\N
189	1	2020-12-01	14.00	16.00	f	\N	1	\N
256	1	2020-12-01	10.00	12.00	f	\N	1	\N
256	1	2020-12-01	12.00	14.00	f	\N	1	\N
256	1	2020-12-01	14.00	16.00	f	\N	1	\N
98	1	2020-12-01	10.00	12.00	f	\N	1	\N
98	1	2020-12-01	12.00	14.00	f	\N	1	\N
98	1	2020-12-01	14.00	16.00	f	\N	1	\N
101	1	2020-12-01	10.00	12.00	f	\N	1	\N
101	1	2020-12-01	12.00	14.00	f	\N	1	\N
101	1	2020-12-01	14.00	16.00	f	\N	1	\N
309	1	2020-12-01	10.00	12.00	f	\N	1	\N
309	1	2020-12-01	12.00	14.00	f	\N	1	\N
309	1	2020-12-01	14.00	16.00	f	\N	1	\N
311	1	2020-12-01	10.00	12.00	f	\N	1	\N
311	1	2020-12-01	12.00	14.00	f	\N	1	\N
311	1	2020-12-01	14.00	16.00	f	\N	1	\N
190	1	2020-12-01	10.00	12.00	f	\N	1	\N
190	1	2020-12-01	12.00	14.00	f	\N	1	\N
190	1	2020-12-01	14.00	16.00	f	\N	1	\N
99	1	2020-12-01	10.00	12.00	f	\N	1	\N
99	1	2020-12-01	12.00	14.00	f	\N	1	\N
99	1	2020-12-01	14.00	16.00	f	\N	1	\N
100	1	2020-12-01	10.00	12.00	f	\N	1	\N
100	1	2020-12-01	12.00	14.00	f	\N	1	\N
100	1	2020-12-01	14.00	16.00	f	\N	1	\N
310	1	2020-12-01	10.00	12.00	f	\N	1	\N
310	1	2020-12-01	12.00	14.00	f	\N	1	\N
310	1	2020-12-01	14.00	16.00	f	\N	1	\N
102	1	2020-12-01	10.00	12.00	f	\N	1	\N
102	1	2020-12-01	12.00	14.00	f	\N	1	\N
102	1	2020-12-01	14.00	16.00	f	\N	1	\N
103	1	2020-12-01	10.00	12.00	f	\N	1	\N
103	1	2020-12-01	12.00	14.00	f	\N	1	\N
103	1	2020-12-01	14.00	16.00	f	\N	1	\N
104	1	2020-12-01	10.00	12.00	f	\N	1	\N
104	1	2020-12-01	12.00	14.00	f	\N	1	\N
104	1	2020-12-01	14.00	16.00	f	\N	1	\N
307	1	2020-12-01	10.00	12.00	f	\N	1	\N
307	1	2020-12-01	12.00	14.00	f	\N	1	\N
307	1	2020-12-01	14.00	16.00	f	\N	1	\N
312	1	2020-12-01	10.00	12.00	f	\N	1	\N
312	1	2020-12-01	12.00	14.00	f	\N	1	\N
312	1	2020-12-01	14.00	16.00	f	\N	1	\N
308	1	2020-12-01	10.00	12.00	f	\N	1	\N
308	1	2020-12-01	12.00	14.00	f	\N	1	\N
308	1	2020-12-01	14.00	16.00	f	\N	1	\N
122	2	2020-12-01	10.00	12.00	f	\N	1	\N
122	2	2020-12-01	12.00	14.00	f	\N	1	\N
122	2	2020-12-01	14.00	16.00	f	\N	1	\N
105	2	2020-12-01	10.00	12.00	f	\N	1	\N
105	2	2020-12-01	12.00	14.00	f	\N	1	\N
105	2	2020-12-01	14.00	16.00	f	\N	1	\N
112	2	2020-12-01	10.00	12.00	f	\N	1	\N
112	2	2020-12-01	12.00	14.00	f	\N	1	\N
112	2	2020-12-01	14.00	16.00	f	\N	1	\N
111	2	2020-12-01	10.00	12.00	f	\N	1	\N
111	2	2020-12-01	12.00	14.00	f	\N	1	\N
111	2	2020-12-01	14.00	16.00	f	\N	1	\N
106	2	2020-12-01	10.00	12.00	f	\N	1	\N
106	2	2020-12-01	12.00	14.00	f	\N	1	\N
106	2	2020-12-01	14.00	16.00	f	\N	1	\N
82	1	2020-11-24	20.00	22.00	f	\N	1	\N
107	2	2020-12-01	10.00	12.00	f	\N	1	\N
107	2	2020-12-01	12.00	14.00	f	\N	1	\N
107	2	2020-12-01	14.00	16.00	f	\N	1	\N
109	2	2020-12-01	10.00	12.00	f	\N	1	\N
109	2	2020-12-01	12.00	14.00	f	\N	1	\N
109	2	2020-12-01	14.00	16.00	f	\N	1	\N
314	3	2020-11-28	12.00	14.00	f	\N	1	\N
108	2	2020-11-21	10.00	12.00	f	\N	1	\N
133	2	2020-12-01	10.00	12.00	f	\N	1	\N
133	2	2020-12-01	12.00	14.00	f	\N	1	\N
133	2	2020-12-01	14.00	16.00	f	\N	1	\N
134	2	2020-12-01	10.00	12.00	f	\N	1	\N
134	2	2020-12-01	12.00	14.00	f	\N	1	\N
134	2	2020-12-01	14.00	16.00	f	\N	1	\N
128	2	2020-12-01	10.00	12.00	f	\N	1	\N
108	2	2020-11-21	12.00	14.00	f	\N	1	\N
108	2	2020-11-21	14.00	16.00	f	\N	1	\N
116	2	2020-11-21	10.00	12.00	f	\N	1	\N
128	2	2020-12-01	12.00	14.00	f	\N	1	\N
128	2	2020-12-01	14.00	16.00	f	\N	1	\N
127	2	2020-12-01	10.00	12.00	f	\N	1	\N
127	2	2020-12-01	12.00	14.00	f	\N	1	\N
116	2	2020-11-21	12.00	14.00	f	\N	1	\N
116	2	2020-11-21	14.00	16.00	f	\N	1	\N
115	2	2020-11-21	10.00	12.00	f	\N	1	\N
115	2	2020-11-21	12.00	14.00	f	\N	1	\N
115	2	2020-11-21	14.00	16.00	f	\N	1	\N
114	2	2020-11-21	10.00	12.00	f	\N	1	\N
114	2	2020-11-21	12.00	14.00	f	\N	1	\N
114	2	2020-11-21	14.00	16.00	f	\N	1	\N
127	2	2020-12-01	14.00	16.00	f	\N	1	\N
113	2	2020-11-21	10.00	12.00	f	\N	1	\N
113	2	2020-11-21	12.00	14.00	f	\N	1	\N
113	2	2020-11-21	14.00	16.00	f	\N	1	\N
120	2	2020-11-21	10.00	12.00	f	\N	1	\N
120	2	2020-11-21	12.00	14.00	f	\N	1	\N
120	2	2020-11-21	14.00	16.00	f	\N	1	\N
286	3	2020-11-21	10.00	12.00	f	\N	1	\N
286	3	2020-11-21	12.00	14.00	f	\N	1	\N
286	3	2020-11-21	14.00	16.00	f	\N	1	\N
89	1	2020-11-21	10.00	12.00	f	\N	1	\N
89	1	2020-11-21	12.00	14.00	f	\N	1	\N
89	1	2020-11-21	14.00	16.00	f	\N	1	\N
300	1	2020-11-21	10.00	12.00	f	\N	1	\N
300	1	2020-11-21	12.00	14.00	f	\N	1	\N
300	1	2020-11-21	14.00	16.00	f	\N	1	\N
298	1	2020-11-21	10.00	12.00	f	\N	1	\N
298	1	2020-11-21	12.00	14.00	f	\N	1	\N
298	1	2020-11-21	14.00	16.00	f	\N	1	\N
95	1	2020-11-21	10.00	12.00	f	\N	1	\N
95	1	2020-11-21	12.00	14.00	f	\N	1	\N
95	1	2020-11-21	14.00	16.00	f	\N	1	\N
90	1	2020-11-21	10.00	12.00	f	\N	1	\N
90	1	2020-11-21	12.00	14.00	f	\N	1	\N
90	1	2020-11-21	14.00	16.00	f	\N	1	\N
94	1	2020-11-21	10.00	12.00	f	\N	1	\N
94	1	2020-11-21	12.00	14.00	f	\N	1	\N
94	1	2020-11-21	14.00	16.00	f	\N	1	\N
92	1	2020-11-21	10.00	12.00	f	\N	1	\N
92	1	2020-11-21	12.00	14.00	f	\N	1	\N
92	1	2020-11-21	14.00	16.00	f	\N	1	\N
93	1	2020-11-21	10.00	12.00	f	\N	1	\N
93	1	2020-11-21	12.00	14.00	f	\N	1	\N
93	1	2020-11-21	14.00	16.00	f	\N	1	\N
96	1	2020-11-21	10.00	12.00	f	\N	1	\N
96	1	2020-11-21	12.00	14.00	f	\N	1	\N
96	1	2020-11-21	14.00	16.00	f	\N	1	\N
91	1	2020-11-21	10.00	12.00	f	\N	1	\N
91	1	2020-11-21	12.00	14.00	f	\N	1	\N
91	1	2020-11-21	14.00	16.00	f	\N	1	\N
301	1	2020-11-21	10.00	12.00	f	\N	1	\N
301	1	2020-11-21	12.00	14.00	f	\N	1	\N
301	1	2020-11-21	14.00	16.00	f	\N	1	\N
299	1	2020-11-21	10.00	12.00	f	\N	1	\N
299	1	2020-11-21	12.00	14.00	f	\N	1	\N
299	1	2020-11-21	14.00	16.00	f	\N	1	\N
176	2	2020-11-21	10.00	12.00	f	\N	1	\N
176	2	2020-11-21	12.00	14.00	f	\N	1	\N
176	2	2020-11-21	14.00	16.00	f	\N	1	\N
126	2	2020-12-01	10.00	12.00	f	\N	1	\N
126	2	2020-12-01	12.00	14.00	f	\N	1	\N
126	2	2020-12-01	14.00	16.00	f	\N	1	\N
125	2	2020-12-01	10.00	12.00	f	\N	1	\N
125	2	2020-12-01	12.00	14.00	f	\N	1	\N
125	2	2020-12-01	14.00	16.00	f	\N	1	\N
132	2	2020-12-01	10.00	12.00	f	\N	1	\N
132	2	2020-12-01	12.00	14.00	f	\N	1	\N
132	2	2020-12-01	14.00	16.00	f	\N	1	\N
131	2	2020-12-01	10.00	12.00	f	\N	1	\N
131	2	2020-12-01	12.00	14.00	f	\N	1	\N
82	1	2020-11-24	22.00	23.00	f	\N	1	\N
87	1	2020-11-24	6.00	8.00	f	\N	1	\N
314	3	2020-11-28	14.00	16.00	f	\N	1	\N
175	2	2020-11-21	10.00	12.00	f	\N	1	\N
175	2	2020-11-21	12.00	14.00	f	\N	1	\N
175	2	2020-11-21	14.00	16.00	f	\N	1	\N
174	2	2020-11-21	10.00	12.00	f	\N	1	\N
174	2	2020-11-21	12.00	14.00	f	\N	1	\N
174	2	2020-11-21	14.00	16.00	f	\N	1	\N
179	2	2020-11-21	10.00	12.00	f	\N	1	\N
179	2	2020-11-21	12.00	14.00	f	\N	1	\N
179	2	2020-11-21	14.00	16.00	f	\N	1	\N
178	2	2020-11-21	10.00	12.00	f	\N	1	\N
178	2	2020-11-21	12.00	14.00	f	\N	1	\N
178	2	2020-11-21	14.00	16.00	f	\N	1	\N
177	2	2020-11-21	10.00	12.00	f	\N	1	\N
177	2	2020-11-21	12.00	14.00	f	\N	1	\N
177	2	2020-11-21	14.00	16.00	f	\N	1	\N
192	2	2020-11-21	10.00	12.00	f	\N	1	\N
192	2	2020-11-21	12.00	14.00	f	\N	1	\N
192	2	2020-11-21	14.00	16.00	f	\N	1	\N
193	2	2020-11-21	10.00	12.00	f	\N	1	\N
193	2	2020-11-21	12.00	14.00	f	\N	1	\N
193	2	2020-11-21	14.00	16.00	f	\N	1	\N
302	3	2020-11-21	10.00	12.00	f	\N	1	\N
302	3	2020-11-21	12.00	14.00	f	\N	1	\N
302	3	2020-11-21	14.00	16.00	f	\N	1	\N
305	3	2020-11-21	10.00	12.00	f	\N	1	\N
305	3	2020-11-21	12.00	14.00	f	\N	1	\N
305	3	2020-11-21	14.00	16.00	f	\N	1	\N
314	3	2020-11-21	10.00	12.00	f	\N	1	\N
131	2	2020-12-01	14.00	16.00	f	\N	1	\N
215	1	2020-11-21	6.00	8.00	f	\N	1	\N
215	1	2020-11-21	8.00	10.00	f	\N	1	\N
215	1	2020-11-21	10.00	12.00	f	\N	1	\N
215	1	2020-11-21	12.00	14.00	f	\N	1	\N
215	1	2020-11-21	14.00	16.00	f	\N	1	\N
215	1	2020-11-21	16.00	18.00	f	\N	1	\N
215	1	2020-11-21	18.00	20.00	f	\N	1	\N
215	1	2020-11-21	20.00	22.00	f	\N	1	\N
215	1	2020-11-21	22.00	23.00	f	\N	1	\N
231	1	2020-11-21	6.00	8.00	f	\N	1	\N
231	1	2020-11-21	8.00	10.00	f	\N	1	\N
231	1	2020-11-21	10.00	12.00	f	\N	1	\N
231	1	2020-11-21	12.00	14.00	f	\N	1	\N
231	1	2020-11-21	14.00	16.00	f	\N	1	\N
231	1	2020-11-21	16.00	18.00	f	\N	1	\N
231	1	2020-11-21	18.00	20.00	f	\N	1	\N
231	1	2020-11-21	20.00	22.00	f	\N	1	\N
231	1	2020-11-21	22.00	23.00	f	\N	1	\N
88	1	2020-11-21	6.00	8.00	f	\N	1	\N
88	1	2020-11-21	8.00	10.00	f	\N	1	\N
88	1	2020-11-21	10.00	12.00	f	\N	1	\N
88	1	2020-11-21	12.00	14.00	f	\N	1	\N
88	1	2020-11-21	14.00	16.00	f	\N	1	\N
88	1	2020-11-21	16.00	18.00	f	\N	1	\N
88	1	2020-11-21	18.00	20.00	f	\N	1	\N
88	1	2020-11-21	20.00	22.00	f	\N	1	\N
88	1	2020-11-21	22.00	23.00	f	\N	1	\N
80	1	2020-11-21	6.00	8.00	f	\N	1	\N
80	1	2020-11-21	8.00	10.00	f	\N	1	\N
80	1	2020-11-21	10.00	12.00	f	\N	1	\N
80	1	2020-11-21	12.00	14.00	f	\N	1	\N
80	1	2020-11-21	14.00	16.00	f	\N	1	\N
80	1	2020-11-21	16.00	18.00	f	\N	1	\N
80	1	2020-11-21	18.00	20.00	f	\N	1	\N
80	1	2020-11-21	20.00	22.00	f	\N	1	\N
80	1	2020-11-21	22.00	23.00	f	\N	1	\N
216	1	2020-11-21	6.00	8.00	f	\N	1	\N
216	1	2020-11-21	8.00	10.00	f	\N	1	\N
216	1	2020-11-21	10.00	12.00	f	\N	1	\N
216	1	2020-11-21	12.00	14.00	f	\N	1	\N
216	1	2020-11-21	14.00	16.00	f	\N	1	\N
216	1	2020-11-21	16.00	18.00	f	\N	1	\N
216	1	2020-11-21	18.00	20.00	f	\N	1	\N
216	1	2020-11-21	20.00	22.00	f	\N	1	\N
216	1	2020-11-21	22.00	23.00	f	\N	1	\N
191	1	2020-11-21	6.00	8.00	f	\N	1	\N
191	1	2020-11-21	8.00	10.00	f	\N	1	\N
191	1	2020-11-21	10.00	12.00	f	\N	1	\N
191	1	2020-11-21	12.00	14.00	f	\N	1	\N
191	1	2020-11-21	14.00	16.00	f	\N	1	\N
191	1	2020-11-21	16.00	18.00	f	\N	1	\N
191	1	2020-11-21	18.00	20.00	f	\N	1	\N
191	1	2020-11-21	20.00	22.00	f	\N	1	\N
191	1	2020-11-21	22.00	23.00	f	\N	1	\N
81	1	2020-11-21	6.00	8.00	f	\N	1	\N
81	1	2020-11-21	8.00	10.00	f	\N	1	\N
81	1	2020-11-21	10.00	12.00	f	\N	1	\N
81	1	2020-11-21	12.00	14.00	f	\N	1	\N
81	1	2020-11-21	14.00	16.00	f	\N	1	\N
81	1	2020-11-21	16.00	18.00	f	\N	1	\N
81	1	2020-11-21	18.00	20.00	f	\N	1	\N
81	1	2020-11-21	20.00	22.00	f	\N	1	\N
81	1	2020-11-21	22.00	23.00	f	\N	1	\N
82	1	2020-11-21	6.00	8.00	f	\N	1	\N
82	1	2020-11-21	8.00	10.00	f	\N	1	\N
82	1	2020-11-21	10.00	12.00	f	\N	1	\N
82	1	2020-11-21	12.00	14.00	f	\N	1	\N
82	1	2020-11-21	14.00	16.00	f	\N	1	\N
82	1	2020-11-21	16.00	18.00	f	\N	1	\N
82	1	2020-11-21	18.00	20.00	f	\N	1	\N
82	1	2020-11-21	20.00	22.00	f	\N	1	\N
82	1	2020-11-21	22.00	23.00	f	\N	1	\N
306	3	2020-11-28	10.00	12.00	f	\N	1	\N
130	2	2020-12-01	10.00	12.00	f	\N	1	\N
130	2	2020-12-01	12.00	14.00	f	\N	1	\N
130	2	2020-12-01	14.00	16.00	f	\N	1	\N
129	2	2020-12-01	10.00	12.00	f	\N	1	\N
129	2	2020-12-01	12.00	14.00	f	\N	1	\N
129	2	2020-12-01	14.00	16.00	f	\N	1	\N
124	2	2020-12-01	10.00	12.00	f	\N	1	\N
124	2	2020-12-01	12.00	14.00	f	\N	1	\N
124	2	2020-12-01	14.00	16.00	f	\N	1	\N
117	2	2020-12-01	10.00	12.00	f	\N	1	\N
117	2	2020-12-01	12.00	14.00	f	\N	1	\N
117	2	2020-12-01	14.00	16.00	f	\N	1	\N
123	2	2020-12-01	10.00	12.00	f	\N	1	\N
314	3	2020-11-21	14.00	16.00	t	8306227208	2	N
314	3	2020-11-21	12.00	14.00	t	8306227208	2	K
306	3	2020-11-21	14.00	16.00	t	8459305474	2	Hellman
87	1	2020-11-24	8.00	10.00	f	\N	1	\N
87	1	2020-11-24	10.00	12.00	f	\N	1	\N
87	1	2020-11-24	12.00	14.00	f	\N	1	\N
87	1	2020-11-24	14.00	16.00	f	\N	1	\N
87	1	2020-11-21	6.00	8.00	f	\N	1	\N
87	1	2020-11-24	16.00	18.00	f	\N	1	\N
87	1	2020-11-21	8.00	10.00	f	\N	1	\N
87	1	2020-11-21	10.00	12.00	f	\N	1	\N
87	1	2020-11-21	12.00	14.00	f	\N	1	\N
87	1	2020-11-21	14.00	16.00	f	\N	1	\N
87	1	2020-11-21	16.00	18.00	f	\N	1	\N
87	1	2020-11-21	18.00	20.00	f	\N	1	\N
87	1	2020-11-21	20.00	22.00	f	\N	1	\N
87	1	2020-11-21	22.00	23.00	f	\N	1	\N
86	1	2020-11-21	6.00	8.00	f	\N	1	\N
86	1	2020-11-21	8.00	10.00	f	\N	1	\N
86	1	2020-11-21	10.00	12.00	f	\N	1	\N
87	1	2020-11-24	18.00	20.00	f	\N	1	\N
87	1	2020-11-24	20.00	22.00	f	\N	1	\N
87	1	2020-11-24	22.00	23.00	f	\N	1	\N
86	1	2020-11-24	6.00	8.00	f	\N	1	\N
86	1	2020-11-24	8.00	10.00	f	\N	1	\N
86	1	2020-11-24	10.00	12.00	f	\N	1	\N
86	1	2020-11-24	12.00	14.00	f	\N	1	\N
86	1	2020-11-24	14.00	16.00	f	\N	1	\N
86	1	2020-11-24	16.00	18.00	f	\N	1	\N
86	1	2020-11-24	18.00	20.00	f	\N	1	\N
86	1	2020-11-24	20.00	22.00	f	\N	1	\N
86	1	2020-11-24	22.00	23.00	f	\N	1	\N
201	1	2020-11-24	6.00	8.00	f	\N	1	\N
306	3	2020-11-28	12.00	14.00	f	\N	1	\N
306	3	2020-11-28	14.00	16.00	f	\N	1	\N
215	1	2020-11-28	6.00	8.00	f	\N	1	\N
215	1	2020-11-28	8.00	10.00	f	\N	1	\N
215	1	2020-11-28	10.00	12.00	f	\N	1	\N
215	1	2020-11-28	12.00	14.00	f	\N	1	\N
215	1	2020-11-28	14.00	16.00	f	\N	1	\N
215	1	2020-11-28	16.00	18.00	f	\N	1	\N
215	1	2020-11-28	18.00	20.00	f	\N	1	\N
215	1	2020-11-28	20.00	22.00	f	\N	1	\N
215	1	2020-11-28	22.00	23.00	f	\N	1	\N
231	1	2020-11-28	6.00	8.00	f	\N	1	\N
231	1	2020-11-28	8.00	10.00	f	\N	1	\N
231	1	2020-11-28	10.00	12.00	f	\N	1	\N
123	2	2020-12-01	12.00	14.00	f	\N	1	\N
123	2	2020-12-01	14.00	16.00	f	\N	1	\N
121	2	2020-12-01	10.00	12.00	f	\N	1	\N
121	2	2020-12-01	12.00	14.00	f	\N	1	\N
121	2	2020-12-01	14.00	16.00	f	\N	1	\N
231	1	2020-11-28	12.00	14.00	f	\N	1	\N
231	1	2020-11-28	14.00	16.00	f	\N	1	\N
231	1	2020-11-28	16.00	18.00	f	\N	1	\N
231	1	2020-11-28	18.00	20.00	f	\N	1	\N
231	1	2020-11-28	20.00	22.00	f	\N	1	\N
231	1	2020-11-28	22.00	23.00	f	\N	1	\N
88	1	2020-11-28	6.00	8.00	f	\N	1	\N
88	1	2020-11-28	8.00	10.00	f	\N	1	\N
88	1	2020-11-28	10.00	12.00	f	\N	1	\N
88	1	2020-11-28	12.00	14.00	f	\N	1	\N
88	1	2020-11-28	14.00	16.00	f	\N	1	\N
88	1	2020-11-28	16.00	18.00	f	\N	1	\N
88	1	2020-11-28	18.00	20.00	f	\N	1	\N
88	1	2020-11-28	20.00	22.00	f	\N	1	\N
88	1	2020-11-28	22.00	23.00	f	\N	1	\N
80	1	2020-11-28	6.00	8.00	f	\N	1	\N
80	1	2020-11-28	8.00	10.00	f	\N	1	\N
80	1	2020-11-28	10.00	12.00	f	\N	1	\N
80	1	2020-11-28	12.00	14.00	f	\N	1	\N
80	1	2020-11-28	14.00	16.00	f	\N	1	\N
80	1	2020-11-28	16.00	18.00	f	\N	1	\N
80	1	2020-11-28	18.00	20.00	f	\N	1	\N
80	1	2020-11-28	20.00	22.00	f	\N	1	\N
80	1	2020-11-28	22.00	23.00	f	\N	1	\N
216	1	2020-11-28	6.00	8.00	f	\N	1	\N
216	1	2020-11-28	8.00	10.00	f	\N	1	\N
216	1	2020-11-28	10.00	12.00	f	\N	1	\N
216	1	2020-11-28	12.00	14.00	f	\N	1	\N
216	1	2020-11-28	14.00	16.00	f	\N	1	\N
216	1	2020-11-28	16.00	18.00	f	\N	1	\N
216	1	2020-11-28	18.00	20.00	f	\N	1	\N
216	1	2020-11-28	20.00	22.00	f	\N	1	\N
216	1	2020-11-28	22.00	23.00	f	\N	1	\N
191	1	2020-11-28	6.00	8.00	f	\N	1	\N
191	1	2020-11-28	8.00	10.00	f	\N	1	\N
191	1	2020-11-28	10.00	12.00	f	\N	1	\N
191	1	2020-11-28	12.00	14.00	f	\N	1	\N
191	1	2020-11-28	14.00	16.00	f	\N	1	\N
191	1	2020-11-28	16.00	18.00	f	\N	1	\N
191	1	2020-11-28	18.00	20.00	f	\N	1	\N
191	1	2020-11-28	20.00	22.00	f	\N	1	\N
191	1	2020-11-28	22.00	23.00	f	\N	1	\N
81	1	2020-11-28	6.00	8.00	f	\N	1	\N
81	1	2020-11-28	8.00	10.00	f	\N	1	\N
81	1	2020-11-28	10.00	12.00	f	\N	1	\N
81	1	2020-11-28	12.00	14.00	f	\N	1	\N
81	1	2020-11-28	14.00	16.00	f	\N	1	\N
81	1	2020-11-28	16.00	18.00	f	\N	1	\N
81	1	2020-11-28	18.00	20.00	f	\N	1	\N
81	1	2020-11-28	20.00	22.00	f	\N	1	\N
81	1	2020-11-28	22.00	23.00	f	\N	1	\N
82	1	2020-11-28	6.00	8.00	f	\N	1	\N
82	1	2020-11-28	8.00	10.00	f	\N	1	\N
82	1	2020-11-28	10.00	12.00	f	\N	1	\N
82	1	2020-11-28	12.00	14.00	f	\N	1	\N
82	1	2020-11-28	14.00	16.00	f	\N	1	\N
82	1	2020-11-28	16.00	18.00	f	\N	1	\N
82	1	2020-11-28	18.00	20.00	f	\N	1	\N
82	1	2020-11-28	20.00	22.00	f	\N	1	\N
82	1	2020-11-28	22.00	23.00	f	\N	1	\N
87	1	2020-11-28	6.00	8.00	f	\N	1	\N
87	1	2020-11-28	8.00	10.00	f	\N	1	\N
87	1	2020-11-28	10.00	12.00	f	\N	1	\N
87	1	2020-11-28	12.00	14.00	f	\N	1	\N
87	1	2020-11-28	14.00	16.00	f	\N	1	\N
87	1	2020-11-28	16.00	18.00	f	\N	1	\N
86	1	2020-11-21	12.00	14.00	f	\N	1	\N
86	1	2020-11-21	14.00	16.00	f	\N	1	\N
86	1	2020-11-21	16.00	18.00	f	\N	1	\N
119	2	2020-12-01	10.00	12.00	f	\N	1	\N
119	2	2020-12-01	12.00	14.00	f	\N	1	\N
119	2	2020-12-01	14.00	16.00	f	\N	1	\N
118	2	2020-12-01	10.00	12.00	f	\N	1	\N
118	2	2020-12-01	12.00	14.00	f	\N	1	\N
118	2	2020-12-01	14.00	16.00	f	\N	1	\N
110	2	2020-12-01	10.00	12.00	f	\N	1	\N
110	2	2020-12-01	12.00	14.00	f	\N	1	\N
110	2	2020-12-01	14.00	16.00	f	\N	1	\N
108	2	2020-12-01	10.00	12.00	f	\N	1	\N
108	2	2020-12-01	12.00	14.00	f	\N	1	\N
108	2	2020-12-01	14.00	16.00	f	\N	1	\N
116	2	2020-12-01	10.00	12.00	f	\N	1	\N
116	2	2020-12-01	12.00	14.00	f	\N	1	\N
116	2	2020-12-01	14.00	16.00	f	\N	1	\N
115	2	2020-12-01	10.00	12.00	f	\N	1	\N
115	2	2020-12-01	12.00	14.00	f	\N	1	\N
115	2	2020-12-01	14.00	16.00	f	\N	1	\N
114	2	2020-12-01	10.00	12.00	f	\N	1	\N
114	2	2020-12-01	12.00	14.00	f	\N	1	\N
114	2	2020-12-01	14.00	16.00	f	\N	1	\N
113	2	2020-12-01	10.00	12.00	f	\N	1	\N
113	2	2020-12-01	12.00	14.00	f	\N	1	\N
87	1	2020-11-28	18.00	20.00	f	\N	1	\N
87	1	2020-11-28	20.00	22.00	f	\N	1	\N
87	1	2020-11-28	22.00	23.00	f	\N	1	\N
86	1	2020-11-28	6.00	8.00	f	\N	1	\N
86	1	2020-11-28	8.00	10.00	f	\N	1	\N
86	1	2020-11-28	10.00	12.00	f	\N	1	\N
86	1	2020-11-28	12.00	14.00	f	\N	1	\N
86	1	2020-11-28	14.00	16.00	f	\N	1	\N
86	1	2020-11-28	16.00	18.00	f	\N	1	\N
86	1	2020-11-28	18.00	20.00	f	\N	1	\N
86	1	2020-11-28	20.00	22.00	f	\N	1	\N
86	1	2020-11-28	22.00	23.00	f	\N	1	\N
201	1	2020-11-28	6.00	8.00	f	\N	1	\N
201	1	2020-11-28	8.00	10.00	f	\N	1	\N
201	1	2020-11-28	10.00	12.00	f	\N	1	\N
201	1	2020-11-28	12.00	14.00	f	\N	1	\N
201	1	2020-11-28	14.00	16.00	f	\N	1	\N
113	2	2020-12-01	14.00	16.00	f	\N	1	\N
120	2	2020-12-01	10.00	12.00	f	\N	1	\N
120	2	2020-12-01	12.00	14.00	f	\N	1	\N
120	2	2020-12-01	14.00	16.00	f	\N	1	\N
286	3	2020-12-01	10.00	12.00	f	\N	1	\N
286	3	2020-12-01	12.00	14.00	f	\N	1	\N
286	3	2020-12-01	14.00	16.00	f	\N	1	\N
89	1	2020-12-01	9.00	11.00	f	\N	1	\N
89	1	2020-12-01	11.00	13.00	f	\N	1	\N
89	1	2020-12-01	13.00	15.00	f	\N	1	\N
89	1	2020-12-01	15.00	17.00	f	\N	1	\N
89	1	2020-12-01	17.00	18.00	f	\N	1	\N
300	1	2020-12-01	9.00	11.00	f	\N	1	\N
300	1	2020-12-01	11.00	13.00	f	\N	1	\N
300	1	2020-12-01	13.00	15.00	f	\N	1	\N
300	1	2020-12-01	15.00	17.00	f	\N	1	\N
300	1	2020-12-01	17.00	18.00	f	\N	1	\N
298	1	2020-12-01	9.00	11.00	f	\N	1	\N
298	1	2020-12-01	11.00	13.00	f	\N	1	\N
298	1	2020-12-01	13.00	15.00	f	\N	1	\N
298	1	2020-12-01	15.00	17.00	f	\N	1	\N
298	1	2020-12-01	17.00	18.00	f	\N	1	\N
95	1	2020-12-01	9.00	11.00	f	\N	1	\N
95	1	2020-12-01	11.00	13.00	f	\N	1	\N
95	1	2020-12-01	13.00	15.00	f	\N	1	\N
95	1	2020-12-01	15.00	17.00	f	\N	1	\N
95	1	2020-12-01	17.00	18.00	f	\N	1	\N
90	1	2020-12-01	9.00	11.00	f	\N	1	\N
90	1	2020-12-01	11.00	13.00	f	\N	1	\N
90	1	2020-12-01	13.00	15.00	f	\N	1	\N
201	1	2020-11-28	16.00	18.00	f	\N	1	\N
201	1	2020-11-28	18.00	20.00	f	\N	1	\N
90	1	2020-12-01	15.00	17.00	f	\N	1	\N
90	1	2020-12-01	17.00	18.00	f	\N	1	\N
94	1	2020-12-01	9.00	11.00	f	\N	1	\N
94	1	2020-12-01	11.00	13.00	f	\N	1	\N
94	1	2020-12-01	13.00	15.00	f	\N	1	\N
94	1	2020-12-01	15.00	17.00	f	\N	1	\N
94	1	2020-12-01	17.00	18.00	f	\N	1	\N
92	1	2020-12-01	9.00	11.00	f	\N	1	\N
86	1	2020-11-21	18.00	20.00	f	\N	1	\N
86	1	2020-11-21	20.00	22.00	f	\N	1	\N
201	1	2020-11-28	20.00	22.00	f	\N	1	\N
201	1	2020-11-28	22.00	23.00	f	\N	1	\N
83	1	2020-11-28	6.00	8.00	f	\N	1	\N
83	1	2020-11-28	8.00	10.00	f	\N	1	\N
83	1	2020-11-28	10.00	12.00	f	\N	1	\N
83	1	2020-11-28	12.00	14.00	f	\N	1	\N
83	1	2020-11-28	14.00	16.00	f	\N	1	\N
83	1	2020-11-28	16.00	18.00	f	\N	1	\N
83	1	2020-11-28	18.00	20.00	f	\N	1	\N
86	1	2020-11-21	22.00	23.00	f	\N	1	\N
201	1	2020-11-21	6.00	8.00	f	\N	1	\N
92	1	2020-12-01	11.00	13.00	f	\N	1	\N
92	1	2020-12-01	13.00	15.00	f	\N	1	\N
92	1	2020-12-01	15.00	17.00	f	\N	1	\N
92	1	2020-12-01	17.00	18.00	f	\N	1	\N
93	1	2020-12-01	9.00	11.00	f	\N	1	\N
93	1	2020-12-01	11.00	13.00	f	\N	1	\N
93	1	2020-12-01	13.00	15.00	f	\N	1	\N
93	1	2020-12-01	15.00	17.00	f	\N	1	\N
93	1	2020-12-01	17.00	18.00	f	\N	1	\N
96	1	2020-12-01	9.00	11.00	f	\N	1	\N
96	1	2020-12-01	11.00	13.00	f	\N	1	\N
96	1	2020-12-01	13.00	15.00	f	\N	1	\N
96	1	2020-12-01	15.00	17.00	f	\N	1	\N
96	1	2020-12-01	17.00	18.00	f	\N	1	\N
91	1	2020-12-01	9.00	11.00	f	\N	1	\N
91	1	2020-12-01	11.00	13.00	f	\N	1	\N
91	1	2020-12-01	13.00	15.00	f	\N	1	\N
91	1	2020-12-01	15.00	17.00	f	\N	1	\N
91	1	2020-12-01	17.00	18.00	f	\N	1	\N
301	1	2020-12-01	9.00	11.00	f	\N	1	\N
301	1	2020-12-01	11.00	13.00	f	\N	1	\N
301	1	2020-12-01	13.00	15.00	f	\N	1	\N
301	1	2020-12-01	15.00	17.00	f	\N	1	\N
301	1	2020-12-01	17.00	18.00	f	\N	1	\N
299	1	2020-12-01	9.00	11.00	f	\N	1	\N
299	1	2020-12-01	11.00	13.00	f	\N	1	\N
299	1	2020-12-01	13.00	15.00	f	\N	1	\N
299	1	2020-12-01	15.00	17.00	f	\N	1	\N
299	1	2020-12-01	17.00	18.00	f	\N	1	\N
176	2	2020-12-01	9.00	11.00	f	\N	1	\N
176	2	2020-12-01	11.00	13.00	f	\N	1	\N
176	2	2020-12-01	13.00	15.00	f	\N	1	\N
176	2	2020-12-01	15.00	17.00	f	\N	1	\N
176	2	2020-12-01	17.00	18.00	f	\N	1	\N
175	2	2020-12-01	9.00	11.00	f	\N	1	\N
175	2	2020-12-01	11.00	13.00	f	\N	1	\N
175	2	2020-12-01	13.00	15.00	f	\N	1	\N
175	2	2020-12-01	15.00	17.00	f	\N	1	\N
175	2	2020-12-01	17.00	18.00	f	\N	1	\N
174	2	2020-12-01	9.00	11.00	f	\N	1	\N
174	2	2020-12-01	11.00	13.00	f	\N	1	\N
174	2	2020-12-01	13.00	15.00	f	\N	1	\N
174	2	2020-12-01	15.00	17.00	f	\N	1	\N
174	2	2020-12-01	17.00	18.00	f	\N	1	\N
179	2	2020-12-01	9.00	11.00	f	\N	1	\N
179	2	2020-12-01	11.00	13.00	f	\N	1	\N
179	2	2020-12-01	13.00	15.00	f	\N	1	\N
179	2	2020-12-01	15.00	17.00	f	\N	1	\N
179	2	2020-12-01	17.00	18.00	f	\N	1	\N
178	2	2020-12-01	9.00	11.00	f	\N	1	\N
178	2	2020-12-01	11.00	13.00	f	\N	1	\N
178	2	2020-12-01	13.00	15.00	f	\N	1	\N
178	2	2020-12-01	15.00	17.00	f	\N	1	\N
178	2	2020-12-01	17.00	18.00	f	\N	1	\N
177	2	2020-12-01	9.00	11.00	f	\N	1	\N
177	2	2020-12-01	11.00	13.00	f	\N	1	\N
177	2	2020-12-01	13.00	15.00	f	\N	1	\N
177	2	2020-12-01	15.00	17.00	f	\N	1	\N
177	2	2020-12-01	17.00	18.00	f	\N	1	\N
192	2	2020-12-01	9.00	11.00	f	\N	1	\N
192	2	2020-12-01	11.00	13.00	f	\N	1	\N
192	2	2020-12-01	13.00	15.00	f	\N	1	\N
192	2	2020-12-01	15.00	17.00	f	\N	1	\N
192	2	2020-12-01	17.00	18.00	f	\N	1	\N
193	2	2020-12-01	9.00	11.00	f	\N	1	\N
193	2	2020-12-01	11.00	13.00	f	\N	1	\N
193	2	2020-12-01	13.00	15.00	f	\N	1	\N
193	2	2020-12-01	15.00	17.00	f	\N	1	\N
193	2	2020-12-01	17.00	18.00	f	\N	1	\N
302	3	2020-12-01	9.00	11.00	f	\N	1	\N
302	3	2020-12-01	11.00	13.00	f	\N	1	\N
302	3	2020-12-01	13.00	15.00	f	\N	1	\N
302	3	2020-12-01	15.00	17.00	f	\N	1	\N
302	3	2020-12-01	17.00	18.00	f	\N	1	\N
305	3	2020-12-01	9.00	11.00	f	\N	1	\N
305	3	2020-12-01	11.00	13.00	f	\N	1	\N
305	3	2020-12-01	13.00	15.00	f	\N	1	\N
305	3	2020-12-01	15.00	17.00	f	\N	1	\N
305	3	2020-12-01	17.00	18.00	f	\N	1	\N
314	3	2020-12-01	9.00	11.00	f	\N	1	\N
314	3	2020-12-01	11.00	13.00	f	\N	1	\N
201	1	2020-11-24	8.00	10.00	f	\N	1	\N
314	3	2020-12-01	13.00	15.00	f	\N	1	\N
314	3	2020-12-01	15.00	17.00	f	\N	1	\N
314	3	2020-12-01	17.00	18.00	f	\N	1	\N
306	3	2020-12-01	9.00	11.00	f	\N	1	\N
306	3	2020-12-01	11.00	13.00	f	\N	1	\N
306	3	2020-12-01	13.00	15.00	f	\N	1	\N
306	3	2020-12-01	15.00	17.00	f	\N	1	\N
306	3	2020-12-01	17.00	18.00	f	\N	1	\N
215	1	2020-12-01	6.00	8.00	f	\N	1	\N
215	1	2020-12-01	8.00	10.00	f	\N	1	\N
215	1	2020-12-01	10.00	12.00	f	\N	1	\N
215	1	2020-12-01	12.00	14.00	f	\N	1	\N
215	1	2020-12-01	14.00	16.00	f	\N	1	\N
215	1	2020-12-01	16.00	18.00	f	\N	1	\N
215	1	2020-12-01	18.00	20.00	f	\N	1	\N
215	1	2020-12-01	20.00	22.00	f	\N	1	\N
215	1	2020-12-01	22.00	23.00	f	\N	1	\N
201	1	2020-11-24	10.00	12.00	f	\N	1	\N
231	1	2020-12-01	6.00	8.00	f	\N	1	\N
231	1	2020-12-01	8.00	10.00	f	\N	1	\N
231	1	2020-12-01	10.00	12.00	f	\N	1	\N
231	1	2020-12-01	12.00	14.00	f	\N	1	\N
231	1	2020-12-01	14.00	16.00	f	\N	1	\N
231	1	2020-12-01	16.00	18.00	f	\N	1	\N
231	1	2020-12-01	18.00	20.00	f	\N	1	\N
231	1	2020-12-01	20.00	22.00	f	\N	1	\N
231	1	2020-12-01	22.00	23.00	f	\N	1	\N
88	1	2020-12-01	6.00	8.00	f	\N	1	\N
88	1	2020-12-01	8.00	10.00	f	\N	1	\N
88	1	2020-12-01	10.00	12.00	f	\N	1	\N
88	1	2020-12-01	12.00	14.00	f	\N	1	\N
88	1	2020-12-01	14.00	16.00	f	\N	1	\N
88	1	2020-12-01	16.00	18.00	f	\N	1	\N
88	1	2020-12-01	18.00	20.00	f	\N	1	\N
88	1	2020-12-01	20.00	22.00	f	\N	1	\N
88	1	2020-12-01	22.00	23.00	f	\N	1	\N
80	1	2020-12-01	6.00	8.00	f	\N	1	\N
80	1	2020-12-01	8.00	10.00	f	\N	1	\N
80	1	2020-12-01	10.00	12.00	f	\N	1	\N
80	1	2020-12-01	12.00	14.00	f	\N	1	\N
80	1	2020-12-01	14.00	16.00	f	\N	1	\N
80	1	2020-12-01	16.00	18.00	f	\N	1	\N
80	1	2020-12-01	18.00	20.00	f	\N	1	\N
80	1	2020-12-01	20.00	22.00	f	\N	1	\N
80	1	2020-12-01	22.00	23.00	f	\N	1	\N
216	1	2020-12-01	6.00	8.00	f	\N	1	\N
216	1	2020-12-01	8.00	10.00	f	\N	1	\N
216	1	2020-12-01	10.00	12.00	f	\N	1	\N
216	1	2020-12-01	12.00	14.00	f	\N	1	\N
216	1	2020-12-01	14.00	16.00	f	\N	1	\N
216	1	2020-12-01	16.00	18.00	f	\N	1	\N
216	1	2020-12-01	18.00	20.00	f	\N	1	\N
216	1	2020-12-01	20.00	22.00	f	\N	1	\N
216	1	2020-12-01	22.00	23.00	f	\N	1	\N
191	1	2020-12-01	6.00	8.00	f	\N	1	\N
191	1	2020-12-01	8.00	10.00	f	\N	1	\N
191	1	2020-12-01	10.00	12.00	f	\N	1	\N
191	1	2020-12-01	12.00	14.00	f	\N	1	\N
191	1	2020-12-01	14.00	16.00	f	\N	1	\N
191	1	2020-12-01	16.00	18.00	f	\N	1	\N
191	1	2020-12-01	18.00	20.00	f	\N	1	\N
191	1	2020-12-01	20.00	22.00	f	\N	1	\N
191	1	2020-12-01	22.00	23.00	f	\N	1	\N
81	1	2020-12-01	6.00	8.00	f	\N	1	\N
81	1	2020-12-01	8.00	10.00	f	\N	1	\N
81	1	2020-12-01	10.00	12.00	f	\N	1	\N
81	1	2020-12-01	12.00	14.00	f	\N	1	\N
81	1	2020-12-01	14.00	16.00	f	\N	1	\N
81	1	2020-12-01	16.00	18.00	f	\N	1	\N
81	1	2020-12-01	18.00	20.00	f	\N	1	\N
81	1	2020-12-01	20.00	22.00	f	\N	1	\N
81	1	2020-12-01	22.00	23.00	f	\N	1	\N
82	1	2020-12-01	6.00	8.00	f	\N	1	\N
82	1	2020-12-01	8.00	10.00	f	\N	1	\N
82	1	2020-12-01	10.00	12.00	f	\N	1	\N
82	1	2020-12-01	12.00	14.00	f	\N	1	\N
82	1	2020-12-01	14.00	16.00	f	\N	1	\N
82	1	2020-12-01	16.00	18.00	f	\N	1	\N
82	1	2020-12-01	18.00	20.00	f	\N	1	\N
82	1	2020-12-01	20.00	22.00	f	\N	1	\N
82	1	2020-12-01	22.00	23.00	f	\N	1	\N
87	1	2020-12-01	6.00	8.00	f	\N	1	\N
87	1	2020-12-01	8.00	10.00	f	\N	1	\N
87	1	2020-12-01	10.00	12.00	f	\N	1	\N
87	1	2020-12-01	12.00	14.00	f	\N	1	\N
87	1	2020-12-01	14.00	16.00	f	\N	1	\N
87	1	2020-12-01	16.00	18.00	f	\N	1	\N
87	1	2020-12-01	18.00	20.00	f	\N	1	\N
87	1	2020-12-01	20.00	22.00	f	\N	1	\N
87	1	2020-12-01	22.00	23.00	f	\N	1	\N
86	1	2020-12-01	6.00	8.00	f	\N	1	\N
86	1	2020-12-01	8.00	10.00	f	\N	1	\N
86	1	2020-12-01	10.00	12.00	f	\N	1	\N
86	1	2020-12-01	12.00	14.00	f	\N	1	\N
86	1	2020-12-01	14.00	16.00	f	\N	1	\N
86	1	2020-12-01	16.00	18.00	f	\N	1	\N
86	1	2020-12-01	18.00	20.00	f	\N	1	\N
86	1	2020-12-01	20.00	22.00	f	\N	1	\N
86	1	2020-12-01	22.00	23.00	f	\N	1	\N
201	1	2020-12-01	6.00	8.00	f	\N	1	\N
201	1	2020-12-01	8.00	10.00	f	\N	1	\N
201	1	2020-12-01	10.00	12.00	f	\N	1	\N
201	1	2020-12-01	12.00	14.00	f	\N	1	\N
201	1	2020-12-01	14.00	16.00	f	\N	1	\N
201	1	2020-12-01	16.00	18.00	f	\N	1	\N
201	1	2020-12-01	18.00	20.00	f	\N	1	\N
201	1	2020-12-01	20.00	22.00	f	\N	1	\N
201	1	2020-12-01	22.00	23.00	f	\N	1	\N
83	1	2020-12-01	6.00	8.00	f	\N	1	\N
83	1	2020-12-01	8.00	10.00	f	\N	1	\N
83	1	2020-12-01	10.00	12.00	f	\N	1	\N
83	1	2020-12-01	12.00	14.00	f	\N	1	\N
83	1	2020-12-01	14.00	16.00	f	\N	1	\N
83	1	2020-12-01	16.00	18.00	f	\N	1	\N
83	1	2020-12-01	18.00	20.00	f	\N	1	\N
83	1	2020-12-01	20.00	22.00	f	\N	1	\N
201	1	2020-11-24	12.00	14.00	f	\N	1	\N
201	1	2020-11-24	14.00	16.00	f	\N	1	\N
83	1	2020-12-01	22.00	23.00	f	\N	1	\N
84	1	2020-12-01	6.00	8.00	f	\N	1	\N
84	1	2020-12-01	8.00	10.00	f	\N	1	\N
84	1	2020-12-01	10.00	12.00	f	\N	1	\N
84	1	2020-12-01	12.00	14.00	f	\N	1	\N
84	1	2020-12-01	14.00	16.00	f	\N	1	\N
84	1	2020-12-01	16.00	18.00	f	\N	1	\N
84	1	2020-12-01	18.00	20.00	f	\N	1	\N
84	1	2020-12-01	20.00	22.00	f	\N	1	\N
84	1	2020-12-01	22.00	23.00	f	\N	1	\N
194	1	2020-12-01	6.00	8.00	f	\N	1	\N
194	1	2020-12-01	8.00	10.00	f	\N	1	\N
194	1	2020-12-01	10.00	12.00	f	\N	1	\N
194	1	2020-12-01	12.00	14.00	f	\N	1	\N
194	1	2020-12-01	14.00	16.00	f	\N	1	\N
194	1	2020-12-01	16.00	18.00	f	\N	1	\N
194	1	2020-12-01	18.00	20.00	f	\N	1	\N
194	1	2020-12-01	20.00	22.00	f	\N	1	\N
194	1	2020-12-01	22.00	23.00	f	\N	1	\N
85	1	2020-12-01	6.00	8.00	f	\N	1	\N
85	1	2020-12-01	8.00	10.00	f	\N	1	\N
85	1	2020-12-01	10.00	12.00	f	\N	1	\N
85	1	2020-12-01	12.00	14.00	f	\N	1	\N
85	1	2020-12-01	14.00	16.00	f	\N	1	\N
85	1	2020-12-01	16.00	18.00	f	\N	1	\N
85	1	2020-12-01	18.00	20.00	f	\N	1	\N
85	1	2020-12-01	20.00	22.00	f	\N	1	\N
85	1	2020-12-01	22.00	23.00	f	\N	1	\N
303	1	2020-12-01	6.00	8.00	f	\N	1	\N
303	1	2020-12-01	8.00	10.00	f	\N	1	\N
303	1	2020-12-01	10.00	12.00	f	\N	1	\N
303	1	2020-12-01	12.00	14.00	f	\N	1	\N
303	1	2020-12-01	14.00	16.00	f	\N	1	\N
303	1	2020-12-01	16.00	18.00	f	\N	1	\N
303	1	2020-12-01	18.00	20.00	f	\N	1	\N
303	1	2020-12-01	20.00	22.00	f	\N	1	\N
303	1	2020-12-01	22.00	23.00	f	\N	1	\N
304	1	2020-12-01	6.00	8.00	f	\N	1	\N
304	1	2020-12-01	8.00	10.00	f	\N	1	\N
304	1	2020-12-01	10.00	12.00	f	\N	1	\N
304	1	2020-12-01	12.00	14.00	f	\N	1	\N
304	1	2020-12-01	14.00	16.00	f	\N	1	\N
304	1	2020-12-01	16.00	18.00	f	\N	1	\N
304	1	2020-12-01	18.00	20.00	f	\N	1	\N
304	1	2020-12-01	20.00	22.00	f	\N	1	\N
304	1	2020-12-01	22.00	23.00	f	\N	1	\N
268	2	2020-12-01	6.00	8.00	f	\N	1	\N
268	2	2020-12-01	8.00	10.00	f	\N	1	\N
268	2	2020-12-01	10.00	12.00	f	\N	1	\N
268	2	2020-12-01	12.00	14.00	f	\N	1	\N
268	2	2020-12-01	14.00	16.00	f	\N	1	\N
268	2	2020-12-01	16.00	18.00	f	\N	1	\N
268	2	2020-12-01	18.00	20.00	f	\N	1	\N
268	2	2020-12-01	20.00	22.00	f	\N	1	\N
268	2	2020-12-01	22.00	23.00	f	\N	1	\N
313	3	2020-12-01	10.00	12.00	f	\N	1	\N
313	3	2020-12-01	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-12-01	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-12-01	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-12-01	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-12-01	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-12-01	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-12-01	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-12-01	22.00	23.00	t	1122334455	5	Stängt
103	1	2020-11-18	10.00	12.00	t	8281053194	4	RL
101	1	2020-11-18	10.00	12.00	f	\N	1	\N
309	1	2020-11-18	10.00	12.00	f	\N	1	\N
99	1	2020-11-18	10.00	12.00	t	3821559644	4	Juan Pablo
306	3	2020-11-21	10.00	12.00	t	8468848640	2	Dd
166	1	2020-12-02	10.00	12.00	f	\N	1	\N
166	1	2020-12-02	12.00	14.00	f	\N	1	\N
83	1	2020-11-28	20.00	22.00	f	\N	1	\N
166	1	2020-12-02	14.00	16.00	f	\N	1	\N
166	1	2020-12-02	16.00	18.00	f	\N	1	\N
168	1	2020-12-02	10.00	12.00	f	\N	1	\N
168	1	2020-12-02	12.00	14.00	f	\N	1	\N
168	1	2020-12-02	14.00	16.00	f	\N	1	\N
168	1	2020-12-02	16.00	18.00	f	\N	1	\N
165	1	2020-12-02	10.00	12.00	f	\N	1	\N
165	1	2020-12-02	12.00	14.00	f	\N	1	\N
165	1	2020-12-02	14.00	16.00	f	\N	1	\N
165	1	2020-12-02	16.00	18.00	f	\N	1	\N
167	1	2020-12-02	10.00	12.00	f	\N	1	\N
167	1	2020-12-02	12.00	14.00	f	\N	1	\N
167	1	2020-12-02	14.00	16.00	f	\N	1	\N
167	1	2020-12-02	16.00	18.00	f	\N	1	\N
289	1	2020-12-02	10.00	12.00	f	\N	1	\N
289	1	2020-12-02	12.00	14.00	f	\N	1	\N
289	1	2020-12-02	14.00	16.00	f	\N	1	\N
289	1	2020-12-02	16.00	18.00	f	\N	1	\N
297	2	2020-12-02	10.00	12.00	f	\N	1	\N
297	2	2020-12-02	12.00	14.00	f	\N	1	\N
297	2	2020-12-02	14.00	16.00	f	\N	1	\N
297	2	2020-12-02	16.00	18.00	f	\N	1	\N
285	3	2020-12-02	10.00	12.00	f	\N	1	\N
285	3	2020-12-02	12.00	14.00	f	\N	1	\N
285	3	2020-12-02	14.00	16.00	f	\N	1	\N
285	3	2020-12-02	16.00	18.00	f	\N	1	\N
204	1	2020-12-02	9.00	11.00	f	\N	1	\N
204	1	2020-12-02	11.00	13.00	f	\N	1	\N
204	1	2020-12-02	13.00	15.00	f	\N	1	\N
204	1	2020-12-02	15.00	17.00	f	\N	1	\N
204	1	2020-12-02	17.00	18.00	f	\N	1	\N
203	1	2020-12-02	9.00	11.00	f	\N	1	\N
203	1	2020-12-02	11.00	13.00	f	\N	1	\N
203	1	2020-12-02	13.00	15.00	f	\N	1	\N
203	1	2020-12-02	15.00	17.00	f	\N	1	\N
203	1	2020-12-02	17.00	18.00	f	\N	1	\N
205	1	2020-12-02	9.00	11.00	f	\N	1	\N
205	1	2020-12-02	11.00	13.00	f	\N	1	\N
205	1	2020-12-02	13.00	15.00	f	\N	1	\N
205	1	2020-12-02	15.00	17.00	f	\N	1	\N
205	1	2020-12-02	17.00	18.00	f	\N	1	\N
202	1	2020-12-02	9.00	11.00	f	\N	1	\N
202	1	2020-12-02	11.00	13.00	f	\N	1	\N
202	1	2020-12-02	13.00	15.00	f	\N	1	\N
202	1	2020-12-02	15.00	17.00	f	\N	1	\N
202	1	2020-12-02	17.00	18.00	f	\N	1	\N
214	1	2020-12-02	9.00	11.00	f	\N	1	\N
214	1	2020-12-02	11.00	13.00	f	\N	1	\N
214	1	2020-12-02	13.00	15.00	f	\N	1	\N
214	1	2020-12-02	15.00	17.00	f	\N	1	\N
214	1	2020-12-02	17.00	18.00	f	\N	1	\N
213	1	2020-12-02	9.00	11.00	f	\N	1	\N
213	1	2020-12-02	11.00	13.00	f	\N	1	\N
213	1	2020-12-02	13.00	15.00	f	\N	1	\N
213	1	2020-12-02	15.00	17.00	f	\N	1	\N
213	1	2020-12-02	17.00	18.00	f	\N	1	\N
208	2	2020-12-02	9.00	11.00	f	\N	1	\N
208	2	2020-12-02	11.00	13.00	f	\N	1	\N
208	2	2020-12-02	13.00	15.00	f	\N	1	\N
208	2	2020-12-02	15.00	17.00	f	\N	1	\N
208	2	2020-12-02	17.00	18.00	f	\N	1	\N
244	2	2020-12-02	9.00	11.00	f	\N	1	\N
244	2	2020-12-02	11.00	13.00	f	\N	1	\N
244	2	2020-12-02	13.00	15.00	f	\N	1	\N
244	2	2020-12-02	15.00	17.00	f	\N	1	\N
244	2	2020-12-02	17.00	18.00	f	\N	1	\N
209	2	2020-12-02	9.00	11.00	f	\N	1	\N
209	2	2020-12-02	11.00	13.00	f	\N	1	\N
209	2	2020-12-02	13.00	15.00	f	\N	1	\N
209	2	2020-12-02	15.00	17.00	f	\N	1	\N
209	2	2020-12-02	17.00	18.00	f	\N	1	\N
245	2	2020-12-02	9.00	11.00	f	\N	1	\N
245	2	2020-12-02	11.00	13.00	f	\N	1	\N
245	2	2020-12-02	13.00	15.00	f	\N	1	\N
245	2	2020-12-02	15.00	17.00	f	\N	1	\N
245	2	2020-12-02	17.00	18.00	f	\N	1	\N
247	2	2020-12-02	9.00	11.00	f	\N	1	\N
247	2	2020-12-02	11.00	13.00	f	\N	1	\N
247	2	2020-12-02	13.00	15.00	f	\N	1	\N
247	2	2020-12-02	15.00	17.00	f	\N	1	\N
247	2	2020-12-02	17.00	18.00	f	\N	1	\N
207	2	2020-12-02	9.00	11.00	f	\N	1	\N
207	2	2020-12-02	11.00	13.00	f	\N	1	\N
207	2	2020-12-02	13.00	15.00	f	\N	1	\N
207	2	2020-12-02	15.00	17.00	f	\N	1	\N
207	2	2020-12-02	17.00	18.00	f	\N	1	\N
212	2	2020-12-02	9.00	11.00	f	\N	1	\N
212	2	2020-12-02	11.00	13.00	f	\N	1	\N
212	2	2020-12-02	13.00	15.00	f	\N	1	\N
212	2	2020-12-02	15.00	17.00	f	\N	1	\N
212	2	2020-12-02	17.00	18.00	f	\N	1	\N
217	2	2020-12-02	9.00	11.00	f	\N	1	\N
217	2	2020-12-02	11.00	13.00	f	\N	1	\N
217	2	2020-12-02	13.00	15.00	f	\N	1	\N
217	2	2020-12-02	15.00	17.00	f	\N	1	\N
217	2	2020-12-02	17.00	18.00	f	\N	1	\N
246	2	2020-12-02	9.00	11.00	f	\N	1	\N
246	2	2020-12-02	11.00	13.00	f	\N	1	\N
246	2	2020-12-02	13.00	15.00	f	\N	1	\N
201	1	2020-11-21	8.00	10.00	f	\N	1	\N
201	1	2020-11-21	10.00	12.00	f	\N	1	\N
83	1	2020-11-28	22.00	23.00	f	\N	1	\N
84	1	2020-11-28	6.00	8.00	f	\N	1	\N
84	1	2020-11-28	8.00	10.00	f	\N	1	\N
84	1	2020-11-28	10.00	12.00	f	\N	1	\N
84	1	2020-11-28	12.00	14.00	f	\N	1	\N
84	1	2020-11-28	14.00	16.00	f	\N	1	\N
84	1	2020-11-28	16.00	18.00	f	\N	1	\N
84	1	2020-11-28	18.00	20.00	f	\N	1	\N
84	1	2020-11-28	20.00	22.00	f	\N	1	\N
84	1	2020-11-28	22.00	23.00	f	\N	1	\N
194	1	2020-11-28	6.00	8.00	f	\N	1	\N
194	1	2020-11-28	8.00	10.00	f	\N	1	\N
194	1	2020-11-28	10.00	12.00	f	\N	1	\N
194	1	2020-11-28	12.00	14.00	f	\N	1	\N
194	1	2020-11-28	14.00	16.00	f	\N	1	\N
194	1	2020-11-28	16.00	18.00	f	\N	1	\N
201	1	2020-11-21	12.00	14.00	f	\N	1	\N
201	1	2020-11-21	14.00	16.00	f	\N	1	\N
201	1	2020-11-21	16.00	18.00	f	\N	1	\N
201	1	2020-11-21	18.00	20.00	f	\N	1	\N
201	1	2020-11-21	20.00	22.00	f	\N	1	\N
201	1	2020-11-21	22.00	23.00	f	\N	1	\N
83	1	2020-11-21	6.00	8.00	f	\N	1	\N
194	1	2020-11-28	18.00	20.00	f	\N	1	\N
83	1	2020-11-21	8.00	10.00	f	\N	1	\N
83	1	2020-11-21	10.00	12.00	f	\N	1	\N
83	1	2020-11-21	12.00	14.00	f	\N	1	\N
194	1	2020-11-28	20.00	22.00	f	\N	1	\N
194	1	2020-11-28	22.00	23.00	f	\N	1	\N
83	1	2020-11-21	14.00	16.00	f	\N	1	\N
83	1	2020-11-21	16.00	18.00	f	\N	1	\N
83	1	2020-11-21	18.00	20.00	f	\N	1	\N
83	1	2020-11-21	20.00	22.00	f	\N	1	\N
83	1	2020-11-21	22.00	23.00	f	\N	1	\N
85	1	2020-11-28	6.00	8.00	f	\N	1	\N
85	1	2020-11-28	8.00	10.00	f	\N	1	\N
85	1	2020-11-28	10.00	12.00	f	\N	1	\N
84	1	2020-11-21	6.00	8.00	f	\N	1	\N
84	1	2020-11-21	8.00	10.00	f	\N	1	\N
84	1	2020-11-21	10.00	12.00	f	\N	1	\N
84	1	2020-11-21	12.00	14.00	f	\N	1	\N
84	1	2020-11-21	14.00	16.00	f	\N	1	\N
84	1	2020-11-21	16.00	18.00	f	\N	1	\N
84	1	2020-11-21	18.00	20.00	f	\N	1	\N
84	1	2020-11-21	20.00	22.00	f	\N	1	\N
84	1	2020-11-21	22.00	23.00	f	\N	1	\N
194	1	2020-11-21	6.00	8.00	f	\N	1	\N
194	1	2020-11-21	8.00	10.00	f	\N	1	\N
194	1	2020-11-21	10.00	12.00	f	\N	1	\N
194	1	2020-11-21	12.00	14.00	f	\N	1	\N
194	1	2020-11-21	14.00	16.00	f	\N	1	\N
194	1	2020-11-21	16.00	18.00	f	\N	1	\N
194	1	2020-11-21	18.00	20.00	f	\N	1	\N
194	1	2020-11-21	20.00	22.00	f	\N	1	\N
194	1	2020-11-21	22.00	23.00	f	\N	1	\N
85	1	2020-11-28	12.00	14.00	f	\N	1	\N
85	1	2020-11-28	14.00	16.00	f	\N	1	\N
85	1	2020-11-28	16.00	18.00	f	\N	1	\N
85	1	2020-11-28	18.00	20.00	f	\N	1	\N
99	1	2020-11-18	12.00	14.00	t	3821559644	4	Juan Pablo
103	1	2020-11-18	12.00	14.00	t	8281053194	4	RL
101	1	2020-11-18	12.00	14.00	f	\N	1	\N
246	2	2020-12-02	15.00	17.00	f	\N	1	\N
246	2	2020-12-02	17.00	18.00	f	\N	1	\N
210	2	2020-12-02	9.00	11.00	f	\N	1	\N
210	2	2020-12-02	11.00	13.00	f	\N	1	\N
210	2	2020-12-02	13.00	15.00	f	\N	1	\N
210	2	2020-12-02	15.00	17.00	f	\N	1	\N
210	2	2020-12-02	17.00	18.00	f	\N	1	\N
206	2	2020-12-02	9.00	11.00	f	\N	1	\N
206	2	2020-12-02	11.00	13.00	f	\N	1	\N
206	2	2020-12-02	13.00	15.00	f	\N	1	\N
206	2	2020-12-02	15.00	17.00	f	\N	1	\N
206	2	2020-12-02	17.00	18.00	f	\N	1	\N
288	3	2020-12-02	9.00	11.00	f	\N	1	\N
288	3	2020-12-02	11.00	13.00	f	\N	1	\N
288	3	2020-12-02	13.00	15.00	f	\N	1	\N
288	3	2020-12-02	15.00	17.00	f	\N	1	\N
288	3	2020-12-02	17.00	18.00	f	\N	1	\N
287	3	2020-12-02	9.00	11.00	f	\N	1	\N
287	3	2020-12-02	11.00	13.00	f	\N	1	\N
287	3	2020-12-02	13.00	15.00	f	\N	1	\N
287	3	2020-12-02	15.00	17.00	f	\N	1	\N
287	3	2020-12-02	17.00	18.00	f	\N	1	\N
196	1	2020-12-02	9.00	11.00	f	\N	1	\N
196	1	2020-12-02	11.00	13.00	f	\N	1	\N
196	1	2020-12-02	13.00	15.00	f	\N	1	\N
196	1	2020-12-02	15.00	17.00	f	\N	1	\N
196	1	2020-12-02	17.00	18.00	f	\N	1	\N
97	1	2020-12-02	9.00	11.00	f	\N	1	\N
97	1	2020-12-02	11.00	13.00	f	\N	1	\N
97	1	2020-12-02	13.00	15.00	f	\N	1	\N
97	1	2020-12-02	15.00	17.00	f	\N	1	\N
97	1	2020-12-02	17.00	18.00	f	\N	1	\N
197	1	2020-12-02	9.00	11.00	f	\N	1	\N
197	1	2020-12-02	11.00	13.00	f	\N	1	\N
197	1	2020-12-02	13.00	15.00	f	\N	1	\N
197	1	2020-12-02	15.00	17.00	f	\N	1	\N
197	1	2020-12-02	17.00	18.00	f	\N	1	\N
135	1	2020-12-02	9.00	11.00	f	\N	1	\N
135	1	2020-12-02	11.00	13.00	f	\N	1	\N
135	1	2020-12-02	13.00	15.00	f	\N	1	\N
135	1	2020-12-02	15.00	17.00	f	\N	1	\N
135	1	2020-12-02	17.00	18.00	f	\N	1	\N
136	1	2020-12-02	9.00	11.00	f	\N	1	\N
136	1	2020-12-02	11.00	13.00	f	\N	1	\N
287	3	2020-11-19	9.00	11.00	t	5081379736	4	Neck
85	1	2020-11-21	6.00	8.00	f	\N	1	\N
85	1	2020-11-21	8.00	10.00	f	\N	1	\N
85	1	2020-11-28	20.00	22.00	f	\N	1	\N
85	1	2020-11-28	22.00	23.00	f	\N	1	\N
303	1	2020-11-28	6.00	8.00	f	\N	1	\N
303	1	2020-11-28	8.00	10.00	f	\N	1	\N
303	1	2020-11-28	10.00	12.00	f	\N	1	\N
303	1	2020-11-28	12.00	14.00	f	\N	1	\N
303	1	2020-11-28	14.00	16.00	f	\N	1	\N
303	1	2020-11-28	16.00	18.00	f	\N	1	\N
303	1	2020-11-28	18.00	20.00	f	\N	1	\N
303	1	2020-11-28	20.00	22.00	f	\N	1	\N
303	1	2020-11-28	22.00	23.00	f	\N	1	\N
304	1	2020-11-28	6.00	8.00	f	\N	1	\N
304	1	2020-11-28	8.00	10.00	f	\N	1	\N
85	1	2020-11-21	10.00	12.00	f	\N	1	\N
85	1	2020-11-21	12.00	14.00	f	\N	1	\N
85	1	2020-11-21	14.00	16.00	f	\N	1	\N
85	1	2020-11-21	16.00	18.00	f	\N	1	\N
85	1	2020-11-21	18.00	20.00	f	\N	1	\N
85	1	2020-11-21	20.00	22.00	f	\N	1	\N
85	1	2020-11-21	22.00	23.00	f	\N	1	\N
303	1	2020-11-21	6.00	8.00	f	\N	1	\N
303	1	2020-11-21	8.00	10.00	f	\N	1	\N
303	1	2020-11-21	10.00	12.00	f	\N	1	\N
303	1	2020-11-21	12.00	14.00	f	\N	1	\N
303	1	2020-11-21	14.00	16.00	f	\N	1	\N
303	1	2020-11-21	16.00	18.00	f	\N	1	\N
303	1	2020-11-21	18.00	20.00	f	\N	1	\N
303	1	2020-11-21	20.00	22.00	f	\N	1	\N
303	1	2020-11-21	22.00	23.00	f	\N	1	\N
304	1	2020-11-21	6.00	8.00	f	\N	1	\N
304	1	2020-11-21	8.00	10.00	f	\N	1	\N
136	1	2020-12-02	13.00	15.00	f	\N	1	\N
136	1	2020-12-02	15.00	17.00	f	\N	1	\N
304	1	2020-11-21	10.00	12.00	f	\N	1	\N
136	1	2020-12-02	17.00	18.00	f	\N	1	\N
304	1	2020-11-28	10.00	12.00	f	\N	1	\N
137	1	2020-12-02	9.00	11.00	f	\N	1	\N
137	1	2020-12-02	11.00	13.00	f	\N	1	\N
137	1	2020-12-02	13.00	15.00	f	\N	1	\N
137	1	2020-12-02	15.00	17.00	f	\N	1	\N
137	1	2020-12-02	17.00	18.00	f	\N	1	\N
195	1	2020-12-02	9.00	11.00	f	\N	1	\N
195	1	2020-12-02	11.00	13.00	f	\N	1	\N
195	1	2020-12-02	13.00	15.00	f	\N	1	\N
195	1	2020-12-02	15.00	17.00	f	\N	1	\N
195	1	2020-12-02	17.00	18.00	f	\N	1	\N
138	1	2020-12-02	9.00	11.00	f	\N	1	\N
138	1	2020-12-02	11.00	13.00	f	\N	1	\N
138	1	2020-12-02	13.00	15.00	f	\N	1	\N
138	1	2020-12-02	15.00	17.00	f	\N	1	\N
138	1	2020-12-02	17.00	18.00	f	\N	1	\N
139	1	2020-12-02	9.00	11.00	f	\N	1	\N
139	1	2020-12-02	11.00	13.00	f	\N	1	\N
139	1	2020-12-02	13.00	15.00	f	\N	1	\N
139	1	2020-12-02	15.00	17.00	f	\N	1	\N
139	1	2020-12-02	17.00	18.00	f	\N	1	\N
140	1	2020-12-02	9.00	11.00	f	\N	1	\N
140	1	2020-12-02	11.00	13.00	f	\N	1	\N
140	1	2020-12-02	13.00	15.00	f	\N	1	\N
140	1	2020-12-02	15.00	17.00	f	\N	1	\N
140	1	2020-12-02	17.00	18.00	f	\N	1	\N
141	1	2020-12-02	9.00	11.00	f	\N	1	\N
141	1	2020-12-02	11.00	13.00	f	\N	1	\N
141	1	2020-12-02	13.00	15.00	f	\N	1	\N
141	1	2020-12-02	15.00	17.00	f	\N	1	\N
141	1	2020-12-02	17.00	18.00	f	\N	1	\N
188	2	2020-12-02	9.00	11.00	f	\N	1	\N
188	2	2020-12-02	11.00	13.00	f	\N	1	\N
188	2	2020-12-02	13.00	15.00	f	\N	1	\N
188	2	2020-12-02	15.00	17.00	f	\N	1	\N
188	2	2020-12-02	17.00	18.00	f	\N	1	\N
248	2	2020-12-02	9.00	11.00	f	\N	1	\N
248	2	2020-12-02	11.00	13.00	f	\N	1	\N
248	2	2020-12-02	13.00	15.00	f	\N	1	\N
248	2	2020-12-02	15.00	17.00	f	\N	1	\N
248	2	2020-12-02	17.00	18.00	f	\N	1	\N
182	2	2020-12-02	9.00	11.00	f	\N	1	\N
182	2	2020-12-02	11.00	13.00	f	\N	1	\N
182	2	2020-12-02	13.00	15.00	f	\N	1	\N
182	2	2020-12-02	15.00	17.00	f	\N	1	\N
182	2	2020-12-02	17.00	18.00	f	\N	1	\N
183	2	2020-12-02	9.00	11.00	f	\N	1	\N
183	2	2020-12-02	11.00	13.00	f	\N	1	\N
183	2	2020-12-02	13.00	15.00	f	\N	1	\N
183	2	2020-12-02	15.00	17.00	f	\N	1	\N
183	2	2020-12-02	17.00	18.00	f	\N	1	\N
181	2	2020-12-02	9.00	11.00	f	\N	1	\N
181	2	2020-12-02	11.00	13.00	f	\N	1	\N
181	2	2020-12-02	13.00	15.00	f	\N	1	\N
181	2	2020-12-02	15.00	17.00	f	\N	1	\N
181	2	2020-12-02	17.00	18.00	f	\N	1	\N
187	2	2020-12-02	9.00	11.00	f	\N	1	\N
187	2	2020-12-02	11.00	13.00	f	\N	1	\N
187	2	2020-12-02	13.00	15.00	f	\N	1	\N
187	2	2020-12-02	15.00	17.00	f	\N	1	\N
187	2	2020-12-02	17.00	18.00	f	\N	1	\N
184	2	2020-12-02	9.00	11.00	f	\N	1	\N
184	2	2020-12-02	11.00	13.00	f	\N	1	\N
184	2	2020-12-02	13.00	15.00	f	\N	1	\N
184	2	2020-12-02	15.00	17.00	f	\N	1	\N
184	2	2020-12-02	17.00	18.00	f	\N	1	\N
249	2	2020-12-02	9.00	11.00	f	\N	1	\N
249	2	2020-12-02	11.00	13.00	f	\N	1	\N
249	2	2020-12-02	13.00	15.00	f	\N	1	\N
249	2	2020-12-02	15.00	17.00	f	\N	1	\N
249	2	2020-12-02	17.00	18.00	f	\N	1	\N
186	2	2020-12-02	9.00	11.00	f	\N	1	\N
186	2	2020-12-02	11.00	13.00	f	\N	1	\N
186	2	2020-12-02	13.00	15.00	f	\N	1	\N
186	2	2020-12-02	15.00	17.00	f	\N	1	\N
186	2	2020-12-02	17.00	18.00	f	\N	1	\N
180	2	2020-12-02	9.00	11.00	f	\N	1	\N
180	2	2020-12-02	11.00	13.00	f	\N	1	\N
180	2	2020-12-02	13.00	15.00	f	\N	1	\N
180	2	2020-12-02	15.00	17.00	f	\N	1	\N
180	2	2020-12-02	17.00	18.00	f	\N	1	\N
185	2	2020-12-02	9.00	11.00	f	\N	1	\N
185	2	2020-12-02	11.00	13.00	f	\N	1	\N
185	2	2020-12-02	13.00	15.00	f	\N	1	\N
185	2	2020-12-02	15.00	17.00	f	\N	1	\N
185	2	2020-12-02	17.00	18.00	f	\N	1	\N
283	3	2020-12-02	9.00	11.00	f	\N	1	\N
283	3	2020-12-02	11.00	13.00	f	\N	1	\N
283	3	2020-12-02	13.00	15.00	f	\N	1	\N
283	3	2020-12-02	15.00	17.00	f	\N	1	\N
283	3	2020-12-02	17.00	18.00	f	\N	1	\N
284	3	2020-12-02	9.00	11.00	f	\N	1	\N
284	3	2020-12-02	11.00	13.00	f	\N	1	\N
284	3	2020-12-02	13.00	15.00	f	\N	1	\N
284	3	2020-12-02	15.00	17.00	f	\N	1	\N
284	3	2020-12-02	17.00	18.00	f	\N	1	\N
189	1	2020-12-02	10.00	12.00	f	\N	1	\N
189	1	2020-12-02	12.00	14.00	f	\N	1	\N
189	1	2020-12-02	14.00	16.00	f	\N	1	\N
256	1	2020-12-02	10.00	12.00	f	\N	1	\N
256	1	2020-12-02	12.00	14.00	f	\N	1	\N
256	1	2020-12-02	14.00	16.00	f	\N	1	\N
98	1	2020-12-02	10.00	12.00	f	\N	1	\N
98	1	2020-12-02	12.00	14.00	f	\N	1	\N
98	1	2020-12-02	14.00	16.00	f	\N	1	\N
101	1	2020-12-02	10.00	12.00	f	\N	1	\N
304	1	2020-11-21	12.00	14.00	f	\N	1	\N
304	1	2020-11-21	14.00	16.00	f	\N	1	\N
304	1	2020-11-21	16.00	18.00	f	\N	1	\N
304	1	2020-11-21	18.00	20.00	f	\N	1	\N
304	1	2020-11-21	20.00	22.00	f	\N	1	\N
304	1	2020-11-21	22.00	23.00	f	\N	1	\N
268	2	2020-11-21	6.00	8.00	f	\N	1	\N
268	2	2020-11-21	8.00	10.00	f	\N	1	\N
268	2	2020-11-21	10.00	12.00	f	\N	1	\N
268	2	2020-11-21	12.00	14.00	f	\N	1	\N
268	2	2020-11-21	14.00	16.00	f	\N	1	\N
268	2	2020-11-21	16.00	18.00	f	\N	1	\N
268	2	2020-11-21	18.00	20.00	f	\N	1	\N
268	2	2020-11-21	20.00	22.00	f	\N	1	\N
268	2	2020-11-21	22.00	23.00	f	\N	1	\N
201	1	2020-11-24	16.00	18.00	f	\N	1	\N
313	3	2020-11-21	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-21	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-21	10.00	12.00	t	1122334455	5	Stängt
313	3	2020-11-21	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-21	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-21	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-21	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-21	20.00	22.00	t	1122334455	5	Stängt
201	1	2020-11-24	18.00	20.00	f	\N	1	\N
201	1	2020-11-24	20.00	22.00	f	\N	1	\N
201	1	2020-11-24	22.00	23.00	f	\N	1	\N
83	1	2020-11-24	6.00	8.00	f	\N	1	\N
83	1	2020-11-24	8.00	10.00	f	\N	1	\N
83	1	2020-11-24	10.00	12.00	f	\N	1	\N
83	1	2020-11-24	12.00	14.00	f	\N	1	\N
83	1	2020-11-24	14.00	16.00	f	\N	1	\N
83	1	2020-11-24	16.00	18.00	f	\N	1	\N
304	1	2020-11-28	12.00	14.00	f	\N	1	\N
304	1	2020-11-28	14.00	16.00	f	\N	1	\N
83	1	2020-11-24	18.00	20.00	f	\N	1	\N
83	1	2020-11-24	20.00	22.00	f	\N	1	\N
101	1	2020-12-02	12.00	14.00	f	\N	1	\N
313	3	2020-11-21	22.00	23.00	t	1122334455	5	Stängt
215	1	2020-11-22	6.00	8.00	f	\N	1	\N
215	1	2020-11-22	8.00	10.00	f	\N	1	\N
215	1	2020-11-22	10.00	12.00	f	\N	1	\N
83	1	2020-11-24	22.00	23.00	f	\N	1	\N
215	1	2020-11-22	12.00	14.00	f	\N	1	\N
215	1	2020-11-22	14.00	16.00	f	\N	1	\N
215	1	2020-11-22	16.00	18.00	f	\N	1	\N
215	1	2020-11-22	18.00	20.00	f	\N	1	\N
215	1	2020-11-22	20.00	22.00	f	\N	1	\N
215	1	2020-11-22	22.00	23.00	f	\N	1	\N
84	1	2020-11-24	6.00	8.00	f	\N	1	\N
84	1	2020-11-24	8.00	10.00	f	\N	1	\N
84	1	2020-11-24	10.00	12.00	f	\N	1	\N
231	1	2020-11-22	6.00	8.00	f	\N	1	\N
231	1	2020-11-22	8.00	10.00	f	\N	1	\N
231	1	2020-11-22	10.00	12.00	f	\N	1	\N
231	1	2020-11-22	12.00	14.00	f	\N	1	\N
231	1	2020-11-22	14.00	16.00	f	\N	1	\N
231	1	2020-11-22	16.00	18.00	f	\N	1	\N
231	1	2020-11-22	18.00	20.00	f	\N	1	\N
304	1	2020-11-28	16.00	18.00	f	\N	1	\N
231	1	2020-11-22	20.00	22.00	f	\N	1	\N
231	1	2020-11-22	22.00	23.00	f	\N	1	\N
88	1	2020-11-22	6.00	8.00	f	\N	1	\N
84	1	2020-11-24	12.00	14.00	f	\N	1	\N
84	1	2020-11-24	14.00	16.00	f	\N	1	\N
304	1	2020-11-28	18.00	20.00	f	\N	1	\N
88	1	2020-11-22	8.00	10.00	f	\N	1	\N
88	1	2020-11-22	10.00	12.00	f	\N	1	\N
88	1	2020-11-22	12.00	14.00	f	\N	1	\N
88	1	2020-11-22	14.00	16.00	f	\N	1	\N
88	1	2020-11-22	16.00	18.00	f	\N	1	\N
88	1	2020-11-22	18.00	20.00	f	\N	1	\N
88	1	2020-11-22	20.00	22.00	f	\N	1	\N
88	1	2020-11-22	22.00	23.00	f	\N	1	\N
80	1	2020-11-22	6.00	8.00	f	\N	1	\N
80	1	2020-11-22	8.00	10.00	f	\N	1	\N
80	1	2020-11-22	10.00	12.00	f	\N	1	\N
80	1	2020-11-22	12.00	14.00	f	\N	1	\N
80	1	2020-11-22	14.00	16.00	f	\N	1	\N
80	1	2020-11-22	16.00	18.00	f	\N	1	\N
80	1	2020-11-22	18.00	20.00	f	\N	1	\N
80	1	2020-11-22	20.00	22.00	f	\N	1	\N
80	1	2020-11-22	22.00	23.00	f	\N	1	\N
216	1	2020-11-22	6.00	8.00	f	\N	1	\N
304	1	2020-11-28	20.00	22.00	f	\N	1	\N
304	1	2020-11-28	22.00	23.00	f	\N	1	\N
268	2	2020-11-28	6.00	8.00	f	\N	1	\N
268	2	2020-11-28	8.00	10.00	f	\N	1	\N
268	2	2020-11-28	10.00	12.00	f	\N	1	\N
268	2	2020-11-28	12.00	14.00	f	\N	1	\N
216	1	2020-11-22	8.00	10.00	f	\N	1	\N
216	1	2020-11-22	10.00	12.00	f	\N	1	\N
216	1	2020-11-22	12.00	14.00	f	\N	1	\N
216	1	2020-11-22	14.00	16.00	f	\N	1	\N
268	2	2020-11-28	14.00	16.00	f	\N	1	\N
216	1	2020-11-22	16.00	18.00	f	\N	1	\N
216	1	2020-11-22	18.00	20.00	f	\N	1	\N
216	1	2020-11-22	20.00	22.00	f	\N	1	\N
216	1	2020-11-22	22.00	23.00	f	\N	1	\N
191	1	2020-11-22	6.00	8.00	f	\N	1	\N
191	1	2020-11-22	8.00	10.00	f	\N	1	\N
191	1	2020-11-22	10.00	12.00	f	\N	1	\N
191	1	2020-11-22	12.00	14.00	f	\N	1	\N
191	1	2020-11-22	14.00	16.00	f	\N	1	\N
191	1	2020-11-22	16.00	18.00	f	\N	1	\N
191	1	2020-11-22	18.00	20.00	f	\N	1	\N
191	1	2020-11-22	20.00	22.00	f	\N	1	\N
191	1	2020-11-22	22.00	23.00	f	\N	1	\N
81	1	2020-11-22	6.00	8.00	f	\N	1	\N
81	1	2020-11-22	8.00	10.00	f	\N	1	\N
81	1	2020-11-22	10.00	12.00	f	\N	1	\N
81	1	2020-11-22	12.00	14.00	f	\N	1	\N
81	1	2020-11-22	14.00	16.00	f	\N	1	\N
81	1	2020-11-22	16.00	18.00	f	\N	1	\N
81	1	2020-11-22	18.00	20.00	f	\N	1	\N
81	1	2020-11-22	20.00	22.00	f	\N	1	\N
81	1	2020-11-22	22.00	23.00	f	\N	1	\N
82	1	2020-11-22	6.00	8.00	f	\N	1	\N
82	1	2020-11-22	8.00	10.00	f	\N	1	\N
82	1	2020-11-22	10.00	12.00	f	\N	1	\N
82	1	2020-11-22	12.00	14.00	f	\N	1	\N
82	1	2020-11-22	14.00	16.00	f	\N	1	\N
268	2	2020-11-28	16.00	18.00	f	\N	1	\N
82	1	2020-11-22	16.00	18.00	f	\N	1	\N
82	1	2020-11-22	18.00	20.00	f	\N	1	\N
82	1	2020-11-22	20.00	22.00	f	\N	1	\N
82	1	2020-11-22	22.00	23.00	f	\N	1	\N
87	1	2020-11-22	6.00	8.00	f	\N	1	\N
87	1	2020-11-22	8.00	10.00	f	\N	1	\N
87	1	2020-11-22	10.00	12.00	f	\N	1	\N
87	1	2020-11-22	12.00	14.00	f	\N	1	\N
87	1	2020-11-22	14.00	16.00	f	\N	1	\N
87	1	2020-11-22	16.00	18.00	f	\N	1	\N
87	1	2020-11-22	18.00	20.00	f	\N	1	\N
87	1	2020-11-22	20.00	22.00	f	\N	1	\N
87	1	2020-11-22	22.00	23.00	f	\N	1	\N
86	1	2020-11-22	6.00	8.00	f	\N	1	\N
86	1	2020-11-22	8.00	10.00	f	\N	1	\N
86	1	2020-11-22	10.00	12.00	f	\N	1	\N
86	1	2020-11-22	12.00	14.00	f	\N	1	\N
86	1	2020-11-22	14.00	16.00	f	\N	1	\N
86	1	2020-11-22	16.00	18.00	f	\N	1	\N
86	1	2020-11-22	18.00	20.00	f	\N	1	\N
268	2	2020-11-28	18.00	20.00	f	\N	1	\N
86	1	2020-11-22	20.00	22.00	f	\N	1	\N
86	1	2020-11-22	22.00	23.00	f	\N	1	\N
268	2	2020-11-28	20.00	22.00	f	\N	1	\N
201	1	2020-11-22	6.00	8.00	f	\N	1	\N
201	1	2020-11-22	8.00	10.00	f	\N	1	\N
201	1	2020-11-22	10.00	12.00	f	\N	1	\N
201	1	2020-11-22	12.00	14.00	f	\N	1	\N
268	2	2020-11-28	22.00	23.00	f	\N	1	\N
201	1	2020-11-22	14.00	16.00	f	\N	1	\N
288	3	2020-11-18	17.00	18.00	f	\N	1	\N
314	3	2020-11-18	17.00	18.00	f	\N	1	\N
101	1	2020-12-02	14.00	16.00	f	\N	1	\N
309	1	2020-12-02	10.00	12.00	f	\N	1	\N
309	1	2020-12-02	12.00	14.00	f	\N	1	\N
309	1	2020-12-02	14.00	16.00	f	\N	1	\N
201	1	2020-11-22	16.00	18.00	f	\N	1	\N
201	1	2020-11-22	18.00	20.00	f	\N	1	\N
201	1	2020-11-22	20.00	22.00	f	\N	1	\N
201	1	2020-11-22	22.00	23.00	f	\N	1	\N
83	1	2020-11-22	6.00	8.00	f	\N	1	\N
83	1	2020-11-22	8.00	10.00	f	\N	1	\N
83	1	2020-11-22	10.00	12.00	f	\N	1	\N
83	1	2020-11-22	12.00	14.00	f	\N	1	\N
83	1	2020-11-22	14.00	16.00	f	\N	1	\N
83	1	2020-11-22	16.00	18.00	f	\N	1	\N
83	1	2020-11-22	18.00	20.00	f	\N	1	\N
83	1	2020-11-22	20.00	22.00	f	\N	1	\N
83	1	2020-11-22	22.00	23.00	f	\N	1	\N
84	1	2020-11-22	6.00	8.00	f	\N	1	\N
84	1	2020-11-22	8.00	10.00	f	\N	1	\N
84	1	2020-11-22	10.00	12.00	f	\N	1	\N
84	1	2020-11-22	12.00	14.00	f	\N	1	\N
84	1	2020-11-22	14.00	16.00	f	\N	1	\N
84	1	2020-11-22	16.00	18.00	f	\N	1	\N
84	1	2020-11-22	18.00	20.00	f	\N	1	\N
84	1	2020-11-22	20.00	22.00	f	\N	1	\N
84	1	2020-11-22	22.00	23.00	f	\N	1	\N
194	1	2020-11-22	6.00	8.00	f	\N	1	\N
194	1	2020-11-22	8.00	10.00	f	\N	1	\N
311	1	2020-12-02	10.00	12.00	f	\N	1	\N
194	1	2020-11-22	10.00	12.00	f	\N	1	\N
194	1	2020-11-22	12.00	14.00	f	\N	1	\N
194	1	2020-11-22	14.00	16.00	f	\N	1	\N
194	1	2020-11-22	16.00	18.00	f	\N	1	\N
84	1	2020-11-24	16.00	18.00	f	\N	1	\N
313	3	2020-11-28	18.00	20.00	t	1122334455	5	Stängt
194	1	2020-11-22	18.00	20.00	f	\N	1	\N
313	3	2020-11-28	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-28	22.00	23.00	t	1122334455	5	Stängt
285	3	2020-11-18	10.00	12.00	t	8324045352	4	mm
285	3	2020-11-18	12.00	14.00	t	8324045352	4	mm
285	3	2020-11-18	16.00	18.00	t	8426770986	4	Sally
311	1	2020-12-02	12.00	14.00	f	\N	1	\N
311	1	2020-12-02	14.00	16.00	f	\N	1	\N
194	1	2020-11-22	20.00	22.00	f	\N	1	\N
285	3	2020-11-18	14.00	16.00	t	8426770986	4	Sally
194	1	2020-11-22	22.00	23.00	f	\N	1	\N
85	1	2020-11-22	6.00	8.00	f	\N	1	\N
85	1	2020-11-22	8.00	10.00	f	\N	1	\N
85	1	2020-11-22	10.00	12.00	f	\N	1	\N
85	1	2020-11-22	12.00	14.00	f	\N	1	\N
85	1	2020-11-22	14.00	16.00	f	\N	1	\N
85	1	2020-11-22	16.00	18.00	f	\N	1	\N
190	1	2020-12-02	10.00	12.00	f	\N	1	\N
190	1	2020-12-02	12.00	14.00	f	\N	1	\N
85	1	2020-11-22	18.00	20.00	f	\N	1	\N
166	1	2020-11-18	10.00	12.00	f	\N	1	\N
166	1	2020-11-18	12.00	14.00	f	\N	1	\N
166	1	2020-11-18	14.00	16.00	f	\N	1	\N
166	1	2020-11-18	16.00	18.00	f	\N	1	\N
85	1	2020-11-22	20.00	22.00	f	\N	1	\N
168	1	2020-11-18	10.00	12.00	f	\N	1	\N
168	1	2020-11-18	12.00	14.00	f	\N	1	\N
168	1	2020-11-18	14.00	16.00	f	\N	1	\N
168	1	2020-11-18	16.00	18.00	f	\N	1	\N
85	1	2020-11-22	22.00	23.00	f	\N	1	\N
165	1	2020-11-18	10.00	12.00	f	\N	1	\N
165	1	2020-11-18	12.00	14.00	f	\N	1	\N
165	1	2020-11-18	14.00	16.00	f	\N	1	\N
165	1	2020-11-18	16.00	18.00	f	\N	1	\N
303	1	2020-11-22	6.00	8.00	f	\N	1	\N
167	1	2020-11-18	10.00	12.00	f	\N	1	\N
167	1	2020-11-18	12.00	14.00	f	\N	1	\N
167	1	2020-11-18	14.00	16.00	f	\N	1	\N
167	1	2020-11-18	16.00	18.00	f	\N	1	\N
303	1	2020-11-22	8.00	10.00	f	\N	1	\N
289	1	2020-11-18	10.00	12.00	f	\N	1	\N
289	1	2020-11-18	12.00	14.00	f	\N	1	\N
289	1	2020-11-18	14.00	16.00	f	\N	1	\N
289	1	2020-11-18	16.00	18.00	f	\N	1	\N
303	1	2020-11-22	10.00	12.00	f	\N	1	\N
297	2	2020-11-18	10.00	12.00	f	\N	1	\N
297	2	2020-11-18	12.00	14.00	f	\N	1	\N
297	2	2020-11-18	14.00	16.00	f	\N	1	\N
297	2	2020-11-18	16.00	18.00	f	\N	1	\N
303	1	2020-11-22	12.00	14.00	f	\N	1	\N
204	1	2020-11-18	9.00	11.00	f	\N	1	\N
204	1	2020-11-18	11.00	13.00	f	\N	1	\N
204	1	2020-11-18	13.00	15.00	f	\N	1	\N
204	1	2020-11-18	15.00	17.00	f	\N	1	\N
204	1	2020-11-18	17.00	18.00	f	\N	1	\N
203	1	2020-11-18	9.00	11.00	f	\N	1	\N
203	1	2020-11-18	11.00	13.00	f	\N	1	\N
203	1	2020-11-18	13.00	15.00	f	\N	1	\N
203	1	2020-11-18	15.00	17.00	f	\N	1	\N
203	1	2020-11-18	17.00	18.00	f	\N	1	\N
205	1	2020-11-18	9.00	11.00	f	\N	1	\N
205	1	2020-11-18	11.00	13.00	f	\N	1	\N
205	1	2020-11-18	13.00	15.00	f	\N	1	\N
205	1	2020-11-18	15.00	17.00	f	\N	1	\N
205	1	2020-11-18	17.00	18.00	f	\N	1	\N
202	1	2020-11-18	9.00	11.00	f	\N	1	\N
202	1	2020-11-18	11.00	13.00	f	\N	1	\N
202	1	2020-11-18	13.00	15.00	f	\N	1	\N
202	1	2020-11-18	15.00	17.00	f	\N	1	\N
202	1	2020-11-18	17.00	18.00	f	\N	1	\N
214	1	2020-11-18	9.00	11.00	f	\N	1	\N
214	1	2020-11-18	11.00	13.00	f	\N	1	\N
214	1	2020-11-18	13.00	15.00	f	\N	1	\N
214	1	2020-11-18	15.00	17.00	f	\N	1	\N
214	1	2020-11-18	17.00	18.00	f	\N	1	\N
213	1	2020-11-18	9.00	11.00	f	\N	1	\N
213	1	2020-11-18	11.00	13.00	f	\N	1	\N
213	1	2020-11-18	13.00	15.00	f	\N	1	\N
213	1	2020-11-18	15.00	17.00	f	\N	1	\N
213	1	2020-11-18	17.00	18.00	f	\N	1	\N
208	2	2020-11-18	9.00	11.00	f	\N	1	\N
208	2	2020-11-18	11.00	13.00	f	\N	1	\N
208	2	2020-11-18	13.00	15.00	f	\N	1	\N
208	2	2020-11-18	15.00	17.00	f	\N	1	\N
208	2	2020-11-18	17.00	18.00	f	\N	1	\N
244	2	2020-11-18	9.00	11.00	f	\N	1	\N
244	2	2020-11-18	11.00	13.00	f	\N	1	\N
244	2	2020-11-18	13.00	15.00	f	\N	1	\N
244	2	2020-11-18	15.00	17.00	f	\N	1	\N
244	2	2020-11-18	17.00	18.00	f	\N	1	\N
209	2	2020-11-18	9.00	11.00	f	\N	1	\N
209	2	2020-11-18	11.00	13.00	f	\N	1	\N
209	2	2020-11-18	13.00	15.00	f	\N	1	\N
209	2	2020-11-18	15.00	17.00	f	\N	1	\N
209	2	2020-11-18	17.00	18.00	f	\N	1	\N
245	2	2020-11-18	9.00	11.00	f	\N	1	\N
245	2	2020-11-18	11.00	13.00	f	\N	1	\N
245	2	2020-11-18	13.00	15.00	f	\N	1	\N
245	2	2020-11-18	15.00	17.00	f	\N	1	\N
245	2	2020-11-18	17.00	18.00	f	\N	1	\N
247	2	2020-11-18	9.00	11.00	f	\N	1	\N
247	2	2020-11-18	11.00	13.00	f	\N	1	\N
247	2	2020-11-18	13.00	15.00	f	\N	1	\N
303	1	2020-11-22	14.00	16.00	f	\N	1	\N
190	1	2020-12-02	14.00	16.00	f	\N	1	\N
99	1	2020-12-02	10.00	12.00	f	\N	1	\N
99	1	2020-12-02	12.00	14.00	f	\N	1	\N
99	1	2020-12-02	14.00	16.00	f	\N	1	\N
100	1	2020-12-02	10.00	12.00	f	\N	1	\N
100	1	2020-12-02	12.00	14.00	f	\N	1	\N
100	1	2020-12-02	14.00	16.00	f	\N	1	\N
310	1	2020-12-02	10.00	12.00	f	\N	1	\N
84	1	2020-11-24	18.00	20.00	f	\N	1	\N
303	1	2020-11-22	16.00	18.00	f	\N	1	\N
303	1	2020-11-22	18.00	20.00	f	\N	1	\N
303	1	2020-11-22	20.00	22.00	f	\N	1	\N
303	1	2020-11-22	22.00	23.00	f	\N	1	\N
304	1	2020-11-22	6.00	8.00	f	\N	1	\N
310	1	2020-12-02	12.00	14.00	f	\N	1	\N
247	2	2020-11-18	15.00	17.00	f	\N	1	\N
247	2	2020-11-18	17.00	18.00	f	\N	1	\N
207	2	2020-11-18	9.00	11.00	f	\N	1	\N
207	2	2020-11-18	11.00	13.00	f	\N	1	\N
207	2	2020-11-18	13.00	15.00	f	\N	1	\N
207	2	2020-11-18	15.00	17.00	f	\N	1	\N
207	2	2020-11-18	17.00	18.00	f	\N	1	\N
212	2	2020-11-18	9.00	11.00	f	\N	1	\N
212	2	2020-11-18	11.00	13.00	f	\N	1	\N
212	2	2020-11-18	13.00	15.00	f	\N	1	\N
212	2	2020-11-18	15.00	17.00	f	\N	1	\N
212	2	2020-11-18	17.00	18.00	f	\N	1	\N
217	2	2020-11-18	9.00	11.00	f	\N	1	\N
217	2	2020-11-18	11.00	13.00	f	\N	1	\N
217	2	2020-11-18	13.00	15.00	f	\N	1	\N
217	2	2020-11-18	15.00	17.00	f	\N	1	\N
217	2	2020-11-18	17.00	18.00	f	\N	1	\N
246	2	2020-11-18	9.00	11.00	f	\N	1	\N
246	2	2020-11-18	11.00	13.00	f	\N	1	\N
246	2	2020-11-18	13.00	15.00	f	\N	1	\N
246	2	2020-11-18	15.00	17.00	f	\N	1	\N
246	2	2020-11-18	17.00	18.00	f	\N	1	\N
210	2	2020-11-18	9.00	11.00	f	\N	1	\N
210	2	2020-11-18	11.00	13.00	f	\N	1	\N
210	2	2020-11-18	13.00	15.00	f	\N	1	\N
210	2	2020-11-18	15.00	17.00	f	\N	1	\N
210	2	2020-11-18	17.00	18.00	f	\N	1	\N
206	2	2020-11-18	9.00	11.00	f	\N	1	\N
206	2	2020-11-18	11.00	13.00	f	\N	1	\N
206	2	2020-11-18	13.00	15.00	f	\N	1	\N
206	2	2020-11-18	15.00	17.00	f	\N	1	\N
206	2	2020-11-18	17.00	18.00	f	\N	1	\N
288	3	2020-11-18	9.00	11.00	f	\N	1	\N
288	3	2020-11-18	11.00	13.00	f	\N	1	\N
288	3	2020-11-18	13.00	15.00	f	\N	1	\N
288	3	2020-11-18	15.00	17.00	f	\N	1	\N
287	3	2020-11-18	9.00	11.00	f	\N	1	\N
287	3	2020-11-18	11.00	13.00	f	\N	1	\N
287	3	2020-11-18	13.00	15.00	f	\N	1	\N
287	3	2020-11-18	15.00	17.00	f	\N	1	\N
287	3	2020-11-18	17.00	18.00	f	\N	1	\N
196	1	2020-11-18	9.00	11.00	f	\N	1	\N
196	1	2020-11-18	11.00	13.00	f	\N	1	\N
196	1	2020-11-18	13.00	15.00	f	\N	1	\N
196	1	2020-11-18	15.00	17.00	f	\N	1	\N
196	1	2020-11-18	17.00	18.00	f	\N	1	\N
97	1	2020-11-18	9.00	11.00	f	\N	1	\N
97	1	2020-11-18	11.00	13.00	f	\N	1	\N
97	1	2020-11-18	13.00	15.00	f	\N	1	\N
97	1	2020-11-18	15.00	17.00	f	\N	1	\N
97	1	2020-11-18	17.00	18.00	f	\N	1	\N
197	1	2020-11-18	9.00	11.00	f	\N	1	\N
197	1	2020-11-18	11.00	13.00	f	\N	1	\N
197	1	2020-11-18	13.00	15.00	f	\N	1	\N
197	1	2020-11-18	15.00	17.00	f	\N	1	\N
197	1	2020-11-18	17.00	18.00	f	\N	1	\N
135	1	2020-11-18	9.00	11.00	f	\N	1	\N
135	1	2020-11-18	11.00	13.00	f	\N	1	\N
135	1	2020-11-18	13.00	15.00	f	\N	1	\N
135	1	2020-11-18	15.00	17.00	f	\N	1	\N
135	1	2020-11-18	17.00	18.00	f	\N	1	\N
136	1	2020-11-18	9.00	11.00	f	\N	1	\N
136	1	2020-11-18	11.00	13.00	f	\N	1	\N
136	1	2020-11-18	13.00	15.00	f	\N	1	\N
136	1	2020-11-18	15.00	17.00	f	\N	1	\N
136	1	2020-11-18	17.00	18.00	f	\N	1	\N
137	1	2020-11-18	9.00	11.00	f	\N	1	\N
137	1	2020-11-18	11.00	13.00	f	\N	1	\N
137	1	2020-11-18	13.00	15.00	f	\N	1	\N
137	1	2020-11-18	15.00	17.00	f	\N	1	\N
137	1	2020-11-18	17.00	18.00	f	\N	1	\N
195	1	2020-11-18	9.00	11.00	f	\N	1	\N
195	1	2020-11-18	11.00	13.00	f	\N	1	\N
195	1	2020-11-18	13.00	15.00	f	\N	1	\N
195	1	2020-11-18	15.00	17.00	f	\N	1	\N
195	1	2020-11-18	17.00	18.00	f	\N	1	\N
138	1	2020-11-18	9.00	11.00	f	\N	1	\N
138	1	2020-11-18	11.00	13.00	f	\N	1	\N
138	1	2020-11-18	13.00	15.00	f	\N	1	\N
138	1	2020-11-18	15.00	17.00	f	\N	1	\N
138	1	2020-11-18	17.00	18.00	f	\N	1	\N
139	1	2020-11-18	9.00	11.00	f	\N	1	\N
139	1	2020-11-18	11.00	13.00	f	\N	1	\N
139	1	2020-11-18	13.00	15.00	f	\N	1	\N
139	1	2020-11-18	15.00	17.00	f	\N	1	\N
139	1	2020-11-18	17.00	18.00	f	\N	1	\N
140	1	2020-11-18	9.00	11.00	f	\N	1	\N
140	1	2020-11-18	11.00	13.00	f	\N	1	\N
140	1	2020-11-18	13.00	15.00	f	\N	1	\N
140	1	2020-11-18	15.00	17.00	f	\N	1	\N
140	1	2020-11-18	17.00	18.00	f	\N	1	\N
141	1	2020-11-18	9.00	11.00	f	\N	1	\N
141	1	2020-11-18	11.00	13.00	f	\N	1	\N
141	1	2020-11-18	13.00	15.00	f	\N	1	\N
141	1	2020-11-18	15.00	17.00	f	\N	1	\N
141	1	2020-11-18	17.00	18.00	f	\N	1	\N
188	2	2020-11-18	9.00	11.00	f	\N	1	\N
188	2	2020-11-18	11.00	13.00	f	\N	1	\N
188	2	2020-11-18	13.00	15.00	f	\N	1	\N
188	2	2020-11-18	15.00	17.00	f	\N	1	\N
188	2	2020-11-18	17.00	18.00	f	\N	1	\N
304	1	2020-11-22	8.00	10.00	f	\N	1	\N
304	1	2020-11-22	10.00	12.00	f	\N	1	\N
84	1	2020-11-24	20.00	22.00	f	\N	1	\N
84	1	2020-11-24	22.00	23.00	f	\N	1	\N
256	1	2020-11-18	10.00	12.00	t	8302037000	4	Sandra A
256	1	2020-11-18	12.00	14.00	t	8302037000	4	Sandra A
313	3	2020-11-22	6.00	8.00	t	1122334455	5	Stängt
256	1	2020-11-18	14.00	16.00	t	5021068303	4	Nora
309	1	2020-11-18	12.00	14.00	f	\N	1	\N
313	3	2020-11-22	8.00	10.00	t	1122334455	5	Stängt
309	1	2020-11-18	14.00	16.00	f	\N	1	\N
194	1	2020-11-24	6.00	8.00	f	\N	1	\N
313	3	2020-11-28	6.00	8.00	t	1122334455	5	Stängt
304	1	2020-11-22	12.00	14.00	f	\N	1	\N
194	1	2020-11-24	8.00	10.00	f	\N	1	\N
194	1	2020-11-24	10.00	12.00	f	\N	1	\N
304	1	2020-11-22	14.00	16.00	f	\N	1	\N
283	3	2020-11-18	15.00	17.00	t	8458414082	4	William
304	1	2020-11-22	16.00	18.00	f	\N	1	\N
304	1	2020-11-22	18.00	20.00	f	\N	1	\N
304	1	2020-11-22	20.00	22.00	f	\N	1	\N
304	1	2020-11-22	22.00	23.00	f	\N	1	\N
194	1	2020-11-24	12.00	14.00	f	\N	1	\N
194	1	2020-11-24	14.00	16.00	f	\N	1	\N
268	2	2020-11-22	6.00	8.00	f	\N	1	\N
194	1	2020-11-24	16.00	18.00	f	\N	1	\N
194	1	2020-11-24	18.00	20.00	f	\N	1	\N
194	1	2020-11-24	20.00	22.00	f	\N	1	\N
248	2	2020-11-18	9.00	11.00	f	\N	1	\N
248	2	2020-11-18	11.00	13.00	f	\N	1	\N
248	2	2020-11-18	13.00	15.00	f	\N	1	\N
248	2	2020-11-18	15.00	17.00	f	\N	1	\N
248	2	2020-11-18	17.00	18.00	f	\N	1	\N
182	2	2020-11-18	9.00	11.00	f	\N	1	\N
182	2	2020-11-18	11.00	13.00	f	\N	1	\N
182	2	2020-11-18	13.00	15.00	f	\N	1	\N
182	2	2020-11-18	15.00	17.00	f	\N	1	\N
182	2	2020-11-18	17.00	18.00	f	\N	1	\N
183	2	2020-11-18	9.00	11.00	f	\N	1	\N
183	2	2020-11-18	11.00	13.00	f	\N	1	\N
183	2	2020-11-18	13.00	15.00	f	\N	1	\N
183	2	2020-11-18	15.00	17.00	f	\N	1	\N
183	2	2020-11-18	17.00	18.00	f	\N	1	\N
181	2	2020-11-18	9.00	11.00	f	\N	1	\N
181	2	2020-11-18	11.00	13.00	f	\N	1	\N
181	2	2020-11-18	13.00	15.00	f	\N	1	\N
181	2	2020-11-18	15.00	17.00	f	\N	1	\N
181	2	2020-11-18	17.00	18.00	f	\N	1	\N
187	2	2020-11-18	9.00	11.00	f	\N	1	\N
187	2	2020-11-18	11.00	13.00	f	\N	1	\N
187	2	2020-11-18	13.00	15.00	f	\N	1	\N
187	2	2020-11-18	15.00	17.00	f	\N	1	\N
187	2	2020-11-18	17.00	18.00	f	\N	1	\N
184	2	2020-11-18	9.00	11.00	f	\N	1	\N
184	2	2020-11-18	11.00	13.00	f	\N	1	\N
184	2	2020-11-18	13.00	15.00	f	\N	1	\N
184	2	2020-11-18	15.00	17.00	f	\N	1	\N
184	2	2020-11-18	17.00	18.00	f	\N	1	\N
249	2	2020-11-18	9.00	11.00	f	\N	1	\N
249	2	2020-11-18	11.00	13.00	f	\N	1	\N
249	2	2020-11-18	13.00	15.00	f	\N	1	\N
249	2	2020-11-18	15.00	17.00	f	\N	1	\N
249	2	2020-11-18	17.00	18.00	f	\N	1	\N
186	2	2020-11-18	9.00	11.00	f	\N	1	\N
186	2	2020-11-18	11.00	13.00	f	\N	1	\N
186	2	2020-11-18	13.00	15.00	f	\N	1	\N
186	2	2020-11-18	15.00	17.00	f	\N	1	\N
186	2	2020-11-18	17.00	18.00	f	\N	1	\N
180	2	2020-11-18	9.00	11.00	f	\N	1	\N
180	2	2020-11-18	11.00	13.00	f	\N	1	\N
180	2	2020-11-18	13.00	15.00	f	\N	1	\N
180	2	2020-11-18	15.00	17.00	f	\N	1	\N
180	2	2020-11-18	17.00	18.00	f	\N	1	\N
185	2	2020-11-18	9.00	11.00	f	\N	1	\N
185	2	2020-11-18	11.00	13.00	f	\N	1	\N
185	2	2020-11-18	13.00	15.00	f	\N	1	\N
185	2	2020-11-18	15.00	17.00	f	\N	1	\N
185	2	2020-11-18	17.00	18.00	f	\N	1	\N
283	3	2020-11-18	9.00	11.00	f	\N	1	\N
284	3	2020-11-18	9.00	11.00	f	\N	1	\N
284	3	2020-11-18	11.00	13.00	f	\N	1	\N
284	3	2020-11-18	13.00	15.00	f	\N	1	\N
284	3	2020-11-18	15.00	17.00	f	\N	1	\N
284	3	2020-11-18	17.00	18.00	f	\N	1	\N
189	1	2020-11-18	10.00	12.00	f	\N	1	\N
189	1	2020-11-18	12.00	14.00	f	\N	1	\N
189	1	2020-11-18	14.00	16.00	f	\N	1	\N
98	1	2020-11-18	10.00	12.00	f	\N	1	\N
98	1	2020-11-18	12.00	14.00	f	\N	1	\N
98	1	2020-11-18	14.00	16.00	f	\N	1	\N
101	1	2020-11-18	14.00	16.00	f	\N	1	\N
311	1	2020-11-18	10.00	12.00	f	\N	1	\N
311	1	2020-11-18	12.00	14.00	f	\N	1	\N
268	2	2020-11-22	8.00	10.00	f	\N	1	\N
268	2	2020-11-22	10.00	12.00	f	\N	1	\N
268	2	2020-11-22	12.00	14.00	f	\N	1	\N
268	2	2020-11-22	14.00	16.00	f	\N	1	\N
268	2	2020-11-22	16.00	18.00	f	\N	1	\N
268	2	2020-11-22	18.00	20.00	f	\N	1	\N
268	2	2020-11-22	20.00	22.00	f	\N	1	\N
268	2	2020-11-22	22.00	23.00	f	\N	1	\N
194	1	2020-11-24	22.00	23.00	f	\N	1	\N
85	1	2020-11-24	6.00	8.00	f	\N	1	\N
85	1	2020-11-24	8.00	10.00	f	\N	1	\N
85	1	2020-11-24	10.00	12.00	f	\N	1	\N
85	1	2020-11-24	12.00	14.00	f	\N	1	\N
85	1	2020-11-24	14.00	16.00	f	\N	1	\N
85	1	2020-11-24	16.00	18.00	f	\N	1	\N
85	1	2020-11-24	18.00	20.00	f	\N	1	\N
283	3	2020-11-18	13.00	15.00	f	\N	1	\N
283	3	2020-11-18	17.00	18.00	f	\N	1	\N
310	1	2020-11-18	14.00	16.00	t	8403847168	4	Sara Zebardast
310	1	2020-11-18	10.00	12.00	t	8404912680	4	Viktor
310	1	2020-11-18	12.00	14.00	t	8403847168	4	Sara Zebardast
99	1	2020-11-18	14.00	16.00	t	8302152194	4	Emma
311	1	2020-11-18	14.00	16.00	f	\N	1	\N
190	1	2020-11-18	14.00	16.00	f	\N	1	\N
100	1	2020-11-18	14.00	16.00	f	\N	1	\N
102	1	2020-11-18	10.00	12.00	f	\N	1	\N
103	1	2020-11-18	14.00	16.00	f	\N	1	\N
104	1	2020-11-18	10.00	12.00	f	\N	1	\N
312	1	2020-11-18	10.00	12.00	f	\N	1	\N
312	1	2020-11-18	12.00	14.00	f	\N	1	\N
312	1	2020-11-18	14.00	16.00	f	\N	1	\N
122	2	2020-11-18	10.00	12.00	f	\N	1	\N
122	2	2020-11-18	12.00	14.00	f	\N	1	\N
122	2	2020-11-18	14.00	16.00	f	\N	1	\N
105	2	2020-11-18	10.00	12.00	f	\N	1	\N
105	2	2020-11-18	12.00	14.00	f	\N	1	\N
105	2	2020-11-18	14.00	16.00	f	\N	1	\N
112	2	2020-11-18	10.00	12.00	f	\N	1	\N
112	2	2020-11-18	12.00	14.00	f	\N	1	\N
112	2	2020-11-18	14.00	16.00	f	\N	1	\N
111	2	2020-11-18	10.00	12.00	f	\N	1	\N
111	2	2020-11-18	12.00	14.00	f	\N	1	\N
111	2	2020-11-18	14.00	16.00	f	\N	1	\N
106	2	2020-11-18	10.00	12.00	f	\N	1	\N
106	2	2020-11-18	12.00	14.00	f	\N	1	\N
106	2	2020-11-18	14.00	16.00	f	\N	1	\N
107	2	2020-11-18	10.00	12.00	f	\N	1	\N
107	2	2020-11-18	12.00	14.00	f	\N	1	\N
107	2	2020-11-18	14.00	16.00	f	\N	1	\N
109	2	2020-11-18	10.00	12.00	f	\N	1	\N
109	2	2020-11-18	12.00	14.00	f	\N	1	\N
109	2	2020-11-18	14.00	16.00	f	\N	1	\N
133	2	2020-11-18	10.00	12.00	f	\N	1	\N
133	2	2020-11-18	12.00	14.00	f	\N	1	\N
133	2	2020-11-18	14.00	16.00	f	\N	1	\N
134	2	2020-11-18	10.00	12.00	f	\N	1	\N
134	2	2020-11-18	12.00	14.00	f	\N	1	\N
134	2	2020-11-18	14.00	16.00	f	\N	1	\N
128	2	2020-11-18	10.00	12.00	f	\N	1	\N
128	2	2020-11-18	12.00	14.00	f	\N	1	\N
128	2	2020-11-18	14.00	16.00	f	\N	1	\N
127	2	2020-11-18	10.00	12.00	f	\N	1	\N
127	2	2020-11-18	12.00	14.00	f	\N	1	\N
127	2	2020-11-18	14.00	16.00	f	\N	1	\N
126	2	2020-11-18	10.00	12.00	f	\N	1	\N
126	2	2020-11-18	12.00	14.00	f	\N	1	\N
126	2	2020-11-18	14.00	16.00	f	\N	1	\N
125	2	2020-11-18	10.00	12.00	f	\N	1	\N
125	2	2020-11-18	12.00	14.00	f	\N	1	\N
313	3	2020-11-22	10.00	12.00	t	1122334455	5	Stängt
313	3	2020-11-22	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-22	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-22	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-22	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-22	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-22	22.00	23.00	t	1122334455	5	Stängt
307	1	2020-11-18	12.00	14.00	t	8283295744	4	hhh
85	1	2020-11-24	20.00	22.00	f	\N	1	\N
85	1	2020-11-24	22.00	23.00	f	\N	1	\N
303	1	2020-11-24	6.00	8.00	f	\N	1	\N
303	1	2020-11-24	8.00	10.00	f	\N	1	\N
303	1	2020-11-24	10.00	12.00	f	\N	1	\N
303	1	2020-11-24	12.00	14.00	f	\N	1	\N
303	1	2020-11-24	14.00	16.00	f	\N	1	\N
303	1	2020-11-24	16.00	18.00	f	\N	1	\N
303	1	2020-11-24	18.00	20.00	f	\N	1	\N
303	1	2020-11-24	20.00	22.00	f	\N	1	\N
303	1	2020-11-24	22.00	23.00	f	\N	1	\N
304	1	2020-11-24	6.00	8.00	f	\N	1	\N
304	1	2020-11-24	8.00	10.00	f	\N	1	\N
304	1	2020-11-24	10.00	12.00	f	\N	1	\N
304	1	2020-11-24	12.00	14.00	f	\N	1	\N
304	1	2020-11-24	14.00	16.00	f	\N	1	\N
304	1	2020-11-24	16.00	18.00	f	\N	1	\N
304	1	2020-11-24	18.00	20.00	f	\N	1	\N
304	1	2020-11-24	20.00	22.00	f	\N	1	\N
304	1	2020-11-24	22.00	23.00	f	\N	1	\N
268	2	2020-11-24	6.00	8.00	f	\N	1	\N
307	1	2020-11-18	14.00	16.00	f	\N	1	\N
308	1	2020-11-18	10.00	12.00	t	8334666274	4	Maja
190	1	2020-11-18	12.00	14.00	t	8443718186	4	Lisa
313	3	2020-11-28	8.00	10.00	t	1122334455	5	Stängt
104	1	2020-11-18	14.00	16.00	f	\N	1	\N
190	1	2020-11-18	10.00	12.00	t	8426962976	4	Johanna
313	3	2020-11-28	10.00	12.00	t	1122334455	5	Stängt
313	3	2020-11-28	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-28	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-28	16.00	18.00	t	1122334455	5	Stängt
100	1	2020-11-18	10.00	12.00	f	\N	1	\N
104	1	2020-11-18	12.00	14.00	f	\N	1	\N
308	1	2020-11-18	14.00	16.00	f	\N	1	\N
308	1	2020-11-18	12.00	14.00	f	\N	1	\N
100	1	2020-11-18	12.00	14.00	f	\N	1	\N
306	3	2020-11-21	12.00	14.00	t	8468848640	2	Dd
307	1	2020-11-18	10.00	12.00	f	\N	1	\N
310	1	2020-12-02	14.00	16.00	f	\N	1	\N
102	1	2020-12-02	10.00	12.00	f	\N	1	\N
102	1	2020-12-02	12.00	14.00	f	\N	1	\N
102	1	2020-12-02	14.00	16.00	f	\N	1	\N
103	1	2020-12-02	10.00	12.00	f	\N	1	\N
103	1	2020-12-02	12.00	14.00	f	\N	1	\N
103	1	2020-12-02	14.00	16.00	f	\N	1	\N
104	1	2020-12-02	10.00	12.00	f	\N	1	\N
104	1	2020-12-02	12.00	14.00	f	\N	1	\N
104	1	2020-12-02	14.00	16.00	f	\N	1	\N
125	2	2020-11-18	14.00	16.00	f	\N	1	\N
132	2	2020-11-18	10.00	12.00	f	\N	1	\N
215	1	2020-11-29	6.00	8.00	f	\N	1	\N
215	1	2020-11-29	8.00	10.00	f	\N	1	\N
215	1	2020-11-29	10.00	12.00	f	\N	1	\N
132	2	2020-11-18	12.00	14.00	f	\N	1	\N
215	1	2020-11-29	12.00	14.00	f	\N	1	\N
132	2	2020-11-18	14.00	16.00	f	\N	1	\N
215	1	2020-11-29	14.00	16.00	f	\N	1	\N
268	2	2020-11-24	8.00	10.00	f	\N	1	\N
131	2	2020-11-18	10.00	12.00	f	\N	1	\N
131	2	2020-11-18	12.00	14.00	f	\N	1	\N
131	2	2020-11-18	14.00	16.00	f	\N	1	\N
130	2	2020-11-18	10.00	12.00	f	\N	1	\N
130	2	2020-11-18	12.00	14.00	f	\N	1	\N
130	2	2020-11-18	14.00	16.00	f	\N	1	\N
129	2	2020-11-18	10.00	12.00	f	\N	1	\N
129	2	2020-11-18	12.00	14.00	f	\N	1	\N
129	2	2020-11-18	14.00	16.00	f	\N	1	\N
124	2	2020-11-18	10.00	12.00	f	\N	1	\N
124	2	2020-11-18	12.00	14.00	f	\N	1	\N
124	2	2020-11-18	14.00	16.00	f	\N	1	\N
117	2	2020-11-18	10.00	12.00	f	\N	1	\N
117	2	2020-11-18	12.00	14.00	f	\N	1	\N
117	2	2020-11-18	14.00	16.00	f	\N	1	\N
123	2	2020-11-18	10.00	12.00	f	\N	1	\N
123	2	2020-11-18	12.00	14.00	f	\N	1	\N
123	2	2020-11-18	14.00	16.00	f	\N	1	\N
121	2	2020-11-18	10.00	12.00	f	\N	1	\N
121	2	2020-11-18	12.00	14.00	f	\N	1	\N
121	2	2020-11-18	14.00	16.00	f	\N	1	\N
119	2	2020-11-18	10.00	12.00	f	\N	1	\N
119	2	2020-11-18	12.00	14.00	f	\N	1	\N
119	2	2020-11-18	14.00	16.00	f	\N	1	\N
118	2	2020-11-18	10.00	12.00	f	\N	1	\N
118	2	2020-11-18	12.00	14.00	f	\N	1	\N
118	2	2020-11-18	14.00	16.00	f	\N	1	\N
110	2	2020-11-18	10.00	12.00	f	\N	1	\N
110	2	2020-11-18	12.00	14.00	f	\N	1	\N
110	2	2020-11-18	14.00	16.00	f	\N	1	\N
108	2	2020-11-18	10.00	12.00	f	\N	1	\N
108	2	2020-11-18	12.00	14.00	f	\N	1	\N
108	2	2020-11-18	14.00	16.00	f	\N	1	\N
116	2	2020-11-18	10.00	12.00	f	\N	1	\N
116	2	2020-11-18	12.00	14.00	f	\N	1	\N
116	2	2020-11-18	14.00	16.00	f	\N	1	\N
115	2	2020-11-18	10.00	12.00	f	\N	1	\N
115	2	2020-11-18	12.00	14.00	f	\N	1	\N
115	2	2020-11-18	14.00	16.00	f	\N	1	\N
114	2	2020-11-18	10.00	12.00	f	\N	1	\N
114	2	2020-11-18	12.00	14.00	f	\N	1	\N
114	2	2020-11-18	14.00	16.00	f	\N	1	\N
113	2	2020-11-18	10.00	12.00	f	\N	1	\N
113	2	2020-11-18	12.00	14.00	f	\N	1	\N
113	2	2020-11-18	14.00	16.00	f	\N	1	\N
120	2	2020-11-18	10.00	12.00	f	\N	1	\N
120	2	2020-11-18	12.00	14.00	f	\N	1	\N
120	2	2020-11-18	14.00	16.00	f	\N	1	\N
286	3	2020-11-18	10.00	12.00	f	\N	1	\N
286	3	2020-11-18	12.00	14.00	f	\N	1	\N
286	3	2020-11-18	14.00	16.00	f	\N	1	\N
89	1	2020-11-18	9.00	11.00	f	\N	1	\N
89	1	2020-11-18	11.00	13.00	f	\N	1	\N
89	1	2020-11-18	13.00	15.00	f	\N	1	\N
89	1	2020-11-18	15.00	17.00	f	\N	1	\N
89	1	2020-11-18	17.00	18.00	f	\N	1	\N
300	1	2020-11-18	9.00	11.00	f	\N	1	\N
300	1	2020-11-18	11.00	13.00	f	\N	1	\N
300	1	2020-11-18	13.00	15.00	f	\N	1	\N
300	1	2020-11-18	15.00	17.00	f	\N	1	\N
300	1	2020-11-18	17.00	18.00	f	\N	1	\N
298	1	2020-11-18	9.00	11.00	f	\N	1	\N
298	1	2020-11-18	11.00	13.00	f	\N	1	\N
298	1	2020-11-18	13.00	15.00	f	\N	1	\N
298	1	2020-11-18	15.00	17.00	f	\N	1	\N
298	1	2020-11-18	17.00	18.00	f	\N	1	\N
95	1	2020-11-18	9.00	11.00	f	\N	1	\N
95	1	2020-11-18	11.00	13.00	f	\N	1	\N
95	1	2020-11-18	13.00	15.00	f	\N	1	\N
95	1	2020-11-18	15.00	17.00	f	\N	1	\N
95	1	2020-11-18	17.00	18.00	f	\N	1	\N
90	1	2020-11-18	9.00	11.00	f	\N	1	\N
90	1	2020-11-18	11.00	13.00	f	\N	1	\N
90	1	2020-11-18	13.00	15.00	f	\N	1	\N
90	1	2020-11-18	15.00	17.00	f	\N	1	\N
90	1	2020-11-18	17.00	18.00	f	\N	1	\N
94	1	2020-11-18	9.00	11.00	f	\N	1	\N
94	1	2020-11-18	11.00	13.00	f	\N	1	\N
94	1	2020-11-18	13.00	15.00	f	\N	1	\N
94	1	2020-11-18	15.00	17.00	f	\N	1	\N
94	1	2020-11-18	17.00	18.00	f	\N	1	\N
92	1	2020-11-18	9.00	11.00	f	\N	1	\N
92	1	2020-11-18	11.00	13.00	f	\N	1	\N
92	1	2020-11-18	13.00	15.00	f	\N	1	\N
268	2	2020-11-24	10.00	12.00	f	\N	1	\N
268	2	2020-11-24	12.00	14.00	f	\N	1	\N
268	2	2020-11-24	14.00	16.00	f	\N	1	\N
268	2	2020-11-24	16.00	18.00	f	\N	1	\N
268	2	2020-11-24	18.00	20.00	f	\N	1	\N
268	2	2020-11-24	20.00	22.00	f	\N	1	\N
268	2	2020-11-24	22.00	23.00	f	\N	1	\N
313	3	2020-11-24	10.00	12.00	f	\N	1	\N
313	3	2020-11-24	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-24	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-24	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-24	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-24	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-24	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-24	20.00	22.00	t	1122334455	5	Stängt
307	1	2020-12-02	10.00	12.00	f	\N	1	\N
307	1	2020-12-02	12.00	14.00	f	\N	1	\N
215	1	2020-11-29	16.00	18.00	f	\N	1	\N
92	1	2020-11-18	15.00	17.00	f	\N	1	\N
92	1	2020-11-18	17.00	18.00	f	\N	1	\N
93	1	2020-11-18	9.00	11.00	f	\N	1	\N
93	1	2020-11-18	11.00	13.00	f	\N	1	\N
93	1	2020-11-18	13.00	15.00	f	\N	1	\N
93	1	2020-11-18	15.00	17.00	f	\N	1	\N
93	1	2020-11-18	17.00	18.00	f	\N	1	\N
96	1	2020-11-18	9.00	11.00	f	\N	1	\N
96	1	2020-11-18	11.00	13.00	f	\N	1	\N
96	1	2020-11-18	13.00	15.00	f	\N	1	\N
96	1	2020-11-18	15.00	17.00	f	\N	1	\N
96	1	2020-11-18	17.00	18.00	f	\N	1	\N
91	1	2020-11-18	9.00	11.00	f	\N	1	\N
91	1	2020-11-18	11.00	13.00	f	\N	1	\N
91	1	2020-11-18	13.00	15.00	f	\N	1	\N
91	1	2020-11-18	15.00	17.00	f	\N	1	\N
91	1	2020-11-18	17.00	18.00	f	\N	1	\N
301	1	2020-11-18	9.00	11.00	f	\N	1	\N
301	1	2020-11-18	11.00	13.00	f	\N	1	\N
301	1	2020-11-18	13.00	15.00	f	\N	1	\N
301	1	2020-11-18	15.00	17.00	f	\N	1	\N
301	1	2020-11-18	17.00	18.00	f	\N	1	\N
299	1	2020-11-18	9.00	11.00	f	\N	1	\N
299	1	2020-11-18	11.00	13.00	f	\N	1	\N
299	1	2020-11-18	13.00	15.00	f	\N	1	\N
299	1	2020-11-18	15.00	17.00	f	\N	1	\N
299	1	2020-11-18	17.00	18.00	f	\N	1	\N
176	2	2020-11-18	9.00	11.00	f	\N	1	\N
176	2	2020-11-18	11.00	13.00	f	\N	1	\N
176	2	2020-11-18	13.00	15.00	f	\N	1	\N
176	2	2020-11-18	15.00	17.00	f	\N	1	\N
176	2	2020-11-18	17.00	18.00	f	\N	1	\N
175	2	2020-11-18	9.00	11.00	f	\N	1	\N
175	2	2020-11-18	11.00	13.00	f	\N	1	\N
175	2	2020-11-18	13.00	15.00	f	\N	1	\N
175	2	2020-11-18	15.00	17.00	f	\N	1	\N
175	2	2020-11-18	17.00	18.00	f	\N	1	\N
174	2	2020-11-18	9.00	11.00	f	\N	1	\N
174	2	2020-11-18	11.00	13.00	f	\N	1	\N
174	2	2020-11-18	13.00	15.00	f	\N	1	\N
174	2	2020-11-18	15.00	17.00	f	\N	1	\N
174	2	2020-11-18	17.00	18.00	f	\N	1	\N
179	2	2020-11-18	9.00	11.00	f	\N	1	\N
179	2	2020-11-18	11.00	13.00	f	\N	1	\N
179	2	2020-11-18	13.00	15.00	f	\N	1	\N
179	2	2020-11-18	15.00	17.00	f	\N	1	\N
179	2	2020-11-18	17.00	18.00	f	\N	1	\N
178	2	2020-11-18	9.00	11.00	f	\N	1	\N
178	2	2020-11-18	11.00	13.00	f	\N	1	\N
178	2	2020-11-18	13.00	15.00	f	\N	1	\N
178	2	2020-11-18	15.00	17.00	f	\N	1	\N
178	2	2020-11-18	17.00	18.00	f	\N	1	\N
177	2	2020-11-18	9.00	11.00	f	\N	1	\N
177	2	2020-11-18	11.00	13.00	f	\N	1	\N
177	2	2020-11-18	13.00	15.00	f	\N	1	\N
177	2	2020-11-18	15.00	17.00	f	\N	1	\N
177	2	2020-11-18	17.00	18.00	f	\N	1	\N
192	2	2020-11-18	9.00	11.00	f	\N	1	\N
192	2	2020-11-18	11.00	13.00	f	\N	1	\N
192	2	2020-11-18	13.00	15.00	f	\N	1	\N
192	2	2020-11-18	15.00	17.00	f	\N	1	\N
192	2	2020-11-18	17.00	18.00	f	\N	1	\N
193	2	2020-11-18	9.00	11.00	f	\N	1	\N
193	2	2020-11-18	11.00	13.00	f	\N	1	\N
193	2	2020-11-18	13.00	15.00	f	\N	1	\N
193	2	2020-11-18	15.00	17.00	f	\N	1	\N
193	2	2020-11-18	17.00	18.00	f	\N	1	\N
302	3	2020-11-18	9.00	11.00	f	\N	1	\N
302	3	2020-11-18	11.00	13.00	f	\N	1	\N
302	3	2020-11-18	13.00	15.00	f	\N	1	\N
302	3	2020-11-18	15.00	17.00	f	\N	1	\N
302	3	2020-11-18	17.00	18.00	f	\N	1	\N
305	3	2020-11-18	9.00	11.00	f	\N	1	\N
305	3	2020-11-18	11.00	13.00	f	\N	1	\N
305	3	2020-11-18	13.00	15.00	f	\N	1	\N
305	3	2020-11-18	15.00	17.00	f	\N	1	\N
305	3	2020-11-18	17.00	18.00	f	\N	1	\N
314	3	2020-11-18	9.00	11.00	f	\N	1	\N
314	3	2020-11-18	11.00	13.00	f	\N	1	\N
306	3	2020-11-18	9.00	11.00	f	\N	1	\N
306	3	2020-11-18	11.00	13.00	f	\N	1	\N
215	1	2020-11-18	6.00	8.00	f	\N	1	\N
215	1	2020-11-18	8.00	10.00	f	\N	1	\N
313	3	2020-11-24	22.00	23.00	t	1122334455	5	Stängt
314	3	2020-11-18	13.00	15.00	t	8306227208	4	J
314	3	2020-11-18	15.00	17.00	t	8306227208	4	I
306	3	2020-11-18	13.00	15.00	f	\N	1	\N
306	3	2020-11-18	15.00	17.00	f	\N	1	\N
215	1	2020-11-29	18.00	20.00	f	\N	1	\N
215	1	2020-11-29	20.00	22.00	f	\N	1	\N
215	1	2020-11-29	22.00	23.00	f	\N	1	\N
231	1	2020-11-29	6.00	8.00	f	\N	1	\N
231	1	2020-11-29	8.00	10.00	f	\N	1	\N
231	1	2020-11-29	10.00	12.00	f	\N	1	\N
231	1	2020-11-29	12.00	14.00	f	\N	1	\N
231	1	2020-11-29	14.00	16.00	f	\N	1	\N
231	1	2020-11-29	16.00	18.00	f	\N	1	\N
231	1	2020-11-29	18.00	20.00	f	\N	1	\N
231	1	2020-11-29	20.00	22.00	f	\N	1	\N
231	1	2020-11-29	22.00	23.00	f	\N	1	\N
88	1	2020-11-29	6.00	8.00	f	\N	1	\N
88	1	2020-11-29	8.00	10.00	f	\N	1	\N
88	1	2020-11-29	10.00	12.00	f	\N	1	\N
88	1	2020-11-29	12.00	14.00	f	\N	1	\N
88	1	2020-11-29	14.00	16.00	f	\N	1	\N
88	1	2020-11-29	16.00	18.00	f	\N	1	\N
88	1	2020-11-29	18.00	20.00	f	\N	1	\N
88	1	2020-11-29	20.00	22.00	f	\N	1	\N
88	1	2020-11-29	22.00	23.00	f	\N	1	\N
80	1	2020-11-29	6.00	8.00	f	\N	1	\N
80	1	2020-11-29	8.00	10.00	f	\N	1	\N
307	1	2020-12-02	14.00	16.00	f	\N	1	\N
312	1	2020-12-02	10.00	12.00	f	\N	1	\N
306	3	2020-11-18	17.00	18.00	f	\N	1	\N
215	1	2020-11-18	10.00	12.00	f	\N	1	\N
215	1	2020-11-18	12.00	14.00	f	\N	1	\N
215	1	2020-11-18	14.00	16.00	f	\N	1	\N
215	1	2020-11-18	16.00	18.00	f	\N	1	\N
215	1	2020-11-18	18.00	20.00	f	\N	1	\N
215	1	2020-11-18	20.00	22.00	f	\N	1	\N
215	1	2020-11-18	22.00	23.00	f	\N	1	\N
231	1	2020-11-18	6.00	8.00	f	\N	1	\N
231	1	2020-11-18	8.00	10.00	f	\N	1	\N
231	1	2020-11-18	10.00	12.00	f	\N	1	\N
231	1	2020-11-18	12.00	14.00	f	\N	1	\N
231	1	2020-11-18	14.00	16.00	f	\N	1	\N
231	1	2020-11-18	16.00	18.00	f	\N	1	\N
231	1	2020-11-18	18.00	20.00	f	\N	1	\N
231	1	2020-11-18	20.00	22.00	f	\N	1	\N
231	1	2020-11-18	22.00	23.00	f	\N	1	\N
88	1	2020-11-18	6.00	8.00	f	\N	1	\N
88	1	2020-11-18	8.00	10.00	f	\N	1	\N
88	1	2020-11-18	10.00	12.00	f	\N	1	\N
88	1	2020-11-18	12.00	14.00	f	\N	1	\N
88	1	2020-11-18	14.00	16.00	f	\N	1	\N
88	1	2020-11-18	16.00	18.00	f	\N	1	\N
88	1	2020-11-18	18.00	20.00	f	\N	1	\N
88	1	2020-11-18	20.00	22.00	f	\N	1	\N
88	1	2020-11-18	22.00	23.00	f	\N	1	\N
80	1	2020-11-18	6.00	8.00	f	\N	1	\N
80	1	2020-11-18	8.00	10.00	f	\N	1	\N
80	1	2020-11-18	10.00	12.00	f	\N	1	\N
80	1	2020-11-18	12.00	14.00	f	\N	1	\N
80	1	2020-11-18	14.00	16.00	f	\N	1	\N
80	1	2020-11-18	16.00	18.00	f	\N	1	\N
80	1	2020-11-18	18.00	20.00	f	\N	1	\N
80	1	2020-11-18	20.00	22.00	f	\N	1	\N
80	1	2020-11-18	22.00	23.00	f	\N	1	\N
216	1	2020-11-18	6.00	8.00	f	\N	1	\N
216	1	2020-11-18	8.00	10.00	f	\N	1	\N
216	1	2020-11-18	10.00	12.00	f	\N	1	\N
216	1	2020-11-18	12.00	14.00	f	\N	1	\N
216	1	2020-11-18	14.00	16.00	f	\N	1	\N
216	1	2020-11-18	16.00	18.00	f	\N	1	\N
216	1	2020-11-18	18.00	20.00	f	\N	1	\N
216	1	2020-11-18	20.00	22.00	f	\N	1	\N
216	1	2020-11-18	22.00	23.00	f	\N	1	\N
191	1	2020-11-18	6.00	8.00	f	\N	1	\N
191	1	2020-11-18	8.00	10.00	f	\N	1	\N
191	1	2020-11-18	10.00	12.00	f	\N	1	\N
191	1	2020-11-18	12.00	14.00	f	\N	1	\N
191	1	2020-11-18	14.00	16.00	f	\N	1	\N
191	1	2020-11-18	16.00	18.00	f	\N	1	\N
191	1	2020-11-18	18.00	20.00	f	\N	1	\N
191	1	2020-11-18	20.00	22.00	f	\N	1	\N
191	1	2020-11-18	22.00	23.00	f	\N	1	\N
81	1	2020-11-18	6.00	8.00	f	\N	1	\N
81	1	2020-11-18	8.00	10.00	f	\N	1	\N
81	1	2020-11-18	10.00	12.00	f	\N	1	\N
81	1	2020-11-18	12.00	14.00	f	\N	1	\N
81	1	2020-11-18	14.00	16.00	f	\N	1	\N
81	1	2020-11-18	16.00	18.00	f	\N	1	\N
81	1	2020-11-18	18.00	20.00	f	\N	1	\N
81	1	2020-11-18	20.00	22.00	f	\N	1	\N
81	1	2020-11-18	22.00	23.00	f	\N	1	\N
82	1	2020-11-18	6.00	8.00	f	\N	1	\N
82	1	2020-11-18	8.00	10.00	f	\N	1	\N
82	1	2020-11-18	10.00	12.00	f	\N	1	\N
82	1	2020-11-18	12.00	14.00	f	\N	1	\N
82	1	2020-11-18	14.00	16.00	f	\N	1	\N
82	1	2020-11-18	16.00	18.00	f	\N	1	\N
82	1	2020-11-18	18.00	20.00	f	\N	1	\N
82	1	2020-11-18	20.00	22.00	f	\N	1	\N
82	1	2020-11-18	22.00	23.00	f	\N	1	\N
87	1	2020-11-18	6.00	8.00	f	\N	1	\N
87	1	2020-11-18	8.00	10.00	f	\N	1	\N
87	1	2020-11-18	10.00	12.00	f	\N	1	\N
87	1	2020-11-18	12.00	14.00	f	\N	1	\N
87	1	2020-11-18	14.00	16.00	f	\N	1	\N
87	1	2020-11-18	16.00	18.00	f	\N	1	\N
87	1	2020-11-18	18.00	20.00	f	\N	1	\N
87	1	2020-11-18	20.00	22.00	f	\N	1	\N
87	1	2020-11-18	22.00	23.00	f	\N	1	\N
86	1	2020-11-18	6.00	8.00	f	\N	1	\N
86	1	2020-11-18	8.00	10.00	f	\N	1	\N
86	1	2020-11-18	10.00	12.00	f	\N	1	\N
86	1	2020-11-18	12.00	14.00	f	\N	1	\N
86	1	2020-11-18	14.00	16.00	f	\N	1	\N
86	1	2020-11-18	16.00	18.00	f	\N	1	\N
86	1	2020-11-18	18.00	20.00	f	\N	1	\N
86	1	2020-11-18	20.00	22.00	f	\N	1	\N
86	1	2020-11-18	22.00	23.00	f	\N	1	\N
201	1	2020-11-18	6.00	8.00	f	\N	1	\N
201	1	2020-11-18	8.00	10.00	f	\N	1	\N
201	1	2020-11-18	10.00	12.00	f	\N	1	\N
201	1	2020-11-18	12.00	14.00	f	\N	1	\N
201	1	2020-11-18	14.00	16.00	f	\N	1	\N
201	1	2020-11-18	16.00	18.00	f	\N	1	\N
201	1	2020-11-18	18.00	20.00	f	\N	1	\N
201	1	2020-11-18	20.00	22.00	f	\N	1	\N
201	1	2020-11-18	22.00	23.00	f	\N	1	\N
83	1	2020-11-18	6.00	8.00	f	\N	1	\N
83	1	2020-11-18	8.00	10.00	f	\N	1	\N
83	1	2020-11-18	10.00	12.00	f	\N	1	\N
83	1	2020-11-18	12.00	14.00	f	\N	1	\N
83	1	2020-11-18	14.00	16.00	f	\N	1	\N
83	1	2020-11-18	16.00	18.00	f	\N	1	\N
83	1	2020-11-18	18.00	20.00	f	\N	1	\N
83	1	2020-11-18	20.00	22.00	f	\N	1	\N
83	1	2020-11-18	22.00	23.00	f	\N	1	\N
84	1	2020-11-18	6.00	8.00	f	\N	1	\N
80	1	2020-11-29	10.00	12.00	f	\N	1	\N
80	1	2020-11-29	12.00	14.00	f	\N	1	\N
84	1	2020-11-18	8.00	10.00	f	\N	1	\N
84	1	2020-11-18	10.00	12.00	f	\N	1	\N
313	3	2020-11-18	12.00	14.00	t	1122334455	5	Stängt
312	1	2020-12-02	12.00	14.00	f	\N	1	\N
84	1	2020-11-18	12.00	14.00	f	\N	1	\N
84	1	2020-11-18	14.00	16.00	f	\N	1	\N
312	1	2020-12-02	14.00	16.00	f	\N	1	\N
308	1	2020-12-02	10.00	12.00	f	\N	1	\N
308	1	2020-12-02	12.00	14.00	f	\N	1	\N
84	1	2020-11-18	16.00	18.00	f	\N	1	\N
84	1	2020-11-18	18.00	20.00	f	\N	1	\N
84	1	2020-11-18	20.00	22.00	f	\N	1	\N
84	1	2020-11-18	22.00	23.00	f	\N	1	\N
194	1	2020-11-18	6.00	8.00	f	\N	1	\N
194	1	2020-11-18	8.00	10.00	f	\N	1	\N
194	1	2020-11-18	10.00	12.00	f	\N	1	\N
194	1	2020-11-18	12.00	14.00	f	\N	1	\N
194	1	2020-11-18	14.00	16.00	f	\N	1	\N
194	1	2020-11-18	16.00	18.00	f	\N	1	\N
194	1	2020-11-18	18.00	20.00	f	\N	1	\N
194	1	2020-11-18	20.00	22.00	f	\N	1	\N
194	1	2020-11-18	22.00	23.00	f	\N	1	\N
85	1	2020-11-18	6.00	8.00	f	\N	1	\N
85	1	2020-11-18	8.00	10.00	f	\N	1	\N
85	1	2020-11-18	10.00	12.00	f	\N	1	\N
85	1	2020-11-18	12.00	14.00	f	\N	1	\N
85	1	2020-11-18	14.00	16.00	f	\N	1	\N
85	1	2020-11-18	16.00	18.00	f	\N	1	\N
85	1	2020-11-18	18.00	20.00	f	\N	1	\N
85	1	2020-11-18	20.00	22.00	f	\N	1	\N
85	1	2020-11-18	22.00	23.00	f	\N	1	\N
303	1	2020-11-18	6.00	8.00	f	\N	1	\N
303	1	2020-11-18	8.00	10.00	f	\N	1	\N
303	1	2020-11-18	10.00	12.00	f	\N	1	\N
303	1	2020-11-18	12.00	14.00	f	\N	1	\N
303	1	2020-11-18	14.00	16.00	f	\N	1	\N
303	1	2020-11-18	16.00	18.00	f	\N	1	\N
303	1	2020-11-18	18.00	20.00	f	\N	1	\N
303	1	2020-11-18	20.00	22.00	f	\N	1	\N
303	1	2020-11-18	22.00	23.00	f	\N	1	\N
304	1	2020-11-18	6.00	8.00	f	\N	1	\N
304	1	2020-11-18	8.00	10.00	f	\N	1	\N
304	1	2020-11-18	10.00	12.00	f	\N	1	\N
304	1	2020-11-18	12.00	14.00	f	\N	1	\N
304	1	2020-11-18	14.00	16.00	f	\N	1	\N
304	1	2020-11-18	16.00	18.00	f	\N	1	\N
304	1	2020-11-18	18.00	20.00	f	\N	1	\N
304	1	2020-11-18	20.00	22.00	f	\N	1	\N
304	1	2020-11-18	22.00	23.00	f	\N	1	\N
268	2	2020-11-18	6.00	8.00	f	\N	1	\N
268	2	2020-11-18	8.00	10.00	f	\N	1	\N
268	2	2020-11-18	10.00	12.00	f	\N	1	\N
268	2	2020-11-18	12.00	14.00	f	\N	1	\N
268	2	2020-11-18	14.00	16.00	f	\N	1	\N
268	2	2020-11-18	16.00	18.00	f	\N	1	\N
268	2	2020-11-18	18.00	20.00	f	\N	1	\N
268	2	2020-11-18	20.00	22.00	f	\N	1	\N
268	2	2020-11-18	22.00	23.00	f	\N	1	\N
313	3	2020-11-18	10.00	12.00	f	\N	1	\N
313	3	2020-11-18	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-18	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-18	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-18	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-18	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-18	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-18	22.00	23.00	t	1122334455	5	Stängt
80	1	2020-11-29	14.00	16.00	f	\N	1	\N
80	1	2020-11-29	16.00	18.00	f	\N	1	\N
80	1	2020-11-29	18.00	20.00	f	\N	1	\N
80	1	2020-11-29	20.00	22.00	f	\N	1	\N
80	1	2020-11-29	22.00	23.00	f	\N	1	\N
216	1	2020-11-29	6.00	8.00	f	\N	1	\N
216	1	2020-11-29	8.00	10.00	f	\N	1	\N
308	1	2020-12-02	14.00	16.00	f	\N	1	\N
122	2	2020-12-02	10.00	12.00	f	\N	1	\N
216	1	2020-11-29	10.00	12.00	f	\N	1	\N
216	1	2020-11-29	12.00	14.00	f	\N	1	\N
216	1	2020-11-29	14.00	16.00	f	\N	1	\N
216	1	2020-11-29	16.00	18.00	f	\N	1	\N
216	1	2020-11-29	18.00	20.00	f	\N	1	\N
216	1	2020-11-29	20.00	22.00	f	\N	1	\N
216	1	2020-11-29	22.00	23.00	f	\N	1	\N
191	1	2020-11-29	6.00	8.00	f	\N	1	\N
191	1	2020-11-29	8.00	10.00	f	\N	1	\N
191	1	2020-11-29	10.00	12.00	f	\N	1	\N
191	1	2020-11-29	12.00	14.00	f	\N	1	\N
191	1	2020-11-29	14.00	16.00	f	\N	1	\N
191	1	2020-11-29	16.00	18.00	f	\N	1	\N
191	1	2020-11-29	18.00	20.00	f	\N	1	\N
191	1	2020-11-29	20.00	22.00	f	\N	1	\N
191	1	2020-11-29	22.00	23.00	f	\N	1	\N
81	1	2020-11-29	6.00	8.00	f	\N	1	\N
81	1	2020-11-29	8.00	10.00	f	\N	1	\N
81	1	2020-11-29	10.00	12.00	f	\N	1	\N
81	1	2020-11-29	12.00	14.00	f	\N	1	\N
81	1	2020-11-29	14.00	16.00	f	\N	1	\N
81	1	2020-11-29	16.00	18.00	f	\N	1	\N
81	1	2020-11-29	18.00	20.00	f	\N	1	\N
81	1	2020-11-29	20.00	22.00	f	\N	1	\N
81	1	2020-11-29	22.00	23.00	f	\N	1	\N
82	1	2020-11-29	6.00	8.00	f	\N	1	\N
82	1	2020-11-29	8.00	10.00	f	\N	1	\N
82	1	2020-11-29	10.00	12.00	f	\N	1	\N
82	1	2020-11-29	12.00	14.00	f	\N	1	\N
82	1	2020-11-29	14.00	16.00	f	\N	1	\N
82	1	2020-11-29	16.00	18.00	f	\N	1	\N
82	1	2020-11-29	18.00	20.00	f	\N	1	\N
82	1	2020-11-29	20.00	22.00	f	\N	1	\N
82	1	2020-11-29	22.00	23.00	f	\N	1	\N
87	1	2020-11-29	6.00	8.00	f	\N	1	\N
122	2	2020-12-02	12.00	14.00	f	\N	1	\N
122	2	2020-12-02	14.00	16.00	f	\N	1	\N
105	2	2020-12-02	10.00	12.00	f	\N	1	\N
105	2	2020-12-02	12.00	14.00	f	\N	1	\N
105	2	2020-12-02	14.00	16.00	f	\N	1	\N
112	2	2020-12-02	10.00	12.00	f	\N	1	\N
87	1	2020-11-29	8.00	10.00	f	\N	1	\N
87	1	2020-11-29	10.00	12.00	f	\N	1	\N
87	1	2020-11-29	12.00	14.00	f	\N	1	\N
87	1	2020-11-29	14.00	16.00	f	\N	1	\N
87	1	2020-11-29	16.00	18.00	f	\N	1	\N
87	1	2020-11-29	18.00	20.00	f	\N	1	\N
87	1	2020-11-29	20.00	22.00	f	\N	1	\N
87	1	2020-11-29	22.00	23.00	f	\N	1	\N
166	1	2020-11-19	10.00	12.00	f	\N	1	\N
166	1	2020-11-19	12.00	14.00	f	\N	1	\N
166	1	2020-11-19	14.00	16.00	f	\N	1	\N
166	1	2020-11-19	16.00	18.00	f	\N	1	\N
168	1	2020-11-19	10.00	12.00	f	\N	1	\N
168	1	2020-11-19	12.00	14.00	f	\N	1	\N
168	1	2020-11-19	14.00	16.00	f	\N	1	\N
168	1	2020-11-19	16.00	18.00	f	\N	1	\N
165	1	2020-11-19	10.00	12.00	f	\N	1	\N
165	1	2020-11-19	12.00	14.00	f	\N	1	\N
165	1	2020-11-19	14.00	16.00	f	\N	1	\N
165	1	2020-11-19	16.00	18.00	f	\N	1	\N
167	1	2020-11-19	10.00	12.00	f	\N	1	\N
167	1	2020-11-19	12.00	14.00	f	\N	1	\N
167	1	2020-11-19	14.00	16.00	f	\N	1	\N
167	1	2020-11-19	16.00	18.00	f	\N	1	\N
289	1	2020-11-19	10.00	12.00	f	\N	1	\N
289	1	2020-11-19	12.00	14.00	f	\N	1	\N
289	1	2020-11-19	14.00	16.00	f	\N	1	\N
289	1	2020-11-19	16.00	18.00	f	\N	1	\N
297	2	2020-11-19	10.00	12.00	f	\N	1	\N
297	2	2020-11-19	12.00	14.00	f	\N	1	\N
297	2	2020-11-19	14.00	16.00	f	\N	1	\N
297	2	2020-11-19	16.00	18.00	f	\N	1	\N
285	3	2020-11-19	16.00	18.00	f	\N	1	\N
204	1	2020-11-19	9.00	11.00	f	\N	1	\N
204	1	2020-11-19	11.00	13.00	f	\N	1	\N
204	1	2020-11-19	13.00	15.00	f	\N	1	\N
204	1	2020-11-19	15.00	17.00	f	\N	1	\N
204	1	2020-11-19	17.00	18.00	f	\N	1	\N
203	1	2020-11-19	9.00	11.00	f	\N	1	\N
203	1	2020-11-19	11.00	13.00	f	\N	1	\N
203	1	2020-11-19	13.00	15.00	f	\N	1	\N
203	1	2020-11-19	15.00	17.00	f	\N	1	\N
203	1	2020-11-19	17.00	18.00	f	\N	1	\N
205	1	2020-11-19	9.00	11.00	f	\N	1	\N
205	1	2020-11-19	11.00	13.00	f	\N	1	\N
205	1	2020-11-19	13.00	15.00	f	\N	1	\N
205	1	2020-11-19	15.00	17.00	f	\N	1	\N
205	1	2020-11-19	17.00	18.00	f	\N	1	\N
202	1	2020-11-19	9.00	11.00	f	\N	1	\N
202	1	2020-11-19	11.00	13.00	f	\N	1	\N
202	1	2020-11-19	13.00	15.00	f	\N	1	\N
202	1	2020-11-19	15.00	17.00	f	\N	1	\N
202	1	2020-11-19	17.00	18.00	f	\N	1	\N
214	1	2020-11-19	9.00	11.00	f	\N	1	\N
214	1	2020-11-19	11.00	13.00	f	\N	1	\N
86	1	2020-11-29	6.00	8.00	f	\N	1	\N
86	1	2020-11-29	8.00	10.00	f	\N	1	\N
86	1	2020-11-29	10.00	12.00	f	\N	1	\N
86	1	2020-11-29	12.00	14.00	f	\N	1	\N
86	1	2020-11-29	14.00	16.00	f	\N	1	\N
86	1	2020-11-29	16.00	18.00	f	\N	1	\N
86	1	2020-11-29	18.00	20.00	f	\N	1	\N
86	1	2020-11-29	20.00	22.00	f	\N	1	\N
214	1	2020-11-19	13.00	15.00	f	\N	1	\N
214	1	2020-11-19	15.00	17.00	f	\N	1	\N
214	1	2020-11-19	17.00	18.00	f	\N	1	\N
213	1	2020-11-19	9.00	11.00	f	\N	1	\N
213	1	2020-11-19	11.00	13.00	f	\N	1	\N
213	1	2020-11-19	13.00	15.00	f	\N	1	\N
213	1	2020-11-19	15.00	17.00	f	\N	1	\N
213	1	2020-11-19	17.00	18.00	f	\N	1	\N
208	2	2020-11-19	9.00	11.00	f	\N	1	\N
86	1	2020-11-29	22.00	23.00	f	\N	1	\N
201	1	2020-11-29	6.00	8.00	f	\N	1	\N
285	3	2020-11-19	12.00	14.00	t	8426770986	2	Sally
285	3	2020-11-19	14.00	16.00	t	8426770986	2	Sally
166	1	2020-11-25	10.00	12.00	f	\N	1	\N
166	1	2020-11-25	12.00	14.00	f	\N	1	\N
166	1	2020-11-25	14.00	16.00	f	\N	1	\N
166	1	2020-11-25	16.00	18.00	f	\N	1	\N
168	1	2020-11-25	10.00	12.00	f	\N	1	\N
168	1	2020-11-25	12.00	14.00	f	\N	1	\N
168	1	2020-11-25	14.00	16.00	f	\N	1	\N
168	1	2020-11-25	16.00	18.00	f	\N	1	\N
165	1	2020-11-25	10.00	12.00	f	\N	1	\N
208	2	2020-11-19	11.00	13.00	f	\N	1	\N
208	2	2020-11-19	13.00	15.00	f	\N	1	\N
208	2	2020-11-19	15.00	17.00	f	\N	1	\N
208	2	2020-11-19	17.00	18.00	f	\N	1	\N
244	2	2020-11-19	9.00	11.00	f	\N	1	\N
244	2	2020-11-19	11.00	13.00	f	\N	1	\N
244	2	2020-11-19	13.00	15.00	f	\N	1	\N
244	2	2020-11-19	15.00	17.00	f	\N	1	\N
244	2	2020-11-19	17.00	18.00	f	\N	1	\N
209	2	2020-11-19	9.00	11.00	f	\N	1	\N
209	2	2020-11-19	11.00	13.00	f	\N	1	\N
209	2	2020-11-19	13.00	15.00	f	\N	1	\N
209	2	2020-11-19	15.00	17.00	f	\N	1	\N
209	2	2020-11-19	17.00	18.00	f	\N	1	\N
245	2	2020-11-19	9.00	11.00	f	\N	1	\N
245	2	2020-11-19	11.00	13.00	f	\N	1	\N
165	1	2020-11-25	12.00	14.00	f	\N	1	\N
165	1	2020-11-25	14.00	16.00	f	\N	1	\N
165	1	2020-11-25	16.00	18.00	f	\N	1	\N
167	1	2020-11-25	10.00	12.00	f	\N	1	\N
167	1	2020-11-25	12.00	14.00	f	\N	1	\N
167	1	2020-11-25	14.00	16.00	f	\N	1	\N
167	1	2020-11-25	16.00	18.00	f	\N	1	\N
289	1	2020-11-25	10.00	12.00	f	\N	1	\N
289	1	2020-11-25	12.00	14.00	f	\N	1	\N
289	1	2020-11-25	14.00	16.00	f	\N	1	\N
289	1	2020-11-25	16.00	18.00	f	\N	1	\N
297	2	2020-11-25	10.00	12.00	f	\N	1	\N
297	2	2020-11-25	12.00	14.00	f	\N	1	\N
297	2	2020-11-25	14.00	16.00	f	\N	1	\N
297	2	2020-11-25	16.00	18.00	f	\N	1	\N
285	3	2020-11-25	10.00	12.00	f	\N	1	\N
285	3	2020-11-25	12.00	14.00	f	\N	1	\N
285	3	2020-11-25	14.00	16.00	f	\N	1	\N
285	3	2020-11-25	16.00	18.00	f	\N	1	\N
204	1	2020-11-25	9.00	11.00	f	\N	1	\N
204	1	2020-11-25	11.00	13.00	f	\N	1	\N
204	1	2020-11-25	13.00	15.00	f	\N	1	\N
204	1	2020-11-25	15.00	17.00	f	\N	1	\N
204	1	2020-11-25	17.00	18.00	f	\N	1	\N
203	1	2020-11-25	9.00	11.00	f	\N	1	\N
203	1	2020-11-25	11.00	13.00	f	\N	1	\N
203	1	2020-11-25	13.00	15.00	f	\N	1	\N
203	1	2020-11-25	15.00	17.00	f	\N	1	\N
203	1	2020-11-25	17.00	18.00	f	\N	1	\N
205	1	2020-11-25	9.00	11.00	f	\N	1	\N
205	1	2020-11-25	11.00	13.00	f	\N	1	\N
205	1	2020-11-25	13.00	15.00	f	\N	1	\N
205	1	2020-11-25	15.00	17.00	f	\N	1	\N
245	2	2020-11-19	13.00	15.00	f	\N	1	\N
245	2	2020-11-19	15.00	17.00	f	\N	1	\N
245	2	2020-11-19	17.00	18.00	f	\N	1	\N
247	2	2020-11-19	9.00	11.00	f	\N	1	\N
247	2	2020-11-19	11.00	13.00	f	\N	1	\N
247	2	2020-11-19	13.00	15.00	f	\N	1	\N
247	2	2020-11-19	15.00	17.00	f	\N	1	\N
247	2	2020-11-19	17.00	18.00	f	\N	1	\N
207	2	2020-11-19	9.00	11.00	f	\N	1	\N
207	2	2020-11-19	11.00	13.00	f	\N	1	\N
207	2	2020-11-19	13.00	15.00	f	\N	1	\N
207	2	2020-11-19	15.00	17.00	f	\N	1	\N
207	2	2020-11-19	17.00	18.00	f	\N	1	\N
212	2	2020-11-19	9.00	11.00	f	\N	1	\N
212	2	2020-11-19	11.00	13.00	f	\N	1	\N
212	2	2020-11-19	13.00	15.00	f	\N	1	\N
212	2	2020-11-19	15.00	17.00	f	\N	1	\N
212	2	2020-11-19	17.00	18.00	f	\N	1	\N
217	2	2020-11-19	9.00	11.00	f	\N	1	\N
217	2	2020-11-19	11.00	13.00	f	\N	1	\N
217	2	2020-11-19	13.00	15.00	f	\N	1	\N
217	2	2020-11-19	15.00	17.00	f	\N	1	\N
217	2	2020-11-19	17.00	18.00	f	\N	1	\N
246	2	2020-11-19	9.00	11.00	f	\N	1	\N
246	2	2020-11-19	11.00	13.00	f	\N	1	\N
205	1	2020-11-25	17.00	18.00	f	\N	1	\N
202	1	2020-11-25	9.00	11.00	f	\N	1	\N
202	1	2020-11-25	11.00	13.00	f	\N	1	\N
202	1	2020-11-25	13.00	15.00	f	\N	1	\N
202	1	2020-11-25	15.00	17.00	f	\N	1	\N
202	1	2020-11-25	17.00	18.00	f	\N	1	\N
214	1	2020-11-25	9.00	11.00	f	\N	1	\N
214	1	2020-11-25	11.00	13.00	f	\N	1	\N
214	1	2020-11-25	13.00	15.00	f	\N	1	\N
214	1	2020-11-25	15.00	17.00	f	\N	1	\N
214	1	2020-11-25	17.00	18.00	f	\N	1	\N
213	1	2020-11-25	9.00	11.00	f	\N	1	\N
213	1	2020-11-25	11.00	13.00	f	\N	1	\N
213	1	2020-11-25	13.00	15.00	f	\N	1	\N
213	1	2020-11-25	15.00	17.00	f	\N	1	\N
213	1	2020-11-25	17.00	18.00	f	\N	1	\N
208	2	2020-11-25	9.00	11.00	f	\N	1	\N
208	2	2020-11-25	11.00	13.00	f	\N	1	\N
208	2	2020-11-25	13.00	15.00	f	\N	1	\N
208	2	2020-11-25	15.00	17.00	f	\N	1	\N
208	2	2020-11-25	17.00	18.00	f	\N	1	\N
244	2	2020-11-25	9.00	11.00	f	\N	1	\N
244	2	2020-11-25	11.00	13.00	f	\N	1	\N
244	2	2020-11-25	13.00	15.00	f	\N	1	\N
244	2	2020-11-25	15.00	17.00	f	\N	1	\N
244	2	2020-11-25	17.00	18.00	f	\N	1	\N
209	2	2020-11-25	9.00	11.00	f	\N	1	\N
209	2	2020-11-25	11.00	13.00	f	\N	1	\N
209	2	2020-11-25	13.00	15.00	f	\N	1	\N
209	2	2020-11-25	15.00	17.00	f	\N	1	\N
209	2	2020-11-25	17.00	18.00	f	\N	1	\N
245	2	2020-11-25	9.00	11.00	f	\N	1	\N
245	2	2020-11-25	11.00	13.00	f	\N	1	\N
245	2	2020-11-25	13.00	15.00	f	\N	1	\N
245	2	2020-11-25	15.00	17.00	f	\N	1	\N
245	2	2020-11-25	17.00	18.00	f	\N	1	\N
247	2	2020-11-25	9.00	11.00	f	\N	1	\N
247	2	2020-11-25	11.00	13.00	f	\N	1	\N
247	2	2020-11-25	13.00	15.00	f	\N	1	\N
247	2	2020-11-25	15.00	17.00	f	\N	1	\N
247	2	2020-11-25	17.00	18.00	f	\N	1	\N
207	2	2020-11-25	9.00	11.00	f	\N	1	\N
207	2	2020-11-25	11.00	13.00	f	\N	1	\N
207	2	2020-11-25	13.00	15.00	f	\N	1	\N
207	2	2020-11-25	15.00	17.00	f	\N	1	\N
207	2	2020-11-25	17.00	18.00	f	\N	1	\N
212	2	2020-11-25	9.00	11.00	f	\N	1	\N
212	2	2020-11-25	11.00	13.00	f	\N	1	\N
212	2	2020-11-25	13.00	15.00	f	\N	1	\N
212	2	2020-11-25	15.00	17.00	f	\N	1	\N
212	2	2020-11-25	17.00	18.00	f	\N	1	\N
217	2	2020-11-25	9.00	11.00	f	\N	1	\N
217	2	2020-11-25	11.00	13.00	f	\N	1	\N
217	2	2020-11-25	13.00	15.00	f	\N	1	\N
217	2	2020-11-25	15.00	17.00	f	\N	1	\N
217	2	2020-11-25	17.00	18.00	f	\N	1	\N
246	2	2020-11-25	9.00	11.00	f	\N	1	\N
246	2	2020-11-25	11.00	13.00	f	\N	1	\N
246	2	2020-11-25	13.00	15.00	f	\N	1	\N
246	2	2020-11-25	15.00	17.00	f	\N	1	\N
112	2	2020-12-02	12.00	14.00	f	\N	1	\N
112	2	2020-12-02	14.00	16.00	f	\N	1	\N
111	2	2020-12-02	10.00	12.00	f	\N	1	\N
111	2	2020-12-02	12.00	14.00	f	\N	1	\N
111	2	2020-12-02	14.00	16.00	f	\N	1	\N
106	2	2020-12-02	10.00	12.00	f	\N	1	\N
106	2	2020-12-02	12.00	14.00	f	\N	1	\N
106	2	2020-12-02	14.00	16.00	f	\N	1	\N
107	2	2020-12-02	10.00	12.00	f	\N	1	\N
107	2	2020-12-02	12.00	14.00	f	\N	1	\N
107	2	2020-12-02	14.00	16.00	f	\N	1	\N
109	2	2020-12-02	10.00	12.00	f	\N	1	\N
109	2	2020-12-02	12.00	14.00	f	\N	1	\N
109	2	2020-12-02	14.00	16.00	f	\N	1	\N
133	2	2020-12-02	10.00	12.00	f	\N	1	\N
133	2	2020-12-02	12.00	14.00	f	\N	1	\N
133	2	2020-12-02	14.00	16.00	f	\N	1	\N
246	2	2020-11-25	17.00	18.00	f	\N	1	\N
210	2	2020-11-25	9.00	11.00	f	\N	1	\N
210	2	2020-11-25	11.00	13.00	f	\N	1	\N
210	2	2020-11-25	13.00	15.00	f	\N	1	\N
210	2	2020-11-25	15.00	17.00	f	\N	1	\N
210	2	2020-11-25	17.00	18.00	f	\N	1	\N
206	2	2020-11-25	9.00	11.00	f	\N	1	\N
206	2	2020-11-25	11.00	13.00	f	\N	1	\N
206	2	2020-11-25	13.00	15.00	f	\N	1	\N
206	2	2020-11-25	15.00	17.00	f	\N	1	\N
206	2	2020-11-25	17.00	18.00	f	\N	1	\N
288	3	2020-11-25	9.00	11.00	f	\N	1	\N
288	3	2020-11-25	11.00	13.00	f	\N	1	\N
288	3	2020-11-25	13.00	15.00	f	\N	1	\N
288	3	2020-11-25	15.00	17.00	f	\N	1	\N
288	3	2020-11-25	17.00	18.00	f	\N	1	\N
287	3	2020-11-25	9.00	11.00	f	\N	1	\N
287	3	2020-11-25	11.00	13.00	f	\N	1	\N
287	3	2020-11-25	13.00	15.00	f	\N	1	\N
287	3	2020-11-25	15.00	17.00	f	\N	1	\N
287	3	2020-11-25	17.00	18.00	f	\N	1	\N
196	1	2020-11-25	9.00	11.00	f	\N	1	\N
196	1	2020-11-25	11.00	13.00	f	\N	1	\N
196	1	2020-11-25	13.00	15.00	f	\N	1	\N
196	1	2020-11-25	15.00	17.00	f	\N	1	\N
196	1	2020-11-25	17.00	18.00	f	\N	1	\N
97	1	2020-11-25	9.00	11.00	f	\N	1	\N
246	2	2020-11-19	13.00	15.00	f	\N	1	\N
97	1	2020-11-25	11.00	13.00	f	\N	1	\N
97	1	2020-11-25	13.00	15.00	f	\N	1	\N
97	1	2020-11-25	15.00	17.00	f	\N	1	\N
97	1	2020-11-25	17.00	18.00	f	\N	1	\N
197	1	2020-11-25	9.00	11.00	f	\N	1	\N
197	1	2020-11-25	11.00	13.00	f	\N	1	\N
197	1	2020-11-25	13.00	15.00	f	\N	1	\N
197	1	2020-11-25	15.00	17.00	f	\N	1	\N
197	1	2020-11-25	17.00	18.00	f	\N	1	\N
135	1	2020-11-25	9.00	11.00	f	\N	1	\N
135	1	2020-11-25	11.00	13.00	f	\N	1	\N
135	1	2020-11-25	13.00	15.00	f	\N	1	\N
246	2	2020-11-19	15.00	17.00	f	\N	1	\N
246	2	2020-11-19	17.00	18.00	f	\N	1	\N
210	2	2020-11-19	9.00	11.00	f	\N	1	\N
210	2	2020-11-19	11.00	13.00	f	\N	1	\N
210	2	2020-11-19	13.00	15.00	f	\N	1	\N
210	2	2020-11-19	15.00	17.00	f	\N	1	\N
210	2	2020-11-19	17.00	18.00	f	\N	1	\N
206	2	2020-11-19	9.00	11.00	f	\N	1	\N
206	2	2020-11-19	11.00	13.00	f	\N	1	\N
206	2	2020-11-19	13.00	15.00	f	\N	1	\N
206	2	2020-11-19	15.00	17.00	f	\N	1	\N
135	1	2020-11-25	15.00	17.00	f	\N	1	\N
206	2	2020-11-19	17.00	18.00	f	\N	1	\N
288	3	2020-11-19	9.00	11.00	f	\N	1	\N
288	3	2020-11-19	11.00	13.00	f	\N	1	\N
288	3	2020-11-19	13.00	15.00	f	\N	1	\N
201	1	2020-11-29	8.00	10.00	f	\N	1	\N
135	1	2020-11-25	17.00	18.00	f	\N	1	\N
136	1	2020-11-25	9.00	11.00	f	\N	1	\N
136	1	2020-11-25	11.00	13.00	f	\N	1	\N
136	1	2020-11-25	13.00	15.00	f	\N	1	\N
136	1	2020-11-25	15.00	17.00	f	\N	1	\N
136	1	2020-11-25	17.00	18.00	f	\N	1	\N
137	1	2020-11-25	9.00	11.00	f	\N	1	\N
137	1	2020-11-25	11.00	13.00	f	\N	1	\N
137	1	2020-11-25	13.00	15.00	f	\N	1	\N
137	1	2020-11-25	15.00	17.00	f	\N	1	\N
137	1	2020-11-25	17.00	18.00	f	\N	1	\N
195	1	2020-11-25	9.00	11.00	f	\N	1	\N
195	1	2020-11-25	11.00	13.00	f	\N	1	\N
288	3	2020-11-19	15.00	17.00	f	\N	1	\N
201	1	2020-11-29	10.00	12.00	f	\N	1	\N
201	1	2020-11-29	12.00	14.00	f	\N	1	\N
201	1	2020-11-29	14.00	16.00	f	\N	1	\N
195	1	2020-11-25	13.00	15.00	f	\N	1	\N
201	1	2020-11-29	16.00	18.00	f	\N	1	\N
201	1	2020-11-29	18.00	20.00	f	\N	1	\N
201	1	2020-11-29	20.00	22.00	f	\N	1	\N
201	1	2020-11-29	22.00	23.00	f	\N	1	\N
195	1	2020-11-25	15.00	17.00	f	\N	1	\N
83	1	2020-11-29	6.00	8.00	f	\N	1	\N
83	1	2020-11-29	8.00	10.00	f	\N	1	\N
83	1	2020-11-29	10.00	12.00	f	\N	1	\N
83	1	2020-11-29	12.00	14.00	f	\N	1	\N
288	3	2020-11-19	17.00	18.00	f	\N	1	\N
287	3	2020-11-19	13.00	15.00	f	\N	1	\N
287	3	2020-11-19	15.00	17.00	f	\N	1	\N
287	3	2020-11-19	17.00	18.00	f	\N	1	\N
196	1	2020-11-19	9.00	11.00	f	\N	1	\N
196	1	2020-11-19	11.00	13.00	f	\N	1	\N
196	1	2020-11-19	13.00	15.00	f	\N	1	\N
196	1	2020-11-19	15.00	17.00	f	\N	1	\N
196	1	2020-11-19	17.00	18.00	f	\N	1	\N
97	1	2020-11-19	9.00	11.00	f	\N	1	\N
97	1	2020-11-19	11.00	13.00	f	\N	1	\N
97	1	2020-11-19	13.00	15.00	f	\N	1	\N
97	1	2020-11-19	15.00	17.00	f	\N	1	\N
97	1	2020-11-19	17.00	18.00	f	\N	1	\N
197	1	2020-11-19	9.00	11.00	f	\N	1	\N
197	1	2020-11-19	11.00	13.00	f	\N	1	\N
197	1	2020-11-19	13.00	15.00	f	\N	1	\N
197	1	2020-11-19	15.00	17.00	f	\N	1	\N
197	1	2020-11-19	17.00	18.00	f	\N	1	\N
135	1	2020-11-19	9.00	11.00	f	\N	1	\N
135	1	2020-11-19	11.00	13.00	f	\N	1	\N
135	1	2020-11-19	13.00	15.00	f	\N	1	\N
135	1	2020-11-19	15.00	17.00	f	\N	1	\N
135	1	2020-11-19	17.00	18.00	f	\N	1	\N
136	1	2020-11-19	9.00	11.00	f	\N	1	\N
136	1	2020-11-19	11.00	13.00	f	\N	1	\N
195	1	2020-11-25	17.00	18.00	f	\N	1	\N
138	1	2020-11-25	9.00	11.00	f	\N	1	\N
138	1	2020-11-25	11.00	13.00	f	\N	1	\N
138	1	2020-11-25	13.00	15.00	f	\N	1	\N
138	1	2020-11-25	15.00	17.00	f	\N	1	\N
83	1	2020-11-29	14.00	16.00	f	\N	1	\N
138	1	2020-11-25	17.00	18.00	f	\N	1	\N
139	1	2020-11-25	9.00	11.00	f	\N	1	\N
139	1	2020-11-25	11.00	13.00	f	\N	1	\N
139	1	2020-11-25	13.00	15.00	f	\N	1	\N
139	1	2020-11-25	15.00	17.00	f	\N	1	\N
139	1	2020-11-25	17.00	18.00	f	\N	1	\N
140	1	2020-11-25	9.00	11.00	f	\N	1	\N
140	1	2020-11-25	11.00	13.00	f	\N	1	\N
140	1	2020-11-25	13.00	15.00	f	\N	1	\N
83	1	2020-11-29	16.00	18.00	f	\N	1	\N
83	1	2020-11-29	18.00	20.00	f	\N	1	\N
140	1	2020-11-25	15.00	17.00	f	\N	1	\N
83	1	2020-11-29	20.00	22.00	f	\N	1	\N
140	1	2020-11-25	17.00	18.00	f	\N	1	\N
136	1	2020-11-19	13.00	15.00	f	\N	1	\N
136	1	2020-11-19	15.00	17.00	f	\N	1	\N
136	1	2020-11-19	17.00	18.00	f	\N	1	\N
137	1	2020-11-19	9.00	11.00	f	\N	1	\N
137	1	2020-11-19	11.00	13.00	f	\N	1	\N
137	1	2020-11-19	13.00	15.00	f	\N	1	\N
137	1	2020-11-19	15.00	17.00	f	\N	1	\N
137	1	2020-11-19	17.00	18.00	f	\N	1	\N
195	1	2020-11-19	9.00	11.00	f	\N	1	\N
195	1	2020-11-19	11.00	13.00	f	\N	1	\N
141	1	2020-11-25	9.00	11.00	f	\N	1	\N
141	1	2020-11-25	11.00	13.00	f	\N	1	\N
141	1	2020-11-25	13.00	15.00	f	\N	1	\N
141	1	2020-11-25	15.00	17.00	f	\N	1	\N
141	1	2020-11-25	17.00	18.00	f	\N	1	\N
188	2	2020-11-25	9.00	11.00	f	\N	1	\N
188	2	2020-11-25	11.00	13.00	f	\N	1	\N
188	2	2020-11-25	13.00	15.00	f	\N	1	\N
188	2	2020-11-25	15.00	17.00	f	\N	1	\N
188	2	2020-11-25	17.00	18.00	f	\N	1	\N
248	2	2020-11-25	9.00	11.00	f	\N	1	\N
248	2	2020-11-25	11.00	13.00	f	\N	1	\N
248	2	2020-11-25	13.00	15.00	f	\N	1	\N
248	2	2020-11-25	15.00	17.00	f	\N	1	\N
248	2	2020-11-25	17.00	18.00	f	\N	1	\N
182	2	2020-11-25	9.00	11.00	f	\N	1	\N
182	2	2020-11-25	11.00	13.00	f	\N	1	\N
182	2	2020-11-25	13.00	15.00	f	\N	1	\N
182	2	2020-11-25	15.00	17.00	f	\N	1	\N
182	2	2020-11-25	17.00	18.00	f	\N	1	\N
183	2	2020-11-25	9.00	11.00	f	\N	1	\N
183	2	2020-11-25	11.00	13.00	f	\N	1	\N
183	2	2020-11-25	13.00	15.00	f	\N	1	\N
183	2	2020-11-25	15.00	17.00	f	\N	1	\N
183	2	2020-11-25	17.00	18.00	f	\N	1	\N
181	2	2020-11-25	9.00	11.00	f	\N	1	\N
181	2	2020-11-25	11.00	13.00	f	\N	1	\N
181	2	2020-11-25	13.00	15.00	f	\N	1	\N
181	2	2020-11-25	15.00	17.00	f	\N	1	\N
195	1	2020-11-19	13.00	15.00	f	\N	1	\N
195	1	2020-11-19	15.00	17.00	f	\N	1	\N
195	1	2020-11-19	17.00	18.00	f	\N	1	\N
138	1	2020-11-19	9.00	11.00	f	\N	1	\N
138	1	2020-11-19	11.00	13.00	f	\N	1	\N
138	1	2020-11-19	13.00	15.00	f	\N	1	\N
138	1	2020-11-19	15.00	17.00	f	\N	1	\N
138	1	2020-11-19	17.00	18.00	f	\N	1	\N
139	1	2020-11-19	9.00	11.00	f	\N	1	\N
139	1	2020-11-19	11.00	13.00	f	\N	1	\N
139	1	2020-11-19	13.00	15.00	f	\N	1	\N
139	1	2020-11-19	15.00	17.00	f	\N	1	\N
139	1	2020-11-19	17.00	18.00	f	\N	1	\N
140	1	2020-11-19	9.00	11.00	f	\N	1	\N
140	1	2020-11-19	11.00	13.00	f	\N	1	\N
140	1	2020-11-19	13.00	15.00	f	\N	1	\N
140	1	2020-11-19	15.00	17.00	f	\N	1	\N
140	1	2020-11-19	17.00	18.00	f	\N	1	\N
141	1	2020-11-19	9.00	11.00	f	\N	1	\N
141	1	2020-11-19	11.00	13.00	f	\N	1	\N
141	1	2020-11-19	13.00	15.00	f	\N	1	\N
141	1	2020-11-19	15.00	17.00	f	\N	1	\N
141	1	2020-11-19	17.00	18.00	f	\N	1	\N
188	2	2020-11-19	9.00	11.00	f	\N	1	\N
188	2	2020-11-19	11.00	13.00	f	\N	1	\N
188	2	2020-11-19	13.00	15.00	f	\N	1	\N
188	2	2020-11-19	15.00	17.00	f	\N	1	\N
188	2	2020-11-19	17.00	18.00	f	\N	1	\N
248	2	2020-11-19	9.00	11.00	f	\N	1	\N
248	2	2020-11-19	11.00	13.00	f	\N	1	\N
248	2	2020-11-19	13.00	15.00	f	\N	1	\N
248	2	2020-11-19	15.00	17.00	f	\N	1	\N
248	2	2020-11-19	17.00	18.00	f	\N	1	\N
182	2	2020-11-19	9.00	11.00	f	\N	1	\N
182	2	2020-11-19	11.00	13.00	f	\N	1	\N
182	2	2020-11-19	13.00	15.00	f	\N	1	\N
182	2	2020-11-19	15.00	17.00	f	\N	1	\N
182	2	2020-11-19	17.00	18.00	f	\N	1	\N
183	2	2020-11-19	9.00	11.00	f	\N	1	\N
183	2	2020-11-19	11.00	13.00	f	\N	1	\N
183	2	2020-11-19	13.00	15.00	f	\N	1	\N
183	2	2020-11-19	15.00	17.00	f	\N	1	\N
183	2	2020-11-19	17.00	18.00	f	\N	1	\N
181	2	2020-11-19	9.00	11.00	f	\N	1	\N
181	2	2020-11-19	11.00	13.00	f	\N	1	\N
181	2	2020-11-19	13.00	15.00	f	\N	1	\N
181	2	2020-11-19	15.00	17.00	f	\N	1	\N
181	2	2020-11-19	17.00	18.00	f	\N	1	\N
187	2	2020-11-19	9.00	11.00	f	\N	1	\N
187	2	2020-11-19	11.00	13.00	f	\N	1	\N
187	2	2020-11-19	13.00	15.00	f	\N	1	\N
187	2	2020-11-19	15.00	17.00	f	\N	1	\N
187	2	2020-11-19	17.00	18.00	f	\N	1	\N
184	2	2020-11-19	9.00	11.00	f	\N	1	\N
184	2	2020-11-19	11.00	13.00	f	\N	1	\N
184	2	2020-11-19	13.00	15.00	f	\N	1	\N
104	1	2020-11-19	12.00	14.00	t	8461381672	2	Kalle
104	1	2020-11-19	14.00	16.00	t	8461381672	2	Kalle
181	2	2020-11-25	17.00	18.00	f	\N	1	\N
187	2	2020-11-25	9.00	11.00	f	\N	1	\N
187	2	2020-11-25	11.00	13.00	f	\N	1	\N
187	2	2020-11-25	13.00	15.00	f	\N	1	\N
187	2	2020-11-25	15.00	17.00	f	\N	1	\N
187	2	2020-11-25	17.00	18.00	f	\N	1	\N
184	2	2020-11-25	9.00	11.00	f	\N	1	\N
184	2	2020-11-25	11.00	13.00	f	\N	1	\N
184	2	2020-11-25	13.00	15.00	f	\N	1	\N
184	2	2020-11-25	15.00	17.00	f	\N	1	\N
310	1	2020-11-19	12.00	14.00	t	8404912680	2	Viktor
310	1	2020-11-19	14.00	16.00	t	8404912680	2	Viktor
308	1	2020-11-19	14.00	16.00	f	\N	1	\N
99	1	2020-11-19	10.00	12.00	t	8283295744	4	hhh
83	1	2020-11-29	22.00	23.00	f	\N	1	\N
84	1	2020-11-29	6.00	8.00	f	\N	1	\N
84	1	2020-11-29	8.00	10.00	f	\N	1	\N
84	1	2020-11-29	10.00	12.00	f	\N	1	\N
84	1	2020-11-29	12.00	14.00	f	\N	1	\N
84	1	2020-11-29	14.00	16.00	f	\N	1	\N
84	1	2020-11-29	16.00	18.00	f	\N	1	\N
84	1	2020-11-29	18.00	20.00	f	\N	1	\N
84	1	2020-11-29	20.00	22.00	f	\N	1	\N
84	1	2020-11-29	22.00	23.00	f	\N	1	\N
194	1	2020-11-29	6.00	8.00	f	\N	1	\N
194	1	2020-11-29	8.00	10.00	f	\N	1	\N
194	1	2020-11-29	10.00	12.00	f	\N	1	\N
194	1	2020-11-29	12.00	14.00	f	\N	1	\N
194	1	2020-11-29	14.00	16.00	f	\N	1	\N
307	1	2020-11-19	10.00	12.00	t	5151498445	4	Martiti
307	1	2020-11-19	14.00	16.00	t	8334666274	2	Maja
99	1	2020-11-19	12.00	14.00	t	8283295744	2	hhh
309	1	2020-11-19	12.00	14.00	t	8276844584	2	Sarah 
309	1	2020-11-19	14.00	16.00	t	8424864264	2	M&S
283	3	2020-11-19	13.00	15.00	t	5081048035	2	V
103	1	2020-11-19	12.00	14.00	t	5131633737	2	Lise
190	1	2020-11-19	14.00	16.00	t	8430049282	2	C. D.
100	1	2020-11-19	12.00	14.00	t	8274917378	2	Erik
256	1	2020-11-19	12.00	14.00	t	5141309338	2	Radwan
256	1	2020-11-19	14.00	16.00	t	5141309338	2	Radwan
102	1	2020-11-19	12.00	14.00	t	5021269304	2	Sandra
102	1	2020-11-19	14.00	16.00	t	5021269304	2	Sandra
134	2	2020-12-02	10.00	12.00	f	\N	1	\N
308	1	2020-11-19	12.00	14.00	f	\N	1	\N
184	2	2020-11-19	15.00	17.00	f	\N	1	\N
184	2	2020-11-19	17.00	18.00	f	\N	1	\N
249	2	2020-11-19	9.00	11.00	f	\N	1	\N
249	2	2020-11-19	11.00	13.00	f	\N	1	\N
249	2	2020-11-19	13.00	15.00	f	\N	1	\N
249	2	2020-11-19	15.00	17.00	f	\N	1	\N
249	2	2020-11-19	17.00	18.00	f	\N	1	\N
186	2	2020-11-19	9.00	11.00	f	\N	1	\N
186	2	2020-11-19	11.00	13.00	f	\N	1	\N
186	2	2020-11-19	13.00	15.00	f	\N	1	\N
186	2	2020-11-19	15.00	17.00	f	\N	1	\N
186	2	2020-11-19	17.00	18.00	f	\N	1	\N
180	2	2020-11-19	9.00	11.00	f	\N	1	\N
180	2	2020-11-19	11.00	13.00	f	\N	1	\N
180	2	2020-11-19	13.00	15.00	f	\N	1	\N
180	2	2020-11-19	15.00	17.00	f	\N	1	\N
180	2	2020-11-19	17.00	18.00	f	\N	1	\N
185	2	2020-11-19	9.00	11.00	f	\N	1	\N
185	2	2020-11-19	11.00	13.00	f	\N	1	\N
185	2	2020-11-19	13.00	15.00	f	\N	1	\N
185	2	2020-11-19	15.00	17.00	f	\N	1	\N
185	2	2020-11-19	17.00	18.00	f	\N	1	\N
283	3	2020-11-19	9.00	11.00	f	\N	1	\N
283	3	2020-11-19	15.00	17.00	f	\N	1	\N
283	3	2020-11-19	17.00	18.00	f	\N	1	\N
284	3	2020-11-19	9.00	11.00	f	\N	1	\N
284	3	2020-11-19	11.00	13.00	f	\N	1	\N
284	3	2020-11-19	13.00	15.00	f	\N	1	\N
284	3	2020-11-19	15.00	17.00	f	\N	1	\N
284	3	2020-11-19	17.00	18.00	f	\N	1	\N
189	1	2020-11-19	10.00	12.00	f	\N	1	\N
189	1	2020-11-19	12.00	14.00	f	\N	1	\N
189	1	2020-11-19	14.00	16.00	f	\N	1	\N
98	1	2020-11-19	10.00	12.00	f	\N	1	\N
98	1	2020-11-19	12.00	14.00	f	\N	1	\N
98	1	2020-11-19	14.00	16.00	f	\N	1	\N
101	1	2020-11-19	14.00	16.00	f	\N	1	\N
311	1	2020-11-19	10.00	12.00	f	\N	1	\N
311	1	2020-11-19	12.00	14.00	f	\N	1	\N
311	1	2020-11-19	14.00	16.00	f	\N	1	\N
190	1	2020-11-19	10.00	12.00	f	\N	1	\N
99	1	2020-11-19	14.00	16.00	f	\N	1	\N
100	1	2020-11-19	14.00	16.00	f	\N	1	\N
310	1	2020-11-19	10.00	12.00	f	\N	1	\N
102	1	2020-11-19	10.00	12.00	f	\N	1	\N
103	1	2020-11-19	14.00	16.00	f	\N	1	\N
312	1	2020-11-19	10.00	12.00	f	\N	1	\N
312	1	2020-11-19	12.00	14.00	f	\N	1	\N
312	1	2020-11-19	14.00	16.00	f	\N	1	\N
308	1	2020-11-19	10.00	12.00	f	\N	1	\N
122	2	2020-11-19	10.00	12.00	f	\N	1	\N
122	2	2020-11-19	12.00	14.00	f	\N	1	\N
122	2	2020-11-19	14.00	16.00	f	\N	1	\N
105	2	2020-11-19	10.00	12.00	f	\N	1	\N
105	2	2020-11-19	12.00	14.00	f	\N	1	\N
105	2	2020-11-19	14.00	16.00	f	\N	1	\N
112	2	2020-11-19	10.00	12.00	f	\N	1	\N
184	2	2020-11-25	17.00	18.00	f	\N	1	\N
249	2	2020-11-25	9.00	11.00	f	\N	1	\N
194	1	2020-11-29	16.00	18.00	f	\N	1	\N
194	1	2020-11-29	18.00	20.00	f	\N	1	\N
194	1	2020-11-29	20.00	22.00	f	\N	1	\N
249	2	2020-11-25	11.00	13.00	f	\N	1	\N
249	2	2020-11-25	13.00	15.00	f	\N	1	\N
249	2	2020-11-25	15.00	17.00	f	\N	1	\N
249	2	2020-11-25	17.00	18.00	f	\N	1	\N
186	2	2020-11-25	9.00	11.00	f	\N	1	\N
194	1	2020-11-29	22.00	23.00	f	\N	1	\N
186	2	2020-11-25	11.00	13.00	f	\N	1	\N
186	2	2020-11-25	13.00	15.00	f	\N	1	\N
186	2	2020-11-25	15.00	17.00	f	\N	1	\N
186	2	2020-11-25	17.00	18.00	f	\N	1	\N
180	2	2020-11-25	9.00	11.00	f	\N	1	\N
180	2	2020-11-25	11.00	13.00	f	\N	1	\N
180	2	2020-11-25	13.00	15.00	f	\N	1	\N
180	2	2020-11-25	15.00	17.00	f	\N	1	\N
180	2	2020-11-25	17.00	18.00	f	\N	1	\N
185	2	2020-11-25	9.00	11.00	f	\N	1	\N
185	2	2020-11-25	11.00	13.00	f	\N	1	\N
185	2	2020-11-25	13.00	15.00	f	\N	1	\N
185	2	2020-11-25	15.00	17.00	f	\N	1	\N
185	2	2020-11-25	17.00	18.00	f	\N	1	\N
283	3	2020-11-25	9.00	11.00	f	\N	1	\N
283	3	2020-11-25	11.00	13.00	f	\N	1	\N
283	3	2020-11-25	13.00	15.00	f	\N	1	\N
283	3	2020-11-25	15.00	17.00	f	\N	1	\N
283	3	2020-11-25	17.00	18.00	f	\N	1	\N
284	3	2020-11-25	9.00	11.00	f	\N	1	\N
284	3	2020-11-25	11.00	13.00	f	\N	1	\N
284	3	2020-11-25	13.00	15.00	f	\N	1	\N
284	3	2020-11-25	15.00	17.00	f	\N	1	\N
284	3	2020-11-25	17.00	18.00	f	\N	1	\N
189	1	2020-11-25	10.00	12.00	f	\N	1	\N
189	1	2020-11-25	12.00	14.00	f	\N	1	\N
189	1	2020-11-25	14.00	16.00	f	\N	1	\N
256	1	2020-11-25	10.00	12.00	f	\N	1	\N
256	1	2020-11-25	12.00	14.00	f	\N	1	\N
256	1	2020-11-25	14.00	16.00	f	\N	1	\N
98	1	2020-11-25	10.00	12.00	f	\N	1	\N
98	1	2020-11-25	12.00	14.00	f	\N	1	\N
98	1	2020-11-25	14.00	16.00	f	\N	1	\N
101	1	2020-11-25	10.00	12.00	f	\N	1	\N
101	1	2020-11-25	12.00	14.00	f	\N	1	\N
101	1	2020-11-25	14.00	16.00	f	\N	1	\N
309	1	2020-11-25	10.00	12.00	f	\N	1	\N
309	1	2020-11-25	12.00	14.00	f	\N	1	\N
309	1	2020-11-25	14.00	16.00	f	\N	1	\N
311	1	2020-11-25	10.00	12.00	f	\N	1	\N
311	1	2020-11-25	12.00	14.00	f	\N	1	\N
311	1	2020-11-25	14.00	16.00	f	\N	1	\N
190	1	2020-11-25	10.00	12.00	f	\N	1	\N
190	1	2020-11-25	12.00	14.00	f	\N	1	\N
190	1	2020-11-25	14.00	16.00	f	\N	1	\N
99	1	2020-11-25	10.00	12.00	f	\N	1	\N
99	1	2020-11-25	12.00	14.00	f	\N	1	\N
99	1	2020-11-25	14.00	16.00	f	\N	1	\N
100	1	2020-11-25	10.00	12.00	f	\N	1	\N
100	1	2020-11-25	12.00	14.00	f	\N	1	\N
100	1	2020-11-25	14.00	16.00	f	\N	1	\N
310	1	2020-11-25	12.00	14.00	f	\N	1	\N
310	1	2020-11-25	14.00	16.00	f	\N	1	\N
102	1	2020-11-25	10.00	12.00	f	\N	1	\N
102	1	2020-11-25	12.00	14.00	f	\N	1	\N
102	1	2020-11-25	14.00	16.00	f	\N	1	\N
103	1	2020-11-25	10.00	12.00	f	\N	1	\N
103	1	2020-11-25	12.00	14.00	f	\N	1	\N
103	1	2020-11-25	14.00	16.00	f	\N	1	\N
104	1	2020-11-25	10.00	12.00	f	\N	1	\N
104	1	2020-11-25	12.00	14.00	f	\N	1	\N
104	1	2020-11-25	14.00	16.00	f	\N	1	\N
312	1	2020-11-25	10.00	12.00	f	\N	1	\N
312	1	2020-11-25	12.00	14.00	f	\N	1	\N
312	1	2020-11-25	14.00	16.00	f	\N	1	\N
308	1	2020-11-25	10.00	12.00	f	\N	1	\N
308	1	2020-11-25	12.00	14.00	f	\N	1	\N
308	1	2020-11-25	14.00	16.00	f	\N	1	\N
122	2	2020-11-25	10.00	12.00	f	\N	1	\N
122	2	2020-11-25	12.00	14.00	f	\N	1	\N
122	2	2020-11-25	14.00	16.00	f	\N	1	\N
105	2	2020-11-25	10.00	12.00	f	\N	1	\N
105	2	2020-11-25	12.00	14.00	f	\N	1	\N
105	2	2020-11-25	14.00	16.00	f	\N	1	\N
112	2	2020-11-25	10.00	12.00	f	\N	1	\N
112	2	2020-11-25	12.00	14.00	f	\N	1	\N
112	2	2020-11-25	14.00	16.00	f	\N	1	\N
111	2	2020-11-25	10.00	12.00	f	\N	1	\N
111	2	2020-11-25	12.00	14.00	f	\N	1	\N
111	2	2020-11-25	14.00	16.00	f	\N	1	\N
106	2	2020-11-25	10.00	12.00	f	\N	1	\N
106	2	2020-11-25	12.00	14.00	f	\N	1	\N
106	2	2020-11-25	14.00	16.00	f	\N	1	\N
107	2	2020-11-25	10.00	12.00	f	\N	1	\N
107	2	2020-11-25	12.00	14.00	f	\N	1	\N
107	2	2020-11-25	14.00	16.00	f	\N	1	\N
109	2	2020-11-25	10.00	12.00	f	\N	1	\N
109	2	2020-11-25	12.00	14.00	f	\N	1	\N
109	2	2020-11-25	14.00	16.00	f	\N	1	\N
133	2	2020-11-25	10.00	12.00	f	\N	1	\N
133	2	2020-11-25	12.00	14.00	f	\N	1	\N
133	2	2020-11-25	14.00	16.00	f	\N	1	\N
134	2	2020-11-25	10.00	12.00	f	\N	1	\N
134	2	2020-11-25	12.00	14.00	f	\N	1	\N
134	2	2020-11-25	14.00	16.00	f	\N	1	\N
128	2	2020-11-25	10.00	12.00	f	\N	1	\N
85	1	2020-11-29	6.00	8.00	f	\N	1	\N
85	1	2020-11-29	8.00	10.00	f	\N	1	\N
85	1	2020-11-29	10.00	12.00	f	\N	1	\N
85	1	2020-11-29	12.00	14.00	f	\N	1	\N
85	1	2020-11-29	14.00	16.00	f	\N	1	\N
85	1	2020-11-29	16.00	18.00	f	\N	1	\N
307	1	2020-11-25	10.00	12.00	t	5151498445	2	Wernheden
112	2	2020-11-19	12.00	14.00	f	\N	1	\N
112	2	2020-11-19	14.00	16.00	f	\N	1	\N
307	1	2020-11-25	12.00	14.00	t	5151498445	2	Wernheden
85	1	2020-11-29	18.00	20.00	f	\N	1	\N
128	2	2020-11-25	12.00	14.00	f	\N	1	\N
128	2	2020-11-25	14.00	16.00	f	\N	1	\N
127	2	2020-11-25	10.00	12.00	f	\N	1	\N
127	2	2020-11-25	12.00	14.00	f	\N	1	\N
127	2	2020-11-25	14.00	16.00	f	\N	1	\N
126	2	2020-11-25	10.00	12.00	f	\N	1	\N
126	2	2020-11-25	12.00	14.00	f	\N	1	\N
126	2	2020-11-25	14.00	16.00	f	\N	1	\N
125	2	2020-11-25	10.00	12.00	f	\N	1	\N
125	2	2020-11-25	12.00	14.00	f	\N	1	\N
125	2	2020-11-25	14.00	16.00	f	\N	1	\N
132	2	2020-11-25	10.00	12.00	f	\N	1	\N
132	2	2020-11-25	12.00	14.00	f	\N	1	\N
132	2	2020-11-25	14.00	16.00	f	\N	1	\N
131	2	2020-11-25	10.00	12.00	f	\N	1	\N
131	2	2020-11-25	12.00	14.00	f	\N	1	\N
131	2	2020-11-25	14.00	16.00	f	\N	1	\N
130	2	2020-11-25	10.00	12.00	f	\N	1	\N
130	2	2020-11-25	12.00	14.00	f	\N	1	\N
130	2	2020-11-25	14.00	16.00	f	\N	1	\N
129	2	2020-11-25	10.00	12.00	f	\N	1	\N
129	2	2020-11-25	12.00	14.00	f	\N	1	\N
129	2	2020-11-25	14.00	16.00	f	\N	1	\N
124	2	2020-11-25	10.00	12.00	f	\N	1	\N
124	2	2020-11-25	12.00	14.00	f	\N	1	\N
124	2	2020-11-25	14.00	16.00	f	\N	1	\N
117	2	2020-11-25	10.00	12.00	f	\N	1	\N
117	2	2020-11-25	12.00	14.00	f	\N	1	\N
117	2	2020-11-25	14.00	16.00	f	\N	1	\N
123	2	2020-11-25	10.00	12.00	f	\N	1	\N
123	2	2020-11-25	12.00	14.00	f	\N	1	\N
123	2	2020-11-25	14.00	16.00	f	\N	1	\N
121	2	2020-11-25	10.00	12.00	f	\N	1	\N
121	2	2020-11-25	12.00	14.00	f	\N	1	\N
121	2	2020-11-25	14.00	16.00	f	\N	1	\N
119	2	2020-11-25	10.00	12.00	f	\N	1	\N
119	2	2020-11-25	12.00	14.00	f	\N	1	\N
119	2	2020-11-25	14.00	16.00	f	\N	1	\N
118	2	2020-11-25	10.00	12.00	f	\N	1	\N
118	2	2020-11-25	12.00	14.00	f	\N	1	\N
118	2	2020-11-25	14.00	16.00	f	\N	1	\N
110	2	2020-11-25	10.00	12.00	f	\N	1	\N
110	2	2020-11-25	12.00	14.00	f	\N	1	\N
110	2	2020-11-25	14.00	16.00	f	\N	1	\N
108	2	2020-11-25	10.00	12.00	f	\N	1	\N
108	2	2020-11-25	12.00	14.00	f	\N	1	\N
108	2	2020-11-25	14.00	16.00	f	\N	1	\N
116	2	2020-11-25	10.00	12.00	f	\N	1	\N
116	2	2020-11-25	12.00	14.00	f	\N	1	\N
116	2	2020-11-25	14.00	16.00	f	\N	1	\N
115	2	2020-11-25	10.00	12.00	f	\N	1	\N
115	2	2020-11-25	12.00	14.00	f	\N	1	\N
115	2	2020-11-25	14.00	16.00	f	\N	1	\N
114	2	2020-11-25	10.00	12.00	f	\N	1	\N
114	2	2020-11-25	12.00	14.00	f	\N	1	\N
114	2	2020-11-25	14.00	16.00	f	\N	1	\N
113	2	2020-11-25	10.00	12.00	f	\N	1	\N
113	2	2020-11-25	12.00	14.00	f	\N	1	\N
113	2	2020-11-25	14.00	16.00	f	\N	1	\N
120	2	2020-11-25	10.00	12.00	f	\N	1	\N
120	2	2020-11-25	12.00	14.00	f	\N	1	\N
120	2	2020-11-25	14.00	16.00	f	\N	1	\N
286	3	2020-11-25	10.00	12.00	f	\N	1	\N
286	3	2020-11-25	12.00	14.00	f	\N	1	\N
286	3	2020-11-25	14.00	16.00	f	\N	1	\N
89	1	2020-11-25	9.00	11.00	f	\N	1	\N
89	1	2020-11-25	11.00	13.00	f	\N	1	\N
89	1	2020-11-25	13.00	15.00	f	\N	1	\N
89	1	2020-11-25	15.00	17.00	f	\N	1	\N
89	1	2020-11-25	17.00	18.00	f	\N	1	\N
300	1	2020-11-25	9.00	11.00	f	\N	1	\N
300	1	2020-11-25	11.00	13.00	f	\N	1	\N
300	1	2020-11-25	13.00	15.00	f	\N	1	\N
300	1	2020-11-25	15.00	17.00	f	\N	1	\N
300	1	2020-11-25	17.00	18.00	f	\N	1	\N
298	1	2020-11-25	9.00	11.00	f	\N	1	\N
298	1	2020-11-25	11.00	13.00	f	\N	1	\N
298	1	2020-11-25	13.00	15.00	f	\N	1	\N
298	1	2020-11-25	15.00	17.00	f	\N	1	\N
298	1	2020-11-25	17.00	18.00	f	\N	1	\N
95	1	2020-11-25	9.00	11.00	f	\N	1	\N
95	1	2020-11-25	11.00	13.00	f	\N	1	\N
95	1	2020-11-25	13.00	15.00	f	\N	1	\N
95	1	2020-11-25	15.00	17.00	f	\N	1	\N
95	1	2020-11-25	17.00	18.00	f	\N	1	\N
90	1	2020-11-25	9.00	11.00	f	\N	1	\N
90	1	2020-11-25	11.00	13.00	f	\N	1	\N
90	1	2020-11-25	13.00	15.00	f	\N	1	\N
90	1	2020-11-25	15.00	17.00	f	\N	1	\N
90	1	2020-11-25	17.00	18.00	f	\N	1	\N
94	1	2020-11-25	9.00	11.00	f	\N	1	\N
94	1	2020-11-25	11.00	13.00	f	\N	1	\N
94	1	2020-11-25	13.00	15.00	f	\N	1	\N
94	1	2020-11-25	15.00	17.00	f	\N	1	\N
94	1	2020-11-25	17.00	18.00	f	\N	1	\N
92	1	2020-11-25	9.00	11.00	f	\N	1	\N
92	1	2020-11-25	11.00	13.00	f	\N	1	\N
92	1	2020-11-25	13.00	15.00	f	\N	1	\N
92	1	2020-11-25	15.00	17.00	f	\N	1	\N
92	1	2020-11-25	17.00	18.00	f	\N	1	\N
93	1	2020-11-25	9.00	11.00	f	\N	1	\N
85	1	2020-11-29	20.00	22.00	f	\N	1	\N
85	1	2020-11-29	22.00	23.00	f	\N	1	\N
111	2	2020-11-19	10.00	12.00	f	\N	1	\N
111	2	2020-11-19	12.00	14.00	f	\N	1	\N
111	2	2020-11-19	14.00	16.00	f	\N	1	\N
106	2	2020-11-19	10.00	12.00	f	\N	1	\N
106	2	2020-11-19	12.00	14.00	f	\N	1	\N
106	2	2020-11-19	14.00	16.00	f	\N	1	\N
107	2	2020-11-19	10.00	12.00	f	\N	1	\N
107	2	2020-11-19	12.00	14.00	f	\N	1	\N
107	2	2020-11-19	14.00	16.00	f	\N	1	\N
109	2	2020-11-19	10.00	12.00	f	\N	1	\N
109	2	2020-11-19	12.00	14.00	f	\N	1	\N
109	2	2020-11-19	14.00	16.00	f	\N	1	\N
133	2	2020-11-19	10.00	12.00	f	\N	1	\N
133	2	2020-11-19	12.00	14.00	f	\N	1	\N
133	2	2020-11-19	14.00	16.00	f	\N	1	\N
134	2	2020-11-19	10.00	12.00	f	\N	1	\N
134	2	2020-11-19	12.00	14.00	f	\N	1	\N
134	2	2020-11-19	14.00	16.00	f	\N	1	\N
128	2	2020-11-19	10.00	12.00	f	\N	1	\N
128	2	2020-11-19	12.00	14.00	f	\N	1	\N
128	2	2020-11-19	14.00	16.00	f	\N	1	\N
127	2	2020-11-19	10.00	12.00	f	\N	1	\N
303	1	2020-11-29	6.00	8.00	f	\N	1	\N
127	2	2020-11-19	12.00	14.00	f	\N	1	\N
303	1	2020-11-29	8.00	10.00	f	\N	1	\N
303	1	2020-11-29	10.00	12.00	f	\N	1	\N
303	1	2020-11-29	12.00	14.00	f	\N	1	\N
303	1	2020-11-29	14.00	16.00	f	\N	1	\N
303	1	2020-11-29	16.00	18.00	f	\N	1	\N
303	1	2020-11-29	18.00	20.00	f	\N	1	\N
303	1	2020-11-29	20.00	22.00	f	\N	1	\N
303	1	2020-11-29	22.00	23.00	f	\N	1	\N
304	1	2020-11-29	6.00	8.00	f	\N	1	\N
304	1	2020-11-29	8.00	10.00	f	\N	1	\N
304	1	2020-11-29	10.00	12.00	f	\N	1	\N
304	1	2020-11-29	12.00	14.00	f	\N	1	\N
304	1	2020-11-29	14.00	16.00	f	\N	1	\N
304	1	2020-11-29	16.00	18.00	f	\N	1	\N
304	1	2020-11-29	18.00	20.00	f	\N	1	\N
304	1	2020-11-29	20.00	22.00	f	\N	1	\N
304	1	2020-11-29	22.00	23.00	f	\N	1	\N
268	2	2020-11-29	6.00	8.00	f	\N	1	\N
268	2	2020-11-29	8.00	10.00	f	\N	1	\N
268	2	2020-11-29	10.00	12.00	f	\N	1	\N
268	2	2020-11-29	12.00	14.00	f	\N	1	\N
268	2	2020-11-29	14.00	16.00	f	\N	1	\N
268	2	2020-11-29	16.00	18.00	f	\N	1	\N
93	1	2020-11-25	11.00	13.00	f	\N	1	\N
93	1	2020-11-25	13.00	15.00	f	\N	1	\N
93	1	2020-11-25	15.00	17.00	f	\N	1	\N
93	1	2020-11-25	17.00	18.00	f	\N	1	\N
96	1	2020-11-25	9.00	11.00	f	\N	1	\N
96	1	2020-11-25	11.00	13.00	f	\N	1	\N
96	1	2020-11-25	13.00	15.00	f	\N	1	\N
96	1	2020-11-25	15.00	17.00	f	\N	1	\N
96	1	2020-11-25	17.00	18.00	f	\N	1	\N
91	1	2020-11-25	9.00	11.00	f	\N	1	\N
91	1	2020-11-25	11.00	13.00	f	\N	1	\N
91	1	2020-11-25	13.00	15.00	f	\N	1	\N
91	1	2020-11-25	15.00	17.00	f	\N	1	\N
91	1	2020-11-25	17.00	18.00	f	\N	1	\N
301	1	2020-11-25	9.00	11.00	f	\N	1	\N
301	1	2020-11-25	11.00	13.00	f	\N	1	\N
301	1	2020-11-25	13.00	15.00	f	\N	1	\N
301	1	2020-11-25	15.00	17.00	f	\N	1	\N
301	1	2020-11-25	17.00	18.00	f	\N	1	\N
127	2	2020-11-19	14.00	16.00	f	\N	1	\N
126	2	2020-11-19	10.00	12.00	f	\N	1	\N
126	2	2020-11-19	12.00	14.00	f	\N	1	\N
126	2	2020-11-19	14.00	16.00	f	\N	1	\N
125	2	2020-11-19	10.00	12.00	f	\N	1	\N
125	2	2020-11-19	12.00	14.00	f	\N	1	\N
299	1	2020-11-25	9.00	11.00	f	\N	1	\N
299	1	2020-11-25	11.00	13.00	f	\N	1	\N
125	2	2020-11-19	14.00	16.00	f	\N	1	\N
268	2	2020-11-29	18.00	20.00	f	\N	1	\N
268	2	2020-11-29	20.00	22.00	f	\N	1	\N
268	2	2020-11-29	22.00	23.00	f	\N	1	\N
313	3	2020-11-29	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-29	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-29	10.00	12.00	t	1122334455	5	Stängt
313	3	2020-11-29	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-29	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-29	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-29	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-29	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-29	22.00	23.00	t	1122334455	5	Stängt
134	2	2020-12-02	12.00	14.00	f	\N	1	\N
134	2	2020-12-02	14.00	16.00	f	\N	1	\N
128	2	2020-12-02	10.00	12.00	f	\N	1	\N
128	2	2020-12-02	12.00	14.00	f	\N	1	\N
128	2	2020-12-02	14.00	16.00	f	\N	1	\N
127	2	2020-12-02	10.00	12.00	f	\N	1	\N
127	2	2020-12-02	12.00	14.00	f	\N	1	\N
127	2	2020-12-02	14.00	16.00	f	\N	1	\N
126	2	2020-12-02	10.00	12.00	f	\N	1	\N
126	2	2020-12-02	12.00	14.00	f	\N	1	\N
126	2	2020-12-02	14.00	16.00	f	\N	1	\N
125	2	2020-12-02	10.00	12.00	f	\N	1	\N
125	2	2020-12-02	12.00	14.00	f	\N	1	\N
125	2	2020-12-02	14.00	16.00	f	\N	1	\N
132	2	2020-12-02	10.00	12.00	f	\N	1	\N
132	2	2020-12-02	12.00	14.00	f	\N	1	\N
132	2	2020-12-02	14.00	16.00	f	\N	1	\N
131	2	2020-12-02	10.00	12.00	f	\N	1	\N
131	2	2020-12-02	12.00	14.00	f	\N	1	\N
131	2	2020-12-02	14.00	16.00	f	\N	1	\N
130	2	2020-12-02	10.00	12.00	f	\N	1	\N
130	2	2020-12-02	12.00	14.00	f	\N	1	\N
130	2	2020-12-02	14.00	16.00	f	\N	1	\N
129	2	2020-12-02	10.00	12.00	f	\N	1	\N
129	2	2020-12-02	12.00	14.00	f	\N	1	\N
129	2	2020-12-02	14.00	16.00	f	\N	1	\N
124	2	2020-12-02	10.00	12.00	f	\N	1	\N
124	2	2020-12-02	12.00	14.00	f	\N	1	\N
124	2	2020-12-02	14.00	16.00	f	\N	1	\N
117	2	2020-12-02	10.00	12.00	f	\N	1	\N
117	2	2020-12-02	12.00	14.00	f	\N	1	\N
117	2	2020-12-02	14.00	16.00	f	\N	1	\N
123	2	2020-12-02	10.00	12.00	f	\N	1	\N
132	2	2020-11-19	10.00	12.00	f	\N	1	\N
132	2	2020-11-19	12.00	14.00	f	\N	1	\N
132	2	2020-11-19	14.00	16.00	f	\N	1	\N
131	2	2020-11-19	10.00	12.00	f	\N	1	\N
131	2	2020-11-19	12.00	14.00	f	\N	1	\N
123	2	2020-12-02	12.00	14.00	f	\N	1	\N
123	2	2020-12-02	14.00	16.00	f	\N	1	\N
121	2	2020-12-02	10.00	12.00	f	\N	1	\N
121	2	2020-12-02	12.00	14.00	f	\N	1	\N
121	2	2020-12-02	14.00	16.00	f	\N	1	\N
119	2	2020-12-02	10.00	12.00	f	\N	1	\N
119	2	2020-12-02	12.00	14.00	f	\N	1	\N
119	2	2020-12-02	14.00	16.00	f	\N	1	\N
118	2	2020-12-02	10.00	12.00	f	\N	1	\N
118	2	2020-12-02	12.00	14.00	f	\N	1	\N
118	2	2020-12-02	14.00	16.00	f	\N	1	\N
110	2	2020-12-02	10.00	12.00	f	\N	1	\N
110	2	2020-12-02	12.00	14.00	f	\N	1	\N
110	2	2020-12-02	14.00	16.00	f	\N	1	\N
108	2	2020-12-02	10.00	12.00	f	\N	1	\N
108	2	2020-12-02	12.00	14.00	f	\N	1	\N
108	2	2020-12-02	14.00	16.00	f	\N	1	\N
116	2	2020-12-02	10.00	12.00	f	\N	1	\N
116	2	2020-12-02	12.00	14.00	f	\N	1	\N
116	2	2020-12-02	14.00	16.00	f	\N	1	\N
115	2	2020-12-02	10.00	12.00	f	\N	1	\N
115	2	2020-12-02	12.00	14.00	f	\N	1	\N
115	2	2020-12-02	14.00	16.00	f	\N	1	\N
114	2	2020-12-02	10.00	12.00	f	\N	1	\N
114	2	2020-12-02	12.00	14.00	f	\N	1	\N
114	2	2020-12-02	14.00	16.00	f	\N	1	\N
113	2	2020-12-02	10.00	12.00	f	\N	1	\N
113	2	2020-12-02	12.00	14.00	f	\N	1	\N
113	2	2020-12-02	14.00	16.00	f	\N	1	\N
120	2	2020-12-02	10.00	12.00	f	\N	1	\N
120	2	2020-12-02	12.00	14.00	f	\N	1	\N
120	2	2020-12-02	14.00	16.00	f	\N	1	\N
286	3	2020-12-02	10.00	12.00	f	\N	1	\N
286	3	2020-12-02	12.00	14.00	f	\N	1	\N
286	3	2020-12-02	14.00	16.00	f	\N	1	\N
89	1	2020-12-02	9.00	11.00	f	\N	1	\N
89	1	2020-12-02	11.00	13.00	f	\N	1	\N
89	1	2020-12-02	13.00	15.00	f	\N	1	\N
89	1	2020-12-02	15.00	17.00	f	\N	1	\N
89	1	2020-12-02	17.00	18.00	f	\N	1	\N
300	1	2020-12-02	9.00	11.00	f	\N	1	\N
300	1	2020-12-02	11.00	13.00	f	\N	1	\N
300	1	2020-12-02	13.00	15.00	f	\N	1	\N
300	1	2020-12-02	15.00	17.00	f	\N	1	\N
300	1	2020-12-02	17.00	18.00	f	\N	1	\N
298	1	2020-12-02	9.00	11.00	f	\N	1	\N
298	1	2020-12-02	11.00	13.00	f	\N	1	\N
298	1	2020-12-02	13.00	15.00	f	\N	1	\N
298	1	2020-12-02	15.00	17.00	f	\N	1	\N
298	1	2020-12-02	17.00	18.00	f	\N	1	\N
95	1	2020-12-02	9.00	11.00	f	\N	1	\N
95	1	2020-12-02	11.00	13.00	f	\N	1	\N
95	1	2020-12-02	13.00	15.00	f	\N	1	\N
95	1	2020-12-02	15.00	17.00	f	\N	1	\N
95	1	2020-12-02	17.00	18.00	f	\N	1	\N
90	1	2020-12-02	9.00	11.00	f	\N	1	\N
90	1	2020-12-02	11.00	13.00	f	\N	1	\N
90	1	2020-12-02	13.00	15.00	f	\N	1	\N
90	1	2020-12-02	15.00	17.00	f	\N	1	\N
90	1	2020-12-02	17.00	18.00	f	\N	1	\N
94	1	2020-12-02	9.00	11.00	f	\N	1	\N
94	1	2020-12-02	11.00	13.00	f	\N	1	\N
94	1	2020-12-02	13.00	15.00	f	\N	1	\N
94	1	2020-12-02	15.00	17.00	f	\N	1	\N
94	1	2020-12-02	17.00	18.00	f	\N	1	\N
92	1	2020-12-02	9.00	11.00	f	\N	1	\N
92	1	2020-12-02	11.00	13.00	f	\N	1	\N
92	1	2020-12-02	13.00	15.00	f	\N	1	\N
92	1	2020-12-02	15.00	17.00	f	\N	1	\N
92	1	2020-12-02	17.00	18.00	f	\N	1	\N
93	1	2020-12-02	9.00	11.00	f	\N	1	\N
93	1	2020-12-02	11.00	13.00	f	\N	1	\N
93	1	2020-12-02	13.00	15.00	f	\N	1	\N
93	1	2020-12-02	15.00	17.00	f	\N	1	\N
93	1	2020-12-02	17.00	18.00	f	\N	1	\N
96	1	2020-12-02	9.00	11.00	f	\N	1	\N
96	1	2020-12-02	11.00	13.00	f	\N	1	\N
96	1	2020-12-02	13.00	15.00	f	\N	1	\N
96	1	2020-12-02	15.00	17.00	f	\N	1	\N
96	1	2020-12-02	17.00	18.00	f	\N	1	\N
91	1	2020-12-02	9.00	11.00	f	\N	1	\N
91	1	2020-12-02	11.00	13.00	f	\N	1	\N
91	1	2020-12-02	13.00	15.00	f	\N	1	\N
91	1	2020-12-02	15.00	17.00	f	\N	1	\N
91	1	2020-12-02	17.00	18.00	f	\N	1	\N
301	1	2020-12-02	9.00	11.00	f	\N	1	\N
301	1	2020-12-02	11.00	13.00	f	\N	1	\N
301	1	2020-12-02	13.00	15.00	f	\N	1	\N
301	1	2020-12-02	15.00	17.00	f	\N	1	\N
301	1	2020-12-02	17.00	18.00	f	\N	1	\N
299	1	2020-12-02	9.00	11.00	f	\N	1	\N
299	1	2020-12-02	11.00	13.00	f	\N	1	\N
299	1	2020-12-02	13.00	15.00	f	\N	1	\N
299	1	2020-12-02	15.00	17.00	f	\N	1	\N
299	1	2020-12-02	17.00	18.00	f	\N	1	\N
176	2	2020-12-02	9.00	11.00	f	\N	1	\N
176	2	2020-12-02	11.00	13.00	f	\N	1	\N
176	2	2020-12-02	13.00	15.00	f	\N	1	\N
176	2	2020-12-02	15.00	17.00	f	\N	1	\N
176	2	2020-12-02	17.00	18.00	f	\N	1	\N
175	2	2020-12-02	9.00	11.00	f	\N	1	\N
175	2	2020-12-02	11.00	13.00	f	\N	1	\N
175	2	2020-12-02	13.00	15.00	f	\N	1	\N
175	2	2020-12-02	15.00	17.00	f	\N	1	\N
175	2	2020-12-02	17.00	18.00	f	\N	1	\N
174	2	2020-12-02	9.00	11.00	f	\N	1	\N
174	2	2020-12-02	11.00	13.00	f	\N	1	\N
174	2	2020-12-02	13.00	15.00	f	\N	1	\N
174	2	2020-12-02	15.00	17.00	f	\N	1	\N
174	2	2020-12-02	17.00	18.00	f	\N	1	\N
131	2	2020-11-19	14.00	16.00	f	\N	1	\N
130	2	2020-11-19	10.00	12.00	f	\N	1	\N
299	1	2020-11-25	13.00	15.00	f	\N	1	\N
299	1	2020-11-25	15.00	17.00	f	\N	1	\N
299	1	2020-11-25	17.00	18.00	f	\N	1	\N
176	2	2020-11-25	9.00	11.00	f	\N	1	\N
179	2	2020-12-02	9.00	11.00	f	\N	1	\N
179	2	2020-12-02	11.00	13.00	f	\N	1	\N
179	2	2020-12-02	13.00	15.00	f	\N	1	\N
179	2	2020-12-02	15.00	17.00	f	\N	1	\N
179	2	2020-12-02	17.00	18.00	f	\N	1	\N
130	2	2020-11-19	12.00	14.00	f	\N	1	\N
130	2	2020-11-19	14.00	16.00	f	\N	1	\N
178	2	2020-12-02	9.00	11.00	f	\N	1	\N
178	2	2020-12-02	11.00	13.00	f	\N	1	\N
178	2	2020-12-02	13.00	15.00	f	\N	1	\N
178	2	2020-12-02	15.00	17.00	f	\N	1	\N
178	2	2020-12-02	17.00	18.00	f	\N	1	\N
177	2	2020-12-02	9.00	11.00	f	\N	1	\N
177	2	2020-12-02	11.00	13.00	f	\N	1	\N
177	2	2020-12-02	13.00	15.00	f	\N	1	\N
177	2	2020-12-02	15.00	17.00	f	\N	1	\N
177	2	2020-12-02	17.00	18.00	f	\N	1	\N
192	2	2020-12-02	9.00	11.00	f	\N	1	\N
192	2	2020-12-02	11.00	13.00	f	\N	1	\N
192	2	2020-12-02	13.00	15.00	f	\N	1	\N
192	2	2020-12-02	15.00	17.00	f	\N	1	\N
192	2	2020-12-02	17.00	18.00	f	\N	1	\N
193	2	2020-12-02	9.00	11.00	f	\N	1	\N
193	2	2020-12-02	11.00	13.00	f	\N	1	\N
193	2	2020-12-02	13.00	15.00	f	\N	1	\N
193	2	2020-12-02	15.00	17.00	f	\N	1	\N
193	2	2020-12-02	17.00	18.00	f	\N	1	\N
302	3	2020-12-02	9.00	11.00	f	\N	1	\N
302	3	2020-12-02	11.00	13.00	f	\N	1	\N
302	3	2020-12-02	13.00	15.00	f	\N	1	\N
302	3	2020-12-02	15.00	17.00	f	\N	1	\N
302	3	2020-12-02	17.00	18.00	f	\N	1	\N
305	3	2020-12-02	9.00	11.00	f	\N	1	\N
305	3	2020-12-02	11.00	13.00	f	\N	1	\N
305	3	2020-12-02	13.00	15.00	f	\N	1	\N
305	3	2020-12-02	15.00	17.00	f	\N	1	\N
305	3	2020-12-02	17.00	18.00	f	\N	1	\N
314	3	2020-12-02	9.00	11.00	f	\N	1	\N
314	3	2020-12-02	11.00	13.00	f	\N	1	\N
314	3	2020-12-02	13.00	15.00	f	\N	1	\N
314	3	2020-12-02	15.00	17.00	f	\N	1	\N
314	3	2020-12-02	17.00	18.00	f	\N	1	\N
306	3	2020-12-02	9.00	11.00	f	\N	1	\N
306	3	2020-12-02	11.00	13.00	f	\N	1	\N
306	3	2020-12-02	13.00	15.00	f	\N	1	\N
306	3	2020-12-02	15.00	17.00	f	\N	1	\N
306	3	2020-12-02	17.00	18.00	f	\N	1	\N
215	1	2020-12-02	6.00	8.00	f	\N	1	\N
215	1	2020-12-02	8.00	10.00	f	\N	1	\N
215	1	2020-12-02	10.00	12.00	f	\N	1	\N
215	1	2020-12-02	12.00	14.00	f	\N	1	\N
215	1	2020-12-02	14.00	16.00	f	\N	1	\N
215	1	2020-12-02	16.00	18.00	f	\N	1	\N
215	1	2020-12-02	18.00	20.00	f	\N	1	\N
215	1	2020-12-02	20.00	22.00	f	\N	1	\N
215	1	2020-12-02	22.00	23.00	f	\N	1	\N
231	1	2020-12-02	6.00	8.00	f	\N	1	\N
231	1	2020-12-02	8.00	10.00	f	\N	1	\N
231	1	2020-12-02	10.00	12.00	f	\N	1	\N
231	1	2020-12-02	12.00	14.00	f	\N	1	\N
231	1	2020-12-02	14.00	16.00	f	\N	1	\N
231	1	2020-12-02	16.00	18.00	f	\N	1	\N
231	1	2020-12-02	18.00	20.00	f	\N	1	\N
231	1	2020-12-02	20.00	22.00	f	\N	1	\N
231	1	2020-12-02	22.00	23.00	f	\N	1	\N
88	1	2020-12-02	6.00	8.00	f	\N	1	\N
88	1	2020-12-02	8.00	10.00	f	\N	1	\N
88	1	2020-12-02	10.00	12.00	f	\N	1	\N
88	1	2020-12-02	12.00	14.00	f	\N	1	\N
88	1	2020-12-02	14.00	16.00	f	\N	1	\N
88	1	2020-12-02	16.00	18.00	f	\N	1	\N
88	1	2020-12-02	18.00	20.00	f	\N	1	\N
88	1	2020-12-02	20.00	22.00	f	\N	1	\N
88	1	2020-12-02	22.00	23.00	f	\N	1	\N
80	1	2020-12-02	6.00	8.00	f	\N	1	\N
80	1	2020-12-02	8.00	10.00	f	\N	1	\N
80	1	2020-12-02	10.00	12.00	f	\N	1	\N
80	1	2020-12-02	12.00	14.00	f	\N	1	\N
80	1	2020-12-02	14.00	16.00	f	\N	1	\N
80	1	2020-12-02	16.00	18.00	f	\N	1	\N
80	1	2020-12-02	18.00	20.00	f	\N	1	\N
80	1	2020-12-02	20.00	22.00	f	\N	1	\N
80	1	2020-12-02	22.00	23.00	f	\N	1	\N
216	1	2020-12-02	6.00	8.00	f	\N	1	\N
216	1	2020-12-02	8.00	10.00	f	\N	1	\N
216	1	2020-12-02	10.00	12.00	f	\N	1	\N
216	1	2020-12-02	12.00	14.00	f	\N	1	\N
216	1	2020-12-02	14.00	16.00	f	\N	1	\N
216	1	2020-12-02	16.00	18.00	f	\N	1	\N
216	1	2020-12-02	18.00	20.00	f	\N	1	\N
216	1	2020-12-02	20.00	22.00	f	\N	1	\N
216	1	2020-12-02	22.00	23.00	f	\N	1	\N
191	1	2020-12-02	6.00	8.00	f	\N	1	\N
191	1	2020-12-02	8.00	10.00	f	\N	1	\N
191	1	2020-12-02	10.00	12.00	f	\N	1	\N
191	1	2020-12-02	12.00	14.00	f	\N	1	\N
191	1	2020-12-02	14.00	16.00	f	\N	1	\N
191	1	2020-12-02	16.00	18.00	f	\N	1	\N
191	1	2020-12-02	18.00	20.00	f	\N	1	\N
191	1	2020-12-02	20.00	22.00	f	\N	1	\N
129	2	2020-11-19	10.00	12.00	f	\N	1	\N
129	2	2020-11-19	12.00	14.00	f	\N	1	\N
129	2	2020-11-19	14.00	16.00	f	\N	1	\N
124	2	2020-11-19	10.00	12.00	f	\N	1	\N
124	2	2020-11-19	12.00	14.00	f	\N	1	\N
176	2	2020-11-25	11.00	13.00	f	\N	1	\N
176	2	2020-11-25	13.00	15.00	f	\N	1	\N
176	2	2020-11-25	15.00	17.00	f	\N	1	\N
176	2	2020-11-25	17.00	18.00	f	\N	1	\N
175	2	2020-11-25	9.00	11.00	f	\N	1	\N
175	2	2020-11-25	11.00	13.00	f	\N	1	\N
175	2	2020-11-25	13.00	15.00	f	\N	1	\N
175	2	2020-11-25	15.00	17.00	f	\N	1	\N
175	2	2020-11-25	17.00	18.00	f	\N	1	\N
174	2	2020-11-25	9.00	11.00	f	\N	1	\N
174	2	2020-11-25	11.00	13.00	f	\N	1	\N
174	2	2020-11-25	13.00	15.00	f	\N	1	\N
174	2	2020-11-25	15.00	17.00	f	\N	1	\N
191	1	2020-12-02	22.00	23.00	f	\N	1	\N
81	1	2020-12-02	6.00	8.00	f	\N	1	\N
81	1	2020-12-02	8.00	10.00	f	\N	1	\N
81	1	2020-12-02	10.00	12.00	f	\N	1	\N
81	1	2020-12-02	12.00	14.00	f	\N	1	\N
124	2	2020-11-19	14.00	16.00	f	\N	1	\N
81	1	2020-12-02	14.00	16.00	f	\N	1	\N
81	1	2020-12-02	16.00	18.00	f	\N	1	\N
81	1	2020-12-02	18.00	20.00	f	\N	1	\N
81	1	2020-12-02	20.00	22.00	f	\N	1	\N
81	1	2020-12-02	22.00	23.00	f	\N	1	\N
82	1	2020-12-02	6.00	8.00	f	\N	1	\N
82	1	2020-12-02	8.00	10.00	f	\N	1	\N
82	1	2020-12-02	10.00	12.00	f	\N	1	\N
82	1	2020-12-02	12.00	14.00	f	\N	1	\N
82	1	2020-12-02	14.00	16.00	f	\N	1	\N
82	1	2020-12-02	16.00	18.00	f	\N	1	\N
82	1	2020-12-02	18.00	20.00	f	\N	1	\N
82	1	2020-12-02	20.00	22.00	f	\N	1	\N
82	1	2020-12-02	22.00	23.00	f	\N	1	\N
87	1	2020-12-02	6.00	8.00	f	\N	1	\N
87	1	2020-12-02	8.00	10.00	f	\N	1	\N
87	1	2020-12-02	10.00	12.00	f	\N	1	\N
87	1	2020-12-02	12.00	14.00	f	\N	1	\N
87	1	2020-12-02	14.00	16.00	f	\N	1	\N
87	1	2020-12-02	16.00	18.00	f	\N	1	\N
87	1	2020-12-02	18.00	20.00	f	\N	1	\N
87	1	2020-12-02	20.00	22.00	f	\N	1	\N
87	1	2020-12-02	22.00	23.00	f	\N	1	\N
86	1	2020-12-02	6.00	8.00	f	\N	1	\N
86	1	2020-12-02	8.00	10.00	f	\N	1	\N
86	1	2020-12-02	10.00	12.00	f	\N	1	\N
86	1	2020-12-02	12.00	14.00	f	\N	1	\N
86	1	2020-12-02	14.00	16.00	f	\N	1	\N
86	1	2020-12-02	16.00	18.00	f	\N	1	\N
86	1	2020-12-02	18.00	20.00	f	\N	1	\N
86	1	2020-12-02	20.00	22.00	f	\N	1	\N
86	1	2020-12-02	22.00	23.00	f	\N	1	\N
201	1	2020-12-02	6.00	8.00	f	\N	1	\N
201	1	2020-12-02	8.00	10.00	f	\N	1	\N
201	1	2020-12-02	10.00	12.00	f	\N	1	\N
201	1	2020-12-02	12.00	14.00	f	\N	1	\N
201	1	2020-12-02	14.00	16.00	f	\N	1	\N
201	1	2020-12-02	16.00	18.00	f	\N	1	\N
201	1	2020-12-02	18.00	20.00	f	\N	1	\N
201	1	2020-12-02	20.00	22.00	f	\N	1	\N
201	1	2020-12-02	22.00	23.00	f	\N	1	\N
83	1	2020-12-02	6.00	8.00	f	\N	1	\N
83	1	2020-12-02	8.00	10.00	f	\N	1	\N
83	1	2020-12-02	10.00	12.00	f	\N	1	\N
83	1	2020-12-02	12.00	14.00	f	\N	1	\N
83	1	2020-12-02	14.00	16.00	f	\N	1	\N
83	1	2020-12-02	16.00	18.00	f	\N	1	\N
83	1	2020-12-02	18.00	20.00	f	\N	1	\N
83	1	2020-12-02	20.00	22.00	f	\N	1	\N
83	1	2020-12-02	22.00	23.00	f	\N	1	\N
84	1	2020-12-02	6.00	8.00	f	\N	1	\N
84	1	2020-12-02	8.00	10.00	f	\N	1	\N
84	1	2020-12-02	10.00	12.00	f	\N	1	\N
84	1	2020-12-02	12.00	14.00	f	\N	1	\N
84	1	2020-12-02	14.00	16.00	f	\N	1	\N
84	1	2020-12-02	16.00	18.00	f	\N	1	\N
84	1	2020-12-02	18.00	20.00	f	\N	1	\N
84	1	2020-12-02	20.00	22.00	f	\N	1	\N
84	1	2020-12-02	22.00	23.00	f	\N	1	\N
194	1	2020-12-02	6.00	8.00	f	\N	1	\N
194	1	2020-12-02	8.00	10.00	f	\N	1	\N
194	1	2020-12-02	10.00	12.00	f	\N	1	\N
194	1	2020-12-02	12.00	14.00	f	\N	1	\N
194	1	2020-12-02	14.00	16.00	f	\N	1	\N
194	1	2020-12-02	16.00	18.00	f	\N	1	\N
194	1	2020-12-02	18.00	20.00	f	\N	1	\N
194	1	2020-12-02	20.00	22.00	f	\N	1	\N
194	1	2020-12-02	22.00	23.00	f	\N	1	\N
85	1	2020-12-02	6.00	8.00	f	\N	1	\N
85	1	2020-12-02	8.00	10.00	f	\N	1	\N
85	1	2020-12-02	10.00	12.00	f	\N	1	\N
85	1	2020-12-02	12.00	14.00	f	\N	1	\N
85	1	2020-12-02	14.00	16.00	f	\N	1	\N
85	1	2020-12-02	16.00	18.00	f	\N	1	\N
85	1	2020-12-02	18.00	20.00	f	\N	1	\N
85	1	2020-12-02	20.00	22.00	f	\N	1	\N
85	1	2020-12-02	22.00	23.00	f	\N	1	\N
303	1	2020-12-02	6.00	8.00	f	\N	1	\N
303	1	2020-12-02	8.00	10.00	f	\N	1	\N
303	1	2020-12-02	10.00	12.00	f	\N	1	\N
303	1	2020-12-02	12.00	14.00	f	\N	1	\N
303	1	2020-12-02	14.00	16.00	f	\N	1	\N
303	1	2020-12-02	16.00	18.00	f	\N	1	\N
303	1	2020-12-02	18.00	20.00	f	\N	1	\N
303	1	2020-12-02	20.00	22.00	f	\N	1	\N
303	1	2020-12-02	22.00	23.00	f	\N	1	\N
304	1	2020-12-02	6.00	8.00	f	\N	1	\N
304	1	2020-12-02	8.00	10.00	f	\N	1	\N
304	1	2020-12-02	10.00	12.00	f	\N	1	\N
304	1	2020-12-02	12.00	14.00	f	\N	1	\N
304	1	2020-12-02	14.00	16.00	f	\N	1	\N
304	1	2020-12-02	16.00	18.00	f	\N	1	\N
304	1	2020-12-02	18.00	20.00	f	\N	1	\N
174	2	2020-11-25	17.00	18.00	f	\N	1	\N
179	2	2020-11-25	9.00	11.00	f	\N	1	\N
117	2	2020-11-19	10.00	12.00	f	\N	1	\N
117	2	2020-11-19	12.00	14.00	f	\N	1	\N
117	2	2020-11-19	14.00	16.00	f	\N	1	\N
123	2	2020-11-19	10.00	12.00	f	\N	1	\N
123	2	2020-11-19	12.00	14.00	f	\N	1	\N
123	2	2020-11-19	14.00	16.00	f	\N	1	\N
179	2	2020-11-25	11.00	13.00	f	\N	1	\N
179	2	2020-11-25	13.00	15.00	f	\N	1	\N
179	2	2020-11-25	15.00	17.00	f	\N	1	\N
179	2	2020-11-25	17.00	18.00	f	\N	1	\N
178	2	2020-11-25	9.00	11.00	f	\N	1	\N
178	2	2020-11-25	11.00	13.00	f	\N	1	\N
178	2	2020-11-25	13.00	15.00	f	\N	1	\N
178	2	2020-11-25	15.00	17.00	f	\N	1	\N
178	2	2020-11-25	17.00	18.00	f	\N	1	\N
177	2	2020-11-25	9.00	11.00	f	\N	1	\N
177	2	2020-11-25	11.00	13.00	f	\N	1	\N
177	2	2020-11-25	13.00	15.00	f	\N	1	\N
177	2	2020-11-25	15.00	17.00	f	\N	1	\N
177	2	2020-11-25	17.00	18.00	f	\N	1	\N
192	2	2020-11-25	9.00	11.00	f	\N	1	\N
192	2	2020-11-25	11.00	13.00	f	\N	1	\N
192	2	2020-11-25	13.00	15.00	f	\N	1	\N
192	2	2020-11-25	15.00	17.00	f	\N	1	\N
192	2	2020-11-25	17.00	18.00	f	\N	1	\N
193	2	2020-11-25	9.00	11.00	f	\N	1	\N
193	2	2020-11-25	11.00	13.00	f	\N	1	\N
193	2	2020-11-25	13.00	15.00	f	\N	1	\N
193	2	2020-11-25	15.00	17.00	f	\N	1	\N
193	2	2020-11-25	17.00	18.00	f	\N	1	\N
302	3	2020-11-25	9.00	11.00	f	\N	1	\N
302	3	2020-11-25	11.00	13.00	f	\N	1	\N
302	3	2020-11-25	13.00	15.00	f	\N	1	\N
302	3	2020-11-25	15.00	17.00	f	\N	1	\N
302	3	2020-11-25	17.00	18.00	f	\N	1	\N
305	3	2020-11-25	9.00	11.00	f	\N	1	\N
305	3	2020-11-25	11.00	13.00	f	\N	1	\N
305	3	2020-11-25	13.00	15.00	f	\N	1	\N
305	3	2020-11-25	15.00	17.00	f	\N	1	\N
305	3	2020-11-25	17.00	18.00	f	\N	1	\N
314	3	2020-11-25	17.00	18.00	f	\N	1	\N
306	3	2020-11-25	9.00	11.00	f	\N	1	\N
306	3	2020-11-25	11.00	13.00	f	\N	1	\N
306	3	2020-11-25	13.00	15.00	f	\N	1	\N
306	3	2020-11-25	15.00	17.00	f	\N	1	\N
306	3	2020-11-25	17.00	18.00	f	\N	1	\N
215	1	2020-11-25	6.00	8.00	f	\N	1	\N
215	1	2020-11-25	8.00	10.00	f	\N	1	\N
215	1	2020-11-25	10.00	12.00	f	\N	1	\N
215	1	2020-11-25	12.00	14.00	f	\N	1	\N
215	1	2020-11-25	14.00	16.00	f	\N	1	\N
215	1	2020-11-25	16.00	18.00	f	\N	1	\N
215	1	2020-11-25	18.00	20.00	f	\N	1	\N
215	1	2020-11-25	20.00	22.00	f	\N	1	\N
215	1	2020-11-25	22.00	23.00	f	\N	1	\N
231	1	2020-11-25	6.00	8.00	f	\N	1	\N
231	1	2020-11-25	8.00	10.00	f	\N	1	\N
231	1	2020-11-25	10.00	12.00	f	\N	1	\N
231	1	2020-11-25	12.00	14.00	f	\N	1	\N
231	1	2020-11-25	14.00	16.00	f	\N	1	\N
231	1	2020-11-25	16.00	18.00	f	\N	1	\N
231	1	2020-11-25	18.00	20.00	f	\N	1	\N
231	1	2020-11-25	20.00	22.00	f	\N	1	\N
231	1	2020-11-25	22.00	23.00	f	\N	1	\N
88	1	2020-11-25	6.00	8.00	f	\N	1	\N
88	1	2020-11-25	8.00	10.00	f	\N	1	\N
88	1	2020-11-25	10.00	12.00	f	\N	1	\N
88	1	2020-11-25	12.00	14.00	f	\N	1	\N
88	1	2020-11-25	14.00	16.00	f	\N	1	\N
88	1	2020-11-25	16.00	18.00	f	\N	1	\N
88	1	2020-11-25	18.00	20.00	f	\N	1	\N
88	1	2020-11-25	20.00	22.00	f	\N	1	\N
88	1	2020-11-25	22.00	23.00	f	\N	1	\N
80	1	2020-11-25	6.00	8.00	f	\N	1	\N
80	1	2020-11-25	8.00	10.00	f	\N	1	\N
80	1	2020-11-25	10.00	12.00	f	\N	1	\N
80	1	2020-11-25	12.00	14.00	f	\N	1	\N
80	1	2020-11-25	14.00	16.00	f	\N	1	\N
80	1	2020-11-25	16.00	18.00	f	\N	1	\N
80	1	2020-11-25	18.00	20.00	f	\N	1	\N
80	1	2020-11-25	20.00	22.00	f	\N	1	\N
80	1	2020-11-25	22.00	23.00	f	\N	1	\N
216	1	2020-11-25	6.00	8.00	f	\N	1	\N
216	1	2020-11-25	8.00	10.00	f	\N	1	\N
216	1	2020-11-25	10.00	12.00	f	\N	1	\N
216	1	2020-11-25	12.00	14.00	f	\N	1	\N
216	1	2020-11-25	14.00	16.00	f	\N	1	\N
216	1	2020-11-25	16.00	18.00	f	\N	1	\N
216	1	2020-11-25	18.00	20.00	f	\N	1	\N
216	1	2020-11-25	20.00	22.00	f	\N	1	\N
216	1	2020-11-25	22.00	23.00	f	\N	1	\N
191	1	2020-11-25	6.00	8.00	f	\N	1	\N
191	1	2020-11-25	8.00	10.00	f	\N	1	\N
191	1	2020-11-25	10.00	12.00	f	\N	1	\N
191	1	2020-11-25	12.00	14.00	f	\N	1	\N
191	1	2020-11-25	14.00	16.00	f	\N	1	\N
191	1	2020-11-25	16.00	18.00	f	\N	1	\N
191	1	2020-11-25	18.00	20.00	f	\N	1	\N
191	1	2020-11-25	20.00	22.00	f	\N	1	\N
191	1	2020-11-25	22.00	23.00	f	\N	1	\N
81	1	2020-11-25	6.00	8.00	f	\N	1	\N
81	1	2020-11-25	8.00	10.00	f	\N	1	\N
81	1	2020-11-25	10.00	12.00	f	\N	1	\N
81	1	2020-11-25	12.00	14.00	f	\N	1	\N
81	1	2020-11-25	14.00	16.00	f	\N	1	\N
81	1	2020-11-25	16.00	18.00	f	\N	1	\N
81	1	2020-11-25	18.00	20.00	f	\N	1	\N
81	1	2020-11-25	20.00	22.00	f	\N	1	\N
81	1	2020-11-25	22.00	23.00	f	\N	1	\N
82	1	2020-11-25	6.00	8.00	f	\N	1	\N
82	1	2020-11-25	8.00	10.00	f	\N	1	\N
82	1	2020-11-25	10.00	12.00	f	\N	1	\N
82	1	2020-11-25	12.00	14.00	f	\N	1	\N
82	1	2020-11-25	14.00	16.00	f	\N	1	\N
82	1	2020-11-25	16.00	18.00	f	\N	1	\N
82	1	2020-11-25	18.00	20.00	f	\N	1	\N
82	1	2020-11-25	20.00	22.00	f	\N	1	\N
82	1	2020-11-25	22.00	23.00	f	\N	1	\N
87	1	2020-11-25	6.00	8.00	f	\N	1	\N
87	1	2020-11-25	8.00	10.00	f	\N	1	\N
87	1	2020-11-25	10.00	12.00	f	\N	1	\N
314	3	2020-11-25	15.00	17.00	t	8306227208	2	Bb
314	3	2020-11-25	9.00	11.00	t	8403704328	2	NH
314	3	2020-11-25	11.00	13.00	t	8403704328	2	NH
121	2	2020-11-19	10.00	12.00	f	\N	1	\N
121	2	2020-11-19	12.00	14.00	f	\N	1	\N
121	2	2020-11-19	14.00	16.00	f	\N	1	\N
119	2	2020-11-19	10.00	12.00	f	\N	1	\N
119	2	2020-11-19	12.00	14.00	f	\N	1	\N
119	2	2020-11-19	14.00	16.00	f	\N	1	\N
118	2	2020-11-19	10.00	12.00	f	\N	1	\N
118	2	2020-11-19	12.00	14.00	f	\N	1	\N
118	2	2020-11-19	14.00	16.00	f	\N	1	\N
110	2	2020-11-19	10.00	12.00	f	\N	1	\N
87	1	2020-11-25	12.00	14.00	f	\N	1	\N
304	1	2020-12-02	20.00	22.00	f	\N	1	\N
304	1	2020-12-02	22.00	23.00	f	\N	1	\N
268	2	2020-12-02	6.00	8.00	f	\N	1	\N
268	2	2020-12-02	8.00	10.00	f	\N	1	\N
268	2	2020-12-02	10.00	12.00	f	\N	1	\N
268	2	2020-12-02	12.00	14.00	f	\N	1	\N
268	2	2020-12-02	14.00	16.00	f	\N	1	\N
268	2	2020-12-02	16.00	18.00	f	\N	1	\N
268	2	2020-12-02	18.00	20.00	f	\N	1	\N
268	2	2020-12-02	20.00	22.00	f	\N	1	\N
268	2	2020-12-02	22.00	23.00	f	\N	1	\N
313	3	2020-12-02	10.00	12.00	f	\N	1	\N
87	1	2020-11-25	14.00	16.00	f	\N	1	\N
87	1	2020-11-25	16.00	18.00	f	\N	1	\N
87	1	2020-11-25	18.00	20.00	f	\N	1	\N
87	1	2020-11-25	20.00	22.00	f	\N	1	\N
87	1	2020-11-25	22.00	23.00	f	\N	1	\N
86	1	2020-11-25	6.00	8.00	f	\N	1	\N
86	1	2020-11-25	8.00	10.00	f	\N	1	\N
86	1	2020-11-25	10.00	12.00	f	\N	1	\N
86	1	2020-11-25	12.00	14.00	f	\N	1	\N
86	1	2020-11-25	14.00	16.00	f	\N	1	\N
86	1	2020-11-25	16.00	18.00	f	\N	1	\N
86	1	2020-11-25	18.00	20.00	f	\N	1	\N
86	1	2020-11-25	20.00	22.00	f	\N	1	\N
86	1	2020-11-25	22.00	23.00	f	\N	1	\N
201	1	2020-11-25	6.00	8.00	f	\N	1	\N
201	1	2020-11-25	8.00	10.00	f	\N	1	\N
201	1	2020-11-25	10.00	12.00	f	\N	1	\N
201	1	2020-11-25	12.00	14.00	f	\N	1	\N
201	1	2020-11-25	14.00	16.00	f	\N	1	\N
201	1	2020-11-25	16.00	18.00	f	\N	1	\N
201	1	2020-11-25	18.00	20.00	f	\N	1	\N
201	1	2020-11-25	20.00	22.00	f	\N	1	\N
201	1	2020-11-25	22.00	23.00	f	\N	1	\N
83	1	2020-11-25	6.00	8.00	f	\N	1	\N
313	3	2020-12-02	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-12-02	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-12-02	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-12-02	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-12-02	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-12-02	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-12-02	20.00	22.00	t	1122334455	5	Stängt
83	1	2020-11-25	8.00	10.00	f	\N	1	\N
83	1	2020-11-25	10.00	12.00	f	\N	1	\N
83	1	2020-11-25	12.00	14.00	f	\N	1	\N
83	1	2020-11-25	14.00	16.00	f	\N	1	\N
313	3	2020-12-02	22.00	23.00	t	1122334455	5	Stängt
83	1	2020-11-25	16.00	18.00	f	\N	1	\N
83	1	2020-11-25	18.00	20.00	f	\N	1	\N
83	1	2020-11-25	20.00	22.00	f	\N	1	\N
83	1	2020-11-25	22.00	23.00	f	\N	1	\N
84	1	2020-11-25	6.00	8.00	f	\N	1	\N
84	1	2020-11-25	8.00	10.00	f	\N	1	\N
84	1	2020-11-25	10.00	12.00	f	\N	1	\N
84	1	2020-11-25	12.00	14.00	f	\N	1	\N
84	1	2020-11-25	14.00	16.00	f	\N	1	\N
84	1	2020-11-25	16.00	18.00	f	\N	1	\N
84	1	2020-11-25	18.00	20.00	f	\N	1	\N
84	1	2020-11-25	20.00	22.00	f	\N	1	\N
84	1	2020-11-25	22.00	23.00	f	\N	1	\N
194	1	2020-11-25	6.00	8.00	f	\N	1	\N
194	1	2020-11-25	8.00	10.00	f	\N	1	\N
194	1	2020-11-25	10.00	12.00	f	\N	1	\N
194	1	2020-11-25	12.00	14.00	f	\N	1	\N
194	1	2020-11-25	14.00	16.00	f	\N	1	\N
194	1	2020-11-25	16.00	18.00	f	\N	1	\N
194	1	2020-11-25	18.00	20.00	f	\N	1	\N
194	1	2020-11-25	20.00	22.00	f	\N	1	\N
194	1	2020-11-25	22.00	23.00	f	\N	1	\N
85	1	2020-11-25	6.00	8.00	f	\N	1	\N
85	1	2020-11-25	8.00	10.00	f	\N	1	\N
85	1	2020-11-25	10.00	12.00	f	\N	1	\N
85	1	2020-11-25	12.00	14.00	f	\N	1	\N
110	2	2020-11-19	12.00	14.00	f	\N	1	\N
313	3	2020-11-25	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-25	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-25	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-25	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-25	16.00	18.00	t	1122334455	5	Stängt
314	3	2020-11-25	13.00	15.00	t	8306227208	2	K
313	3	2020-11-25	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-25	20.00	22.00	t	1122334455	5	Stängt
310	1	2020-11-25	10.00	12.00	t	8404912680	2	Viktor
313	3	2020-11-25	22.00	23.00	t	1122334455	5	Stängt
104	1	2020-11-19	10.00	12.00	t	8281053194	4	Rl
307	1	2020-11-25	14.00	16.00	t	8334666274	2	Maja
110	2	2020-11-19	14.00	16.00	f	\N	1	\N
108	2	2020-11-19	10.00	12.00	f	\N	1	\N
108	2	2020-11-19	12.00	14.00	f	\N	1	\N
108	2	2020-11-19	14.00	16.00	f	\N	1	\N
116	2	2020-11-19	10.00	12.00	f	\N	1	\N
116	2	2020-11-19	12.00	14.00	f	\N	1	\N
116	2	2020-11-19	14.00	16.00	f	\N	1	\N
85	1	2020-11-25	14.00	16.00	f	\N	1	\N
85	1	2020-11-25	16.00	18.00	f	\N	1	\N
115	2	2020-11-19	10.00	12.00	f	\N	1	\N
85	1	2020-11-25	18.00	20.00	f	\N	1	\N
85	1	2020-11-25	20.00	22.00	f	\N	1	\N
85	1	2020-11-25	22.00	23.00	f	\N	1	\N
303	1	2020-11-25	6.00	8.00	f	\N	1	\N
115	2	2020-11-19	12.00	14.00	f	\N	1	\N
303	1	2020-11-25	8.00	10.00	f	\N	1	\N
303	1	2020-11-25	10.00	12.00	f	\N	1	\N
303	1	2020-11-25	12.00	14.00	f	\N	1	\N
115	2	2020-11-19	14.00	16.00	f	\N	1	\N
114	2	2020-11-19	10.00	12.00	f	\N	1	\N
303	1	2020-11-25	14.00	16.00	f	\N	1	\N
303	1	2020-11-25	16.00	18.00	f	\N	1	\N
114	2	2020-11-19	12.00	14.00	f	\N	1	\N
114	2	2020-11-19	14.00	16.00	f	\N	1	\N
113	2	2020-11-19	10.00	12.00	f	\N	1	\N
303	1	2020-11-25	18.00	20.00	f	\N	1	\N
303	1	2020-11-25	20.00	22.00	f	\N	1	\N
303	1	2020-11-25	22.00	23.00	f	\N	1	\N
304	1	2020-11-25	6.00	8.00	f	\N	1	\N
304	1	2020-11-25	8.00	10.00	f	\N	1	\N
304	1	2020-11-25	10.00	12.00	f	\N	1	\N
304	1	2020-11-25	12.00	14.00	f	\N	1	\N
304	1	2020-11-25	14.00	16.00	f	\N	1	\N
304	1	2020-11-25	16.00	18.00	f	\N	1	\N
304	1	2020-11-25	18.00	20.00	f	\N	1	\N
304	1	2020-11-25	20.00	22.00	f	\N	1	\N
304	1	2020-11-25	22.00	23.00	f	\N	1	\N
268	2	2020-11-25	6.00	8.00	f	\N	1	\N
268	2	2020-11-25	8.00	10.00	f	\N	1	\N
268	2	2020-11-25	10.00	12.00	f	\N	1	\N
268	2	2020-11-25	12.00	14.00	f	\N	1	\N
268	2	2020-11-25	14.00	16.00	f	\N	1	\N
268	2	2020-11-25	16.00	18.00	f	\N	1	\N
268	2	2020-11-25	18.00	20.00	f	\N	1	\N
268	2	2020-11-25	20.00	22.00	f	\N	1	\N
268	2	2020-11-25	22.00	23.00	f	\N	1	\N
313	3	2020-11-25	10.00	12.00	f	\N	1	\N
113	2	2020-11-19	12.00	14.00	f	\N	1	\N
113	2	2020-11-19	14.00	16.00	f	\N	1	\N
287	3	2020-11-19	11.00	13.00	t	5081379736	4	Neck
120	2	2020-11-19	10.00	12.00	f	\N	1	\N
120	2	2020-11-19	12.00	14.00	f	\N	1	\N
120	2	2020-11-19	14.00	16.00	f	\N	1	\N
309	1	2020-11-19	10.00	12.00	t	8276844584	4	Sarah 
101	1	2020-11-19	10.00	12.00	t	8328392746	4	tobbe
103	1	2020-11-19	10.00	12.00	f	\N	1	\N
256	1	2020-11-19	10.00	12.00	f	\N	1	\N
100	1	2020-11-19	10.00	12.00	f	\N	1	\N
286	3	2020-11-19	10.00	12.00	f	\N	1	\N
286	3	2020-11-19	12.00	14.00	f	\N	1	\N
286	3	2020-11-19	14.00	16.00	f	\N	1	\N
89	1	2020-11-19	9.00	11.00	f	\N	1	\N
89	1	2020-11-19	11.00	13.00	f	\N	1	\N
89	1	2020-11-19	13.00	15.00	f	\N	1	\N
89	1	2020-11-19	15.00	17.00	f	\N	1	\N
89	1	2020-11-19	17.00	18.00	f	\N	1	\N
300	1	2020-11-19	9.00	11.00	f	\N	1	\N
300	1	2020-11-19	11.00	13.00	f	\N	1	\N
300	1	2020-11-19	13.00	15.00	f	\N	1	\N
300	1	2020-11-19	15.00	17.00	f	\N	1	\N
300	1	2020-11-19	17.00	18.00	f	\N	1	\N
298	1	2020-11-19	9.00	11.00	f	\N	1	\N
298	1	2020-11-19	11.00	13.00	f	\N	1	\N
298	1	2020-11-19	13.00	15.00	f	\N	1	\N
298	1	2020-11-19	15.00	17.00	f	\N	1	\N
298	1	2020-11-19	17.00	18.00	f	\N	1	\N
95	1	2020-11-19	9.00	11.00	f	\N	1	\N
95	1	2020-11-19	11.00	13.00	f	\N	1	\N
95	1	2020-11-19	13.00	15.00	f	\N	1	\N
95	1	2020-11-19	15.00	17.00	f	\N	1	\N
95	1	2020-11-19	17.00	18.00	f	\N	1	\N
90	1	2020-11-19	9.00	11.00	f	\N	1	\N
90	1	2020-11-19	11.00	13.00	f	\N	1	\N
90	1	2020-11-19	13.00	15.00	f	\N	1	\N
90	1	2020-11-19	15.00	17.00	f	\N	1	\N
90	1	2020-11-19	17.00	18.00	f	\N	1	\N
94	1	2020-11-19	9.00	11.00	f	\N	1	\N
94	1	2020-11-19	11.00	13.00	f	\N	1	\N
94	1	2020-11-19	13.00	15.00	f	\N	1	\N
94	1	2020-11-19	15.00	17.00	f	\N	1	\N
94	1	2020-11-19	17.00	18.00	f	\N	1	\N
92	1	2020-11-19	9.00	11.00	f	\N	1	\N
92	1	2020-11-19	11.00	13.00	f	\N	1	\N
92	1	2020-11-19	13.00	15.00	f	\N	1	\N
92	1	2020-11-19	15.00	17.00	f	\N	1	\N
92	1	2020-11-19	17.00	18.00	f	\N	1	\N
93	1	2020-11-19	9.00	11.00	f	\N	1	\N
93	1	2020-11-19	11.00	13.00	f	\N	1	\N
93	1	2020-11-19	13.00	15.00	f	\N	1	\N
93	1	2020-11-19	15.00	17.00	f	\N	1	\N
93	1	2020-11-19	17.00	18.00	f	\N	1	\N
96	1	2020-11-19	9.00	11.00	f	\N	1	\N
96	1	2020-11-19	11.00	13.00	f	\N	1	\N
96	1	2020-11-19	13.00	15.00	f	\N	1	\N
96	1	2020-11-19	15.00	17.00	f	\N	1	\N
96	1	2020-11-19	17.00	18.00	f	\N	1	\N
91	1	2020-11-19	9.00	11.00	f	\N	1	\N
91	1	2020-11-19	11.00	13.00	f	\N	1	\N
91	1	2020-11-19	13.00	15.00	f	\N	1	\N
91	1	2020-11-19	15.00	17.00	f	\N	1	\N
91	1	2020-11-19	17.00	18.00	f	\N	1	\N
301	1	2020-11-19	9.00	11.00	f	\N	1	\N
301	1	2020-11-19	11.00	13.00	f	\N	1	\N
301	1	2020-11-19	13.00	15.00	f	\N	1	\N
301	1	2020-11-19	15.00	17.00	f	\N	1	\N
301	1	2020-11-19	17.00	18.00	f	\N	1	\N
299	1	2020-11-19	9.00	11.00	f	\N	1	\N
299	1	2020-11-19	11.00	13.00	f	\N	1	\N
299	1	2020-11-19	13.00	15.00	f	\N	1	\N
299	1	2020-11-19	15.00	17.00	f	\N	1	\N
299	1	2020-11-19	17.00	18.00	f	\N	1	\N
176	2	2020-11-19	9.00	11.00	f	\N	1	\N
176	2	2020-11-19	11.00	13.00	f	\N	1	\N
176	2	2020-11-19	13.00	15.00	f	\N	1	\N
176	2	2020-11-19	15.00	17.00	f	\N	1	\N
176	2	2020-11-19	17.00	18.00	f	\N	1	\N
175	2	2020-11-19	9.00	11.00	f	\N	1	\N
175	2	2020-11-19	11.00	13.00	f	\N	1	\N
175	2	2020-11-19	13.00	15.00	f	\N	1	\N
314	3	2020-11-19	17.00	18.00	t	5101145936	2	Melin
166	1	2020-11-26	10.00	12.00	f	\N	1	\N
166	1	2020-11-26	12.00	14.00	f	\N	1	\N
166	1	2020-11-26	14.00	16.00	f	\N	1	\N
166	1	2020-11-26	16.00	18.00	f	\N	1	\N
168	1	2020-11-26	10.00	12.00	f	\N	1	\N
306	3	2020-11-19	13.00	15.00	t	3750500927	2	is
168	1	2020-11-26	12.00	14.00	f	\N	1	\N
306	3	2020-11-19	9.00	11.00	f	\N	1	\N
168	1	2020-11-26	14.00	16.00	f	\N	1	\N
306	3	2020-11-19	11.00	13.00	f	\N	1	\N
314	3	2020-11-19	9.00	11.00	f	\N	1	\N
314	3	2020-11-19	11.00	13.00	t	8403704328	3	nh
175	2	2020-11-19	15.00	17.00	f	\N	1	\N
175	2	2020-11-19	17.00	18.00	f	\N	1	\N
174	2	2020-11-19	9.00	11.00	f	\N	1	\N
174	2	2020-11-19	11.00	13.00	f	\N	1	\N
174	2	2020-11-19	13.00	15.00	f	\N	1	\N
174	2	2020-11-19	15.00	17.00	f	\N	1	\N
174	2	2020-11-19	17.00	18.00	f	\N	1	\N
179	2	2020-11-19	9.00	11.00	f	\N	1	\N
179	2	2020-11-19	11.00	13.00	f	\N	1	\N
179	2	2020-11-19	13.00	15.00	f	\N	1	\N
179	2	2020-11-19	15.00	17.00	f	\N	1	\N
179	2	2020-11-19	17.00	18.00	f	\N	1	\N
178	2	2020-11-19	9.00	11.00	f	\N	1	\N
178	2	2020-11-19	11.00	13.00	f	\N	1	\N
178	2	2020-11-19	13.00	15.00	f	\N	1	\N
178	2	2020-11-19	15.00	17.00	f	\N	1	\N
178	2	2020-11-19	17.00	18.00	f	\N	1	\N
177	2	2020-11-19	9.00	11.00	f	\N	1	\N
177	2	2020-11-19	11.00	13.00	f	\N	1	\N
177	2	2020-11-19	13.00	15.00	f	\N	1	\N
177	2	2020-11-19	15.00	17.00	f	\N	1	\N
177	2	2020-11-19	17.00	18.00	f	\N	1	\N
192	2	2020-11-19	9.00	11.00	f	\N	1	\N
192	2	2020-11-19	11.00	13.00	f	\N	1	\N
192	2	2020-11-19	13.00	15.00	f	\N	1	\N
192	2	2020-11-19	15.00	17.00	f	\N	1	\N
192	2	2020-11-19	17.00	18.00	f	\N	1	\N
193	2	2020-11-19	9.00	11.00	f	\N	1	\N
168	1	2020-11-26	16.00	18.00	f	\N	1	\N
193	2	2020-11-19	11.00	13.00	f	\N	1	\N
193	2	2020-11-19	13.00	15.00	f	\N	1	\N
193	2	2020-11-19	15.00	17.00	f	\N	1	\N
193	2	2020-11-19	17.00	18.00	f	\N	1	\N
302	3	2020-11-19	9.00	11.00	f	\N	1	\N
302	3	2020-11-19	11.00	13.00	f	\N	1	\N
302	3	2020-11-19	13.00	15.00	f	\N	1	\N
302	3	2020-11-19	15.00	17.00	f	\N	1	\N
302	3	2020-11-19	17.00	18.00	f	\N	1	\N
305	3	2020-11-19	9.00	11.00	f	\N	1	\N
305	3	2020-11-19	11.00	13.00	f	\N	1	\N
305	3	2020-11-19	13.00	15.00	f	\N	1	\N
305	3	2020-11-19	15.00	17.00	f	\N	1	\N
305	3	2020-11-19	17.00	18.00	f	\N	1	\N
306	3	2020-11-19	15.00	17.00	f	\N	1	\N
306	3	2020-11-19	17.00	18.00	f	\N	1	\N
215	1	2020-11-19	6.00	8.00	f	\N	1	\N
215	1	2020-11-19	8.00	10.00	f	\N	1	\N
215	1	2020-11-19	10.00	12.00	f	\N	1	\N
215	1	2020-11-19	12.00	14.00	f	\N	1	\N
215	1	2020-11-19	14.00	16.00	f	\N	1	\N
215	1	2020-11-19	16.00	18.00	f	\N	1	\N
215	1	2020-11-19	18.00	20.00	f	\N	1	\N
215	1	2020-11-19	20.00	22.00	f	\N	1	\N
215	1	2020-11-19	22.00	23.00	f	\N	1	\N
231	1	2020-11-19	6.00	8.00	f	\N	1	\N
231	1	2020-11-19	8.00	10.00	f	\N	1	\N
231	1	2020-11-19	10.00	12.00	f	\N	1	\N
231	1	2020-11-19	12.00	14.00	f	\N	1	\N
231	1	2020-11-19	14.00	16.00	f	\N	1	\N
231	1	2020-11-19	16.00	18.00	f	\N	1	\N
231	1	2020-11-19	18.00	20.00	f	\N	1	\N
231	1	2020-11-19	20.00	22.00	f	\N	1	\N
231	1	2020-11-19	22.00	23.00	f	\N	1	\N
88	1	2020-11-19	6.00	8.00	f	\N	1	\N
88	1	2020-11-19	8.00	10.00	f	\N	1	\N
88	1	2020-11-19	10.00	12.00	f	\N	1	\N
88	1	2020-11-19	12.00	14.00	f	\N	1	\N
165	1	2020-11-26	10.00	12.00	f	\N	1	\N
165	1	2020-11-26	12.00	14.00	f	\N	1	\N
165	1	2020-11-26	14.00	16.00	f	\N	1	\N
165	1	2020-11-26	16.00	18.00	f	\N	1	\N
167	1	2020-11-26	10.00	12.00	f	\N	1	\N
167	1	2020-11-26	12.00	14.00	f	\N	1	\N
167	1	2020-11-26	14.00	16.00	f	\N	1	\N
167	1	2020-11-26	16.00	18.00	f	\N	1	\N
289	1	2020-11-26	10.00	12.00	f	\N	1	\N
289	1	2020-11-26	12.00	14.00	f	\N	1	\N
289	1	2020-11-26	14.00	16.00	f	\N	1	\N
289	1	2020-11-26	16.00	18.00	f	\N	1	\N
297	2	2020-11-26	10.00	12.00	f	\N	1	\N
297	2	2020-11-26	12.00	14.00	f	\N	1	\N
297	2	2020-11-26	14.00	16.00	f	\N	1	\N
297	2	2020-11-26	16.00	18.00	f	\N	1	\N
285	3	2020-11-26	10.00	12.00	f	\N	1	\N
285	3	2020-11-26	12.00	14.00	f	\N	1	\N
285	3	2020-11-26	14.00	16.00	f	\N	1	\N
285	3	2020-11-26	16.00	18.00	f	\N	1	\N
204	1	2020-11-26	9.00	11.00	f	\N	1	\N
314	3	2020-11-19	15.00	17.00	t	8306227208	2	Bb
88	1	2020-11-19	14.00	16.00	f	\N	1	\N
204	1	2020-11-26	11.00	13.00	f	\N	1	\N
204	1	2020-11-26	13.00	15.00	f	\N	1	\N
204	1	2020-11-26	15.00	17.00	f	\N	1	\N
204	1	2020-11-26	17.00	18.00	f	\N	1	\N
203	1	2020-11-26	9.00	11.00	f	\N	1	\N
203	1	2020-11-26	11.00	13.00	f	\N	1	\N
203	1	2020-11-26	13.00	15.00	f	\N	1	\N
203	1	2020-11-26	15.00	17.00	f	\N	1	\N
203	1	2020-11-26	17.00	18.00	f	\N	1	\N
88	1	2020-11-19	16.00	18.00	f	\N	1	\N
88	1	2020-11-19	18.00	20.00	f	\N	1	\N
88	1	2020-11-19	20.00	22.00	f	\N	1	\N
88	1	2020-11-19	22.00	23.00	f	\N	1	\N
80	1	2020-11-19	6.00	8.00	f	\N	1	\N
80	1	2020-11-19	8.00	10.00	f	\N	1	\N
80	1	2020-11-19	10.00	12.00	f	\N	1	\N
80	1	2020-11-19	12.00	14.00	f	\N	1	\N
80	1	2020-11-19	14.00	16.00	f	\N	1	\N
80	1	2020-11-19	16.00	18.00	f	\N	1	\N
80	1	2020-11-19	18.00	20.00	f	\N	1	\N
80	1	2020-11-19	20.00	22.00	f	\N	1	\N
80	1	2020-11-19	22.00	23.00	f	\N	1	\N
216	1	2020-11-19	6.00	8.00	f	\N	1	\N
216	1	2020-11-19	8.00	10.00	f	\N	1	\N
216	1	2020-11-19	10.00	12.00	f	\N	1	\N
216	1	2020-11-19	12.00	14.00	f	\N	1	\N
216	1	2020-11-19	14.00	16.00	f	\N	1	\N
216	1	2020-11-19	16.00	18.00	f	\N	1	\N
216	1	2020-11-19	18.00	20.00	f	\N	1	\N
216	1	2020-11-19	20.00	22.00	f	\N	1	\N
216	1	2020-11-19	22.00	23.00	f	\N	1	\N
191	1	2020-11-19	6.00	8.00	f	\N	1	\N
191	1	2020-11-19	8.00	10.00	f	\N	1	\N
191	1	2020-11-19	10.00	12.00	f	\N	1	\N
191	1	2020-11-19	12.00	14.00	f	\N	1	\N
191	1	2020-11-19	14.00	16.00	f	\N	1	\N
191	1	2020-11-19	16.00	18.00	f	\N	1	\N
191	1	2020-11-19	18.00	20.00	f	\N	1	\N
191	1	2020-11-19	20.00	22.00	f	\N	1	\N
191	1	2020-11-19	22.00	23.00	f	\N	1	\N
81	1	2020-11-19	6.00	8.00	f	\N	1	\N
81	1	2020-11-19	8.00	10.00	f	\N	1	\N
81	1	2020-11-19	10.00	12.00	f	\N	1	\N
81	1	2020-11-19	12.00	14.00	f	\N	1	\N
81	1	2020-11-19	14.00	16.00	f	\N	1	\N
81	1	2020-11-19	16.00	18.00	f	\N	1	\N
81	1	2020-11-19	18.00	20.00	f	\N	1	\N
81	1	2020-11-19	20.00	22.00	f	\N	1	\N
81	1	2020-11-19	22.00	23.00	f	\N	1	\N
82	1	2020-11-19	6.00	8.00	f	\N	1	\N
82	1	2020-11-19	8.00	10.00	f	\N	1	\N
82	1	2020-11-19	10.00	12.00	f	\N	1	\N
82	1	2020-11-19	12.00	14.00	f	\N	1	\N
82	1	2020-11-19	14.00	16.00	f	\N	1	\N
82	1	2020-11-19	16.00	18.00	f	\N	1	\N
82	1	2020-11-19	18.00	20.00	f	\N	1	\N
82	1	2020-11-19	20.00	22.00	f	\N	1	\N
82	1	2020-11-19	22.00	23.00	f	\N	1	\N
87	1	2020-11-19	6.00	8.00	f	\N	1	\N
87	1	2020-11-19	8.00	10.00	f	\N	1	\N
87	1	2020-11-19	10.00	12.00	f	\N	1	\N
87	1	2020-11-19	12.00	14.00	f	\N	1	\N
87	1	2020-11-19	14.00	16.00	f	\N	1	\N
87	1	2020-11-19	16.00	18.00	f	\N	1	\N
87	1	2020-11-19	18.00	20.00	f	\N	1	\N
87	1	2020-11-19	20.00	22.00	f	\N	1	\N
87	1	2020-11-19	22.00	23.00	f	\N	1	\N
86	1	2020-11-19	6.00	8.00	f	\N	1	\N
86	1	2020-11-19	8.00	10.00	f	\N	1	\N
86	1	2020-11-19	10.00	12.00	f	\N	1	\N
86	1	2020-11-19	12.00	14.00	f	\N	1	\N
86	1	2020-11-19	14.00	16.00	f	\N	1	\N
86	1	2020-11-19	16.00	18.00	f	\N	1	\N
86	1	2020-11-19	18.00	20.00	f	\N	1	\N
86	1	2020-11-19	20.00	22.00	f	\N	1	\N
86	1	2020-11-19	22.00	23.00	f	\N	1	\N
201	1	2020-11-19	6.00	8.00	f	\N	1	\N
201	1	2020-11-19	8.00	10.00	f	\N	1	\N
201	1	2020-11-19	10.00	12.00	f	\N	1	\N
201	1	2020-11-19	12.00	14.00	f	\N	1	\N
201	1	2020-11-19	14.00	16.00	f	\N	1	\N
201	1	2020-11-19	16.00	18.00	f	\N	1	\N
201	1	2020-11-19	18.00	20.00	f	\N	1	\N
201	1	2020-11-19	20.00	22.00	f	\N	1	\N
201	1	2020-11-19	22.00	23.00	f	\N	1	\N
83	1	2020-11-19	6.00	8.00	f	\N	1	\N
83	1	2020-11-19	8.00	10.00	f	\N	1	\N
83	1	2020-11-19	10.00	12.00	f	\N	1	\N
83	1	2020-11-19	12.00	14.00	f	\N	1	\N
83	1	2020-11-19	14.00	16.00	f	\N	1	\N
83	1	2020-11-19	16.00	18.00	f	\N	1	\N
83	1	2020-11-19	18.00	20.00	f	\N	1	\N
83	1	2020-11-19	20.00	22.00	f	\N	1	\N
83	1	2020-11-19	22.00	23.00	f	\N	1	\N
84	1	2020-11-19	6.00	8.00	f	\N	1	\N
84	1	2020-11-19	8.00	10.00	f	\N	1	\N
84	1	2020-11-19	10.00	12.00	f	\N	1	\N
84	1	2020-11-19	12.00	14.00	f	\N	1	\N
84	1	2020-11-19	14.00	16.00	f	\N	1	\N
84	1	2020-11-19	16.00	18.00	f	\N	1	\N
84	1	2020-11-19	18.00	20.00	f	\N	1	\N
84	1	2020-11-19	20.00	22.00	f	\N	1	\N
84	1	2020-11-19	22.00	23.00	f	\N	1	\N
194	1	2020-11-19	6.00	8.00	f	\N	1	\N
194	1	2020-11-19	8.00	10.00	f	\N	1	\N
194	1	2020-11-19	10.00	12.00	f	\N	1	\N
194	1	2020-11-19	12.00	14.00	f	\N	1	\N
194	1	2020-11-19	14.00	16.00	f	\N	1	\N
194	1	2020-11-19	16.00	18.00	f	\N	1	\N
194	1	2020-11-19	18.00	20.00	f	\N	1	\N
194	1	2020-11-19	20.00	22.00	f	\N	1	\N
194	1	2020-11-19	22.00	23.00	f	\N	1	\N
85	1	2020-11-19	6.00	8.00	f	\N	1	\N
85	1	2020-11-19	8.00	10.00	f	\N	1	\N
85	1	2020-11-19	10.00	12.00	f	\N	1	\N
85	1	2020-11-19	12.00	14.00	f	\N	1	\N
85	1	2020-11-19	14.00	16.00	f	\N	1	\N
205	1	2020-11-26	9.00	11.00	f	\N	1	\N
85	1	2020-11-19	16.00	18.00	f	\N	1	\N
85	1	2020-11-19	18.00	20.00	f	\N	1	\N
85	1	2020-11-19	20.00	22.00	f	\N	1	\N
85	1	2020-11-19	22.00	23.00	f	\N	1	\N
303	1	2020-11-19	6.00	8.00	f	\N	1	\N
303	1	2020-11-19	8.00	10.00	f	\N	1	\N
303	1	2020-11-19	10.00	12.00	f	\N	1	\N
303	1	2020-11-19	12.00	14.00	f	\N	1	\N
303	1	2020-11-19	14.00	16.00	f	\N	1	\N
303	1	2020-11-19	16.00	18.00	f	\N	1	\N
303	1	2020-11-19	18.00	20.00	f	\N	1	\N
303	1	2020-11-19	20.00	22.00	f	\N	1	\N
303	1	2020-11-19	22.00	23.00	f	\N	1	\N
304	1	2020-11-19	6.00	8.00	f	\N	1	\N
304	1	2020-11-19	8.00	10.00	f	\N	1	\N
304	1	2020-11-19	10.00	12.00	f	\N	1	\N
304	1	2020-11-19	12.00	14.00	f	\N	1	\N
304	1	2020-11-19	14.00	16.00	f	\N	1	\N
304	1	2020-11-19	16.00	18.00	f	\N	1	\N
304	1	2020-11-19	18.00	20.00	f	\N	1	\N
304	1	2020-11-19	20.00	22.00	f	\N	1	\N
304	1	2020-11-19	22.00	23.00	f	\N	1	\N
268	2	2020-11-19	6.00	8.00	f	\N	1	\N
268	2	2020-11-19	8.00	10.00	f	\N	1	\N
268	2	2020-11-19	10.00	12.00	f	\N	1	\N
268	2	2020-11-19	12.00	14.00	f	\N	1	\N
268	2	2020-11-19	14.00	16.00	f	\N	1	\N
268	2	2020-11-19	16.00	18.00	f	\N	1	\N
268	2	2020-11-19	18.00	20.00	f	\N	1	\N
268	2	2020-11-19	20.00	22.00	f	\N	1	\N
268	2	2020-11-19	22.00	23.00	f	\N	1	\N
313	3	2020-11-19	10.00	12.00	f	\N	1	\N
313	3	2020-11-19	6.00	8.00	t	1122334455	5	Stängt
313	3	2020-11-19	8.00	10.00	t	1122334455	5	Stängt
313	3	2020-11-19	12.00	14.00	t	1122334455	5	Stängt
313	3	2020-11-19	14.00	16.00	t	1122334455	5	Stängt
313	3	2020-11-19	16.00	18.00	t	1122334455	5	Stängt
313	3	2020-11-19	18.00	20.00	t	1122334455	5	Stängt
313	3	2020-11-19	20.00	22.00	t	1122334455	5	Stängt
313	3	2020-11-19	22.00	23.00	t	1122334455	5	Stängt
205	1	2020-11-26	11.00	13.00	f	\N	1	\N
205	1	2020-11-26	13.00	15.00	f	\N	1	\N
205	1	2020-11-26	15.00	17.00	f	\N	1	\N
205	1	2020-11-26	17.00	18.00	f	\N	1	\N
202	1	2020-11-26	9.00	11.00	f	\N	1	\N
202	1	2020-11-26	11.00	13.00	f	\N	1	\N
202	1	2020-11-26	13.00	15.00	f	\N	1	\N
202	1	2020-11-26	15.00	17.00	f	\N	1	\N
202	1	2020-11-26	17.00	18.00	f	\N	1	\N
214	1	2020-11-26	9.00	11.00	f	\N	1	\N
214	1	2020-11-26	11.00	13.00	f	\N	1	\N
214	1	2020-11-26	13.00	15.00	f	\N	1	\N
214	1	2020-11-26	15.00	17.00	f	\N	1	\N
214	1	2020-11-26	17.00	18.00	f	\N	1	\N
213	1	2020-11-26	9.00	11.00	f	\N	1	\N
213	1	2020-11-26	11.00	13.00	f	\N	1	\N
213	1	2020-11-26	13.00	15.00	f	\N	1	\N
213	1	2020-11-26	15.00	17.00	f	\N	1	\N
213	1	2020-11-26	17.00	18.00	f	\N	1	\N
208	2	2020-11-26	9.00	11.00	f	\N	1	\N
208	2	2020-11-26	11.00	13.00	f	\N	1	\N
208	2	2020-11-26	13.00	15.00	f	\N	1	\N
208	2	2020-11-26	15.00	17.00	f	\N	1	\N
208	2	2020-11-26	17.00	18.00	f	\N	1	\N
244	2	2020-11-26	9.00	11.00	f	\N	1	\N
244	2	2020-11-26	11.00	13.00	f	\N	1	\N
244	2	2020-11-26	13.00	15.00	f	\N	1	\N
244	2	2020-11-26	15.00	17.00	f	\N	1	\N
244	2	2020-11-26	17.00	18.00	f	\N	1	\N
209	2	2020-11-26	9.00	11.00	f	\N	1	\N
209	2	2020-11-26	11.00	13.00	f	\N	1	\N
209	2	2020-11-26	13.00	15.00	f	\N	1	\N
209	2	2020-11-26	15.00	17.00	f	\N	1	\N
209	2	2020-11-26	17.00	18.00	f	\N	1	\N
245	2	2020-11-26	9.00	11.00	f	\N	1	\N
245	2	2020-11-26	11.00	13.00	f	\N	1	\N
245	2	2020-11-26	13.00	15.00	f	\N	1	\N
245	2	2020-11-26	15.00	17.00	f	\N	1	\N
245	2	2020-11-26	17.00	18.00	f	\N	1	\N
247	2	2020-11-26	9.00	11.00	f	\N	1	\N
247	2	2020-11-26	11.00	13.00	f	\N	1	\N
247	2	2020-11-26	13.00	15.00	f	\N	1	\N
247	2	2020-11-26	15.00	17.00	f	\N	1	\N
247	2	2020-11-26	17.00	18.00	f	\N	1	\N
207	2	2020-11-26	9.00	11.00	f	\N	1	\N
207	2	2020-11-26	11.00	13.00	f	\N	1	\N
207	2	2020-11-26	13.00	15.00	f	\N	1	\N
207	2	2020-11-26	15.00	17.00	f	\N	1	\N
207	2	2020-11-26	17.00	18.00	f	\N	1	\N
212	2	2020-11-26	9.00	11.00	f	\N	1	\N
212	2	2020-11-26	11.00	13.00	f	\N	1	\N
212	2	2020-11-26	13.00	15.00	f	\N	1	\N
212	2	2020-11-26	15.00	17.00	f	\N	1	\N
212	2	2020-11-26	17.00	18.00	f	\N	1	\N
217	2	2020-11-26	9.00	11.00	f	\N	1	\N
217	2	2020-11-26	11.00	13.00	f	\N	1	\N
217	2	2020-11-26	13.00	15.00	f	\N	1	\N
217	2	2020-11-26	15.00	17.00	f	\N	1	\N
217	2	2020-11-26	17.00	18.00	f	\N	1	\N
246	2	2020-11-26	9.00	11.00	f	\N	1	\N
246	2	2020-11-26	11.00	13.00	f	\N	1	\N
246	2	2020-11-26	13.00	15.00	f	\N	1	\N
246	2	2020-11-26	15.00	17.00	f	\N	1	\N
246	2	2020-11-26	17.00	18.00	f	\N	1	\N
210	2	2020-11-26	9.00	11.00	f	\N	1	\N
210	2	2020-11-26	11.00	13.00	f	\N	1	\N
210	2	2020-11-26	13.00	15.00	f	\N	1	\N
210	2	2020-11-26	15.00	17.00	f	\N	1	\N
210	2	2020-11-26	17.00	18.00	f	\N	1	\N
206	2	2020-11-26	9.00	11.00	f	\N	1	\N
206	2	2020-11-26	11.00	13.00	f	\N	1	\N
206	2	2020-11-26	13.00	15.00	f	\N	1	\N
206	2	2020-11-26	15.00	17.00	f	\N	1	\N
206	2	2020-11-26	17.00	18.00	f	\N	1	\N
288	3	2020-11-26	9.00	11.00	f	\N	1	\N
288	3	2020-11-26	11.00	13.00	f	\N	1	\N
288	3	2020-11-26	13.00	15.00	f	\N	1	\N
288	3	2020-11-26	15.00	17.00	f	\N	1	\N
288	3	2020-11-26	17.00	18.00	f	\N	1	\N
287	3	2020-11-26	9.00	11.00	f	\N	1	\N
287	3	2020-11-26	11.00	13.00	f	\N	1	\N
287	3	2020-11-26	13.00	15.00	f	\N	1	\N
287	3	2020-11-26	15.00	17.00	f	\N	1	\N
287	3	2020-11-26	17.00	18.00	f	\N	1	\N
196	1	2020-11-26	9.00	11.00	f	\N	1	\N
196	1	2020-11-26	11.00	13.00	f	\N	1	\N
196	1	2020-11-26	13.00	15.00	f	\N	1	\N
196	1	2020-11-26	15.00	17.00	f	\N	1	\N
196	1	2020-11-26	17.00	18.00	f	\N	1	\N
97	1	2020-11-26	9.00	11.00	f	\N	1	\N
97	1	2020-11-26	11.00	13.00	f	\N	1	\N
97	1	2020-11-26	13.00	15.00	f	\N	1	\N
97	1	2020-11-26	15.00	17.00	f	\N	1	\N
97	1	2020-11-26	17.00	18.00	f	\N	1	\N
197	1	2020-11-26	9.00	11.00	f	\N	1	\N
197	1	2020-11-26	11.00	13.00	f	\N	1	\N
197	1	2020-11-26	13.00	15.00	f	\N	1	\N
197	1	2020-11-26	15.00	17.00	f	\N	1	\N
197	1	2020-11-26	17.00	18.00	f	\N	1	\N
135	1	2020-11-26	9.00	11.00	f	\N	1	\N
135	1	2020-11-26	11.00	13.00	f	\N	1	\N
135	1	2020-11-26	13.00	15.00	f	\N	1	\N
135	1	2020-11-26	15.00	17.00	f	\N	1	\N
135	1	2020-11-26	17.00	18.00	f	\N	1	\N
136	1	2020-11-26	9.00	11.00	f	\N	1	\N
136	1	2020-11-26	11.00	13.00	f	\N	1	\N
136	1	2020-11-26	13.00	15.00	f	\N	1	\N
136	1	2020-11-26	15.00	17.00	f	\N	1	\N
136	1	2020-11-26	17.00	18.00	f	\N	1	\N
137	1	2020-11-26	9.00	11.00	f	\N	1	\N
137	1	2020-11-26	11.00	13.00	f	\N	1	\N
137	1	2020-11-26	13.00	15.00	f	\N	1	\N
137	1	2020-11-26	15.00	17.00	f	\N	1	\N
137	1	2020-11-26	17.00	18.00	f	\N	1	\N
195	1	2020-11-26	9.00	11.00	f	\N	1	\N
195	1	2020-11-26	11.00	13.00	f	\N	1	\N
195	1	2020-11-26	13.00	15.00	f	\N	1	\N
195	1	2020-11-26	15.00	17.00	f	\N	1	\N
195	1	2020-11-26	17.00	18.00	f	\N	1	\N
138	1	2020-11-26	9.00	11.00	f	\N	1	\N
138	1	2020-11-26	11.00	13.00	f	\N	1	\N
138	1	2020-11-26	13.00	15.00	f	\N	1	\N
138	1	2020-11-26	15.00	17.00	f	\N	1	\N
138	1	2020-11-26	17.00	18.00	f	\N	1	\N
139	1	2020-11-26	9.00	11.00	f	\N	1	\N
139	1	2020-11-26	11.00	13.00	f	\N	1	\N
139	1	2020-11-26	13.00	15.00	f	\N	1	\N
139	1	2020-11-26	15.00	17.00	f	\N	1	\N
139	1	2020-11-26	17.00	18.00	f	\N	1	\N
140	1	2020-11-26	9.00	11.00	f	\N	1	\N
140	1	2020-11-26	11.00	13.00	f	\N	1	\N
140	1	2020-11-26	13.00	15.00	f	\N	1	\N
140	1	2020-11-26	15.00	17.00	f	\N	1	\N
140	1	2020-11-26	17.00	18.00	f	\N	1	\N
141	1	2020-11-26	9.00	11.00	f	\N	1	\N
141	1	2020-11-26	11.00	13.00	f	\N	1	\N
141	1	2020-11-26	13.00	15.00	f	\N	1	\N
141	1	2020-11-26	15.00	17.00	f	\N	1	\N
141	1	2020-11-26	17.00	18.00	f	\N	1	\N
188	2	2020-11-26	9.00	11.00	f	\N	1	\N
188	2	2020-11-26	11.00	13.00	f	\N	1	\N
188	2	2020-11-26	13.00	15.00	f	\N	1	\N
188	2	2020-11-26	15.00	17.00	f	\N	1	\N
188	2	2020-11-26	17.00	18.00	f	\N	1	\N
248	2	2020-11-26	9.00	11.00	f	\N	1	\N
248	2	2020-11-26	11.00	13.00	f	\N	1	\N
248	2	2020-11-26	13.00	15.00	f	\N	1	\N
248	2	2020-11-26	15.00	17.00	f	\N	1	\N
248	2	2020-11-26	17.00	18.00	f	\N	1	\N
182	2	2020-11-26	9.00	11.00	f	\N	1	\N
182	2	2020-11-26	11.00	13.00	f	\N	1	\N
182	2	2020-11-26	13.00	15.00	f	\N	1	\N
182	2	2020-11-26	15.00	17.00	f	\N	1	\N
182	2	2020-11-26	17.00	18.00	f	\N	1	\N
183	2	2020-11-26	9.00	11.00	f	\N	1	\N
183	2	2020-11-26	11.00	13.00	f	\N	1	\N
183	2	2020-11-26	13.00	15.00	f	\N	1	\N
183	2	2020-11-26	15.00	17.00	f	\N	1	\N
183	2	2020-11-26	17.00	18.00	f	\N	1	\N
181	2	2020-11-26	9.00	11.00	f	\N	1	\N
181	2	2020-11-26	11.00	13.00	f	\N	1	\N
181	2	2020-11-26	13.00	15.00	f	\N	1	\N
181	2	2020-11-26	15.00	17.00	f	\N	1	\N
181	2	2020-11-26	17.00	18.00	f	\N	1	\N
187	2	2020-11-26	9.00	11.00	f	\N	1	\N
187	2	2020-11-26	11.00	13.00	f	\N	1	\N
187	2	2020-11-26	13.00	15.00	f	\N	1	\N
187	2	2020-11-26	15.00	17.00	f	\N	1	\N
187	2	2020-11-26	17.00	18.00	f	\N	1	\N
184	2	2020-11-26	9.00	11.00	f	\N	1	\N
184	2	2020-11-26	11.00	13.00	f	\N	1	\N
184	2	2020-11-26	13.00	15.00	f	\N	1	\N
184	2	2020-11-26	15.00	17.00	f	\N	1	\N
184	2	2020-11-26	17.00	18.00	f	\N	1	\N
249	2	2020-11-26	9.00	11.00	f	\N	1	\N
249	2	2020-11-26	11.00	13.00	f	\N	1	\N
249	2	2020-11-26	13.00	15.00	f	\N	1	\N
249	2	2020-11-26	15.00	17.00	f	\N	1	\N
249	2	2020-11-26	17.00	18.00	f	\N	1	\N
186	2	2020-11-26	9.00	11.00	f	\N	1	\N
186	2	2020-11-26	11.00	13.00	f	\N	1	\N
186	2	2020-11-26	13.00	15.00	f	\N	1	\N
186	2	2020-11-26	15.00	17.00	f	\N	1	\N
186	2	2020-11-26	17.00	18.00	f	\N	1	\N
180	2	2020-11-26	9.00	11.00	f	\N	1	\N
180	2	2020-11-26	11.00	13.00	f	\N	1	\N
180	2	2020-11-26	13.00	15.00	f	\N	1	\N
180	2	2020-11-26	15.00	17.00	f	\N	1	\N
180	2	2020-11-26	17.00	18.00	f	\N	1	\N
185	2	2020-11-26	9.00	11.00	f	\N	1	\N
185	2	2020-11-26	11.00	13.00	f	\N	1	\N
185	2	2020-11-26	13.00	15.00	f	\N	1	\N
185	2	2020-11-26	15.00	17.00	f	\N	1	\N
185	2	2020-11-26	17.00	18.00	f	\N	1	\N
283	3	2020-11-26	9.00	11.00	f	\N	1	\N
283	3	2020-11-26	11.00	13.00	f	\N	1	\N
283	3	2020-11-26	13.00	15.00	f	\N	1	\N
283	3	2020-11-26	15.00	17.00	f	\N	1	\N
283	3	2020-11-26	17.00	18.00	f	\N	1	\N
284	3	2020-11-26	9.00	11.00	f	\N	1	\N
284	3	2020-11-26	11.00	13.00	f	\N	1	\N
284	3	2020-11-26	13.00	15.00	f	\N	1	\N
284	3	2020-11-26	15.00	17.00	f	\N	1	\N
284	3	2020-11-26	17.00	18.00	f	\N	1	\N
189	1	2020-11-26	10.00	12.00	f	\N	1	\N
189	1	2020-11-26	12.00	14.00	f	\N	1	\N
189	1	2020-11-26	14.00	16.00	f	\N	1	\N
256	1	2020-11-26	10.00	12.00	f	\N	1	\N
256	1	2020-11-26	12.00	14.00	f	\N	1	\N
256	1	2020-11-26	14.00	16.00	f	\N	1	\N
98	1	2020-11-26	10.00	12.00	f	\N	1	\N
98	1	2020-11-26	12.00	14.00	f	\N	1	\N
98	1	2020-11-26	14.00	16.00	f	\N	1	\N
101	1	2020-11-26	10.00	12.00	f	\N	1	\N
101	1	2020-11-26	12.00	14.00	f	\N	1	\N
101	1	2020-11-26	14.00	16.00	f	\N	1	\N
309	1	2020-11-26	10.00	12.00	f	\N	1	\N
309	1	2020-11-26	12.00	14.00	f	\N	1	\N
309	1	2020-11-26	14.00	16.00	f	\N	1	\N
311	1	2020-11-26	10.00	12.00	f	\N	1	\N
311	1	2020-11-26	12.00	14.00	f	\N	1	\N
311	1	2020-11-26	14.00	16.00	f	\N	1	\N
190	1	2020-11-26	10.00	12.00	f	\N	1	\N
190	1	2020-11-26	12.00	14.00	f	\N	1	\N
190	1	2020-11-26	14.00	16.00	f	\N	1	\N
99	1	2020-11-26	10.00	12.00	f	\N	1	\N
99	1	2020-11-26	12.00	14.00	f	\N	1	\N
99	1	2020-11-26	14.00	16.00	f	\N	1	\N
100	1	2020-11-26	10.00	12.00	f	\N	1	\N
100	1	2020-11-26	12.00	14.00	f	\N	1	\N
100	1	2020-11-26	14.00	16.00	f	\N	1	\N
310	1	2020-11-26	10.00	12.00	f	\N	1	\N
310	1	2020-11-26	12.00	14.00	f	\N	1	\N
310	1	2020-11-26	14.00	16.00	f	\N	1	\N
102	1	2020-11-26	10.00	12.00	f	\N	1	\N
102	1	2020-11-26	12.00	14.00	f	\N	1	\N
102	1	2020-11-26	14.00	16.00	f	\N	1	\N
103	1	2020-11-26	10.00	12.00	f	\N	1	\N
103	1	2020-11-26	12.00	14.00	f	\N	1	\N
\.


--
-- Data for Name: bokning_backup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY bokning_backup (obj_id, typ, dag, start, slut, bokad, bokad_barcode, status, kommentar) FROM stdin;
159	3	2002-02-25	14.00	15.00	f	\N	1	\N
159	3	2002-02-25	15.00	16.00	f	\N	1	\N
159	3	2002-02-25	16.00	17.00	f	\N	1	\N
159	3	2002-02-25	17.00	18.00	f	\N	1	\N
159	3	2002-02-25	18.00	19.00	f	\N	1	\N
159	3	2002-02-25	19.00	20.00	f	\N	1	\N
159	3	2002-02-25	20.00	21.00	f	\N	1	\N
159	3	2002-02-26	14.00	15.00	f	\N	1	\N
159	3	2002-02-26	15.00	16.00	f	\N	1	\N
159	3	2002-02-26	16.00	17.00	f	\N	1	\N
159	3	2002-02-26	17.00	18.00	f	\N	1	\N
159	3	2002-02-26	18.00	19.00	f	\N	1	\N
159	3	2002-02-26	19.00	20.00	f	\N	1	\N
159	3	2002-02-26	20.00	21.00	f	\N	1	\N
159	3	2002-02-28	14.00	15.00	f	\N	1	\N
159	3	2002-02-28	15.00	16.00	f	\N	1	\N
159	3	2002-02-28	16.00	17.00	f	\N	1	\N
159	3	2002-02-28	17.00	18.00	f	\N	1	\N
159	3	2002-02-28	18.00	19.00	f	\N	1	\N
159	3	2002-02-28	19.00	20.00	f	\N	1	\N
159	3	2002-02-28	20.00	21.00	f	\N	1	\N
159	3	2002-03-01	14.00	15.00	f	\N	1	\N
159	3	2002-03-01	15.00	16.00	f	\N	1	\N
159	3	2002-03-01	16.00	17.00	f	\N	1	\N
159	3	2002-03-01	17.00	18.00	f	\N	1	\N
159	3	2002-03-01	18.00	19.00	f	\N	1	\N
159	3	2002-03-01	19.00	20.00	f	\N	1	\N
159	3	2002-03-01	20.00	21.00	f	\N	1	\N
159	3	2002-03-03	14.00	15.00	f	\N	1	\N
159	3	2002-03-03	15.00	16.00	f	\N	1	\N
159	3	2002-03-03	16.00	17.00	f	\N	1	\N
159	3	2002-03-03	17.00	18.00	f	\N	1	\N
159	3	2002-03-03	18.00	19.00	f	\N	1	\N
159	3	2002-03-03	19.00	20.00	f	\N	1	\N
159	3	2002-03-03	20.00	21.00	f	\N	1	\N
159	3	2002-03-04	14.00	15.00	f	\N	1	\N
159	3	2002-03-04	15.00	16.00	f	\N	1	\N
159	3	2002-03-04	16.00	17.00	f	\N	1	\N
159	3	2002-03-04	17.00	18.00	f	\N	1	\N
159	3	2002-03-04	18.00	19.00	f	\N	1	\N
159	3	2002-03-04	19.00	20.00	f	\N	1	\N
159	3	2002-03-04	20.00	21.00	f	\N	1	\N
159	3	2002-03-05	14.00	15.00	f	\N	1	\N
159	3	2002-03-05	15.00	16.00	f	\N	1	\N
159	3	2002-03-05	16.00	17.00	f	\N	1	\N
159	3	2002-03-05	17.00	18.00	f	\N	1	\N
159	3	2002-03-05	18.00	19.00	f	\N	1	\N
159	3	2002-03-05	19.00	20.00	f	\N	1	\N
159	3	2002-03-05	20.00	21.00	f	\N	1	\N
159	3	2002-03-06	14.00	15.00	f	\N	1	\N
159	3	2002-03-06	15.00	16.00	f	\N	1	\N
159	3	2002-03-06	16.00	17.00	f	\N	1	\N
159	3	2002-03-06	17.00	18.00	f	\N	1	\N
159	3	2002-03-06	18.00	19.00	f	\N	1	\N
159	3	2002-03-06	19.00	20.00	f	\N	1	\N
159	3	2002-03-06	20.00	21.00	f	\N	1	\N
159	3	2002-03-07	14.00	15.00	f	\N	1	\N
159	3	2002-03-07	15.00	16.00	f	\N	1	\N
159	3	2002-03-07	16.00	17.00	f	\N	1	\N
159	3	2002-03-07	17.00	18.00	f	\N	1	\N
159	3	2002-03-07	18.00	19.00	f	\N	1	\N
159	3	2002-03-07	19.00	20.00	f	\N	1	\N
159	3	2002-03-07	20.00	21.00	f	\N	1	\N
159	3	2002-03-08	14.00	15.00	f	\N	1	\N
159	3	2002-03-08	15.00	16.00	f	\N	1	\N
159	3	2002-03-08	16.00	17.00	f	\N	1	\N
159	3	2002-03-08	17.00	18.00	f	\N	1	\N
159	3	2002-03-08	18.00	19.00	f	\N	1	\N
159	3	2002-03-08	19.00	20.00	f	\N	1	\N
159	3	2002-03-08	20.00	21.00	f	\N	1	\N
159	3	2002-03-09	14.00	15.00	f	\N	1	\N
159	3	2002-03-09	15.00	16.00	f	\N	1	\N
159	3	2002-03-09	16.00	17.00	f	\N	1	\N
159	3	2002-03-09	17.00	18.00	f	\N	1	\N
159	3	2002-03-09	18.00	19.00	f	\N	1	\N
159	3	2002-03-09	19.00	20.00	f	\N	1	\N
159	3	2002-03-09	20.00	21.00	f	\N	1	\N
159	3	2002-03-10	14.00	15.00	f	\N	1	\N
159	3	2002-03-10	15.00	16.00	f	\N	1	\N
159	3	2002-03-10	16.00	17.00	f	\N	1	\N
159	3	2002-03-10	17.00	18.00	f	\N	1	\N
159	3	2002-03-10	18.00	19.00	f	\N	1	\N
159	3	2002-03-10	19.00	20.00	f	\N	1	\N
159	3	2002-03-10	20.00	21.00	f	\N	1	\N
159	3	2002-03-11	14.00	15.00	f	\N	1	\N
159	3	2002-03-11	15.00	16.00	f	\N	1	\N
159	3	2002-03-11	16.00	17.00	f	\N	1	\N
159	3	2002-03-11	17.00	18.00	f	\N	1	\N
159	3	2002-03-11	18.00	19.00	f	\N	1	\N
159	3	2002-03-11	19.00	20.00	f	\N	1	\N
159	3	2002-03-11	20.00	21.00	f	\N	1	\N
159	3	2002-03-12	14.00	15.00	f	\N	1	\N
159	3	2002-03-12	15.00	16.00	f	\N	1	\N
159	3	2002-03-12	16.00	17.00	f	\N	1	\N
159	3	2002-03-12	17.00	18.00	f	\N	1	\N
159	3	2002-03-12	18.00	19.00	f	\N	1	\N
159	3	2002-03-12	19.00	20.00	f	\N	1	\N
159	3	2002-03-12	20.00	21.00	f	\N	1	\N
159	3	2002-03-13	14.00	15.00	f	\N	1	\N
159	3	2002-03-13	15.00	16.00	f	\N	1	\N
159	3	2002-03-13	16.00	17.00	f	\N	1	\N
159	3	2002-03-13	17.00	18.00	f	\N	1	\N
159	3	2002-03-13	18.00	19.00	f	\N	1	\N
159	3	2002-03-13	19.00	20.00	f	\N	1	\N
159	3	2002-03-13	20.00	21.00	f	\N	1	\N
159	3	2002-03-14	14.00	15.00	f	\N	1	\N
159	3	2002-03-14	15.00	16.00	f	\N	1	\N
159	3	2002-03-14	16.00	17.00	f	\N	1	\N
159	3	2002-03-14	17.00	18.00	f	\N	1	\N
159	3	2002-03-14	18.00	19.00	f	\N	1	\N
159	3	2002-03-14	19.00	20.00	f	\N	1	\N
159	3	2002-03-14	20.00	21.00	f	\N	1	\N
159	3	2002-03-15	14.00	15.00	f	\N	1	\N
159	3	2002-03-15	15.00	16.00	f	\N	1	\N
159	3	2002-03-15	16.00	17.00	f	\N	1	\N
159	3	2002-03-15	17.00	18.00	f	\N	1	\N
159	3	2002-03-15	18.00	19.00	f	\N	1	\N
159	3	2002-03-15	19.00	20.00	f	\N	1	\N
159	3	2002-03-15	20.00	21.00	f	\N	1	\N
105	2	2002-02-25	13.00	15.00	f	\N	1	\N
105	2	2002-02-25	15.00	17.00	f	\N	1	\N
105	2	2002-02-25	17.00	19.00	f	\N	1	\N
105	2	2002-02-25	19.00	21.00	f	\N	1	\N
113	2	2002-02-25	13.00	15.00	f	\N	1	\N
113	2	2002-02-25	15.00	17.00	f	\N	1	\N
113	2	2002-02-25	17.00	19.00	f	\N	1	\N
113	2	2002-02-25	19.00	21.00	f	\N	1	\N
114	2	2002-02-25	13.00	15.00	f	\N	1	\N
114	2	2002-02-25	15.00	17.00	f	\N	1	\N
114	2	2002-02-25	17.00	19.00	f	\N	1	\N
114	2	2002-02-25	19.00	21.00	f	\N	1	\N
115	2	2002-02-25	13.00	15.00	f	\N	1	\N
115	2	2002-02-25	15.00	17.00	f	\N	1	\N
115	2	2002-02-25	17.00	19.00	f	\N	1	\N
115	2	2002-02-25	19.00	21.00	f	\N	1	\N
116	2	2002-02-25	13.00	15.00	f	\N	1	\N
116	2	2002-02-25	15.00	17.00	f	\N	1	\N
116	2	2002-02-25	17.00	19.00	f	\N	1	\N
116	2	2002-02-25	19.00	21.00	f	\N	1	\N
117	2	2002-02-25	13.00	15.00	f	\N	1	\N
117	2	2002-02-25	15.00	17.00	f	\N	1	\N
117	2	2002-02-25	17.00	19.00	f	\N	1	\N
117	2	2002-02-25	19.00	21.00	f	\N	1	\N
118	2	2002-02-25	13.00	15.00	f	\N	1	\N
118	2	2002-02-25	15.00	17.00	f	\N	1	\N
118	2	2002-02-25	17.00	19.00	f	\N	1	\N
118	2	2002-02-25	19.00	21.00	f	\N	1	\N
119	2	2002-02-25	13.00	15.00	f	\N	1	\N
119	2	2002-02-25	15.00	17.00	f	\N	1	\N
119	2	2002-02-25	17.00	19.00	f	\N	1	\N
119	2	2002-02-25	19.00	21.00	f	\N	1	\N
120	2	2002-02-25	13.00	15.00	f	\N	1	\N
120	2	2002-02-25	15.00	17.00	f	\N	1	\N
120	2	2002-02-25	17.00	19.00	f	\N	1	\N
120	2	2002-02-25	19.00	21.00	f	\N	1	\N
121	2	2002-02-25	13.00	15.00	f	\N	1	\N
121	2	2002-02-25	15.00	17.00	f	\N	1	\N
121	2	2002-02-25	17.00	19.00	f	\N	1	\N
121	2	2002-02-25	19.00	21.00	f	\N	1	\N
122	2	2002-02-25	13.00	15.00	f	\N	1	\N
122	2	2002-02-25	15.00	17.00	f	\N	1	\N
122	2	2002-02-25	17.00	19.00	f	\N	1	\N
122	2	2002-02-25	19.00	21.00	f	\N	1	\N
123	2	2002-02-25	13.00	15.00	f	\N	1	\N
123	2	2002-02-25	15.00	17.00	f	\N	1	\N
123	2	2002-02-25	17.00	19.00	f	\N	1	\N
123	2	2002-02-25	19.00	21.00	f	\N	1	\N
124	2	2002-02-25	13.00	15.00	f	\N	1	\N
124	2	2002-02-25	15.00	17.00	f	\N	1	\N
124	2	2002-02-25	17.00	19.00	f	\N	1	\N
124	2	2002-02-25	19.00	21.00	f	\N	1	\N
125	2	2002-02-25	13.00	15.00	f	\N	1	\N
125	2	2002-02-25	15.00	17.00	f	\N	1	\N
125	2	2002-02-25	17.00	19.00	f	\N	1	\N
125	2	2002-02-25	19.00	21.00	f	\N	1	\N
126	2	2002-02-25	13.00	15.00	f	\N	1	\N
126	2	2002-02-25	15.00	17.00	f	\N	1	\N
126	2	2002-02-25	17.00	19.00	f	\N	1	\N
126	2	2002-02-25	19.00	21.00	f	\N	1	\N
127	2	2002-02-25	13.00	15.00	f	\N	1	\N
127	2	2002-02-25	15.00	17.00	f	\N	1	\N
127	2	2002-02-25	17.00	19.00	f	\N	1	\N
127	2	2002-02-25	19.00	21.00	f	\N	1	\N
128	2	2002-02-25	13.00	15.00	f	\N	1	\N
128	2	2002-02-25	15.00	17.00	f	\N	1	\N
128	2	2002-02-25	17.00	19.00	f	\N	1	\N
128	2	2002-02-25	19.00	21.00	f	\N	1	\N
129	2	2002-02-25	13.00	15.00	f	\N	1	\N
129	2	2002-02-25	15.00	17.00	f	\N	1	\N
129	2	2002-02-25	17.00	19.00	f	\N	1	\N
129	2	2002-02-25	19.00	21.00	f	\N	1	\N
130	2	2002-02-25	13.00	15.00	f	\N	1	\N
130	2	2002-02-25	15.00	17.00	f	\N	1	\N
130	2	2002-02-25	17.00	19.00	f	\N	1	\N
130	2	2002-02-25	19.00	21.00	f	\N	1	\N
131	2	2002-02-25	13.00	15.00	f	\N	1	\N
131	2	2002-02-25	15.00	17.00	f	\N	1	\N
131	2	2002-02-25	17.00	19.00	f	\N	1	\N
131	2	2002-02-25	19.00	21.00	f	\N	1	\N
132	2	2002-02-25	13.00	15.00	f	\N	1	\N
132	2	2002-02-25	15.00	17.00	f	\N	1	\N
132	2	2002-02-25	17.00	19.00	f	\N	1	\N
132	2	2002-02-25	19.00	21.00	f	\N	1	\N
133	2	2002-02-25	13.00	15.00	f	\N	1	\N
133	2	2002-02-25	15.00	17.00	f	\N	1	\N
133	2	2002-02-25	17.00	19.00	f	\N	1	\N
133	2	2002-02-25	19.00	21.00	f	\N	1	\N
134	2	2002-02-25	13.00	15.00	f	\N	1	\N
134	2	2002-02-25	15.00	17.00	f	\N	1	\N
134	2	2002-02-25	17.00	19.00	f	\N	1	\N
134	2	2002-02-25	19.00	21.00	f	\N	1	\N
108	2	2002-02-25	13.00	15.00	f	\N	1	\N
108	2	2002-02-25	15.00	17.00	f	\N	1	\N
108	2	2002-02-25	17.00	19.00	f	\N	1	\N
108	2	2002-02-25	19.00	21.00	f	\N	1	\N
107	2	2002-02-25	13.00	15.00	f	\N	1	\N
107	2	2002-02-25	15.00	17.00	f	\N	1	\N
107	2	2002-02-25	17.00	19.00	f	\N	1	\N
107	2	2002-02-25	19.00	21.00	f	\N	1	\N
106	2	2002-02-25	13.00	15.00	f	\N	1	\N
106	2	2002-02-25	15.00	17.00	f	\N	1	\N
106	2	2002-02-25	17.00	19.00	f	\N	1	\N
106	2	2002-02-25	19.00	21.00	f	\N	1	\N
109	2	2002-02-25	13.00	15.00	f	\N	1	\N
109	2	2002-02-25	15.00	17.00	f	\N	1	\N
109	2	2002-02-25	19.00	21.00	f	\N	1	\N
110	2	2002-02-25	13.00	15.00	f	\N	1	\N
110	2	2002-02-25	15.00	17.00	f	\N	1	\N
110	2	2002-02-25	17.00	19.00	f	\N	1	\N
110	2	2002-02-25	19.00	21.00	f	\N	1	\N
111	2	2002-02-25	13.00	15.00	f	\N	1	\N
111	2	2002-02-25	15.00	17.00	f	\N	1	\N
111	2	2002-02-25	17.00	19.00	f	\N	1	\N
111	2	2002-02-25	19.00	21.00	f	\N	1	\N
112	2	2002-02-25	13.00	15.00	f	\N	1	\N
112	2	2002-02-25	15.00	17.00	f	\N	1	\N
112	2	2002-02-25	17.00	19.00	f	\N	1	\N
112	2	2002-02-25	19.00	21.00	f	\N	1	\N
82	1	2002-02-25	13.00	17.00	f	\N	1	\N
84	1	2002-02-25	13.00	17.00	f	\N	1	\N
87	1	2002-02-25	13.00	17.00	f	\N	1	\N
88	1	2002-02-25	13.00	17.00	f	\N	1	\N
98	1	2002-02-26	13.00	17.00	f	\N	1	\N
98	1	2002-02-26	17.00	21.00	f	\N	1	\N
99	1	2002-02-26	13.00	17.00	f	\N	1	\N
99	1	2002-02-26	17.00	21.00	f	\N	1	\N
100	1	2002-02-26	13.00	17.00	f	\N	1	\N
100	1	2002-02-26	17.00	21.00	f	\N	1	\N
101	1	2002-02-26	13.00	17.00	f	\N	1	\N
102	1	2002-02-26	13.00	17.00	f	\N	1	\N
102	1	2002-02-26	17.00	21.00	f	\N	1	\N
103	1	2002-02-26	13.00	17.00	f	\N	1	\N
103	1	2002-02-26	17.00	21.00	f	\N	1	\N
104	1	2002-02-26	13.00	17.00	f	\N	1	\N
104	1	2002-02-26	17.00	21.00	f	\N	1	\N
105	2	2002-02-26	13.00	15.00	f	\N	1	\N
105	2	2002-02-26	15.00	17.00	f	\N	1	\N
105	2	2002-02-26	17.00	19.00	f	\N	1	\N
105	2	2002-02-26	19.00	21.00	f	\N	1	\N
113	2	2002-02-26	13.00	15.00	f	\N	1	\N
113	2	2002-02-26	15.00	17.00	f	\N	1	\N
113	2	2002-02-26	17.00	19.00	f	\N	1	\N
113	2	2002-02-26	19.00	21.00	f	\N	1	\N
114	2	2002-02-26	13.00	15.00	f	\N	1	\N
114	2	2002-02-26	15.00	17.00	f	\N	1	\N
114	2	2002-02-26	17.00	19.00	f	\N	1	\N
114	2	2002-02-26	19.00	21.00	f	\N	1	\N
115	2	2002-02-26	13.00	15.00	f	\N	1	\N
115	2	2002-02-26	15.00	17.00	f	\N	1	\N
115	2	2002-02-26	17.00	19.00	f	\N	1	\N
115	2	2002-02-26	19.00	21.00	f	\N	1	\N
116	2	2002-02-26	13.00	15.00	f	\N	1	\N
116	2	2002-02-26	15.00	17.00	f	\N	1	\N
116	2	2002-02-26	17.00	19.00	f	\N	1	\N
116	2	2002-02-26	19.00	21.00	f	\N	1	\N
117	2	2002-02-26	13.00	15.00	f	\N	1	\N
117	2	2002-02-26	15.00	17.00	f	\N	1	\N
117	2	2002-02-26	17.00	19.00	f	\N	1	\N
117	2	2002-02-26	19.00	21.00	f	\N	1	\N
118	2	2002-02-26	13.00	15.00	f	\N	1	\N
118	2	2002-02-26	15.00	17.00	f	\N	1	\N
118	2	2002-02-26	17.00	19.00	f	\N	1	\N
118	2	2002-02-26	19.00	21.00	f	\N	1	\N
119	2	2002-02-26	13.00	15.00	f	\N	1	\N
119	2	2002-02-26	15.00	17.00	f	\N	1	\N
119	2	2002-02-26	17.00	19.00	f	\N	1	\N
119	2	2002-02-26	19.00	21.00	f	\N	1	\N
120	2	2002-02-26	13.00	15.00	f	\N	1	\N
120	2	2002-02-26	15.00	17.00	f	\N	1	\N
120	2	2002-02-26	17.00	19.00	f	\N	1	\N
120	2	2002-02-26	19.00	21.00	f	\N	1	\N
121	2	2002-02-26	13.00	15.00	f	\N	1	\N
121	2	2002-02-26	15.00	17.00	f	\N	1	\N
121	2	2002-02-26	17.00	19.00	f	\N	1	\N
121	2	2002-02-26	19.00	21.00	f	\N	1	\N
122	2	2002-02-26	13.00	15.00	f	\N	1	\N
122	2	2002-02-26	15.00	17.00	f	\N	1	\N
122	2	2002-02-26	17.00	19.00	f	\N	1	\N
122	2	2002-02-26	19.00	21.00	f	\N	1	\N
123	2	2002-02-26	13.00	15.00	f	\N	1	\N
123	2	2002-02-26	15.00	17.00	f	\N	1	\N
123	2	2002-02-26	17.00	19.00	f	\N	1	\N
123	2	2002-02-26	19.00	21.00	f	\N	1	\N
124	2	2002-02-26	13.00	15.00	f	\N	1	\N
124	2	2002-02-26	15.00	17.00	f	\N	1	\N
124	2	2002-02-26	17.00	19.00	f	\N	1	\N
124	2	2002-02-26	19.00	21.00	f	\N	1	\N
125	2	2002-02-26	13.00	15.00	f	\N	1	\N
125	2	2002-02-26	15.00	17.00	f	\N	1	\N
125	2	2002-02-26	17.00	19.00	f	\N	1	\N
125	2	2002-02-26	19.00	21.00	f	\N	1	\N
126	2	2002-02-26	13.00	15.00	f	\N	1	\N
126	2	2002-02-26	15.00	17.00	f	\N	1	\N
126	2	2002-02-26	17.00	19.00	f	\N	1	\N
126	2	2002-02-26	19.00	21.00	f	\N	1	\N
127	2	2002-02-26	13.00	15.00	f	\N	1	\N
127	2	2002-02-26	15.00	17.00	f	\N	1	\N
127	2	2002-02-26	17.00	19.00	f	\N	1	\N
127	2	2002-02-26	19.00	21.00	f	\N	1	\N
128	2	2002-02-26	13.00	15.00	f	\N	1	\N
128	2	2002-02-26	15.00	17.00	f	\N	1	\N
128	2	2002-02-26	17.00	19.00	f	\N	1	\N
128	2	2002-02-26	19.00	21.00	f	\N	1	\N
129	2	2002-02-26	13.00	15.00	f	\N	1	\N
129	2	2002-02-26	15.00	17.00	f	\N	1	\N
129	2	2002-02-26	17.00	19.00	f	\N	1	\N
129	2	2002-02-26	19.00	21.00	f	\N	1	\N
130	2	2002-02-26	13.00	15.00	f	\N	1	\N
130	2	2002-02-26	15.00	17.00	f	\N	1	\N
130	2	2002-02-26	17.00	19.00	f	\N	1	\N
130	2	2002-02-26	19.00	21.00	f	\N	1	\N
131	2	2002-02-26	13.00	15.00	f	\N	1	\N
131	2	2002-02-26	15.00	17.00	f	\N	1	\N
131	2	2002-02-26	17.00	19.00	f	\N	1	\N
131	2	2002-02-26	19.00	21.00	f	\N	1	\N
132	2	2002-02-26	13.00	15.00	f	\N	1	\N
132	2	2002-02-26	15.00	17.00	f	\N	1	\N
132	2	2002-02-26	17.00	19.00	f	\N	1	\N
132	2	2002-02-26	19.00	21.00	f	\N	1	\N
133	2	2002-02-26	13.00	15.00	f	\N	1	\N
133	2	2002-02-26	15.00	17.00	f	\N	1	\N
133	2	2002-02-26	17.00	19.00	f	\N	1	\N
133	2	2002-02-26	19.00	21.00	f	\N	1	\N
134	2	2002-02-26	13.00	15.00	f	\N	1	\N
134	2	2002-02-26	15.00	17.00	f	\N	1	\N
134	2	2002-02-26	17.00	19.00	f	\N	1	\N
134	2	2002-02-26	19.00	21.00	f	\N	1	\N
108	2	2002-02-26	13.00	15.00	f	\N	1	\N
108	2	2002-02-26	15.00	17.00	f	\N	1	\N
108	2	2002-02-26	19.00	21.00	f	\N	1	\N
107	2	2002-02-26	13.00	15.00	f	\N	1	\N
107	2	2002-02-26	15.00	17.00	f	\N	1	\N
107	2	2002-02-26	17.00	19.00	f	\N	1	\N
107	2	2002-02-26	19.00	21.00	f	\N	1	\N
106	2	2002-02-26	13.00	15.00	f	\N	1	\N
106	2	2002-02-26	15.00	17.00	f	\N	1	\N
106	2	2002-02-26	17.00	19.00	f	\N	1	\N
106	2	2002-02-26	19.00	21.00	f	\N	1	\N
109	2	2002-02-26	13.00	15.00	f	\N	1	\N
109	2	2002-02-26	15.00	17.00	f	\N	1	\N
109	2	2002-02-26	17.00	19.00	f	\N	1	\N
109	2	2002-02-26	19.00	21.00	f	\N	1	\N
110	2	2002-02-26	13.00	15.00	f	\N	1	\N
110	2	2002-02-26	15.00	17.00	f	\N	1	\N
110	2	2002-02-26	17.00	19.00	f	\N	1	\N
110	2	2002-02-26	19.00	21.00	f	\N	1	\N
111	2	2002-02-26	13.00	15.00	f	\N	1	\N
111	2	2002-02-26	15.00	17.00	f	\N	1	\N
111	2	2002-02-26	17.00	19.00	f	\N	1	\N
111	2	2002-02-26	19.00	21.00	f	\N	1	\N
112	2	2002-02-26	13.00	15.00	f	\N	1	\N
112	2	2002-02-26	15.00	17.00	f	\N	1	\N
112	2	2002-02-26	17.00	19.00	f	\N	1	\N
112	2	2002-02-26	19.00	21.00	f	\N	1	\N
94	1	2002-02-26	17.00	21.00	f	\N	1	\N
95	1	2002-02-26	17.00	21.00	f	\N	1	\N
141	1	2002-02-26	17.00	21.00	f	\N	1	\N
97	1	2002-02-26	17.00	21.00	f	\N	1	\N
140	1	2002-02-26	17.00	21.00	f	\N	1	\N
136	1	2002-02-26	17.00	21.00	f	\N	1	\N
139	1	2002-02-26	17.00	21.00	f	\N	1	\N
84	1	2002-02-26	13.00	17.00	f	\N	1	\N
85	1	2002-02-26	13.00	17.00	f	\N	1	\N
87	1	2002-02-26	13.00	17.00	f	\N	1	\N
93	1	2002-02-26	17.00	21.00	t	3240850727	2	Emma+Ana
96	1	2002-02-26	17.00	21.00	t	3080550727	2	Katarina
92	1	2002-02-26	17.00	21.00	t	24000433544904	2	Jörgen
98	1	2002-02-27	13.00	17.00	f	\N	1	\N
98	1	2002-02-27	17.00	21.00	f	\N	1	\N
99	1	2002-02-27	13.00	17.00	f	\N	1	\N
99	1	2002-02-27	17.00	21.00	f	\N	1	\N
100	1	2002-02-27	13.00	17.00	f	\N	1	\N
100	1	2002-02-27	17.00	21.00	f	\N	1	\N
101	1	2002-02-27	13.00	17.00	f	\N	1	\N
101	1	2002-02-27	17.00	21.00	f	\N	1	\N
102	1	2002-02-27	13.00	17.00	f	\N	1	\N
102	1	2002-02-27	17.00	21.00	f	\N	1	\N
103	1	2002-02-27	13.00	17.00	f	\N	1	\N
103	1	2002-02-27	17.00	21.00	f	\N	1	\N
104	1	2002-02-27	13.00	17.00	f	\N	1	\N
104	1	2002-02-27	17.00	21.00	f	\N	1	\N
105	2	2002-02-27	13.00	15.00	f	\N	1	\N
105	2	2002-02-27	15.00	17.00	f	\N	1	\N
105	2	2002-02-27	17.00	19.00	f	\N	1	\N
105	2	2002-02-27	19.00	21.00	f	\N	1	\N
113	2	2002-02-27	13.00	15.00	f	\N	1	\N
113	2	2002-02-27	15.00	17.00	f	\N	1	\N
113	2	2002-02-27	17.00	19.00	f	\N	1	\N
113	2	2002-02-27	19.00	21.00	f	\N	1	\N
114	2	2002-02-27	13.00	15.00	f	\N	1	\N
114	2	2002-02-27	15.00	17.00	f	\N	1	\N
114	2	2002-02-27	17.00	19.00	f	\N	1	\N
114	2	2002-02-27	19.00	21.00	f	\N	1	\N
115	2	2002-02-27	13.00	15.00	f	\N	1	\N
115	2	2002-02-27	15.00	17.00	f	\N	1	\N
115	2	2002-02-27	17.00	19.00	f	\N	1	\N
115	2	2002-02-27	19.00	21.00	f	\N	1	\N
116	2	2002-02-27	13.00	15.00	f	\N	1	\N
116	2	2002-02-27	15.00	17.00	f	\N	1	\N
116	2	2002-02-27	17.00	19.00	f	\N	1	\N
116	2	2002-02-27	19.00	21.00	f	\N	1	\N
117	2	2002-02-27	13.00	15.00	f	\N	1	\N
117	2	2002-02-27	15.00	17.00	f	\N	1	\N
117	2	2002-02-27	17.00	19.00	f	\N	1	\N
117	2	2002-02-27	19.00	21.00	f	\N	1	\N
118	2	2002-02-27	13.00	15.00	f	\N	1	\N
118	2	2002-02-27	15.00	17.00	f	\N	1	\N
118	2	2002-02-27	17.00	19.00	f	\N	1	\N
118	2	2002-02-27	19.00	21.00	f	\N	1	\N
119	2	2002-02-27	13.00	15.00	f	\N	1	\N
119	2	2002-02-27	15.00	17.00	f	\N	1	\N
119	2	2002-02-27	17.00	19.00	f	\N	1	\N
119	2	2002-02-27	19.00	21.00	f	\N	1	\N
120	2	2002-02-27	13.00	15.00	f	\N	1	\N
120	2	2002-02-27	15.00	17.00	f	\N	1	\N
120	2	2002-02-27	17.00	19.00	f	\N	1	\N
120	2	2002-02-27	19.00	21.00	f	\N	1	\N
121	2	2002-02-27	13.00	15.00	f	\N	1	\N
121	2	2002-02-27	15.00	17.00	f	\N	1	\N
121	2	2002-02-27	17.00	19.00	f	\N	1	\N
121	2	2002-02-27	19.00	21.00	f	\N	1	\N
122	2	2002-02-27	13.00	15.00	f	\N	1	\N
122	2	2002-02-27	15.00	17.00	f	\N	1	\N
122	2	2002-02-27	17.00	19.00	f	\N	1	\N
122	2	2002-02-27	19.00	21.00	f	\N	1	\N
123	2	2002-02-27	13.00	15.00	f	\N	1	\N
123	2	2002-02-27	15.00	17.00	f	\N	1	\N
123	2	2002-02-27	17.00	19.00	f	\N	1	\N
123	2	2002-02-27	19.00	21.00	f	\N	1	\N
124	2	2002-02-27	13.00	15.00	f	\N	1	\N
124	2	2002-02-27	15.00	17.00	f	\N	1	\N
124	2	2002-02-27	17.00	19.00	f	\N	1	\N
124	2	2002-02-27	19.00	21.00	f	\N	1	\N
125	2	2002-02-27	13.00	15.00	f	\N	1	\N
125	2	2002-02-27	15.00	17.00	f	\N	1	\N
125	2	2002-02-27	17.00	19.00	f	\N	1	\N
125	2	2002-02-27	19.00	21.00	f	\N	1	\N
126	2	2002-02-27	13.00	15.00	f	\N	1	\N
126	2	2002-02-27	15.00	17.00	f	\N	1	\N
126	2	2002-02-27	17.00	19.00	f	\N	1	\N
126	2	2002-02-27	19.00	21.00	f	\N	1	\N
127	2	2002-02-27	13.00	15.00	f	\N	1	\N
127	2	2002-02-27	15.00	17.00	f	\N	1	\N
127	2	2002-02-27	17.00	19.00	f	\N	1	\N
127	2	2002-02-27	19.00	21.00	f	\N	1	\N
128	2	2002-02-27	13.00	15.00	f	\N	1	\N
128	2	2002-02-27	15.00	17.00	f	\N	1	\N
128	2	2002-02-27	17.00	19.00	f	\N	1	\N
128	2	2002-02-27	19.00	21.00	f	\N	1	\N
129	2	2002-02-27	13.00	15.00	f	\N	1	\N
129	2	2002-02-27	15.00	17.00	f	\N	1	\N
129	2	2002-02-27	17.00	19.00	f	\N	1	\N
129	2	2002-02-27	19.00	21.00	f	\N	1	\N
130	2	2002-02-27	13.00	15.00	f	\N	1	\N
130	2	2002-02-27	15.00	17.00	f	\N	1	\N
130	2	2002-02-27	17.00	19.00	f	\N	1	\N
130	2	2002-02-27	19.00	21.00	f	\N	1	\N
131	2	2002-02-27	13.00	15.00	f	\N	1	\N
131	2	2002-02-27	15.00	17.00	f	\N	1	\N
131	2	2002-02-27	17.00	19.00	f	\N	1	\N
131	2	2002-02-27	19.00	21.00	f	\N	1	\N
132	2	2002-02-27	13.00	15.00	f	\N	1	\N
132	2	2002-02-27	15.00	17.00	f	\N	1	\N
132	2	2002-02-27	17.00	19.00	f	\N	1	\N
132	2	2002-02-27	19.00	21.00	f	\N	1	\N
133	2	2002-02-27	13.00	15.00	f	\N	1	\N
133	2	2002-02-27	15.00	17.00	f	\N	1	\N
133	2	2002-02-27	17.00	19.00	f	\N	1	\N
133	2	2002-02-27	19.00	21.00	f	\N	1	\N
134	2	2002-02-27	13.00	15.00	f	\N	1	\N
134	2	2002-02-27	15.00	17.00	f	\N	1	\N
134	2	2002-02-27	17.00	19.00	f	\N	1	\N
134	2	2002-02-27	19.00	21.00	f	\N	1	\N
108	2	2002-02-27	13.00	15.00	f	\N	1	\N
108	2	2002-02-27	15.00	17.00	f	\N	1	\N
108	2	2002-02-27	17.00	19.00	f	\N	1	\N
108	2	2002-02-27	19.00	21.00	f	\N	1	\N
107	2	2002-02-27	13.00	15.00	f	\N	1	\N
107	2	2002-02-27	15.00	17.00	f	\N	1	\N
107	2	2002-02-27	17.00	19.00	f	\N	1	\N
107	2	2002-02-27	19.00	21.00	f	\N	1	\N
106	2	2002-02-27	13.00	15.00	f	\N	1	\N
106	2	2002-02-27	15.00	17.00	f	\N	1	\N
106	2	2002-02-27	17.00	19.00	f	\N	1	\N
106	2	2002-02-27	19.00	21.00	f	\N	1	\N
109	2	2002-02-27	13.00	15.00	f	\N	1	\N
109	2	2002-02-27	15.00	17.00	f	\N	1	\N
109	2	2002-02-27	17.00	19.00	f	\N	1	\N
109	2	2002-02-27	19.00	21.00	f	\N	1	\N
110	2	2002-02-27	13.00	15.00	f	\N	1	\N
110	2	2002-02-27	15.00	17.00	f	\N	1	\N
110	2	2002-02-27	17.00	19.00	f	\N	1	\N
110	2	2002-02-27	19.00	21.00	f	\N	1	\N
111	2	2002-02-27	13.00	15.00	f	\N	1	\N
111	2	2002-02-27	15.00	17.00	f	\N	1	\N
111	2	2002-02-27	17.00	19.00	f	\N	1	\N
111	2	2002-02-27	19.00	21.00	f	\N	1	\N
112	2	2002-02-27	13.00	15.00	f	\N	1	\N
112	2	2002-02-27	15.00	17.00	f	\N	1	\N
112	2	2002-02-27	17.00	19.00	f	\N	1	\N
112	2	2002-02-27	19.00	21.00	f	\N	1	\N
89	1	2002-02-27	17.00	21.00	f	\N	1	\N
96	1	2002-02-27	17.00	21.00	f	\N	1	\N
91	1	2002-02-27	17.00	21.00	f	\N	1	\N
137	1	2002-02-27	17.00	21.00	f	\N	1	\N
140	1	2002-02-27	17.00	21.00	f	\N	1	\N
136	1	2002-02-27	17.00	21.00	f	\N	1	\N
139	1	2002-02-27	17.00	21.00	f	\N	1	\N
80	1	2002-02-27	13.00	17.00	f	\N	1	\N
84	1	2002-02-27	13.00	17.00	f	\N	1	\N
85	1	2002-02-27	13.00	17.00	f	\N	1	\N
86	1	2002-02-27	13.00	17.00	f	\N	1	\N
87	1	2002-02-27	13.00	17.00	f	\N	1	\N
88	1	2002-02-27	13.00	17.00	f	\N	1	\N
135	1	2002-02-27	9.00	13.00	t	3020310627	2	Tomas
94	1	2002-02-27	9.00	13.00	t	3180420827	2	ali
139	1	2002-02-27	13.00	17.00	t	3180230127	2	Christian
97	1	2002-02-27	13.00	17.00	t	3580030827	2	Lena, Anders m.fl.
97	1	2002-02-27	9.00	13.00	t	3180030927	2	Anders, David m.fl.
137	1	2002-02-27	9.00	13.00	t	3260820127	2	Magnus
136	1	2002-02-27	9.00	13.00	t	3260740127	2	John
136	1	2002-02-27	13.00	17.00	t	3060280227	2	mike
91	1	2002-02-27	9.00	13.00	t	3240850727	2	emma+ana
91	1	2002-02-27	13.00	17.00	t	3280770727	2	ana+emma
95	1	2002-02-27	13.00	17.00	t	3230850027	2	anna
95	1	2002-02-27	17.00	21.00	t	3330230527	2	Hanna
90	1	2002-02-27	17.00	21.00	t	3150560927	2	Nilsson
92	1	2002-02-27	9.00	13.00	t	3240600227	2	Lisa och Elin
135	1	2002-02-27	13.00	17.00	t	3180340427	2	Lars Ö
90	1	2002-02-27	9.00	13.00	t	3170090327	2	Emma
140	1	2002-02-27	9.00	13.00	t	3590460027	2	Linda S
98	1	2002-02-28	17.00	21.00	f	\N	1	\N
99	1	2002-02-28	17.00	21.00	f	\N	1	\N
100	1	2002-02-28	17.00	21.00	f	\N	1	\N
101	1	2002-02-28	17.00	21.00	f	\N	1	\N
102	1	2002-02-28	17.00	21.00	f	\N	1	\N
103	1	2002-02-28	17.00	21.00	f	\N	1	\N
104	1	2002-02-28	13.00	17.00	f	\N	1	\N
104	1	2002-02-28	17.00	21.00	f	\N	1	\N
105	2	2002-02-28	13.00	15.00	f	\N	1	\N
105	2	2002-02-28	15.00	17.00	f	\N	1	\N
105	2	2002-02-28	17.00	19.00	f	\N	1	\N
105	2	2002-02-28	19.00	21.00	f	\N	1	\N
113	2	2002-02-28	13.00	15.00	f	\N	1	\N
113	2	2002-02-28	15.00	17.00	f	\N	1	\N
113	2	2002-02-28	17.00	19.00	f	\N	1	\N
113	2	2002-02-28	19.00	21.00	f	\N	1	\N
114	2	2002-02-28	13.00	15.00	f	\N	1	\N
114	2	2002-02-28	15.00	17.00	f	\N	1	\N
114	2	2002-02-28	17.00	19.00	f	\N	1	\N
114	2	2002-02-28	19.00	21.00	f	\N	1	\N
115	2	2002-02-28	13.00	15.00	f	\N	1	\N
115	2	2002-02-28	15.00	17.00	f	\N	1	\N
115	2	2002-02-28	17.00	19.00	f	\N	1	\N
115	2	2002-02-28	19.00	21.00	f	\N	1	\N
116	2	2002-02-28	13.00	15.00	f	\N	1	\N
116	2	2002-02-28	15.00	17.00	f	\N	1	\N
116	2	2002-02-28	17.00	19.00	f	\N	1	\N
116	2	2002-02-28	19.00	21.00	f	\N	1	\N
117	2	2002-02-28	13.00	15.00	f	\N	1	\N
117	2	2002-02-28	15.00	17.00	f	\N	1	\N
117	2	2002-02-28	17.00	19.00	f	\N	1	\N
117	2	2002-02-28	19.00	21.00	f	\N	1	\N
118	2	2002-02-28	13.00	15.00	f	\N	1	\N
118	2	2002-02-28	15.00	17.00	f	\N	1	\N
118	2	2002-02-28	17.00	19.00	f	\N	1	\N
118	2	2002-02-28	19.00	21.00	f	\N	1	\N
119	2	2002-02-28	13.00	15.00	f	\N	1	\N
119	2	2002-02-28	15.00	17.00	f	\N	1	\N
119	2	2002-02-28	17.00	19.00	f	\N	1	\N
119	2	2002-02-28	19.00	21.00	f	\N	1	\N
120	2	2002-02-28	13.00	15.00	f	\N	1	\N
120	2	2002-02-28	15.00	17.00	f	\N	1	\N
120	2	2002-02-28	17.00	19.00	f	\N	1	\N
120	2	2002-02-28	19.00	21.00	f	\N	1	\N
121	2	2002-02-28	13.00	15.00	f	\N	1	\N
121	2	2002-02-28	15.00	17.00	f	\N	1	\N
121	2	2002-02-28	17.00	19.00	f	\N	1	\N
121	2	2002-02-28	19.00	21.00	f	\N	1	\N
122	2	2002-02-28	13.00	15.00	f	\N	1	\N
122	2	2002-02-28	15.00	17.00	f	\N	1	\N
122	2	2002-02-28	17.00	19.00	f	\N	1	\N
122	2	2002-02-28	19.00	21.00	f	\N	1	\N
123	2	2002-02-28	13.00	15.00	f	\N	1	\N
123	2	2002-02-28	15.00	17.00	f	\N	1	\N
123	2	2002-02-28	17.00	19.00	f	\N	1	\N
123	2	2002-02-28	19.00	21.00	f	\N	1	\N
124	2	2002-02-28	13.00	15.00	f	\N	1	\N
124	2	2002-02-28	15.00	17.00	f	\N	1	\N
124	2	2002-02-28	17.00	19.00	f	\N	1	\N
124	2	2002-02-28	19.00	21.00	f	\N	1	\N
125	2	2002-02-28	13.00	15.00	f	\N	1	\N
125	2	2002-02-28	15.00	17.00	f	\N	1	\N
125	2	2002-02-28	17.00	19.00	f	\N	1	\N
125	2	2002-02-28	19.00	21.00	f	\N	1	\N
126	2	2002-02-28	13.00	15.00	f	\N	1	\N
126	2	2002-02-28	15.00	17.00	f	\N	1	\N
126	2	2002-02-28	17.00	19.00	f	\N	1	\N
126	2	2002-02-28	19.00	21.00	f	\N	1	\N
127	2	2002-02-28	13.00	15.00	f	\N	1	\N
127	2	2002-02-28	15.00	17.00	f	\N	1	\N
127	2	2002-02-28	17.00	19.00	f	\N	1	\N
127	2	2002-02-28	19.00	21.00	f	\N	1	\N
128	2	2002-02-28	13.00	15.00	f	\N	1	\N
128	2	2002-02-28	15.00	17.00	f	\N	1	\N
128	2	2002-02-28	17.00	19.00	f	\N	1	\N
128	2	2002-02-28	19.00	21.00	f	\N	1	\N
129	2	2002-02-28	13.00	15.00	f	\N	1	\N
129	2	2002-02-28	15.00	17.00	f	\N	1	\N
129	2	2002-02-28	17.00	19.00	f	\N	1	\N
129	2	2002-02-28	19.00	21.00	f	\N	1	\N
130	2	2002-02-28	13.00	15.00	f	\N	1	\N
130	2	2002-02-28	15.00	17.00	f	\N	1	\N
130	2	2002-02-28	17.00	19.00	f	\N	1	\N
130	2	2002-02-28	19.00	21.00	f	\N	1	\N
131	2	2002-02-28	13.00	15.00	f	\N	1	\N
131	2	2002-02-28	15.00	17.00	f	\N	1	\N
131	2	2002-02-28	17.00	19.00	f	\N	1	\N
131	2	2002-02-28	19.00	21.00	f	\N	1	\N
132	2	2002-02-28	13.00	15.00	f	\N	1	\N
132	2	2002-02-28	15.00	17.00	f	\N	1	\N
132	2	2002-02-28	17.00	19.00	f	\N	1	\N
132	2	2002-02-28	19.00	21.00	f	\N	1	\N
133	2	2002-02-28	13.00	15.00	f	\N	1	\N
133	2	2002-02-28	15.00	17.00	f	\N	1	\N
133	2	2002-02-28	17.00	19.00	f	\N	1	\N
133	2	2002-02-28	19.00	21.00	f	\N	1	\N
134	2	2002-02-28	13.00	15.00	f	\N	1	\N
134	2	2002-02-28	15.00	17.00	f	\N	1	\N
134	2	2002-02-28	17.00	19.00	f	\N	1	\N
134	2	2002-02-28	19.00	21.00	f	\N	1	\N
108	2	2002-02-28	13.00	15.00	f	\N	1	\N
108	2	2002-02-28	15.00	17.00	f	\N	1	\N
108	2	2002-02-28	17.00	19.00	f	\N	1	\N
108	2	2002-02-28	19.00	21.00	f	\N	1	\N
107	2	2002-02-28	13.00	15.00	f	\N	1	\N
107	2	2002-02-28	15.00	17.00	f	\N	1	\N
107	2	2002-02-28	17.00	19.00	f	\N	1	\N
107	2	2002-02-28	19.00	21.00	f	\N	1	\N
106	2	2002-02-28	13.00	15.00	f	\N	1	\N
106	2	2002-02-28	15.00	17.00	f	\N	1	\N
106	2	2002-02-28	17.00	19.00	f	\N	1	\N
106	2	2002-02-28	19.00	21.00	f	\N	1	\N
109	2	2002-02-28	13.00	15.00	f	\N	1	\N
109	2	2002-02-28	15.00	17.00	f	\N	1	\N
109	2	2002-02-28	17.00	19.00	f	\N	1	\N
109	2	2002-02-28	19.00	21.00	f	\N	1	\N
110	2	2002-02-28	13.00	15.00	f	\N	1	\N
110	2	2002-02-28	15.00	17.00	f	\N	1	\N
110	2	2002-02-28	17.00	19.00	f	\N	1	\N
110	2	2002-02-28	19.00	21.00	f	\N	1	\N
111	2	2002-02-28	13.00	15.00	f	\N	1	\N
111	2	2002-02-28	15.00	17.00	f	\N	1	\N
111	2	2002-02-28	17.00	19.00	f	\N	1	\N
111	2	2002-02-28	19.00	21.00	f	\N	1	\N
112	2	2002-02-28	13.00	15.00	f	\N	1	\N
112	2	2002-02-28	15.00	17.00	f	\N	1	\N
112	2	2002-02-28	17.00	19.00	f	\N	1	\N
112	2	2002-02-28	19.00	21.00	f	\N	1	\N
89	1	2002-02-28	17.00	21.00	f	\N	1	\N
92	1	2002-02-28	17.00	21.00	f	\N	1	\N
93	1	2002-02-28	17.00	21.00	f	\N	1	\N
95	1	2002-02-28	17.00	21.00	f	\N	1	\N
96	1	2002-02-28	17.00	21.00	f	\N	1	\N
91	1	2002-02-28	17.00	21.00	f	\N	1	\N
135	1	2002-02-28	17.00	21.00	f	\N	1	\N
137	1	2002-02-28	17.00	21.00	f	\N	1	\N
138	1	2002-02-28	13.00	17.00	f	\N	1	\N
138	1	2002-02-28	17.00	21.00	f	\N	1	\N
141	1	2002-02-28	17.00	21.00	f	\N	1	\N
97	1	2002-02-28	17.00	21.00	f	\N	1	\N
140	1	2002-02-28	17.00	21.00	f	\N	1	\N
139	1	2002-02-28	17.00	21.00	f	\N	1	\N
80	1	2002-02-28	13.00	17.00	f	\N	1	\N
83	1	2002-02-28	13.00	17.00	f	\N	1	\N
84	1	2002-02-28	13.00	17.00	f	\N	1	\N
85	1	2002-02-28	13.00	17.00	f	\N	1	\N
86	1	2002-02-28	13.00	17.00	f	\N	1	\N
87	1	2002-02-28	13.00	17.00	f	\N	1	\N
88	1	2002-02-28	13.00	17.00	f	\N	1	\N
96	1	2002-02-28	13.00	17.00	t	3160390227	2	Susanne, Elisabeth, Anneli
93	1	2002-02-27	9.00	13.00	t	3160290927	2	Fredrik mfl
93	1	2002-02-27	13.00	17.00	t	3230520827	2	Ulrica mfl
140	1	2002-02-27	13.00	17.00	t	3170100327	2	Sandra
98	1	2002-02-28	13.00	17.00	t	3250400127	2	test
99	1	2002-02-28	13.00	17.00	t	3250400127	2	test2
100	1	2002-02-28	13.00	17.00	t	3250400127	2	test3
101	1	2002-02-28	13.00	17.00	t	3250400127	2	test4
102	1	2002-02-28	13.00	17.00	t	3250400127	2	test5
103	1	2002-02-28	13.00	17.00	t	3250400127	2	test6
138	1	2002-02-27	9.00	13.00	t	3060610027	2	Magnus
96	1	2002-02-27	9.00	13.00	t	24000823330272	2	dorys
96	1	2002-02-27	13.00	17.00	t	3030490327	2	kristina
139	1	2002-02-27	9.00	13.00	t	3250040427	2	Jessica G
89	1	2002-02-27	13.00	17.00	t	3010430327	2	kate, maya, boel
90	1	2002-02-28	17.00	21.00	t	3240630627	2	Eva-Lotta Sandberg
92	1	2002-02-27	13.00	17.00	t	3310560327	2	Micke
95	1	2002-02-27	9.00	13.00	t	3480360527	2	Isabelle
92	1	2002-02-27	17.00	21.00	t	24000433544904	2	Jörgen
90	1	2002-02-26	17.00	21.00	t	3240600127	2	Sara och Sofia
92	1	2002-02-28	13.00	17.00	t	3240600127	2	Sara och Sofia
92	1	2002-02-28	9.00	13.00	t	3250790027	2	Lennart och Jörgen
90	1	2002-02-27	13.00	17.00	t	3210570327	2	pelle
91	1	2002-02-28	9.00	13.00	t	3210570327	2	pelle
91	1	2002-02-28	13.00	17.00	t	3180070427	2	nikola
93	1	2002-02-28	9.00	13.00	t	3240850727	2	emma+ana
93	1	2002-02-28	13.00	17.00	t	3280770727	2	ana+emma
95	1	2002-02-28	9.00	13.00	t	3230750427	2	Göran
94	1	2002-02-27	13.00	17.00	t	3020170527	2	Andreas
90	1	2002-02-28	9.00	13.00	t	24000420955653	2	Jenny
160	1	2002-02-25	13.00	16.30	f	\N	1	\N
160	1	2002-02-26	13.00	16.30	f	\N	1	\N
160	1	2002-02-27	13.00	17.00	f	\N	1	\N
160	1	2002-02-28	13.00	16.30	f	\N	1	\N
108	2	2002-02-26	17.00	19.00	t	3250400127	2	lars dator test 26/2
101	1	2002-02-26	17.00	21.00	t	3250400127	2	Lars test
98	1	2002-03-01	13.00	17.00	f	\N	1	\N
98	1	2002-03-01	17.00	19.00	f	\N	1	\N
99	1	2002-03-01	13.00	17.00	f	\N	1	\N
99	1	2002-03-01	17.00	19.00	f	\N	1	\N
100	1	2002-03-01	13.00	17.00	f	\N	1	\N
100	1	2002-03-01	17.00	19.00	f	\N	1	\N
101	1	2002-03-01	13.00	17.00	f	\N	1	\N
101	1	2002-03-01	17.00	19.00	f	\N	1	\N
102	1	2002-03-01	13.00	17.00	f	\N	1	\N
102	1	2002-03-01	17.00	19.00	f	\N	1	\N
103	1	2002-03-01	13.00	17.00	f	\N	1	\N
103	1	2002-03-01	17.00	19.00	f	\N	1	\N
104	1	2002-03-01	13.00	17.00	f	\N	1	\N
104	1	2002-03-01	17.00	19.00	f	\N	1	\N
105	2	2002-03-01	13.00	15.00	f	\N	1	\N
105	2	2002-03-01	15.00	17.00	f	\N	1	\N
105	2	2002-03-01	17.00	19.00	f	\N	1	\N
113	2	2002-03-01	13.00	15.00	f	\N	1	\N
113	2	2002-03-01	15.00	17.00	f	\N	1	\N
113	2	2002-03-01	17.00	19.00	f	\N	1	\N
114	2	2002-03-01	13.00	15.00	f	\N	1	\N
114	2	2002-03-01	15.00	17.00	f	\N	1	\N
114	2	2002-03-01	17.00	19.00	f	\N	1	\N
115	2	2002-03-01	13.00	15.00	f	\N	1	\N
115	2	2002-03-01	15.00	17.00	f	\N	1	\N
115	2	2002-03-01	17.00	19.00	f	\N	1	\N
116	2	2002-03-01	13.00	15.00	f	\N	1	\N
116	2	2002-03-01	15.00	17.00	f	\N	1	\N
116	2	2002-03-01	17.00	19.00	f	\N	1	\N
117	2	2002-03-01	13.00	15.00	f	\N	1	\N
117	2	2002-03-01	15.00	17.00	f	\N	1	\N
117	2	2002-03-01	17.00	19.00	f	\N	1	\N
118	2	2002-03-01	13.00	15.00	f	\N	1	\N
118	2	2002-03-01	15.00	17.00	f	\N	1	\N
118	2	2002-03-01	17.00	19.00	f	\N	1	\N
119	2	2002-03-01	13.00	15.00	f	\N	1	\N
119	2	2002-03-01	15.00	17.00	f	\N	1	\N
119	2	2002-03-01	17.00	19.00	f	\N	1	\N
120	2	2002-03-01	13.00	15.00	f	\N	1	\N
120	2	2002-03-01	15.00	17.00	f	\N	1	\N
120	2	2002-03-01	17.00	19.00	f	\N	1	\N
121	2	2002-03-01	13.00	15.00	f	\N	1	\N
121	2	2002-03-01	15.00	17.00	f	\N	1	\N
121	2	2002-03-01	17.00	19.00	f	\N	1	\N
122	2	2002-03-01	13.00	15.00	f	\N	1	\N
122	2	2002-03-01	15.00	17.00	f	\N	1	\N
122	2	2002-03-01	17.00	19.00	f	\N	1	\N
123	2	2002-03-01	13.00	15.00	f	\N	1	\N
123	2	2002-03-01	15.00	17.00	f	\N	1	\N
123	2	2002-03-01	17.00	19.00	f	\N	1	\N
124	2	2002-03-01	13.00	15.00	f	\N	1	\N
124	2	2002-03-01	15.00	17.00	f	\N	1	\N
124	2	2002-03-01	17.00	19.00	f	\N	1	\N
125	2	2002-03-01	13.00	15.00	f	\N	1	\N
125	2	2002-03-01	15.00	17.00	f	\N	1	\N
125	2	2002-03-01	17.00	19.00	f	\N	1	\N
126	2	2002-03-01	13.00	15.00	f	\N	1	\N
126	2	2002-03-01	15.00	17.00	f	\N	1	\N
126	2	2002-03-01	17.00	19.00	f	\N	1	\N
127	2	2002-03-01	13.00	15.00	f	\N	1	\N
127	2	2002-03-01	15.00	17.00	f	\N	1	\N
127	2	2002-03-01	17.00	19.00	f	\N	1	\N
128	2	2002-03-01	13.00	15.00	f	\N	1	\N
128	2	2002-03-01	15.00	17.00	f	\N	1	\N
128	2	2002-03-01	17.00	19.00	f	\N	1	\N
129	2	2002-03-01	13.00	15.00	f	\N	1	\N
129	2	2002-03-01	15.00	17.00	f	\N	1	\N
129	2	2002-03-01	17.00	19.00	f	\N	1	\N
130	2	2002-03-01	13.00	15.00	f	\N	1	\N
130	2	2002-03-01	15.00	17.00	f	\N	1	\N
130	2	2002-03-01	17.00	19.00	f	\N	1	\N
131	2	2002-03-01	13.00	15.00	f	\N	1	\N
131	2	2002-03-01	15.00	17.00	f	\N	1	\N
131	2	2002-03-01	17.00	19.00	f	\N	1	\N
132	2	2002-03-01	13.00	15.00	f	\N	1	\N
132	2	2002-03-01	15.00	17.00	f	\N	1	\N
132	2	2002-03-01	17.00	19.00	f	\N	1	\N
133	2	2002-03-01	13.00	15.00	f	\N	1	\N
133	2	2002-03-01	15.00	17.00	f	\N	1	\N
133	2	2002-03-01	17.00	19.00	f	\N	1	\N
134	2	2002-03-01	13.00	15.00	f	\N	1	\N
134	2	2002-03-01	15.00	17.00	f	\N	1	\N
134	2	2002-03-01	17.00	19.00	f	\N	1	\N
108	2	2002-03-01	13.00	15.00	f	\N	1	\N
108	2	2002-03-01	15.00	17.00	f	\N	1	\N
108	2	2002-03-01	17.00	19.00	f	\N	1	\N
107	2	2002-03-01	13.00	15.00	f	\N	1	\N
107	2	2002-03-01	15.00	17.00	f	\N	1	\N
107	2	2002-03-01	17.00	19.00	f	\N	1	\N
106	2	2002-03-01	13.00	15.00	f	\N	1	\N
106	2	2002-03-01	15.00	17.00	f	\N	1	\N
106	2	2002-03-01	17.00	19.00	f	\N	1	\N
109	2	2002-03-01	13.00	15.00	f	\N	1	\N
109	2	2002-03-01	15.00	17.00	f	\N	1	\N
109	2	2002-03-01	17.00	19.00	f	\N	1	\N
110	2	2002-03-01	13.00	15.00	f	\N	1	\N
110	2	2002-03-01	15.00	17.00	f	\N	1	\N
110	2	2002-03-01	17.00	19.00	f	\N	1	\N
111	2	2002-03-01	13.00	15.00	f	\N	1	\N
111	2	2002-03-01	15.00	17.00	f	\N	1	\N
111	2	2002-03-01	17.00	19.00	f	\N	1	\N
112	2	2002-03-01	13.00	15.00	f	\N	1	\N
112	2	2002-03-01	15.00	17.00	f	\N	1	\N
112	2	2002-03-01	17.00	19.00	f	\N	1	\N
89	1	2002-03-01	17.00	20.00	f	\N	1	\N
92	1	2002-03-01	17.00	20.00	f	\N	1	\N
93	1	2002-03-01	17.00	20.00	f	\N	1	\N
94	1	2002-03-01	17.00	20.00	f	\N	1	\N
95	1	2002-03-01	17.00	20.00	f	\N	1	\N
96	1	2002-03-01	17.00	20.00	f	\N	1	\N
160	1	2002-03-01	13.00	16.30	f	\N	1	\N
135	1	2002-03-01	13.00	17.00	f	\N	1	\N
135	1	2002-03-01	17.00	19.00	f	\N	1	\N
137	1	2002-03-01	17.00	19.00	f	\N	1	\N
138	1	2002-03-01	13.00	17.00	f	\N	1	\N
138	1	2002-03-01	17.00	19.00	f	\N	1	\N
141	1	2002-03-01	13.00	17.00	f	\N	1	\N
141	1	2002-03-01	17.00	19.00	f	\N	1	\N
140	1	2002-03-01	13.00	17.00	f	\N	1	\N
140	1	2002-03-01	17.00	19.00	f	\N	1	\N
136	1	2002-03-01	13.00	17.00	f	\N	1	\N
136	1	2002-03-01	17.00	19.00	f	\N	1	\N
139	1	2002-03-01	13.00	17.00	f	\N	1	\N
139	1	2002-03-01	17.00	19.00	f	\N	1	\N
80	1	2002-03-01	13.00	17.00	f	\N	1	\N
81	1	2002-03-01	13.00	17.00	f	\N	1	\N
82	1	2002-03-01	13.00	17.00	f	\N	1	\N
83	1	2002-03-01	13.00	17.00	f	\N	1	\N
84	1	2002-03-01	13.00	17.00	f	\N	1	\N
85	1	2002-03-01	13.00	17.00	f	\N	1	\N
86	1	2002-03-01	13.00	17.00	f	\N	1	\N
87	1	2002-03-01	13.00	17.00	f	\N	1	\N
88	1	2002-03-01	13.00	17.00	f	\N	1	\N
93	1	2002-03-01	13.00	17.00	t	3250250327	2	Mia m fl
137	1	2002-02-27	13.00	17.00	t	3180230527	2	Kattis
137	1	2002-03-01	13.00	17.00	t	3180230527	2	Kattis
97	1	2002-02-28	9.00	13.00	t	3020310627	2	Tomas
97	1	2002-03-01	9.00	13.00	t	3020310627	2	Tomas
98	1	2002-03-02	13.00	17.00	f	\N	1	\N
99	1	2002-03-02	13.00	17.00	f	\N	1	\N
100	1	2002-03-02	13.00	17.00	f	\N	1	\N
101	1	2002-03-02	13.00	17.00	f	\N	1	\N
102	1	2002-03-02	13.00	17.00	f	\N	1	\N
103	1	2002-03-02	13.00	17.00	f	\N	1	\N
104	1	2002-03-02	13.00	17.00	f	\N	1	\N
105	2	2002-03-02	13.00	15.00	f	\N	1	\N
105	2	2002-03-02	15.00	17.00	f	\N	1	\N
113	2	2002-03-02	13.00	15.00	f	\N	1	\N
113	2	2002-03-02	15.00	17.00	f	\N	1	\N
114	2	2002-03-02	13.00	15.00	f	\N	1	\N
114	2	2002-03-02	15.00	17.00	f	\N	1	\N
115	2	2002-03-02	13.00	15.00	f	\N	1	\N
115	2	2002-03-02	15.00	17.00	f	\N	1	\N
116	2	2002-03-02	13.00	15.00	f	\N	1	\N
116	2	2002-03-02	15.00	17.00	f	\N	1	\N
117	2	2002-03-02	13.00	15.00	f	\N	1	\N
117	2	2002-03-02	15.00	17.00	f	\N	1	\N
118	2	2002-03-02	13.00	15.00	f	\N	1	\N
118	2	2002-03-02	15.00	17.00	f	\N	1	\N
119	2	2002-03-02	13.00	15.00	f	\N	1	\N
119	2	2002-03-02	15.00	17.00	f	\N	1	\N
120	2	2002-03-02	13.00	15.00	f	\N	1	\N
120	2	2002-03-02	15.00	17.00	f	\N	1	\N
121	2	2002-03-02	13.00	15.00	f	\N	1	\N
121	2	2002-03-02	15.00	17.00	f	\N	1	\N
122	2	2002-03-02	13.00	15.00	f	\N	1	\N
122	2	2002-03-02	15.00	17.00	f	\N	1	\N
123	2	2002-03-02	13.00	15.00	f	\N	1	\N
123	2	2002-03-02	15.00	17.00	f	\N	1	\N
124	2	2002-03-02	13.00	15.00	f	\N	1	\N
124	2	2002-03-02	15.00	17.00	f	\N	1	\N
125	2	2002-03-02	13.00	15.00	f	\N	1	\N
125	2	2002-03-02	15.00	17.00	f	\N	1	\N
126	2	2002-03-02	13.00	15.00	f	\N	1	\N
126	2	2002-03-02	15.00	17.00	f	\N	1	\N
127	2	2002-03-02	13.00	15.00	f	\N	1	\N
127	2	2002-03-02	15.00	17.00	f	\N	1	\N
128	2	2002-03-02	13.00	15.00	f	\N	1	\N
128	2	2002-03-02	15.00	17.00	f	\N	1	\N
129	2	2002-03-02	13.00	15.00	f	\N	1	\N
129	2	2002-03-02	15.00	17.00	f	\N	1	\N
130	2	2002-03-02	13.00	15.00	f	\N	1	\N
130	2	2002-03-02	15.00	17.00	f	\N	1	\N
131	2	2002-03-02	13.00	15.00	f	\N	1	\N
131	2	2002-03-02	15.00	17.00	f	\N	1	\N
132	2	2002-03-02	13.00	15.00	f	\N	1	\N
132	2	2002-03-02	15.00	17.00	f	\N	1	\N
133	2	2002-03-02	13.00	15.00	f	\N	1	\N
133	2	2002-03-02	15.00	17.00	f	\N	1	\N
134	2	2002-03-02	13.00	15.00	f	\N	1	\N
134	2	2002-03-02	15.00	17.00	f	\N	1	\N
108	2	2002-03-02	13.00	15.00	f	\N	1	\N
108	2	2002-03-02	15.00	17.00	f	\N	1	\N
107	2	2002-03-02	13.00	15.00	f	\N	1	\N
107	2	2002-03-02	15.00	17.00	f	\N	1	\N
106	2	2002-03-02	13.00	15.00	f	\N	1	\N
106	2	2002-03-02	15.00	17.00	f	\N	1	\N
109	2	2002-03-02	13.00	15.00	f	\N	1	\N
109	2	2002-03-02	15.00	17.00	f	\N	1	\N
110	2	2002-03-02	13.00	15.00	f	\N	1	\N
110	2	2002-03-02	15.00	17.00	f	\N	1	\N
111	2	2002-03-02	13.00	15.00	f	\N	1	\N
111	2	2002-03-02	15.00	17.00	f	\N	1	\N
112	2	2002-03-02	13.00	15.00	f	\N	1	\N
112	2	2002-03-02	15.00	17.00	f	\N	1	\N
93	1	2002-03-02	14.00	18.00	f	\N	1	\N
95	1	2002-03-02	14.00	18.00	f	\N	1	\N
135	1	2002-03-02	14.00	16.00	f	\N	1	\N
137	1	2002-03-02	14.00	16.00	f	\N	1	\N
138	1	2002-03-02	14.00	16.00	f	\N	1	\N
141	1	2002-03-02	14.00	16.00	f	\N	1	\N
140	1	2002-03-02	14.00	16.00	f	\N	1	\N
136	1	2002-03-02	14.00	16.00	f	\N	1	\N
139	1	2002-03-02	14.00	16.00	f	\N	1	\N
97	1	2002-02-28	13.00	17.00	t	3180340427	2	Lars Ö
97	1	2002-03-01	13.00	17.00	t	3180340427	2	Lars Ö
97	1	2002-03-02	10.00	14.00	t	3020310627	2	Tomas
97	1	2002-03-02	14.00	16.00	t	3180340427	2	Lars Ö§
90	1	2002-03-01	9.00	13.00	t	3240850727	2	emma+ana
90	1	2002-03-01	17.00	20.00	t	3280770727	2	ana+emma
91	1	2002-03-02	14.00	18.00	t	3240850727	2	emma+ana
138	1	2002-02-27	13.00	17.00	t	3060250127	2	mia&lotta (14.00)
138	1	2002-02-27	17.00	21.00	t	3160070427	2	charlotte adonis
95	1	2002-02-28	13.00	17.00	t	3010050727	2	Lina
96	1	2002-03-02	10.00	14.00	t	3070040227	2	Anna
96	1	2002-03-02	14.00	18.00	t	3080600027	2	Therese
91	1	2002-03-01	9.00	13.00	t	3050470727	2	karin
90	1	2002-03-03	14.00	18.00	f	\N	1	\N
93	1	2002-03-03	14.00	18.00	f	\N	1	\N
95	1	2002-03-03	14.00	18.00	f	\N	1	\N
91	1	2002-03-03	14.00	18.00	f	\N	1	\N
95	1	2002-03-01	13.00	17.00	t	3160390227	2	Susanne och Elisabeth
86	1	2002-02-25	9.00	13.00	t	3170890027	4	Elin
96	1	2002-02-25	9.00	13.00	t	3320920027	4	Anna Ericsson
141	1	2002-02-27	13.00	17.00	t	3240460827	2	Tess
89	1	2002-02-27	9.00	13.00	t	3320920027	2	Anna Ericsson
89	1	2002-03-01	9.00	13.00	t	3320920027	2	Anna Ericsson
84	1	2002-02-25	9.00	13.00	t	3020450527	4	sandra
81	1	2002-02-25	9.00	13.00	t	3160590227	4	MvL
136	1	2002-02-28	9.00	13.00	t	3580030827	2	Lena, Pia mfl.
95	1	2002-02-25	9.00	13.00	t	3480570227	4	Camilla
81	1	2002-02-27	9.00	13.00	t	3160590227	2	MvL
92	1	2002-02-25	9.00	13.00	t	3240850727	4	Emma+Ana
90	1	2002-02-25	9.00	13.00	t	3230520827	4	Stefan T.  mfl.
94	1	2002-02-25	9.00	13.00	t	3180420827	4	ali
92	1	2002-03-01	9.00	13.00	t	3070850127	2	Marianne mfl
92	1	2002-03-01	13.00	17.00	t	3180100827	2	Stefan mfl
82	1	2002-02-25	9.00	13.00	t	3290870327	4	erik i
89	1	2002-02-25	9.00	13.00	t	3240930427	4	Johan
81	1	2002-02-27	13.00	17.00	t	3170920227	2	inger
83	1	2002-02-25	9.00	13.00	t	3000960527	4	ida
83	1	2002-02-25	13.00	17.00	f	\N	1	\N
94	1	2002-03-02	14.00	18.00	t	3200240727	2	Carolina & Karolina
97	1	2002-03-01	17.00	19.00	t	3260890827	2	Anna B
91	1	2002-02-25	9.00	13.00	t	3060720727	4	Jonas sture
80	1	2002-02-25	13.00	17.00	f	\N	1	\N
93	1	2002-02-25	9.00	13.00	t	3160630927	4	Kristy + Helena
140	1	2002-03-01	9.00	13.00	t	3250040427	2	Jessica G
139	1	2002-02-28	13.00	17.00	t	3250040427	2	Jessica G
141	1	2002-02-27	9.00	13.00	t	3070390627	2	anna-karin
135	1	2002-02-26	17.00	21.00	t	3200050827	2	Kristoffer, Kerstin, Mattias. Erika
135	1	2002-02-27	17.00	21.00	t	3200050827	2	Mattias, Erika
135	1	2002-02-28	13.00	17.00	t	3200050827	2	Erika, Mattias
140	1	2002-02-28	13.00	17.00	t	3240690227	2	Josef och några fler
94	1	2002-03-01	9.00	13.00	t	3250790027	2	Sara & Sofia
94	1	2002-03-01	13.00	17.00	t	3240600127	2	Lennart & Jörgen
92	1	2002-03-02	10.00	14.00	t	3250790027	2	Sara & Sofia
92	1	2002-03-02	14.00	18.00	t	3240600127	2	Lennart & Jörgen
92	1	2002-03-03	10.00	14.00	t	3250790027	2	Sara & Sofia
92	1	2002-03-03	14.00	18.00	t	3240600127	2	Lennart & Jörgen
96	1	2002-02-28	9.00	13.00	t	3590010127	2	Sara
89	1	2002-03-01	13.00	17.00	t	3160770927	2	annika wedebrand
85	1	2002-02-25	13.00	17.00	t	3300090127	4	lena
92	1	2002-02-25	13.00	17.00	t	3280770727	4	Ana+Emma
136	1	2002-02-28	13.00	17.00	t	3570300427	2	Carl Sjösvärd
136	1	2002-02-28	17.00	21.00	t	3570300327	2	Calle
137	1	2002-02-26	17.00	21.00	t	3180260727	2	Anders och Daniel
87	1	2002-02-25	9.00	13.00	t	3340400327	4	Sofia
93	1	2002-02-25	13.00	17.00	t	3080600027	4	Therese
89	1	2002-02-25	13.00	17.00	t	3170160027	4	Lars Claesson
96	1	2002-02-25	13.00	17.00	t	3180190027	4	Elisabeth
89	1	2002-02-28	9.00	13.00	t	3170160027	2	Lars Claesson
89	1	2002-02-28	13.00	17.00	t	3240260127	2	Hanna
96	1	2002-03-01	9.00	13.00	t	3240260127	2	Hanna
96	1	2002-03-03	10.00	14.00	t	3070040227	2	Anna
96	1	2002-03-01	13.00	17.00	t	3170160027	2	Lars Claesson
96	1	2002-03-03	14.00	18.00	t	3080600027	2	Therese
83	1	2002-02-27	9.00	13.00	t	3320940527	2	Karin
94	1	2002-02-25	13.00	17.00	t	3200450227	4	Ewa, Tunde o Elin
81	1	2002-02-25	13.00	17.00	t	3170920227	4	inglanse
91	1	2002-02-26	17.00	21.00	t	3200450227	2	Ewa o Thunde
94	1	2002-02-28	13.00	17.00	t	3200450227	2	Ewa o Thunde
94	1	2002-02-28	17.00	21.00	t	3210950827	2	Ewa o Thunde
91	1	2002-03-01	13.00	17.00	t	3200450227	2	Ewa o Thunde
91	1	2002-03-01	17.00	20.00	t	3210950827	2	Ewa o Thunde
89	1	2002-03-02	10.00	14.00	t	3200450227	2	Ewa o Thunde
83	1	2002-02-27	13.00	17.00	t	3170410827	2	Elin
89	1	2002-03-02	14.00	18.00	t	3210950827	2	Ewa o Thunde
94	1	2002-03-03	10.00	14.00	t	3200450227	2	Ewa o Thunde
94	1	2002-03-03	14.00	18.00	t	3210950827	2	Ewa o Thunde
94	1	2002-02-28	9.00	13.00	t	3320250827	2	lollo
90	1	2002-02-28	13.00	17.00	t	3250430927	2	lollo
93	1	2002-03-01	9.00	13.00	t	3250430927	2	lollo
95	1	2002-02-25	13.00	17.00	t	3240430427	4	Yolanta
90	1	2002-03-01	13.00	17.00	t	3320250827	2	lollo
90	1	2002-03-02	10.00	14.00	t	3250430927	2	lollo
90	1	2002-03-02	14.00	18.00	t	3320250827	2	lollo
89	1	2002-03-03	10.00	14.00	t	3250430927	2	lollo
89	1	2002-03-03	14.00	18.00	t	3320250827	2	lollo
86	1	2002-02-25	13.00	17.00	f	\N	1	\N
91	1	2002-02-25	13.00	17.00	t	3480380827	4	lotta
139	1	2002-03-01	9.00	13.00	t	3580150027	2	madeleine
95	1	2002-03-01	9.00	13.00	t	3230750427	2	Göran
89	1	2002-02-26	17.00	21.00	t	3060230627	2	Epo rockar
90	1	2002-02-25	13.00	17.00	t	3210950227	4	oddis
94	1	2002-02-27	17.00	21.00	t	3210950827	2	Ewa Elin o Thunde
137	1	2002-02-28	9.00	13.00	t	3040550527	2	Max
86	1	2002-02-27	9.00	13.00	t	3580960227	2	Zeta
138	1	2002-02-28	9.00	13.00	t	3200480727	2	Alexis
97	1	2002-02-27	17.00	21.00	f	\N	1	\N
141	1	2002-02-27	17.00	21.00	t	3200480727	2	Alexis
93	1	2002-02-25	17.00	21.00	t	3160070427	4	charlotte adonis
92	1	2002-02-25	17.00	21.00	t	3250250327	4	Maria, Marita, Åsa & Mia
94	1	2002-02-25	17.00	21.00	t	3210950827	4	Ewa Thunde och Elin
137	1	2002-02-28	13.00	17.00	t	3170090327	2	Emma
90	1	2002-02-25	17.00	21.00	f	\N	1	\N
89	1	2002-02-25	17.00	21.00	f	\N	1	\N
109	2	2002-02-25	17.00	19.00	f	\N	1	\N
91	1	2002-02-25	17.00	21.00	f	\N	1	\N
95	1	2002-02-25	17.00	21.00	f	\N	1	\N
159	3	2002-02-25	7.00	8.00	f	\N	1	
159	3	2002-02-25	8.00	9.00	f	\N	1	
159	3	2002-02-25	9.00	10.00	f	\N	1	
159	3	2002-02-25	10.00	11.00	f	\N	1	
159	3	2002-02-25	11.00	12.00	f	\N	1	
159	3	2002-02-25	12.00	13.00	f	\N	1	
159	3	2002-02-25	13.00	14.00	f	\N	1	
159	3	2002-02-26	7.00	8.00	f	\N	1	
159	3	2002-02-26	8.00	9.00	f	\N	1	
159	3	2002-02-26	9.00	10.00	f	\N	1	
159	3	2002-02-26	10.00	11.00	f	\N	1	
159	3	2002-02-26	11.00	12.00	f	\N	1	
159	3	2002-02-26	12.00	13.00	f	\N	1	
159	3	2002-02-26	13.00	14.00	f	\N	1	
159	3	2002-02-28	7.00	8.00	f	\N	1	
159	3	2002-02-28	8.00	9.00	f	\N	1	
159	3	2002-02-28	9.00	10.00	f	\N	1	
159	3	2002-02-28	10.00	11.00	f	\N	1	
159	3	2002-02-28	11.00	12.00	f	\N	1	
159	3	2002-02-28	12.00	13.00	f	\N	1	
159	3	2002-02-28	13.00	14.00	f	\N	1	
159	3	2002-03-01	7.00	8.00	f	\N	1	
159	3	2002-03-01	8.00	9.00	f	\N	1	
159	3	2002-03-01	9.00	10.00	f	\N	1	
159	3	2002-03-01	10.00	11.00	f	\N	1	
159	3	2002-03-01	11.00	12.00	f	\N	1	
159	3	2002-03-01	12.00	13.00	f	\N	1	
159	3	2002-03-01	13.00	14.00	f	\N	1	
159	3	2002-03-02	15.00	16.00	f	\N	1	
159	3	2002-03-02	16.00	17.00	f	\N	1	
159	3	2002-03-02	17.00	18.00	f	\N	1	
159	3	2002-03-02	18.00	19.00	f	\N	1	
159	3	2002-03-02	19.00	20.00	f	\N	1	
159	3	2002-03-02	20.00	21.00	f	\N	1	
159	3	2002-03-03	7.00	8.00	f	\N	1	
159	3	2002-03-03	8.00	9.00	f	\N	1	
159	3	2002-03-03	9.00	10.00	f	\N	1	
159	3	2002-03-03	10.00	11.00	f	\N	1	
159	3	2002-03-03	11.00	12.00	f	\N	1	
159	3	2002-03-03	12.00	13.00	f	\N	1	
159	3	2002-03-03	13.00	14.00	f	\N	1	
159	3	2002-03-04	7.00	8.00	f	\N	1	
159	3	2002-03-04	8.00	9.00	f	\N	1	
159	3	2002-03-04	9.00	10.00	f	\N	1	
159	3	2002-03-04	10.00	11.00	f	\N	1	
159	3	2002-03-04	12.00	13.00	f	\N	1	
159	3	2002-03-04	13.00	14.00	f	\N	1	
159	3	2002-03-05	7.00	8.00	f	\N	1	
159	3	2002-03-05	8.00	9.00	f	\N	1	
159	3	2002-03-05	9.00	10.00	f	\N	1	
159	3	2002-03-05	10.00	11.00	f	\N	1	
159	3	2002-03-05	11.00	12.00	f	\N	1	
159	3	2002-03-05	12.00	13.00	f	\N	1	
159	3	2002-03-05	13.00	14.00	f	\N	1	
159	3	2002-03-06	7.00	8.00	f	\N	1	
159	3	2002-03-06	8.00	9.00	f	\N	1	
159	3	2002-03-06	9.00	10.00	f	\N	1	
159	3	2002-03-06	10.00	11.00	f	\N	1	
159	3	2002-03-06	11.00	12.00	f	\N	1	
159	3	2002-03-06	12.00	13.00	f	\N	1	
159	3	2002-03-06	13.00	14.00	f	\N	1	
159	3	2002-03-07	7.00	8.00	f	\N	1	
159	3	2002-03-07	8.00	9.00	f	\N	1	
159	3	2002-03-07	9.00	10.00	f	\N	1	
159	3	2002-03-07	10.00	11.00	f	\N	1	
159	3	2002-03-07	11.00	12.00	f	\N	1	
159	3	2002-03-07	12.00	13.00	f	\N	1	
159	3	2002-03-07	13.00	14.00	f	\N	1	
159	3	2002-03-08	7.00	8.00	f	\N	1	
159	3	2002-03-08	8.00	9.00	f	\N	1	
159	3	2002-03-08	9.00	10.00	f	\N	1	
159	3	2002-03-08	10.00	11.00	f	\N	1	
159	3	2002-03-08	11.00	12.00	f	\N	1	
159	3	2002-03-08	12.00	13.00	f	\N	1	
159	3	2002-03-08	13.00	14.00	f	\N	1	
159	3	2002-03-09	7.00	8.00	f	\N	1	
159	3	2002-03-09	8.00	9.00	f	\N	1	
159	3	2002-03-09	9.00	10.00	f	\N	1	
159	3	2002-03-09	10.00	11.00	f	\N	1	
159	3	2002-03-09	11.00	12.00	f	\N	1	
159	3	2002-03-09	12.00	13.00	f	\N	1	
159	3	2002-03-09	13.00	14.00	f	\N	1	
159	3	2002-03-10	7.00	8.00	f	\N	1	
159	3	2002-03-10	8.00	9.00	f	\N	1	
159	3	2002-03-10	9.00	10.00	f	\N	1	
159	3	2002-03-10	10.00	11.00	f	\N	1	
159	3	2002-03-10	11.00	12.00	f	\N	1	
159	3	2002-03-10	12.00	13.00	f	\N	1	
159	3	2002-03-10	13.00	14.00	f	\N	1	
159	3	2002-03-11	7.00	8.00	f	\N	1	
159	3	2002-03-11	8.00	9.00	f	\N	1	
159	3	2002-03-11	9.00	10.00	f	\N	1	
159	3	2002-03-11	10.00	11.00	f	\N	1	
159	3	2002-03-11	11.00	12.00	f	\N	1	
159	3	2002-03-11	12.00	13.00	f	\N	1	
159	3	2002-03-11	13.00	14.00	f	\N	1	
159	3	2002-03-12	7.00	8.00	f	\N	1	
159	3	2002-03-12	8.00	9.00	f	\N	1	
159	3	2002-03-12	9.00	10.00	f	\N	1	
159	3	2002-03-12	10.00	11.00	f	\N	1	
159	3	2002-03-12	11.00	12.00	f	\N	1	
159	3	2002-03-12	12.00	13.00	f	\N	1	
159	3	2002-03-12	13.00	14.00	f	\N	1	
159	3	2002-03-13	7.00	8.00	f	\N	1	
159	3	2002-03-13	8.00	9.00	f	\N	1	
159	3	2002-03-13	9.00	10.00	f	\N	1	
159	3	2002-03-13	10.00	11.00	f	\N	1	
159	3	2002-03-13	11.00	12.00	f	\N	1	
159	3	2002-03-13	12.00	13.00	f	\N	1	
159	3	2002-03-13	13.00	14.00	f	\N	1	
159	3	2002-03-14	7.00	8.00	f	\N	1	
159	3	2002-03-14	8.00	9.00	f	\N	1	
159	3	2002-03-14	9.00	10.00	f	\N	1	
159	3	2002-03-14	10.00	11.00	f	\N	1	
159	3	2002-03-14	11.00	12.00	f	\N	1	
159	3	2002-03-14	12.00	13.00	f	\N	1	
159	3	2002-03-14	13.00	14.00	f	\N	1	
159	3	2002-03-15	7.00	8.00	f	\N	1	
159	3	2002-03-15	8.00	9.00	f	\N	1	
159	3	2002-03-15	9.00	10.00	f	\N	1	
159	3	2002-03-15	10.00	11.00	f	\N	1	
159	3	2002-03-15	11.00	12.00	f	\N	1	
159	3	2002-03-15	12.00	13.00	f	\N	1	
159	3	2002-03-15	13.00	14.00	f	\N	1	
105	2	2002-02-25	9.00	11.00	f	\N	1	
105	2	2002-02-25	11.00	13.00	f	\N	1	
113	2	2002-02-25	9.00	11.00	f	\N	1	
113	2	2002-02-25	11.00	13.00	f	\N	1	
114	2	2002-02-25	9.00	11.00	f	\N	1	
114	2	2002-02-25	11.00	13.00	f	\N	1	
115	2	2002-02-25	9.00	11.00	f	\N	1	
115	2	2002-02-25	11.00	13.00	f	\N	1	
116	2	2002-02-25	9.00	11.00	f	\N	1	
116	2	2002-02-25	11.00	13.00	f	\N	1	
117	2	2002-02-25	9.00	11.00	f	\N	1	
117	2	2002-02-25	11.00	13.00	f	\N	1	
118	2	2002-02-25	9.00	11.00	f	\N	1	
118	2	2002-02-25	11.00	13.00	f	\N	1	
119	2	2002-02-25	9.00	11.00	f	\N	1	
119	2	2002-02-25	11.00	13.00	f	\N	1	
120	2	2002-02-25	9.00	11.00	f	\N	1	
120	2	2002-02-25	11.00	13.00	f	\N	1	
121	2	2002-02-25	9.00	11.00	f	\N	1	
121	2	2002-02-25	11.00	13.00	f	\N	1	
122	2	2002-02-25	9.00	11.00	f	\N	1	
122	2	2002-02-25	11.00	13.00	f	\N	1	
123	2	2002-02-25	9.00	11.00	f	\N	1	
123	2	2002-02-25	11.00	13.00	f	\N	1	
124	2	2002-02-25	9.00	11.00	f	\N	1	
124	2	2002-02-25	11.00	13.00	f	\N	1	
125	2	2002-02-25	9.00	11.00	f	\N	1	
125	2	2002-02-25	11.00	13.00	f	\N	1	
126	2	2002-02-25	9.00	11.00	f	\N	1	
126	2	2002-02-25	11.00	13.00	f	\N	1	
127	2	2002-02-25	9.00	11.00	f	\N	1	
127	2	2002-02-25	11.00	13.00	f	\N	1	
128	2	2002-02-25	9.00	11.00	f	\N	1	
128	2	2002-02-25	11.00	13.00	f	\N	1	
129	2	2002-02-25	9.00	11.00	f	\N	1	
129	2	2002-02-25	11.00	13.00	f	\N	1	
130	2	2002-02-25	9.00	11.00	f	\N	1	
130	2	2002-02-25	11.00	13.00	f	\N	1	
131	2	2002-02-25	9.00	11.00	f	\N	1	
131	2	2002-02-25	11.00	13.00	f	\N	1	
132	2	2002-02-25	9.00	11.00	f	\N	1	
132	2	2002-02-25	11.00	13.00	f	\N	1	
133	2	2002-02-25	9.00	11.00	f	\N	1	
133	2	2002-02-25	11.00	13.00	f	\N	1	
134	2	2002-02-25	9.00	11.00	f	\N	1	
134	2	2002-02-25	11.00	13.00	f	\N	1	
108	2	2002-02-25	9.00	11.00	f	\N	1	
108	2	2002-02-25	11.00	13.00	f	\N	1	
107	2	2002-02-25	9.00	11.00	f	\N	1	
107	2	2002-02-25	11.00	13.00	f	\N	1	
106	2	2002-02-25	9.00	11.00	f	\N	1	
106	2	2002-02-25	11.00	13.00	f	\N	1	
109	2	2002-02-25	9.00	11.00	f	\N	1	
109	2	2002-02-25	11.00	13.00	f	\N	1	
110	2	2002-02-25	9.00	11.00	f	\N	1	
110	2	2002-02-25	11.00	13.00	f	\N	1	
111	2	2002-02-25	9.00	11.00	f	\N	1	
111	2	2002-02-25	11.00	13.00	f	\N	1	
112	2	2002-02-25	9.00	11.00	f	\N	1	
112	2	2002-02-25	11.00	13.00	f	\N	1	
80	1	2002-02-25	9.00	13.00	f	\N	1	
85	1	2002-02-25	9.00	13.00	f	\N	1	
88	1	2002-02-25	9.00	13.00	f	\N	1	
98	1	2002-02-26	9.00	13.00	f	\N	1	
99	1	2002-02-26	9.00	13.00	f	\N	1	
100	1	2002-02-26	9.00	13.00	f	\N	1	
101	1	2002-02-26	9.00	13.00	f	\N	1	
102	1	2002-02-26	9.00	13.00	f	\N	1	
103	1	2002-02-26	9.00	13.00	f	\N	1	
104	1	2002-02-26	9.00	13.00	f	\N	1	
105	2	2002-02-26	9.00	11.00	f	\N	1	
105	2	2002-02-26	11.00	13.00	f	\N	1	
113	2	2002-02-26	9.00	11.00	f	\N	1	
113	2	2002-02-26	11.00	13.00	f	\N	1	
114	2	2002-02-26	9.00	11.00	f	\N	1	
114	2	2002-02-26	11.00	13.00	f	\N	1	
115	2	2002-02-26	9.00	11.00	f	\N	1	
115	2	2002-02-26	11.00	13.00	f	\N	1	
116	2	2002-02-26	9.00	11.00	f	\N	1	
116	2	2002-02-26	11.00	13.00	f	\N	1	
117	2	2002-02-26	9.00	11.00	f	\N	1	
117	2	2002-02-26	11.00	13.00	f	\N	1	
118	2	2002-02-26	9.00	11.00	f	\N	1	
118	2	2002-02-26	11.00	13.00	f	\N	1	
119	2	2002-02-26	9.00	11.00	f	\N	1	
119	2	2002-02-26	11.00	13.00	f	\N	1	
120	2	2002-02-26	9.00	11.00	f	\N	1	
120	2	2002-02-26	11.00	13.00	f	\N	1	
121	2	2002-02-26	9.00	11.00	f	\N	1	
121	2	2002-02-26	11.00	13.00	f	\N	1	
122	2	2002-02-26	9.00	11.00	f	\N	1	
122	2	2002-02-26	11.00	13.00	f	\N	1	
123	2	2002-02-26	9.00	11.00	f	\N	1	
123	2	2002-02-26	11.00	13.00	f	\N	1	
124	2	2002-02-26	9.00	11.00	f	\N	1	
124	2	2002-02-26	11.00	13.00	f	\N	1	
125	2	2002-02-26	9.00	11.00	f	\N	1	
125	2	2002-02-26	11.00	13.00	f	\N	1	
126	2	2002-02-26	9.00	11.00	f	\N	1	
126	2	2002-02-26	11.00	13.00	f	\N	1	
127	2	2002-02-26	9.00	11.00	f	\N	1	
127	2	2002-02-26	11.00	13.00	f	\N	1	
128	2	2002-02-26	9.00	11.00	f	\N	1	
128	2	2002-02-26	11.00	13.00	f	\N	1	
129	2	2002-02-26	9.00	11.00	f	\N	1	
129	2	2002-02-26	11.00	13.00	f	\N	1	
130	2	2002-02-26	9.00	11.00	f	\N	1	
130	2	2002-02-26	11.00	13.00	f	\N	1	
131	2	2002-02-26	9.00	11.00	f	\N	1	
131	2	2002-02-26	11.00	13.00	f	\N	1	
132	2	2002-02-26	9.00	11.00	f	\N	1	
132	2	2002-02-26	11.00	13.00	f	\N	1	
133	2	2002-02-26	9.00	11.00	f	\N	1	
133	2	2002-02-26	11.00	13.00	f	\N	1	
134	2	2002-02-26	9.00	11.00	f	\N	1	
134	2	2002-02-26	11.00	13.00	f	\N	1	
108	2	2002-02-26	9.00	11.00	f	\N	1	
108	2	2002-02-26	11.00	13.00	f	\N	1	
107	2	2002-02-26	9.00	11.00	f	\N	1	
107	2	2002-02-26	11.00	13.00	f	\N	1	
106	2	2002-02-26	9.00	11.00	f	\N	1	
106	2	2002-02-26	11.00	13.00	f	\N	1	
109	2	2002-02-26	9.00	11.00	f	\N	1	
109	2	2002-02-26	11.00	13.00	f	\N	1	
110	2	2002-02-26	9.00	11.00	f	\N	1	
110	2	2002-02-26	11.00	13.00	f	\N	1	
111	2	2002-02-26	9.00	11.00	f	\N	1	
111	2	2002-02-26	11.00	13.00	f	\N	1	
112	2	2002-02-26	9.00	11.00	f	\N	1	
112	2	2002-02-26	11.00	13.00	f	\N	1	
85	1	2002-02-26	9.00	13.00	f	\N	1	
87	1	2002-02-26	9.00	13.00	f	\N	1	
88	1	2002-02-26	9.00	13.00	f	\N	1	
84	1	2002-02-26	9.00	13.00	f	\N	1	
98	1	2002-02-27	9.00	13.00	f	\N	1	
99	1	2002-02-27	9.00	13.00	f	\N	1	
100	1	2002-02-27	9.00	13.00	f	\N	1	
101	1	2002-02-27	9.00	13.00	f	\N	1	
102	1	2002-02-27	9.00	13.00	f	\N	1	
103	1	2002-02-27	9.00	13.00	f	\N	1	
104	1	2002-02-27	9.00	13.00	f	\N	1	
105	2	2002-02-27	9.00	11.00	f	\N	1	
105	2	2002-02-27	11.00	13.00	f	\N	1	
113	2	2002-02-27	9.00	11.00	f	\N	1	
113	2	2002-02-27	11.00	13.00	f	\N	1	
114	2	2002-02-27	9.00	11.00	f	\N	1	
114	2	2002-02-27	11.00	13.00	f	\N	1	
115	2	2002-02-27	9.00	11.00	f	\N	1	
115	2	2002-02-27	11.00	13.00	f	\N	1	
116	2	2002-02-27	9.00	11.00	f	\N	1	
116	2	2002-02-27	11.00	13.00	f	\N	1	
117	2	2002-02-27	9.00	11.00	f	\N	1	
117	2	2002-02-27	11.00	13.00	f	\N	1	
118	2	2002-02-27	9.00	11.00	f	\N	1	
118	2	2002-02-27	11.00	13.00	f	\N	1	
119	2	2002-02-27	9.00	11.00	f	\N	1	
119	2	2002-02-27	11.00	13.00	f	\N	1	
120	2	2002-02-27	9.00	11.00	f	\N	1	
120	2	2002-02-27	11.00	13.00	f	\N	1	
121	2	2002-02-27	9.00	11.00	f	\N	1	
121	2	2002-02-27	11.00	13.00	f	\N	1	
122	2	2002-02-27	9.00	11.00	f	\N	1	
122	2	2002-02-27	11.00	13.00	f	\N	1	
123	2	2002-02-27	9.00	11.00	f	\N	1	
123	2	2002-02-27	11.00	13.00	f	\N	1	
124	2	2002-02-27	9.00	11.00	f	\N	1	
124	2	2002-02-27	11.00	13.00	f	\N	1	
125	2	2002-02-27	9.00	11.00	f	\N	1	
125	2	2002-02-27	11.00	13.00	f	\N	1	
126	2	2002-02-27	9.00	11.00	f	\N	1	
126	2	2002-02-27	11.00	13.00	f	\N	1	
127	2	2002-02-27	9.00	11.00	f	\N	1	
127	2	2002-02-27	11.00	13.00	f	\N	1	
128	2	2002-02-27	9.00	11.00	f	\N	1	
128	2	2002-02-27	11.00	13.00	f	\N	1	
129	2	2002-02-27	9.00	11.00	f	\N	1	
129	2	2002-02-27	11.00	13.00	f	\N	1	
130	2	2002-02-27	9.00	11.00	f	\N	1	
130	2	2002-02-27	11.00	13.00	f	\N	1	
131	2	2002-02-27	9.00	11.00	f	\N	1	
131	2	2002-02-27	11.00	13.00	f	\N	1	
132	2	2002-02-27	9.00	11.00	f	\N	1	
132	2	2002-02-27	11.00	13.00	f	\N	1	
133	2	2002-02-27	9.00	11.00	f	\N	1	
133	2	2002-02-27	11.00	13.00	f	\N	1	
134	2	2002-02-27	9.00	11.00	f	\N	1	
134	2	2002-02-27	11.00	13.00	f	\N	1	
108	2	2002-02-27	9.00	11.00	f	\N	1	
108	2	2002-02-27	11.00	13.00	f	\N	1	
107	2	2002-02-27	9.00	11.00	f	\N	1	
107	2	2002-02-27	11.00	13.00	f	\N	1	
106	2	2002-02-27	9.00	11.00	f	\N	1	
106	2	2002-02-27	11.00	13.00	f	\N	1	
109	2	2002-02-27	9.00	11.00	f	\N	1	
109	2	2002-02-27	11.00	13.00	f	\N	1	
110	2	2002-02-27	9.00	11.00	f	\N	1	
110	2	2002-02-27	11.00	13.00	f	\N	1	
111	2	2002-02-27	9.00	11.00	f	\N	1	
111	2	2002-02-27	11.00	13.00	f	\N	1	
112	2	2002-02-27	9.00	11.00	f	\N	1	
112	2	2002-02-27	11.00	13.00	f	\N	1	
80	1	2002-02-27	9.00	13.00	f	\N	1	
84	1	2002-02-27	9.00	13.00	f	\N	1	
85	1	2002-02-27	9.00	13.00	f	\N	1	
98	1	2002-02-28	9.00	13.00	f	\N	1	
99	1	2002-02-28	9.00	13.00	f	\N	1	
100	1	2002-02-28	9.00	13.00	f	\N	1	
101	1	2002-02-28	9.00	13.00	f	\N	1	
102	1	2002-02-28	9.00	13.00	f	\N	1	
103	1	2002-02-28	9.00	13.00	f	\N	1	
104	1	2002-02-28	9.00	13.00	f	\N	1	
105	2	2002-02-28	9.00	11.00	f	\N	1	
105	2	2002-02-28	11.00	13.00	f	\N	1	
113	2	2002-02-28	9.00	11.00	f	\N	1	
113	2	2002-02-28	11.00	13.00	f	\N	1	
114	2	2002-02-28	9.00	11.00	f	\N	1	
114	2	2002-02-28	11.00	13.00	f	\N	1	
115	2	2002-02-28	9.00	11.00	f	\N	1	
115	2	2002-02-28	11.00	13.00	f	\N	1	
116	2	2002-02-28	9.00	11.00	f	\N	1	
116	2	2002-02-28	11.00	13.00	f	\N	1	
117	2	2002-02-28	9.00	11.00	f	\N	1	
117	2	2002-02-28	11.00	13.00	f	\N	1	
118	2	2002-02-28	9.00	11.00	f	\N	1	
118	2	2002-02-28	11.00	13.00	f	\N	1	
119	2	2002-02-28	9.00	11.00	f	\N	1	
119	2	2002-02-28	11.00	13.00	f	\N	1	
120	2	2002-02-28	9.00	11.00	f	\N	1	
120	2	2002-02-28	11.00	13.00	f	\N	1	
121	2	2002-02-28	9.00	11.00	f	\N	1	
121	2	2002-02-28	11.00	13.00	f	\N	1	
122	2	2002-02-28	9.00	11.00	f	\N	1	
122	2	2002-02-28	11.00	13.00	f	\N	1	
123	2	2002-02-28	9.00	11.00	f	\N	1	
123	2	2002-02-28	11.00	13.00	f	\N	1	
124	2	2002-02-28	9.00	11.00	f	\N	1	
124	2	2002-02-28	11.00	13.00	f	\N	1	
125	2	2002-02-28	9.00	11.00	f	\N	1	
125	2	2002-02-28	11.00	13.00	f	\N	1	
126	2	2002-02-28	9.00	11.00	f	\N	1	
126	2	2002-02-28	11.00	13.00	f	\N	1	
127	2	2002-02-28	9.00	11.00	f	\N	1	
127	2	2002-02-28	11.00	13.00	f	\N	1	
128	2	2002-02-28	9.00	11.00	f	\N	1	
128	2	2002-02-28	11.00	13.00	f	\N	1	
129	2	2002-02-28	9.00	11.00	f	\N	1	
129	2	2002-02-28	11.00	13.00	f	\N	1	
130	2	2002-02-28	9.00	11.00	f	\N	1	
130	2	2002-02-28	11.00	13.00	f	\N	1	
131	2	2002-02-28	9.00	11.00	f	\N	1	
131	2	2002-02-28	11.00	13.00	f	\N	1	
132	2	2002-02-28	9.00	11.00	f	\N	1	
132	2	2002-02-28	11.00	13.00	f	\N	1	
133	2	2002-02-28	9.00	11.00	f	\N	1	
133	2	2002-02-28	11.00	13.00	f	\N	1	
134	2	2002-02-28	9.00	11.00	f	\N	1	
134	2	2002-02-28	11.00	13.00	f	\N	1	
108	2	2002-02-28	9.00	11.00	f	\N	1	
108	2	2002-02-28	11.00	13.00	f	\N	1	
107	2	2002-02-28	9.00	11.00	f	\N	1	
107	2	2002-02-28	11.00	13.00	f	\N	1	
106	2	2002-02-28	9.00	11.00	f	\N	1	
106	2	2002-02-28	11.00	13.00	f	\N	1	
109	2	2002-02-28	9.00	11.00	f	\N	1	
109	2	2002-02-28	11.00	13.00	f	\N	1	
110	2	2002-02-28	9.00	11.00	f	\N	1	
110	2	2002-02-28	11.00	13.00	f	\N	1	
111	2	2002-02-28	9.00	11.00	f	\N	1	
111	2	2002-02-28	11.00	13.00	f	\N	1	
112	2	2002-02-28	9.00	11.00	f	\N	1	
112	2	2002-02-28	11.00	13.00	f	\N	1	
80	1	2002-02-28	9.00	13.00	f	\N	1	
83	1	2002-02-28	9.00	13.00	f	\N	1	
84	1	2002-02-28	9.00	13.00	f	\N	1	
85	1	2002-02-28	9.00	13.00	f	\N	1	
86	1	2002-02-28	9.00	13.00	f	\N	1	
87	1	2002-02-28	9.00	13.00	f	\N	1	
88	1	2002-02-28	9.00	13.00	f	\N	1	
160	1	2002-02-25	9.00	13.00	f	\N	1	
160	1	2002-02-26	9.00	13.00	f	\N	1	
160	1	2002-02-27	9.00	13.00	f	\N	1	
160	1	2002-02-28	9.00	13.00	f	\N	1	
98	1	2002-03-01	9.00	13.00	f	\N	1	
99	1	2002-03-01	9.00	13.00	f	\N	1	
100	1	2002-03-01	9.00	13.00	f	\N	1	
101	1	2002-03-01	9.00	13.00	f	\N	1	
102	1	2002-03-01	9.00	13.00	f	\N	1	
103	1	2002-03-01	9.00	13.00	f	\N	1	
104	1	2002-03-01	9.00	13.00	f	\N	1	
105	2	2002-03-01	9.00	11.00	f	\N	1	
105	2	2002-03-01	11.00	13.00	f	\N	1	
113	2	2002-03-01	9.00	11.00	f	\N	1	
113	2	2002-03-01	11.00	13.00	f	\N	1	
114	2	2002-03-01	9.00	11.00	f	\N	1	
114	2	2002-03-01	11.00	13.00	f	\N	1	
115	2	2002-03-01	9.00	11.00	f	\N	1	
115	2	2002-03-01	11.00	13.00	f	\N	1	
116	2	2002-03-01	9.00	11.00	f	\N	1	
116	2	2002-03-01	11.00	13.00	f	\N	1	
117	2	2002-03-01	9.00	11.00	f	\N	1	
117	2	2002-03-01	11.00	13.00	f	\N	1	
118	2	2002-03-01	9.00	11.00	f	\N	1	
118	2	2002-03-01	11.00	13.00	f	\N	1	
119	2	2002-03-01	9.00	11.00	f	\N	1	
119	2	2002-03-01	11.00	13.00	f	\N	1	
120	2	2002-03-01	9.00	11.00	f	\N	1	
120	2	2002-03-01	11.00	13.00	f	\N	1	
121	2	2002-03-01	9.00	11.00	f	\N	1	
121	2	2002-03-01	11.00	13.00	f	\N	1	
122	2	2002-03-01	9.00	11.00	f	\N	1	
122	2	2002-03-01	11.00	13.00	f	\N	1	
123	2	2002-03-01	9.00	11.00	f	\N	1	
123	2	2002-03-01	11.00	13.00	f	\N	1	
124	2	2002-03-01	9.00	11.00	f	\N	1	
124	2	2002-03-01	11.00	13.00	f	\N	1	
125	2	2002-03-01	9.00	11.00	f	\N	1	
125	2	2002-03-01	11.00	13.00	f	\N	1	
126	2	2002-03-01	9.00	11.00	f	\N	1	
126	2	2002-03-01	11.00	13.00	f	\N	1	
127	2	2002-03-01	9.00	11.00	f	\N	1	
127	2	2002-03-01	11.00	13.00	f	\N	1	
128	2	2002-03-01	9.00	11.00	f	\N	1	
128	2	2002-03-01	11.00	13.00	f	\N	1	
129	2	2002-03-01	9.00	11.00	f	\N	1	
129	2	2002-03-01	11.00	13.00	f	\N	1	
130	2	2002-03-01	9.00	11.00	f	\N	1	
130	2	2002-03-01	11.00	13.00	f	\N	1	
131	2	2002-03-01	9.00	11.00	f	\N	1	
131	2	2002-03-01	11.00	13.00	f	\N	1	
132	2	2002-03-01	9.00	11.00	f	\N	1	
132	2	2002-03-01	11.00	13.00	f	\N	1	
133	2	2002-03-01	9.00	11.00	f	\N	1	
133	2	2002-03-01	11.00	13.00	f	\N	1	
134	2	2002-03-01	9.00	11.00	f	\N	1	
134	2	2002-03-01	11.00	13.00	f	\N	1	
108	2	2002-03-01	9.00	11.00	f	\N	1	
108	2	2002-03-01	11.00	13.00	f	\N	1	
107	2	2002-03-01	9.00	11.00	f	\N	1	
107	2	2002-03-01	11.00	13.00	f	\N	1	
106	2	2002-03-01	9.00	11.00	f	\N	1	
106	2	2002-03-01	11.00	13.00	f	\N	1	
109	2	2002-03-01	9.00	11.00	f	\N	1	
109	2	2002-03-01	11.00	13.00	f	\N	1	
110	2	2002-03-01	9.00	11.00	f	\N	1	
110	2	2002-03-01	11.00	13.00	f	\N	1	
111	2	2002-03-01	9.00	11.00	f	\N	1	
111	2	2002-03-01	11.00	13.00	f	\N	1	
112	2	2002-03-01	9.00	11.00	f	\N	1	
112	2	2002-03-01	11.00	13.00	f	\N	1	
160	1	2002-03-01	9.00	13.00	f	\N	1	
137	1	2002-03-01	9.00	13.00	f	\N	1	
138	1	2002-03-01	9.00	13.00	f	\N	1	
141	1	2002-03-01	9.00	13.00	f	\N	1	
80	1	2002-03-01	9.00	13.00	f	\N	1	
81	1	2002-03-01	9.00	13.00	f	\N	1	
82	1	2002-03-01	9.00	13.00	f	\N	1	
83	1	2002-03-01	9.00	13.00	f	\N	1	
84	1	2002-03-01	9.00	13.00	f	\N	1	
85	1	2002-03-01	9.00	13.00	f	\N	1	
86	1	2002-03-01	9.00	13.00	f	\N	1	
87	1	2002-03-01	9.00	13.00	f	\N	1	
88	1	2002-03-01	9.00	13.00	f	\N	1	
98	1	2002-03-02	9.00	13.00	f	\N	1	
99	1	2002-03-02	9.00	13.00	f	\N	1	
100	1	2002-03-02	9.00	13.00	f	\N	1	
101	1	2002-03-02	9.00	13.00	f	\N	1	
102	1	2002-03-02	9.00	13.00	f	\N	1	
103	1	2002-03-02	9.00	13.00	f	\N	1	
104	1	2002-03-02	9.00	13.00	f	\N	1	
105	2	2002-03-02	9.00	11.00	f	\N	1	
105	2	2002-03-02	11.00	13.00	f	\N	1	
113	2	2002-03-02	9.00	11.00	f	\N	1	
113	2	2002-03-02	11.00	13.00	f	\N	1	
114	2	2002-03-02	9.00	11.00	f	\N	1	
114	2	2002-03-02	11.00	13.00	f	\N	1	
115	2	2002-03-02	9.00	11.00	f	\N	1	
115	2	2002-03-02	11.00	13.00	f	\N	1	
116	2	2002-03-02	9.00	11.00	f	\N	1	
116	2	2002-03-02	11.00	13.00	f	\N	1	
117	2	2002-03-02	9.00	11.00	f	\N	1	
117	2	2002-03-02	11.00	13.00	f	\N	1	
118	2	2002-03-02	9.00	11.00	f	\N	1	
118	2	2002-03-02	11.00	13.00	f	\N	1	
119	2	2002-03-02	9.00	11.00	f	\N	1	
119	2	2002-03-02	11.00	13.00	f	\N	1	
120	2	2002-03-02	9.00	11.00	f	\N	1	
120	2	2002-03-02	11.00	13.00	f	\N	1	
121	2	2002-03-02	9.00	11.00	f	\N	1	
121	2	2002-03-02	11.00	13.00	f	\N	1	
122	2	2002-03-02	9.00	11.00	f	\N	1	
122	2	2002-03-02	11.00	13.00	f	\N	1	
123	2	2002-03-02	9.00	11.00	f	\N	1	
123	2	2002-03-02	11.00	13.00	f	\N	1	
124	2	2002-03-02	9.00	11.00	f	\N	1	
124	2	2002-03-02	11.00	13.00	f	\N	1	
125	2	2002-03-02	9.00	11.00	f	\N	1	
125	2	2002-03-02	11.00	13.00	f	\N	1	
126	2	2002-03-02	9.00	11.00	f	\N	1	
126	2	2002-03-02	11.00	13.00	f	\N	1	
127	2	2002-03-02	9.00	11.00	f	\N	1	
127	2	2002-03-02	11.00	13.00	f	\N	1	
128	2	2002-03-02	9.00	11.00	f	\N	1	
128	2	2002-03-02	11.00	13.00	f	\N	1	
129	2	2002-03-02	9.00	11.00	f	\N	1	
129	2	2002-03-02	11.00	13.00	f	\N	1	
130	2	2002-03-02	9.00	11.00	f	\N	1	
130	2	2002-03-02	11.00	13.00	f	\N	1	
131	2	2002-03-02	9.00	11.00	f	\N	1	
131	2	2002-03-02	11.00	13.00	f	\N	1	
132	2	2002-03-02	9.00	11.00	f	\N	1	
132	2	2002-03-02	11.00	13.00	f	\N	1	
133	2	2002-03-02	9.00	11.00	f	\N	1	
133	2	2002-03-02	11.00	13.00	f	\N	1	
134	2	2002-03-02	9.00	11.00	f	\N	1	
134	2	2002-03-02	11.00	13.00	f	\N	1	
108	2	2002-03-02	9.00	11.00	f	\N	1	
108	2	2002-03-02	11.00	13.00	f	\N	1	
107	2	2002-03-02	9.00	11.00	f	\N	1	
107	2	2002-03-02	11.00	13.00	f	\N	1	
106	2	2002-03-02	9.00	11.00	f	\N	1	
106	2	2002-03-02	11.00	13.00	f	\N	1	
109	2	2002-03-02	9.00	11.00	f	\N	1	
109	2	2002-03-02	11.00	13.00	f	\N	1	
110	2	2002-03-02	9.00	11.00	f	\N	1	
110	2	2002-03-02	11.00	13.00	f	\N	1	
111	2	2002-03-02	9.00	11.00	f	\N	1	
111	2	2002-03-02	11.00	13.00	f	\N	1	
112	2	2002-03-02	9.00	11.00	f	\N	1	
112	2	2002-03-02	11.00	13.00	f	\N	1	
93	1	2002-03-02	10.00	14.00	f	\N	1	
94	1	2002-03-02	10.00	14.00	f	\N	1	
95	1	2002-03-02	10.00	14.00	f	\N	1	
91	1	2002-03-02	10.00	14.00	f	\N	1	
135	1	2002-03-02	10.00	14.00	f	\N	1	
137	1	2002-03-02	10.00	14.00	f	\N	1	
138	1	2002-03-02	10.00	14.00	f	\N	1	
141	1	2002-03-02	10.00	14.00	f	\N	1	
140	1	2002-03-02	10.00	14.00	f	\N	1	
136	1	2002-03-02	10.00	14.00	f	\N	1	
139	1	2002-03-02	10.00	14.00	f	\N	1	
90	1	2002-03-03	10.00	14.00	f	\N	1	
93	1	2002-03-03	10.00	14.00	f	\N	1	
95	1	2002-03-03	10.00	14.00	f	\N	1	
91	1	2002-03-03	10.00	14.00	f	\N	1	
86	1	2002-02-26	9.00	13.00	f	\N	1	
88	1	2002-02-27	9.00	13.00	f	\N	1	
159	3	2002-03-04	11.00	12.00	f		1	
159	3	2002-03-02	10.00	11.00	t	1234567890	2	test internrum 10-15
159	3	2002-03-02	11.00	12.00	t	1234567890	2	test internrum 10-15
159	3	2002-03-02	12.00	13.00	t	1234567890	2	test internrum 10-15
159	3	2002-03-02	13.00	14.00	t	1234567890	2	test internrum 10-15
159	3	2002-03-02	14.00	15.00	t	1234567890	2	test internrum 10-15
96	1	2002-02-25	17.00	21.00	t	3550650527	4	Andreas!
159	3	2002-03-02	7.00	8.00	t	1234567890	2	två pass
159	3	2002-03-02	8.00	9.00	t	1234567890	2	två pass
159	3	2002-03-02	9.00	10.00	t	1234567890	2	ett pass
93	1	2002-02-27	17.00	21.00	t	3320690227	2	Janne
98	1	2002-03-04	9.00	13.00	f	\N	1	\N
98	1	2002-03-04	13.00	17.00	f	\N	1	\N
98	1	2002-03-04	17.00	21.00	f	\N	1	\N
99	1	2002-03-04	9.00	13.00	f	\N	1	\N
99	1	2002-03-04	13.00	17.00	f	\N	1	\N
99	1	2002-03-04	17.00	21.00	f	\N	1	\N
100	1	2002-03-04	9.00	13.00	f	\N	1	\N
100	1	2002-03-04	13.00	17.00	f	\N	1	\N
100	1	2002-03-04	17.00	21.00	f	\N	1	\N
101	1	2002-03-04	9.00	13.00	f	\N	1	\N
101	1	2002-03-04	13.00	17.00	f	\N	1	\N
101	1	2002-03-04	17.00	21.00	f	\N	1	\N
102	1	2002-03-04	9.00	13.00	f	\N	1	\N
102	1	2002-03-04	13.00	17.00	f	\N	1	\N
102	1	2002-03-04	17.00	21.00	f	\N	1	\N
103	1	2002-03-04	9.00	13.00	f	\N	1	\N
103	1	2002-03-04	13.00	17.00	f	\N	1	\N
103	1	2002-03-04	17.00	21.00	f	\N	1	\N
104	1	2002-03-04	9.00	13.00	f	\N	1	\N
104	1	2002-03-04	13.00	17.00	f	\N	1	\N
104	1	2002-03-04	17.00	21.00	f	\N	1	\N
105	2	2002-03-04	9.00	11.00	f	\N	1	\N
105	2	2002-03-04	11.00	13.00	f	\N	1	\N
105	2	2002-03-04	13.00	15.00	f	\N	1	\N
105	2	2002-03-04	15.00	17.00	f	\N	1	\N
105	2	2002-03-04	17.00	19.00	f	\N	1	\N
105	2	2002-03-04	19.00	21.00	f	\N	1	\N
113	2	2002-03-04	9.00	11.00	f	\N	1	\N
113	2	2002-03-04	11.00	13.00	f	\N	1	\N
113	2	2002-03-04	13.00	15.00	f	\N	1	\N
113	2	2002-03-04	15.00	17.00	f	\N	1	\N
113	2	2002-03-04	17.00	19.00	f	\N	1	\N
113	2	2002-03-04	19.00	21.00	f	\N	1	\N
114	2	2002-03-04	9.00	11.00	f	\N	1	\N
114	2	2002-03-04	11.00	13.00	f	\N	1	\N
114	2	2002-03-04	13.00	15.00	f	\N	1	\N
114	2	2002-03-04	15.00	17.00	f	\N	1	\N
114	2	2002-03-04	17.00	19.00	f	\N	1	\N
114	2	2002-03-04	19.00	21.00	f	\N	1	\N
115	2	2002-03-04	9.00	11.00	f	\N	1	\N
115	2	2002-03-04	11.00	13.00	f	\N	1	\N
115	2	2002-03-04	13.00	15.00	f	\N	1	\N
115	2	2002-03-04	15.00	17.00	f	\N	1	\N
115	2	2002-03-04	17.00	19.00	f	\N	1	\N
115	2	2002-03-04	19.00	21.00	f	\N	1	\N
116	2	2002-03-04	9.00	11.00	f	\N	1	\N
116	2	2002-03-04	11.00	13.00	f	\N	1	\N
116	2	2002-03-04	13.00	15.00	f	\N	1	\N
116	2	2002-03-04	15.00	17.00	f	\N	1	\N
116	2	2002-03-04	17.00	19.00	f	\N	1	\N
116	2	2002-03-04	19.00	21.00	f	\N	1	\N
117	2	2002-03-04	9.00	11.00	f	\N	1	\N
117	2	2002-03-04	11.00	13.00	f	\N	1	\N
117	2	2002-03-04	13.00	15.00	f	\N	1	\N
117	2	2002-03-04	15.00	17.00	f	\N	1	\N
117	2	2002-03-04	17.00	19.00	f	\N	1	\N
117	2	2002-03-04	19.00	21.00	f	\N	1	\N
118	2	2002-03-04	9.00	11.00	f	\N	1	\N
118	2	2002-03-04	11.00	13.00	f	\N	1	\N
118	2	2002-03-04	13.00	15.00	f	\N	1	\N
118	2	2002-03-04	15.00	17.00	f	\N	1	\N
118	2	2002-03-04	17.00	19.00	f	\N	1	\N
118	2	2002-03-04	19.00	21.00	f	\N	1	\N
119	2	2002-03-04	9.00	11.00	f	\N	1	\N
119	2	2002-03-04	11.00	13.00	f	\N	1	\N
119	2	2002-03-04	13.00	15.00	f	\N	1	\N
119	2	2002-03-04	15.00	17.00	f	\N	1	\N
119	2	2002-03-04	17.00	19.00	f	\N	1	\N
119	2	2002-03-04	19.00	21.00	f	\N	1	\N
120	2	2002-03-04	9.00	11.00	f	\N	1	\N
120	2	2002-03-04	11.00	13.00	f	\N	1	\N
120	2	2002-03-04	13.00	15.00	f	\N	1	\N
120	2	2002-03-04	15.00	17.00	f	\N	1	\N
120	2	2002-03-04	17.00	19.00	f	\N	1	\N
120	2	2002-03-04	19.00	21.00	f	\N	1	\N
121	2	2002-03-04	9.00	11.00	f	\N	1	\N
121	2	2002-03-04	11.00	13.00	f	\N	1	\N
121	2	2002-03-04	13.00	15.00	f	\N	1	\N
121	2	2002-03-04	15.00	17.00	f	\N	1	\N
121	2	2002-03-04	17.00	19.00	f	\N	1	\N
121	2	2002-03-04	19.00	21.00	f	\N	1	\N
122	2	2002-03-04	9.00	11.00	f	\N	1	\N
122	2	2002-03-04	11.00	13.00	f	\N	1	\N
122	2	2002-03-04	13.00	15.00	f	\N	1	\N
122	2	2002-03-04	15.00	17.00	f	\N	1	\N
122	2	2002-03-04	17.00	19.00	f	\N	1	\N
122	2	2002-03-04	19.00	21.00	f	\N	1	\N
123	2	2002-03-04	9.00	11.00	f	\N	1	\N
123	2	2002-03-04	11.00	13.00	f	\N	1	\N
123	2	2002-03-04	13.00	15.00	f	\N	1	\N
123	2	2002-03-04	15.00	17.00	f	\N	1	\N
123	2	2002-03-04	17.00	19.00	f	\N	1	\N
123	2	2002-03-04	19.00	21.00	f	\N	1	\N
124	2	2002-03-04	9.00	11.00	f	\N	1	\N
124	2	2002-03-04	11.00	13.00	f	\N	1	\N
124	2	2002-03-04	13.00	15.00	f	\N	1	\N
124	2	2002-03-04	15.00	17.00	f	\N	1	\N
124	2	2002-03-04	17.00	19.00	f	\N	1	\N
124	2	2002-03-04	19.00	21.00	f	\N	1	\N
125	2	2002-03-04	9.00	11.00	f	\N	1	\N
125	2	2002-03-04	11.00	13.00	f	\N	1	\N
125	2	2002-03-04	13.00	15.00	f	\N	1	\N
125	2	2002-03-04	15.00	17.00	f	\N	1	\N
125	2	2002-03-04	17.00	19.00	f	\N	1	\N
125	2	2002-03-04	19.00	21.00	f	\N	1	\N
126	2	2002-03-04	9.00	11.00	f	\N	1	\N
126	2	2002-03-04	11.00	13.00	f	\N	1	\N
126	2	2002-03-04	13.00	15.00	f	\N	1	\N
126	2	2002-03-04	15.00	17.00	f	\N	1	\N
126	2	2002-03-04	17.00	19.00	f	\N	1	\N
126	2	2002-03-04	19.00	21.00	f	\N	1	\N
127	2	2002-03-04	9.00	11.00	f	\N	1	\N
127	2	2002-03-04	11.00	13.00	f	\N	1	\N
127	2	2002-03-04	13.00	15.00	f	\N	1	\N
127	2	2002-03-04	15.00	17.00	f	\N	1	\N
127	2	2002-03-04	17.00	19.00	f	\N	1	\N
127	2	2002-03-04	19.00	21.00	f	\N	1	\N
128	2	2002-03-04	9.00	11.00	f	\N	1	\N
128	2	2002-03-04	11.00	13.00	f	\N	1	\N
128	2	2002-03-04	13.00	15.00	f	\N	1	\N
128	2	2002-03-04	15.00	17.00	f	\N	1	\N
128	2	2002-03-04	17.00	19.00	f	\N	1	\N
128	2	2002-03-04	19.00	21.00	f	\N	1	\N
129	2	2002-03-04	9.00	11.00	f	\N	1	\N
129	2	2002-03-04	11.00	13.00	f	\N	1	\N
129	2	2002-03-04	13.00	15.00	f	\N	1	\N
129	2	2002-03-04	15.00	17.00	f	\N	1	\N
129	2	2002-03-04	17.00	19.00	f	\N	1	\N
129	2	2002-03-04	19.00	21.00	f	\N	1	\N
130	2	2002-03-04	9.00	11.00	f	\N	1	\N
130	2	2002-03-04	11.00	13.00	f	\N	1	\N
130	2	2002-03-04	13.00	15.00	f	\N	1	\N
130	2	2002-03-04	15.00	17.00	f	\N	1	\N
130	2	2002-03-04	17.00	19.00	f	\N	1	\N
130	2	2002-03-04	19.00	21.00	f	\N	1	\N
131	2	2002-03-04	9.00	11.00	f	\N	1	\N
131	2	2002-03-04	11.00	13.00	f	\N	1	\N
131	2	2002-03-04	13.00	15.00	f	\N	1	\N
131	2	2002-03-04	15.00	17.00	f	\N	1	\N
131	2	2002-03-04	17.00	19.00	f	\N	1	\N
131	2	2002-03-04	19.00	21.00	f	\N	1	\N
132	2	2002-03-04	9.00	11.00	f	\N	1	\N
132	2	2002-03-04	11.00	13.00	f	\N	1	\N
132	2	2002-03-04	13.00	15.00	f	\N	1	\N
132	2	2002-03-04	15.00	17.00	f	\N	1	\N
132	2	2002-03-04	17.00	19.00	f	\N	1	\N
132	2	2002-03-04	19.00	21.00	f	\N	1	\N
133	2	2002-03-04	9.00	11.00	f	\N	1	\N
133	2	2002-03-04	11.00	13.00	f	\N	1	\N
133	2	2002-03-04	13.00	15.00	f	\N	1	\N
133	2	2002-03-04	15.00	17.00	f	\N	1	\N
133	2	2002-03-04	17.00	19.00	f	\N	1	\N
133	2	2002-03-04	19.00	21.00	f	\N	1	\N
134	2	2002-03-04	9.00	11.00	f	\N	1	\N
134	2	2002-03-04	11.00	13.00	f	\N	1	\N
134	2	2002-03-04	13.00	15.00	f	\N	1	\N
134	2	2002-03-04	15.00	17.00	f	\N	1	\N
134	2	2002-03-04	17.00	19.00	f	\N	1	\N
134	2	2002-03-04	19.00	21.00	f	\N	1	\N
108	2	2002-03-04	9.00	11.00	f	\N	1	\N
108	2	2002-03-04	11.00	13.00	f	\N	1	\N
108	2	2002-03-04	13.00	15.00	f	\N	1	\N
108	2	2002-03-04	15.00	17.00	f	\N	1	\N
108	2	2002-03-04	17.00	19.00	f	\N	1	\N
108	2	2002-03-04	19.00	21.00	f	\N	1	\N
107	2	2002-03-04	9.00	11.00	f	\N	1	\N
107	2	2002-03-04	11.00	13.00	f	\N	1	\N
107	2	2002-03-04	13.00	15.00	f	\N	1	\N
107	2	2002-03-04	15.00	17.00	f	\N	1	\N
107	2	2002-03-04	17.00	19.00	f	\N	1	\N
107	2	2002-03-04	19.00	21.00	f	\N	1	\N
106	2	2002-03-04	9.00	11.00	f	\N	1	\N
106	2	2002-03-04	11.00	13.00	f	\N	1	\N
106	2	2002-03-04	13.00	15.00	f	\N	1	\N
106	2	2002-03-04	15.00	17.00	f	\N	1	\N
106	2	2002-03-04	17.00	19.00	f	\N	1	\N
106	2	2002-03-04	19.00	21.00	f	\N	1	\N
109	2	2002-03-04	9.00	11.00	f	\N	1	\N
109	2	2002-03-04	11.00	13.00	f	\N	1	\N
109	2	2002-03-04	13.00	15.00	f	\N	1	\N
109	2	2002-03-04	15.00	17.00	f	\N	1	\N
109	2	2002-03-04	17.00	19.00	f	\N	1	\N
109	2	2002-03-04	19.00	21.00	f	\N	1	\N
110	2	2002-03-04	9.00	11.00	f	\N	1	\N
110	2	2002-03-04	11.00	13.00	f	\N	1	\N
110	2	2002-03-04	13.00	15.00	f	\N	1	\N
110	2	2002-03-04	15.00	17.00	f	\N	1	\N
110	2	2002-03-04	17.00	19.00	f	\N	1	\N
110	2	2002-03-04	19.00	21.00	f	\N	1	\N
111	2	2002-03-04	9.00	11.00	f	\N	1	\N
111	2	2002-03-04	11.00	13.00	f	\N	1	\N
111	2	2002-03-04	13.00	15.00	f	\N	1	\N
111	2	2002-03-04	15.00	17.00	f	\N	1	\N
111	2	2002-03-04	17.00	19.00	f	\N	1	\N
111	2	2002-03-04	19.00	21.00	f	\N	1	\N
112	2	2002-03-04	9.00	11.00	f	\N	1	\N
112	2	2002-03-04	11.00	13.00	f	\N	1	\N
112	2	2002-03-04	13.00	15.00	f	\N	1	\N
112	2	2002-03-04	15.00	17.00	f	\N	1	\N
112	2	2002-03-04	17.00	19.00	f	\N	1	\N
112	2	2002-03-04	19.00	21.00	f	\N	1	\N
89	1	2002-03-04	13.00	17.00	f	\N	1	\N
89	1	2002-03-04	17.00	21.00	f	\N	1	\N
90	1	2002-03-04	9.00	13.00	f	\N	1	\N
90	1	2002-03-04	17.00	21.00	f	\N	1	\N
92	1	2002-03-04	13.00	17.00	f	\N	1	\N
92	1	2002-03-04	17.00	21.00	f	\N	1	\N
93	1	2002-03-04	13.00	17.00	f	\N	1	\N
93	1	2002-03-04	17.00	21.00	f	\N	1	\N
94	1	2002-03-04	9.00	13.00	f	\N	1	\N
94	1	2002-03-04	13.00	17.00	f	\N	1	\N
94	1	2002-03-04	17.00	21.00	f	\N	1	\N
95	1	2002-03-04	13.00	17.00	f	\N	1	\N
95	1	2002-03-04	17.00	21.00	f	\N	1	\N
96	1	2002-03-04	9.00	13.00	f	\N	1	\N
96	1	2002-03-04	17.00	21.00	f	\N	1	\N
91	1	2002-03-04	9.00	13.00	f	\N	1	\N
91	1	2002-03-04	17.00	21.00	f	\N	1	\N
160	1	2002-03-04	9.00	13.00	f	\N	1	\N
160	1	2002-03-04	13.00	16.30	f	\N	1	\N
135	1	2002-03-04	9.00	13.00	f	\N	1	\N
135	1	2002-03-04	13.00	17.00	f	\N	1	\N
135	1	2002-03-04	17.00	21.00	f	\N	1	\N
137	1	2002-03-04	9.00	13.00	f	\N	1	\N
137	1	2002-03-04	13.00	17.00	f	\N	1	\N
137	1	2002-03-04	17.00	21.00	f	\N	1	\N
138	1	2002-03-04	9.00	13.00	f	\N	1	\N
138	1	2002-03-04	13.00	17.00	f	\N	1	\N
138	1	2002-03-04	17.00	21.00	f	\N	1	\N
141	1	2002-03-04	9.00	13.00	f	\N	1	\N
141	1	2002-03-04	13.00	17.00	f	\N	1	\N
141	1	2002-03-04	17.00	21.00	f	\N	1	\N
97	1	2002-03-04	13.00	17.00	f	\N	1	\N
97	1	2002-03-04	17.00	21.00	f	\N	1	\N
140	1	2002-03-04	9.00	13.00	f	\N	1	\N
140	1	2002-03-04	13.00	17.00	f	\N	1	\N
140	1	2002-03-04	17.00	21.00	f	\N	1	\N
136	1	2002-03-04	13.00	17.00	f	\N	1	\N
136	1	2002-03-04	17.00	21.00	f	\N	1	\N
139	1	2002-03-04	9.00	13.00	f	\N	1	\N
139	1	2002-03-04	13.00	17.00	f	\N	1	\N
139	1	2002-03-04	17.00	21.00	f	\N	1	\N
80	1	2002-03-04	9.00	13.00	f	\N	1	\N
80	1	2002-03-04	13.00	17.00	f	\N	1	\N
81	1	2002-03-04	9.00	13.00	f	\N	1	\N
81	1	2002-03-04	13.00	17.00	f	\N	1	\N
82	1	2002-03-04	9.00	13.00	f	\N	1	\N
82	1	2002-03-04	13.00	17.00	f	\N	1	\N
83	1	2002-03-04	9.00	13.00	f	\N	1	\N
83	1	2002-03-04	13.00	17.00	f	\N	1	\N
84	1	2002-03-04	9.00	13.00	f	\N	1	\N
84	1	2002-03-04	13.00	17.00	f	\N	1	\N
85	1	2002-03-04	9.00	13.00	f	\N	1	\N
85	1	2002-03-04	13.00	17.00	f	\N	1	\N
86	1	2002-03-04	9.00	13.00	f	\N	1	\N
86	1	2002-03-04	13.00	17.00	f	\N	1	\N
87	1	2002-03-04	9.00	13.00	f	\N	1	\N
87	1	2002-03-04	13.00	17.00	f	\N	1	\N
88	1	2002-03-04	9.00	13.00	f	\N	1	\N
88	1	2002-03-04	13.00	17.00	f	\N	1	\N
136	1	2002-03-01	9.00	13.00	t	3210550127	2	Björn (IA0106-12)
96	1	2002-03-04	13.00	17.00	t	3160390227	2	Susanne, Elisabet, Anneli
93	1	2002-03-04	9.00	13.00	t	3250250327	2	Mia m fl
92	1	2002-03-04	9.00	13.00	t	3250790027	2	Sara & Sofia
97	1	2002-02-26	9.00	13.00	t	3580030827	4	Lena, Pia mfl.
96	1	2002-02-26	9.00	13.00	t	3210950227	4	Christoffer
139	1	2002-02-26	9.00	13.00	t	3260990127	4	Eive A
92	1	2002-02-26	9.00	13.00	t	3230750427	4	Göran
141	1	2002-02-26	9.00	13.00	t	3550370327	4	KARIN W
81	1	2002-02-26	9.00	13.00	t	3160590227	4	malin
91	1	2002-02-26	9.00	13.00	t	3230560227	4	Lotta Svensson
89	1	2002-02-26	9.00	13.00	t	3480570227	4	Camilla
95	1	2002-02-26	9.00	13.00	t	3070850127	4	Marianne mfl
137	1	2002-02-26	9.00	13.00	t	3320940527	4	Karin
82	1	2002-02-27	9.00	13.00	t	3300090127	2	lena
138	1	2002-02-26	17.00	21.00	t	3310950027	2	Anneli
140	1	2002-02-26	9.00	13.00	t	24000632544551	4	Marie
138	1	2002-02-26	9.00	13.00	t	3160070427	4	charlotte adonis
140	1	2002-02-28	9.00	13.00	t	24000632544551	2	Marie
94	1	2002-02-26	9.00	13.00	f	\N	1	\N
135	1	2002-02-26	9.00	13.00	f	\N	1	\N
136	1	2002-02-26	9.00	13.00	f	\N	1	\N
136	1	2002-03-04	9.00	13.00	t	3550370327	2	Karin W
141	1	2002-02-28	13.00	17.00	t	3590520827	2	malin
82	1	2002-02-26	9.00	13.00	t	3170910927	4	Ellen Hansson
82	1	2002-02-27	13.00	17.00	t	3000960527	2	ida
83	1	2002-02-26	9.00	13.00	t	24000151218542	4	Eva
82	1	2002-02-28	9.00	13.00	t	3000960527	2	ida
82	1	2002-02-28	13.00	17.00	t	3300090127	2	lena
90	1	2002-02-26	9.00	13.00	t	3290580627	4	sara, helene
86	1	2002-02-26	13.00	17.00	f	\N	1	\N
80	1	2002-02-26	9.00	13.00	t	3560500327	4	Charlotte
89	1	2002-03-04	9.00	13.00	t	3240260127	2	Hanna.B
97	1	2002-03-04	9.00	13.00	t	3180240627	2	Lena & Stina
93	1	2002-02-26	9.00	13.00	t	3290820927	4	P, Dz, M, L
139	1	2002-02-28	9.00	13.00	t	3160120827	2	SF
95	1	2002-03-04	9.00	13.00	t	3070850127	2	Marianne mfl
135	1	2002-02-28	9.00	13.00	t	3280830027	2	Ros-marie/ grupparbete
90	1	2002-03-04	13.00	17.00	t	3050750127	2	ewa o thunde
89	1	2002-02-26	13.00	17.00	t	3170160027	3	Lars Claesson
139	1	2002-02-26	13.00	17.00	t	3180230127	3	Christian
135	1	2002-02-26	13.00	17.00	t	3180340427	3	Øiseth
94	1	2002-02-26	13.00	17.00	t	3160290927	3	Fredrik mfl
90	1	2002-02-26	13.00	17.00	t	3210570327	3	Pelle
138	1	2002-02-26	13.00	17.00	t	3060250127	3	mia lundgren
141	1	2002-02-26	13.00	17.00	t	3580370027	3	Maria Qvinth
80	1	2002-02-26	13.00	17.00	t	3340400327	3	Sofia
88	1	2002-02-26	13.00	17.00	t	3320250527	3	ghada
91	1	2002-02-26	13.00	17.00	t	3210950827	4	Ewa Elin o Tunde
82	1	2002-02-26	13.00	17.00	t	3300090127	4	lena
96	1	2002-02-26	13.00	17.00	t	3080550627	4	Heidi
95	1	2002-02-26	13.00	17.00	t	3180190027	4	Elisabeth
81	1	2002-02-26	13.00	17.00	t	3170920227	4	Inger
81	1	2002-02-28	13.00	17.00	t	3170920227	2	inger
81	1	2002-02-28	9.00	13.00	t	3160590227	2	malin
83	1	2002-02-26	13.00	17.00	t	3170520227	4	Maria Hilding
87	1	2002-02-27	9.00	13.00	t	3170520227	2	Maria
159	3	2002-02-27	11.00	12.00	t	1234567890	2	sfdsf
159	3	2002-02-27	7.00	8.00	t	1234567890	2	ffsf 
159	3	2002-02-27	8.00	9.00	t	1234567890	2	ffsf 
159	3	2002-02-27	9.00	10.00	t	1234567890	2	ffsf 
159	3	2002-02-27	10.00	11.00	t	1234567890	2	ffsf 
159	3	2002-02-27	13.00	14.00	t	1234567890	2	adasda
159	3	2002-02-27	14.00	15.00	t	1234567890	2	adasda
159	3	2002-02-27	15.00	16.00	t	1234567890	2	adasda
159	3	2002-02-27	16.00	17.00	t	1234567890	2	adasda
159	3	2002-02-27	17.00	18.00	t	1234567890	2	adasda
159	3	2002-02-27	18.00	19.00	t	1234567890	2	adasda
159	3	2002-02-27	19.00	20.00	t	1234567890	2	adasda
159	3	2002-02-27	20.00	21.00	t	1234567890	2	adasda
159	3	2002-02-27	12.00	13.00	t	1234567890	2	jljkl jkl jkl jkljkl jklluioluljkluiolukljoi
91	1	2002-03-04	13.00	17.00	t	3200410127	2	Sabina o Marie
137	1	2002-02-26	13.00	17.00	t	3180230527	4	Kattis
135	1	2002-03-01	9.00	13.00	t	3200410127	2	Marie och Sabina
93	1	2002-02-26	13.00	17.00	t	3280770727	4	Ana+Emma
140	1	2002-02-26	13.00	17.00	t	3160240227	4	susanne
136	1	2002-02-26	13.00	17.00	t	3250040427	4	Jessica G
141	1	2002-02-28	9.00	13.00	t	3170040827	2	Johan Setteryd
97	1	2002-02-26	13.00	17.00	t	3180430927	4	David
92	1	2002-02-26	13.00	17.00	t	3310560327	4	Micke
\.


--
-- Data for Name: boknings_objekt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY boknings_objekt (obj_id, typ, lokal_id, namn, plats, ska_kvitteras, kommentar, aktiv, intern_bruk) FROM stdin;
188	2	48	Dator PC11A5 (HGUS-konto) Balkong 3	Balkong 3	t	HGUS-konto krävs. TRUST. I första hand avsedd för sökning i TRUST	f	f
208	2	47	PO032	Entreplan	t		f	f
89	1	42	Inget	Inget	f	- - -	f	t
189	1	44	Testgrupprum	Fantasivärlden	t	Finns inte på riktigt...	f	f
296	1	66	Grupprum 2	Bottenvåningen 	t		t	f
297	2	40	Mikrofilmsläsare	Plan 4	t		f	f
160	1	43	Grupprum 2	En trappa upp från entrén	t	<b>OBS! Passerkort krävs. Har du ej passerkort till IVM el. Inst. marin ekol. kan du låna ett  kort samma dag på bibl. (8.30-16.00). Rummet har ej tillgång till skrivare.</b>	f	f
215	1	60	Test	Test	t	Test	f	f
268	2	60	LO002	Datasal, 1 trappa ner	t		f	f
231	1	60	Testrum	Testplats	t	Lite info	f	f
244	2	47	Testdator	Platsbeskrivning	t	Lite info om datorn	f	f
122	2	44	Rad 5, <br>dator GO089	Nedre läsesal	t	Ara,Bul,Eng,Gre,Jap,Kir,Kro,Mac,Pol,Rys,Ser,Slova,Slove,Sve,Tje,Ukr. Saknar SPSS, Supernova och WordFinder	f	f
176	2	42	Dator 3  KO032  BORTTAGET	Entréplan	t	Office-paket, mail 	f	f
105	2	44	Dator GO074 <br> Plan 6B	Plan 6B	t		f	f
112	2	44	Dator GO075 <br> Plan 6B	Plan 6B	t		f	f
111	2	44	Dator GO076 <br> Plan 6B	Plan 6B	t		f	f
196	1	48	Gruppstudieplats 11, (Plan 1)	Plan 1	t		f	f
204	1	47	Rum 2	Entréplan	t		f	f
166	1	40	Grupprum 2	Plan 4	t	extern bildskärm/external monitor	f	f
209	2	47	Datorplats 7 Valvet höger	Entréplan, PO032 	t		f	f
97	1	48	Lässtudio	Balkong 1	t	Lässtudio. Kan endast bokas med särskild behörighet	f	f
106	2	44	Dator GO073 <br> Plan 6B	Plan 6B	t		f	f
203	1	47	Rum 3	Entréplan	t		f	f
175	2	42	Dator 2  KO031  BORTTAGET  	Entréplan	t	Office-paket, mail	f	f
286	3	44	Lässtudio	Plan 6	t		t	f
256	1	44	Grupprum 01	Plan 6B	t		t	f
245	2	47	Datorplats 4 Valvet vänster	Entréplan, PO030	t		f	f
279	2	50	Dator LO013	Datasal, 1 trappa ner	t		f	f
248	2	48	Dator EO012 Plan 1	Plan 1	t	Internet, E-post, Office	f	f
247	2	47	Datorplats 5 Valvet vänster	Entréplan, PO033 	t		f	f
207	2	47	Datorplats 2 Valvet vänster	Entréplan, PO035 	t		f	f
280	2	50	Dator LO014	Datasal, 1 trappa ner	t		f	f
174	2	42	Dator 1  KO028  BORTTAGET	Entréplan	t	Office-paket, mail, 	f	f
98	1	44	Grupprum 03	Plan 6A	t		f	f
101	1	44	Grupprum 06	Plan 6A	t		t	f
212	2	47	Datorplats 9 Valvet höger	Entréplan, PO044	t		f	f
217	2	47	Datorplats 3 Valvet vänster	Entréplan, dator PO028	t		f	f
88	1	60	Grupprum 09	Plan 1	t		f	f
285	3	40	Lässtudio	Plan 4	t		t	f
246	2	47	Datorplats 6 Valvet vänster	Entréplan, PO031	t		f	f
205	1	47	INAKTIVT Grupprum 4	Entréplan	f		f	f
182	2	48	Dator EO062 Plan 1	Plan 1	t	Internet, E-post, Office	f	f
168	1	40	Grupprum 3	Plan 4	t		f	f
261	1	50	Grupprum 1	Entréplan	t		f	f
202	1	47	Rum 1	Entréplan	t	extern bildskärm/external monitor	f	f
210	2	47	Datorplats 8 Valvet höger	Entréplan, PO029	t		f	f
183	2	48	Dator EO063 Plan 1	Plan 1	t	Internet, E-post, Office	f	f
181	2	48	Dator EO064 Plan 1	Plan 1	t	Internet, E-post, Office	f	f
265	2	50	Dator LO000	Datasal, 1 trappa ner	t		f	f
266	2	50	Dator LO001	Datasal, 1 trappa ner	t		f	f
267	2	50	Dator LO002	Datasal, 1 trappa ner	t		f	f
269	2	50	Dator LO003	Datasal, 1 trappa ner	t		f	f
270	2	50	Dator LO004	Datasal, 1 trappa ner	t		f	f
271	2	50	Dator LO005	Datasal, 1 trappa ner	t		f	f
272	2	50	Dator LO006	Datasal, 1 trappa ner	t		f	f
274	2	50	Dator LO008	Datasal, 1 trappa ner	t		f	f
273	2	50	Dator LO007	Datasal, 1 trappa ner	t		f	f
275	2	50	Dator LO009	Datasal, 1 trappa ner	t		f	f
276	2	50	Dator LO010	Datasal, 1 trappa ner	t		f	f
277	2	50	Dator LO011	Datasal, 1 trappa ner	t		f	f
278	2	50	Dator LO012	Datasal, 1 trappa ner	t		f	f
281	2	50	Dator LO015	Datasal, 1 trappa ner	t		f	f
282	2	50	Dator LO016	Datasal, 1 trappa ner	t		f	f
107	2	44	Dator GO072 <br> Offentligt tryck Plan 6	Offentligt tryck Plan 6	t		f	f
109	2	44	Dator GO078 <br> Studierum Plan 6	Studierum Plan 6	t		f	f
214	1	47	Rum 4	Entréplan	t		f	f
80	1	60	Grupprum 01	Plan 1	t		f	f
216	1	60	Test1	Test1	t	Test1	f	f
165	1	40	Grupprum 1	Plan 4	t	extern bildskärm/external monitor	f	f
197	1	48	Gruppstudieplats 12, (Plan 1)	Plan 1	t		f	f
262	1	50	Grupprum 2	Entréplan	t		f	f
263	1	50	Grupprum 3	Entréplan	t		f	f
264	1	50	Grupprum 4	Entréplan	t		f	f
288	3	47	PC	Dörrplats	t		t	f
191	1	60	Grupprum 02	Plan 1	t		f	f
81	1	60	Grupprum 04	plan 1	t		f	f
82	1	60	Grupprum 03	Plan 1	t		f	f
87	1	60	Grupprum 08	Plan 1	t		f	f
86	1	60	Grupprum 10	Plan 1	t		f	f
201	1	60	Grupprum 11	Plan 1	t	extern bildskärm/external monitor	f	f
83	1	60	Grupprum 06 - gammal - återaktivera inte	Plan 1	t		f	f
167	1	40	Grupprum 4	Plan 3	t		f	f
84	1	60	Grupprum 05	Plan 1	t		f	f
287	3	47	Mac	Fönsterplats	t		t	f
194	1	60	Grupprum 06	Plan 1	t		f	f
85	1	60	Grupprum 07	Plan 1	t		f	f
187	2	48	Dator PC08A5 (HGUS-konto) Balkong 3	Balkong 3	t	HGUS-konto krävs. TRUST. I första hand avsedd för sökning i TRUST	f	f
295	1	66	Grupprum 1	Bottenvåningen	t		t	f
133	2	44	Rad 8, <br>dator GO100	Nedre läsesal	t		f	f
134	2	44	Rad 8, <br>dator GO099	Nedre läsesal	t		f	f
128	2	44	Rad 6, <br>dator GO091	Nedre läsesal	t		f	f
127	2	44	Rad 6, <br>dator GO092	Nedre läsesal	t		f	f
126	2	44	Rad 6, <br>dator GO093	Nedre läsesal	t		f	f
125	2	44	Rad 6, <br>dator GO094	Nedre läsesal	t		f	f
132	2	44	Rad 7, <br>dator GO095	Nedre läsesal	t		f	f
131	2	44	Rad 7, <br>dator GO096	Nedre läsesal	t		f	f
130	2	44	Rad 7, <br>dator GO097	Nedre läsesal	t		f	f
129	2	44	Rad 7, <br>dator GO098	Nedre läsesal	t		f	f
124	2	44	Rad 5, <br>dator GO087	Nedre läsesal	t	Ryska, polska, tjeckiska, arabiska och japanska.	f	f
117	2	44	Rad 4, <br>dator GO086	Nedre läsesal	t		f	f
123	2	44	Rad 5, <br>dator GO088	Nedre läsesal	t	Ara,Bul,Eng,Gre,Jap,Kir,Kro,Mac,Pol,Rys,Ser,Slova,Slove,Sve,Tje,Ukr. Saknar SPSS, Supernova och WordFinder	f	f
121	2	44	Rad 5, <br>dator GO090	Nedre läsesal	t	Ara,Bul,Eng,Gre,Jap,Kir,Kro,Mac,Pol,Rys,Ser,Slova,Slove,Sve,Tje,Ukr. Saknar SPSS, Supernova och WordFinder	f	f
119	2	44	Rad 3, <br>dator GO084	Nedre läsesal	t		f	f
118	2	44	Rad 3, <br>dator GO085	Nedre läsesal	t		f	f
110	2	44	Dator GO077 <br> Offentligt tryck Plan 6	Offentligt tryck Plan 6	t		f	f
206	2	47	Datorplats 1 Valvet vänster	Entréplan, PO036 	t		f	f
300	1	42	Plan 5 - Oceanien	Plan 5	t	extern bildskärm/external monitor	f	f
309	1	44	Grupprum 12	Plan 6B	t	extern bildskärm/external monitor	t	f
179	2	42	Dator 6  KO003 Källarplan 	Datasal, källarplan	t	Office-paket. mail	f	f
311	1	44	Grupprum 14	Plan 6B	t		f	f
190	1	44	Grupprum 02	Plan 6B	t		t	f
184	2	48	Dator EO068  Plan 1	Plan 1	t	Internet, E-post, Office	f	f
99	1	44	Grupprum 04	Plan 6A	t		t	f
100	1	44	Grupprum 05	Plan 6A	t		t	f
298	1	42	Plan 5 - Sydamerika	Plan 5	t		f	f
135	1	48	Grupprum 1, (Balkong 1)	Balkong 1	t		f	f
302	3	42	Lässtudio används ej	Plan 4	t		f	f
310	1	44	Grupprum 13	Plan 6B	t		t	f
249	2	48	Dator EO071 Plan 1	Plan 1	t	Internet, E-post, Office	f	f
283	3	48	Fönsterplats	Balkong 1	t	Claro read-programmet finns	t	f
136	1	48	Grupprum 3, (Balkong 1)	Balkong 1	t	extern bildskärm/external monitor	f	f
102	1	44	Grupprum 07	Plan 6A , tidskriftsmagasin	t		t	f
137	1	48	Grupprum 4, (Balkong 1)	Balkong 1	t		f	f
195	1	48	Gruppstudieplats 10, (Plan 1)	Plan 1	t		f	f
103	1	44	Grupprum 08	Plan 6A , tidskriftsmagasin	t		t	f
303	1	60	Grupprum 12	Balkong	t	extern bildskärm/external monitor	f	f
186	2	48	Dator EO065 Plan 1	Plan 1	t	Internet, E-post, Office	f	f
289	1	40	Grupprum 5	Plan 3	t		f	f
178	2	42	Dator 5  KO000  Källarplan	Datasal, källarplan	t	Office-paket, mail	f	f
108	2	44	Dator GO071 <br> Plan 6B	Plan 6B	t		f	f
180	2	48	Dator EO066 Plan 1	Plan 1	t	Internet, E-post, Office	f	f
304	1	60	Grupprum 13	Balkong	t		f	f
284	3	48	Dörrplats	Balkong 1	t		f	f
177	2	42	Dator 4  KO027  BORTTAGET 	Entréplan	t	Office-paket, mail	f	f
95	1	42	Plan 1 - Beatrice	Källarplan	t		f	f
90	1	42	Plan 1 - Elfrida	Källarplan	t		f	f
104	1	44	Grupprum 09	Plan 6A , tidskriftsmagasin	t		t	f
94	1	42	Plan 1 - Erik	Källarplan	t		f	f
92	1	42	Plan 1 - Hans	Källarplan	t		f	f
93	1	42	Plan 1 - Karin	Källarplan	t		f	f
305	3	42	Lässtudio används ej	Plan 5	t		f	f
185	2	48	Dator EO067  Plan 1	Plan 1	t	Internet, E-post, Office	f	f
307	1	44	Grupprum 10	Plan 6B	t	extern bildskärm/external monitor	t	f
116	2	44	Dator GO079 <br> Studierum Plan 6	Studierum Plan 6	t		f	f
115	2	44	Dator GO080 <br> Studierum Plan 6	Studierum Plan 6	t		f	f
114	2	44	Dator GO081 <br> Studierum Plan 6	Studierum Plan 6	t		f	f
113	2	44	Dator GO082 <br> Plan 6B	Plan 6B	t	Utökad teckenuppsättning	f	f
120	2	44	Dator GO083 <br> Plan 6B	Plan 6B	t	Utökad teckenuppsättning	f	f
96	1	42	Plan 1 - Kålle & Ada	Källarplan	t		f	f
312	1	44	Grupprum 15	Plan 6B	t		f	f
91	1	42	Plan 1 - Pontus	Källarplan	t		f	f
301	1	42	Plan 5 - Afrika	Plan 5	t		f	f
299	1	42	Plan 5 - Europa	Plan 5	t	extern bildskärm/external monitor	f	f
308	1	44	Grupprum 11	Plan 6B	t		t	f
192	2	42	Dator 7 KO002 Källarplan	Datasal, källarplan	t	Office-paket, mail	f	f
193	2	42	Dator 8 KO001 Källarplan	Datasal, Källarplan	t	Office-paket, mail	f	f
138	1	48	Grupprum 5, (Balkong 3)	Balkong 3	t		f	f
139	1	48	Grupprum 6, (Balkong 3)	Balkong 3	f	extern bildskärm/external monitor	f	f
140	1	48	Grupprum 7, (Balkong 3)	Balkong 3	t	extern bildskärm/external monitor	f	f
141	1	48	Grupprum 8, (Balkong 3)	Balkong 3	t		f	f
313	3	60	Lässtudio	Entréplan	t		t	f
314	3	42	Plan 1	Plan 1	t		t	f
306	3	42	Plan 5	Plan 5	t		t	f
213	1	47	INAKTIVT Rum 4, Glenn (delat rum)	Entréplan	t	Rummet kan bokas av två grupper. Ni kan därför få dela rum med annan grupp. 	f	f
\.


--
-- Data for Name: dag_ordning; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dag_ordning (day, ordning, dag) FROM stdin;
Monday    	1	M&aring;ndag        
Tuesday   	2	Tisdag              
Wednesday 	3	Onsdag              
Thursday  	4	Torsdag             
Friday    	5	Fredag              
Saturday  	6	L&ouml;rdag         
Sunday    	7	S&ouml;ndag         
Sunday    	0	S&ouml;ndag         
\.


--
-- Data for Name: dagar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dagar (dag, ordning) FROM stdin;
Monday	1
Tuesday	2
Wednesday	3
Thursday	4
Friday	5
Saturday	6
Sunday	7
\.


--
-- Data for Name: gamla_bokningar; Type: TABLE DATA; Schema: public; Owner: postgres
--


--
-- Data for Name: gamla_openhours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY gamla_openhours (lokal_id, day, open, close, prioritet, from_dag, nummer) FROM stdin;
40	2002-12-25	12.00	12.00	1	\N	\N
42	2002-12-25	12.00	12.00	1	\N	\N
43	2002-12-25	12.00	12.00	1	\N	\N
44	2002-12-25	12.00	12.00	1	\N	\N
47	2002-12-25	12.00	12.00	1	\N	\N
48	2002-12-25	12.00	12.00	1	\N	\N
49	2002-12-25	12.00	12.00	1	\N	\N
60	2002-12-25	9.00	9.00	1	\N	\N
40	Monday    	9.00	21.00	2	2002-01-10	1
44	Monday    	9.00	21.00	2	2002-01-10	1
48	Monday    	9.00	21.00	2	2002-01-10	1
43	Monday    	9.00	16.30	2	2002-01-10	1
49	Monday    	8.00	16.30	2	2002-01-10	1
42	Monday    	9.00	22.00	2	2002-01-10	1
47	Monday    	9.00	17.00	2	2002-01-10	1
60	Monday    	9.00	18.00	2	2002-01-01	1
40	Tuesday   	9.00	21.00	2	2002-01-10	2
44	Tuesday   	9.00	21.00	2	2002-01-10	2
48	Tuesday   	9.00	21.00	2	2002-01-10	2
43	Tuesday   	9.00	16.30	2	2002-01-10	2
49	Tuesday   	8.00	16.30	2	2002-01-10	2
42	Tuesday   	9.00	22.00	2	2002-01-10	2
47	Tuesday   	9.00	17.00	2	2002-01-10	2
60	Tuesday   	9.00	18.00	2	2002-01-01	2
40	Wednesday 	9.00	21.00	2	2002-01-10	3
44	Wednesday 	9.00	21.00	2	2002-01-10	3
48	Wednesday 	9.00	21.00	2	2002-01-10	3
43	Wednesday 	9.00	18.00	2	2002-01-10	3
49	Wednesday 	8.00	16.30	2	2002-01-10	3
42	Wednesday 	9.00	22.00	2	2002-01-10	3
47	Wednesday 	9.00	17.00	2	2002-01-10	3
60	Wednesday 	9.00	18.00	2	2002-01-01	3
40	Thursday  	9.00	21.00	2	2002-01-10	4
44	Thursday  	9.00	21.00	2	2002-01-10	4
48	Thursday  	9.00	21.00	2	2002-01-10	4
43	Thursday  	9.00	16.30	2	2002-01-10	4
49	Thursday  	8.00	16.30	2	2002-01-10	4
42	Thursday  	9.00	22.00	2	2002-01-10	4
47	Thursday  	9.00	17.00	2	2002-01-10	4
60	Thursday  	9.00	18.00	2	2002-01-01	4
43	Friday    	9.00	16.30	2	2002-01-10	5
40	Friday    	9.00	19.00	2	2002-01-10	5
44	Friday    	9.00	19.00	2	2002-01-10	5
48	Friday    	9.00	19.00	2	2002-01-10	5
49	Friday    	8.00	16.30	2	2002-01-10	5
42	Friday    	9.00	20.00	2	2002-01-10	5
47	Friday    	9.00	16.00	2	2002-01-10	5
60	Friday    	9.00	17.00	2	2002-01-01	5
40	Saturday  	10.00	16.00	2	2002-01-10	6
48	Saturday  	10.00	16.00	2	2002-01-10	6
44	Saturday  	9.00	17.00	2	2002-01-10	6
42	Saturday  	10.00	18.00	2	2002-01-10	6
43	Saturday  	9.00	9.00	2	2002-01-10	6
47	Saturday  	9.00	9.00	2	2002-01-10	6
49	Saturday  	9.00	9.00	2	2002-01-10	6
60	Saturday  	9.00	9.00	2	2002-01-01	6
40	Sunday    	9.00	9.00	2	2002-01-10	7
43	Sunday    	9.00	9.00	2	2002-01-10	7
44	Sunday    	9.00	9.00	2	2002-01-10	7
47	Sunday    	9.00	9.00	2	2002-01-10	7
48	Sunday    	9.00	9.00	2	2002-01-10	7
49	Sunday    	9.00	9.00	2	2002-01-10	7
42	Sunday    	10.00	18.00	2	2002-01-10	7
60	Sunday    	9.00	9.00	2	2002-01-01	7
\.


--
-- Data for Name: lokal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lokal (id, namn, name) FROM stdin;
40	Biomedicinska biblioteket	Biomedical Library
43	Botanik och milj&ouml;biblioteket	Botanical and Environmental Library
47	Pedagogiska biblioteket	Education Library
48	Ekonomiska biblioteket	Economics Library
49	Geovetenskapliga biblioteket	Earth Sciences Library
61	Konstbiblioteket	Art Library
66	Studietorget Campus Haga	Learning Centre Campus Haga
50	Studietorget Campus Linn&eacute;	Learning Centre Campus Linn&eacute;
62	Biblioteket f&ouml;r musik och dramatik	Music and Drama Library
44	Humanistiska biblioteket	Humanities Library
42	Samh&auml;llsvetenskapliga biblioteket	Social Sciences Library
90	KvinnSam	KvinnSam
60	H&auml;lsovetarbackens bibliotek	H&auml;lsovetarbacken Library
\.


--
-- Data for Name: lokal_sort; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lokal_sort (id, sort_order) FROM stdin;
40	0
42	0
44	0
47	0
48	0
61	0
62	0
60	1
66	\N
43	\N
49	\N
90	0
50	\N
\.


--
-- Data for Name: openhours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY openhours (lokal_id, day, open, close, prioritet, from_dag) FROM stdin;
43	Monday    	8.00	21.00	2	2007-08-20
43	Tuesday   	8.00	21.00	2	2007-08-20
43	Wednesday 	8.00	21.00	2	2007-08-20
43	Thursday  	8.00	21.00	2	2007-08-20
43	Friday    	8.00	21.00	2	2007-08-20
42	Monday    	9.00	18.00	2	2020-08-31
42	Tuesday   	9.00	18.00	2	2020-08-31
42	Wednesday 	9.00	18.00	2	2020-08-31
42	Thursday  	9.00	18.00	2	2020-08-31
42	Friday    	9.00	18.00	2	2020-08-31
44	2020-12-26	8.00	8.00	1	\N
90	2020-12-26	8.00	8.00	1	\N
49	Wednesday 	8.00	17.00	2	2016-02-01
43	Saturday  	0.00	0.00	2	2007-06-25
43	Monday    	8.30	16.00	2	2006-05-01
43	Tuesday   	8.30	16.00	2	2006-05-01
43	Thursday  	8.30	16.00	2	2006-05-01
43	Friday    	8.30	16.00	2	2006-05-01
43	Wednesday 	8.30	18.00	2	2006-05-01
40	2020-12-31	8.00	8.00	1	\N
42	2020-12-31	8.00	8.00	1	\N
44	2020-12-31	8.00	8.00	1	\N
47	2020-12-31	8.00	8.00	1	\N
66	Friday    	12.00	16.00	2	2011-01-14
48	2020-12-31	8.00	8.00	1	\N
90	2020-12-31	8.00	8.00	1	\N
61	Saturday  	8.00	8.00	2	2021-01-07
61	Sunday    	8.00	8.00	2	2021-01-07
62	Saturday  	8.00	8.00	2	2021-01-07
62	Sunday    	8.00	8.00	2	2021-01-07
49	Monday    	8.00	17.00	2	2016-08-22
49	Tuesday   	8.00	17.00	2	2016-08-22
49	Wednesday 	8.00	17.00	2	2016-08-22
49	Thursday  	8.00	17.00	2	2016-08-22
49	Friday    	8.00	17.00	2	2016-08-22
43	Saturday  	0.00	0.00	2	2006-05-01
43	Sunday    	0.00	0.00	2	2006-05-01
43	Monday    	9.00	16.00	2	2006-05-29
43	Tuesday   	9.00	16.00	2	2006-05-29
43	Wednesday 	9.00	16.00	2	2006-05-29
43	Thursday  	9.00	16.00	2	2006-05-29
43	Friday    	9.00	16.00	2	2006-05-29
43	Sunday    	0.00	0.00	2	2007-06-25
43	Saturday  	0.00	0.00	2	2007-08-20
43	Sunday    	0.00	0.00	2	2007-08-20
49	Monday    	9.00	9.00	2	2016-10-17
49	Tuesday   	9.00	9.00	2	2016-10-17
49	Wednesday 	9.00	9.00	2	2016-10-17
49	Thursday  	9.00	9.00	2	2016-10-17
49	Friday    	9.00	9.00	2	2016-10-17
49	Saturday  	9.00	9.00	2	2016-10-17
43	Monday    	8.30	16.30	2	2006-09-01
43	Tuesday   	8.30	16.30	2	2006-09-01
43	Wednesday 	8.30	18.00	2	2006-09-01
43	Thursday  	8.30	16.30	2	2006-09-01
43	Friday    	8.30	16.30	2	2006-09-01
43	Saturday  	0.00	0.00	2	2006-09-01
43	Sunday    	0.00	0.00	2	2006-09-01
43	Monday    	8.00	21.00	2	2006-11-05
43	Tuesday   	8.00	21.00	2	2006-11-05
43	Wednesday 	8.00	21.00	2	2006-11-05
43	Thursday  	8.00	21.00	2	2006-11-05
43	Friday    	8.00	21.00	2	2006-11-05
49	Sunday    	9.00	9.00	2	2016-10-17
42	Saturday  	10.00	16.00	2	2020-08-31
43	Monday    	8.00	21.00	2	2007-06-01
43	Tuesday   	8.00	21.00	2	2007-06-01
43	Monday    	0.00	0.00	2	2007-06-25
43	Tuesday   	0.00	0.00	2	2007-06-25
43	Wednesday 	0.00	0.00	2	2007-06-25
49	Thursday  	8.00	17.00	2	2016-02-01
40	2021-01-01	8.00	8.00	1	\N
42	2021-01-01	8.00	8.00	1	\N
44	2021-01-01	8.00	8.00	1	\N
47	2021-01-01	8.00	8.00	1	\N
48	2021-01-01	8.00	8.00	1	\N
90	2021-01-01	8.00	8.00	1	\N
40	2020-12-23	10.00	17.00	1	\N
49	Saturday  	8.00	8.00	2	2016-08-22
49	Sunday    	8.00	8.00	2	2016-08-22
66	Friday    	9.00	15.00	2	2009-04-06
66	Monday    	9.00	16.00	2	2009-04-06
43	Wednesday 	8.00	21.00	2	2007-06-01
43	Thursday  	8.00	21.00	2	2007-06-01
43	Friday    	8.00	21.00	2	2007-06-01
47	Saturday  	8.00	8.00	2	2020-08-31
44	Monday    	10.00	16.00	2	2020-08-17
44	Tuesday   	10.00	16.00	2	2020-08-17
44	Wednesday 	10.00	16.00	2	2020-08-17
44	Thursday  	10.00	16.00	2	2020-08-17
44	Friday    	10.00	16.00	2	2020-08-17
43	Thursday  	0.00	0.00	2	2007-06-25
43	Friday    	0.00	0.00	2	2007-06-25
44	Saturday  	10.00	16.00	2	2020-08-17
66	Tuesday   	9.00	16.00	2	2009-04-06
66	Wednesday 	9.00	16.00	2	2009-04-06
66	Thursday  	9.00	16.00	2	2009-04-06
42	Sunday    	8.00	8.00	2	2020-08-31
49	Friday    	8.00	17.00	2	2016-02-01
40	2020-12-25	8.00	8.00	1	\N
42	2020-12-25	8.00	8.00	1	\N
44	2020-12-25	8.00	8.00	1	\N
47	2020-12-25	8.00	8.00	1	\N
48	2020-12-25	8.00	8.00	1	\N
66	Monday    	9.00	9.00	2	2012-03-01
66	Tuesday   	9.00	9.00	2	2012-03-01
44	Sunday    	8.00	8.00	2	2020-08-17
90	2020-12-25	8.00	8.00	1	\N
42	2021-01-04	9.00	16.00	1	\N
47	2021-01-04	9.00	16.00	1	\N
48	2021-01-04	9.00	16.00	1	\N
40	2021-01-07	10.00	17.00	1	\N
66	Wednesday 	9.00	9.00	2	2012-03-01
66	Thursday  	9.00	9.00	2	2012-03-01
66	Saturday  	9.00	9.00	2	2009-04-06
66	Sunday    	9.00	9.00	2	2009-04-06
43	Monday    	8.30	16.30	2	2011-01-01
48	Monday    	9.00	18.00	2	2020-08-31
48	Tuesday   	9.00	18.00	2	2020-08-31
48	Wednesday 	9.00	18.00	2	2020-08-31
48	Thursday  	9.00	18.00	2	2020-08-31
48	Friday    	9.00	18.00	2	2020-08-31
42	2020-12-28	9.00	16.00	1	\N
47	2020-12-28	9.00	16.00	1	\N
48	2020-12-28	9.00	16.00	1	\N
40	2021-01-04	10.00	17.00	1	\N
40	2021-01-08	10.00	17.00	1	\N
43	Tuesday   	8.30	16.30	2	2011-01-01
66	Monday    	9.00	9.00	2	2009-06-22
66	Tuesday   	9.00	9.00	2	2009-06-22
66	Wednesday 	9.00	9.00	2	2009-06-22
66	Thursday  	9.00	9.00	2	2009-06-22
66	Friday    	9.00	9.00	2	2009-06-22
66	Monday    	9.00	16.00	2	2009-08-24
66	Tuesday   	9.00	16.00	2	2009-08-24
66	Wednesday 	9.00	16.00	2	2009-08-24
66	Thursday  	9.00	16.00	2	2009-08-24
66	Friday    	9.00	15.00	2	2009-08-28
66	Monday    	9.00	9.00	2	2011-12-19
66	Tuesday   	9.00	9.00	2	2011-12-19
66	Wednesday 	9.00	9.00	2	2011-12-19
66	Thursday  	9.00	9.00	2	2011-12-19
66	Friday    	9.00	9.00	2	2011-12-19
61	Monday    	10.00	14.00	2	2020-08-17
43	Wednesday 	8.30	16.30	2	2011-01-01
61	Tuesday   	10.00	14.00	2	2020-08-17
61	Wednesday 	10.00	14.00	2	2020-08-17
61	Thursday  	10.00	14.00	2	2020-08-17
61	Friday    	10.00	14.00	2	2020-08-17
66	Monday    	12.00	18.00	2	2012-01-09
66	Tuesday   	12.00	18.00	2	2012-01-09
66	Wednesday 	12.00	18.00	2	2012-01-09
66	Thursday  	12.00	18.00	2	2012-01-09
43	Thursday  	8.30	16.30	2	2011-01-01
48	Saturday  	10.00	16.00	2	2020-08-31
43	Monday    	8.30	16.00	2	2011-05-05
43	Tuesday   	8.30	16.00	2	2011-05-05
43	Wednesday 	8.30	16.00	2	2011-05-05
43	Thursday  	8.30	16.00	2	2011-05-05
43	Friday    	8.30	16.00	2	2011-05-05
90	Monday    	10.00	16.00	2	2020-08-17
90	Tuesday   	10.00	16.00	2	2020-08-17
90	Wednesday 	10.00	16.00	2	2020-08-17
90	Thursday  	10.00	16.00	2	2020-08-17
90	Friday    	10.00	16.00	2	2020-08-17
49	Tuesday   	9.00	16.00	2	2016-06-07
49	Thursday  	9.00	16.00	2	2016-06-07
90	Saturday  	10.00	16.00	2	2020-08-17
40	2020-12-28	10.00	17.00	1	\N
42	2021-01-05	9.00	16.00	1	\N
47	2021-01-05	9.00	16.00	1	\N
48	2021-01-05	9.00	16.00	1	\N
42	2020-12-26	8.00	8.00	1	\N
48	2020-12-26	8.00	8.00	1	\N
66	Monday    	9.00	9.00	2	2010-06-14
66	Tuesday   	9.00	9.00	2	2010-06-14
66	Wednesday 	9.00	9.00	2	2010-06-14
66	Thursday  	9.00	9.00	2	2010-06-14
66	Friday    	9.00	9.00	2	2010-06-14
66	Monday    	9.00	18.00	2	2010-08-16
66	Tuesday   	9.00	18.00	2	2010-08-16
66	Wednesday 	9.00	18.00	2	2010-08-16
66	Thursday  	9.00	18.00	2	2010-08-16
66	Friday    	9.00	16.00	2	2010-08-20
61	Saturday  	8.00	8.00	2	2020-08-17
61	Sunday    	8.00	8.00	2	2020-08-17
66	Monday    	9.00	9.00	2	2010-12-20
66	Tuesday   	9.00	9.00	2	2010-12-20
66	Wednesday 	9.00	9.00	2	2010-12-20
66	Thursday  	9.00	9.00	2	2010-12-20
66	Friday    	9.00	9.00	2	2010-12-20
49	Saturday  	8.00	8.00	2	2016-02-01
48	Sunday    	8.00	8.00	2	2020-08-31
62	Monday    	10.00	14.00	2	2020-08-17
49	Wednesday 	8.00	8.00	2	2016-06-07
49	Friday    	8.00	8.00	2	2016-06-07
62	Tuesday   	10.00	14.00	2	2020-08-17
90	Sunday    	8.00	8.00	2	2020-08-17
62	Wednesday 	10.00	14.00	2	2020-08-17
62	Thursday  	10.00	14.00	2	2020-08-17
62	Friday    	10.00	14.00	2	2020-08-17
42	2020-12-29	9.00	16.00	1	\N
47	2020-12-29	9.00	16.00	1	\N
48	2020-12-29	9.00	16.00	1	\N
40	2021-01-05	10.00	17.00	1	\N
66	Monday    	12.00	18.00	2	2011-01-10
66	Tuesday   	12.00	18.00	2	2011-01-10
66	Wednesday 	12.00	18.00	2	2011-01-10
66	Thursday  	12.00	18.00	2	2011-01-10
43	Friday    	8.30	16.30	2	2011-01-01
66	Monday    	12.00	18.00	2	2010-10-25
66	Tuesday   	12.00	18.00	2	2010-10-25
66	Wednesday 	12.00	18.00	2	2010-10-25
66	Thursday  	12.00	18.00	2	2010-10-25
66	Friday    	12.00	16.00	2	2010-10-25
66	Monday    	9.00	9.00	2	2011-06-06
66	Tuesday   	9.00	9.00	2	2011-06-06
66	Wednesday 	9.00	9.00	2	2011-06-06
66	Thursday  	9.00	9.00	2	2011-06-06
66	Friday    	9.00	9.00	2	2011-06-06
66	Monday    	12.00	18.00	2	2011-08-29
66	Tuesday   	12.00	18.00	2	2011-08-29
66	Wednesday 	12.00	18.00	2	2011-08-29
66	Thursday  	12.00	18.00	2	2011-08-29
66	Friday    	12.00	16.00	2	2011-08-29
47	Monday    	9.00	18.00	2	2020-08-31
47	Tuesday   	9.00	18.00	2	2020-08-31
47	Wednesday 	9.00	18.00	2	2020-08-31
47	Thursday  	9.00	18.00	2	2020-08-31
47	Friday    	9.00	18.00	2	2020-08-31
60	Monday    	6.00	23.00	2	2020-08-24
60	Tuesday   	6.00	23.00	2	2020-08-24
60	Wednesday 	6.00	23.00	2	2020-08-24
60	Thursday  	6.00	23.00	2	2020-08-24
60	Friday    	6.00	23.00	2	2020-08-24
60	Saturday  	6.00	23.00	2	2020-08-24
60	Sunday    	6.00	23.00	2	2020-08-24
49	Monday    	8.00	8.00	2	2016-06-27
49	Tuesday   	8.00	8.00	2	2016-06-27
49	Wednesday 	8.00	8.00	2	2016-06-27
49	Thursday  	8.00	8.00	2	2016-06-27
49	Friday    	8.00	8.00	2	2016-06-27
62	Saturday  	8.00	8.00	2	2020-08-17
62	Sunday    	8.00	8.00	2	2020-08-17
40	Monday    	10.00	18.00	2	2020-11-09
40	Tuesday   	10.00	18.00	2	2020-11-09
40	Wednesday 	10.00	18.00	2	2020-11-09
40	Thursday  	10.00	18.00	2	2020-11-09
40	Friday    	10.00	18.00	2	2020-11-09
40	2020-12-24	8.00	8.00	1	\N
42	2020-12-24	8.00	8.00	1	\N
44	2020-12-24	8.00	8.00	1	\N
47	2020-12-24	8.00	8.00	1	\N
48	2020-12-24	8.00	8.00	1	\N
90	2020-12-24	8.00	8.00	1	\N
40	2020-12-29	10.00	17.00	1	\N
40	2021-01-06	8.00	8.00	1	\N
42	2021-01-06	8.00	8.00	1	\N
44	2021-01-06	8.00	8.00	1	\N
47	2021-01-06	8.00	8.00	1	\N
48	2021-01-06	8.00	8.00	1	\N
90	2021-01-06	8.00	8.00	1	\N
49	Monday    	8.00	17.00	2	2016-02-01
49	Sunday    	8.00	8.00	2	2016-02-01
47	Sunday    	8.00	8.00	2	2020-08-31
40	Saturday  	10.00	10.00	2	2020-11-09
40	Sunday    	10.00	10.00	2	2020-11-09
42	2020-12-23	9.00	16.00	1	\N
47	2020-12-23	9.00	16.00	1	\N
48	2020-12-23	9.00	16.00	1	\N
42	2020-12-30	9.00	16.00	1	\N
49	Monday    	8.00	8.00	2	2016-08-08
49	Wednesday 	8.00	8.00	2	2016-08-08
43	Monday    	9.00	9.00	2	2012-06-02
43	Tuesday   	9.00	9.00	2	2012-06-02
43	Wednesday 	9.00	9.00	2	2012-06-02
43	Thursday  	9.00	9.00	2	2012-06-02
43	Friday    	9.00	9.00	2	2012-06-02
43	Saturday  	9.00	9.00	2	2012-06-02
43	Sunday    	9.00	9.00	2	2012-06-02
47	2020-12-30	9.00	16.00	1	\N
48	2020-12-30	9.00	16.00	1	\N
61	Monday    	8.00	8.00	2	2020-12-21
61	Tuesday   	8.00	8.00	2	2020-12-21
61	Wednesday 	8.00	8.00	2	2020-12-21
61	Thursday  	8.00	8.00	2	2020-12-21
61	Friday    	8.00	8.00	2	2020-12-21
61	Saturday  	8.00	8.00	2	2020-12-21
61	Sunday    	8.00	8.00	2	2020-12-21
62	Monday    	8.00	8.00	2	2020-12-21
62	Tuesday   	8.00	8.00	2	2020-12-21
62	Wednesday 	8.00	8.00	2	2020-12-21
62	Thursday  	8.00	8.00	2	2020-12-21
62	Friday    	8.00	8.00	2	2020-12-21
62	Saturday  	8.00	8.00	2	2020-12-21
62	Sunday    	8.00	8.00	2	2020-12-21
49	Tuesday   	8.00	17.00	2	2016-02-01
40	2020-12-30	10.00	17.00	1	\N
61	Monday    	10.00	14.00	2	2021-01-07
61	Tuesday   	10.00	14.00	2	2021-01-07
61	Wednesday 	10.00	14.00	2	2021-01-07
61	Thursday  	10.00	14.00	2	2021-01-07
61	Friday    	10.00	14.00	2	2021-01-07
62	Monday    	10.00	14.00	2	2021-01-07
62	Tuesday   	10.00	14.00	2	2021-01-07
62	Wednesday 	10.00	14.00	2	2021-01-07
62	Thursday  	10.00	14.00	2	2021-01-07
49	Tuesday   	9.00	16.00	2	2016-08-08
49	Thursday  	9.00	16.00	2	2016-08-08
62	Friday    	10.00	14.00	2	2021-01-07
\.


--
-- Data for Name: pga_diagrams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pga_diagrams (diagramname, diagramtables, diagramlinks) FROM stdin;
\.


--
-- Data for Name: pga_forms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pga_forms (formname, formsource) FROM stdin;
\.


--
-- Data for Name: pga_graphs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pga_graphs (graphname, graphsource, graphcode) FROM stdin;
\.


--
-- Data for Name: pga_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pga_images (imagename, imagesource) FROM stdin;
\.


--
-- Data for Name: pga_layout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pga_layout (tablename, nrcols, colnames, colwidth) FROM stdin;
public.boknings_objekt	9	obj_id typ lokal_id namn plats ska_kvitteras kommentar aktiv intern_bruk	150 150 150 150 150 150 150 150 150
public.bokning	9	obj_id typ dag start slut bokad bokad_barcode status kommentar	150 150 150 150 150 150 150 150 150
public.gamla_bokningar	9	obj_id typ dag start slut bokad bokad_barcode status kommentar	150 150 150 150 150 150 150 150 150
stat_2006	7	dag start slut status objekt bibliotek typ	150 150 150 150 150 150 150
statistik_2006	7	dag start slut status objekt bibliotek typ	150 150 150 150 150 150 150
stat2	8	dag start slut status objekt bib bibliotek typ	150 150 150 150 150 150 150 150
\.


--
-- Data for Name: pga_queries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pga_queries (queryname, querytype, querycommand, querytables, querylinks, queryresults, querycomments) FROM stdin;
\.


--
-- Data for Name: pga_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pga_reports (reportname, reportsource, reportbody, reportprocs, reportoptions) FROM stdin;
\.


--
-- Data for Name: pga_scripts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pga_scripts (scriptname, scriptsource) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY schema_migrations (version) FROM stdin;
\.


--
-- Data for Name: typ_1_grupprum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY typ_1_grupprum (obj_id, antal_platser, finns_dator, finns_tavla, kommentar) FROM stdin;
189	12	t	t	
89	0	f	f	
160	10	t	t	
295	6	t	t	
296	6	t	t	
215	1	f	f	
231	4	t	t	
88	6	t	t	
86	6	t	t	
201	6	t	t	
303	6	t	t	
97	6	t	t	
304	6	t	t	
83	4	t	t	
311	4	f	t	
261	5	t	f	
262	5	t	t	
263	5	t	t	
264	5	t	f	
256	2	t	t	
190	2	t	t	
98	2	t	t	
99	2	t	t	
100	2	t	t	
101	2	t	t	
102	2	t	t	
103	2	t	t	
104	2	t	t	
307	2	f	t	
308	2	f	t	
309	2	f	t	
310	2	f	t	
312	6	f	t	
165	8	t	t	
166	6	t	t	
168	6	t	t	
167	8	t	t	
289	8	t	t	
95	6	t	t	
216	1	f	f	
90	6	t	t	
94	6	t	t	
205	6	t	t	
92	6	t	t	
213	3	t	t	
93	6	t	t	
96	6	t	t	
91	6	t	t	
301	4	f	f	
299	6	f	f	
300	6	f	f	
298	4	f	f	
202	6	f	t	
204	6	t	t	
203	6	t	t	
214	6	t	t	
135	5	t	t	
136	5	f	t	
137	5	t	t	
138	5	t	t	
139	6	t	t	
140	6	t	t	
141	5	t	t	
195	8	f	f	
196	6	f	f	
197	6	f	f	
80	6	t	t	
191	6	t	t	
82	6	t	t	
81	4	t	t	
84	4	t	t	
194	4	t	t	
85	6	t	t	
87	4	t	t	
\.


--
-- Data for Name: typ_2_datorer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY typ_2_datorer (obj_id, webb, ordbehandling, skrivare, kommentar, extra_tangentbord, diskettstation) FROM stdin;
188	f	f	f		0	1
268	t	t	t		0	0
208	t	t	t		0	1
128	t	t	t		0	1
127	t	t	t		0	1
126	t	t	t		0	1
125	t	t	t		0	1
132	t	t	t		0	1
131	t	t	t		0	1
130	t	t	t		0	1
129	t	t	t		0	1
244	t	t	t		0	0
124	t	t	t		1	1
187	f	f	f		0	1
133	t	t	t		0	1
117	t	t	t		0	1
134	t	t	t		0	1
123	t	t	t		1	1
122	t	t	t		1	1
121	t	t	t		1	1
297	f	f	f		0	0
119	t	t	t		1	1
118	t	t	t		1	1
178	t	t	t		0	1
179	t	t	t		0	1
192	t	t	t		0	1
193	t	t	t		0	1
207	t	t	t		0	1
217	t	t	t		0	1
245	t	t	t		0	1
247	t	t	t		0	1
246	t	t	t		0	1
209	t	t	t		0	1
210	t	t	t		0	1
212	t	t	t		0	1
248	t	t	t		0	1
182	t	t	t		0	1
183	t	t	t		0	1
181	t	t	t		0	1
186	t	t	t		0	1
180	t	t	t		0	1
185	t	t	t		0	1
279	t	t	t		0	0
280	t	t	t		0	0
184	t	t	t		0	1
249	t	t	t		0	1
265	t	t	t		0	0
266	t	t	t		0	0
267	t	t	t		0	0
269	t	t	t		0	0
270	t	t	t		0	0
174	t	t	t		0	1
175	t	t	t		0	1
176	t	t	t		0	1
177	t	t	t		0	1
271	t	t	t		0	0
272	t	t	t		0	0
273	t	t	t		0	0
274	t	t	t		0	0
275	t	t	t		0	0
276	t	t	t		0	0
277	t	t	t		0	0
278	t	t	t		0	0
281	t	t	t		0	0
282	t	t	t		0	0
108	t	t	t		0	1
107	t	t	t		0	1
106	t	t	t		0	1
105	t	t	t		0	1
112	t	t	t		0	1
111	t	t	t		0	1
110	t	t	t		0	1
109	t	t	t		0	1
116	t	t	t		0	1
115	t	t	t		0	1
114	t	t	t		0	1
113	t	t	t		1	1
120	t	t	t		1	1
206	t	t	t		0	1
\.


--
-- Data for Name: typ_3_lasstudio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY typ_3_lasstudio (obj_id, braille, kommentar) FROM stdin;
286	f	\N
305	f	\N
302	f	\N
284	f	\N
313	f	\N
285	f	\N
287	f	\N
288	f	\N
283	t	\N
314	f	\N
306	f	\N
\.


--
-- Data for Name: typ_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY typ_info (typ, typ_namn, timmar_pass, antal_pass, dagar_fram, typ_namn_stor, from_dag, type_name, type_name_heading) FROM stdin;
2	datorarbetsplats	2	2	14	Datorarbetsplats	2002-01-01	computer work stations	Computer work stations
1	grupprum	2	2	14	Grupprum	2006-02-13	group study rooms	Group study rooms
3	l&auml;sstudio	2	2	14	L&auml;sstudio	2008-01-22	disability resource room	Disability resource room
\.


--
-- Name: pga_diagrams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pga_diagrams
    ADD CONSTRAINT pga_diagrams_pkey PRIMARY KEY (diagramname);


--
-- Name: pga_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pga_forms
    ADD CONSTRAINT pga_forms_pkey PRIMARY KEY (formname);


--
-- Name: pga_graphs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pga_graphs
    ADD CONSTRAINT pga_graphs_pkey PRIMARY KEY (graphname);


--
-- Name: pga_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pga_images
    ADD CONSTRAINT pga_images_pkey PRIMARY KEY (imagename);


--
-- Name: pga_layout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pga_layout
    ADD CONSTRAINT pga_layout_pkey PRIMARY KEY (tablename);


--
-- Name: pga_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pga_queries
    ADD CONSTRAINT pga_queries_pkey PRIMARY KEY (queryname);


--
-- Name: pga_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pga_reports
    ADD CONSTRAINT pga_reports_pkey PRIMARY KEY (reportname);


--
-- Name: pga_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pga_scripts
    ADD CONSTRAINT pga_scripts_pkey PRIMARY KEY (scriptname);


--
-- Name: typ_3_lasstudio_obj_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY typ_3_lasstudio
    ADD CONSTRAINT typ_3_lasstudio_obj_id_key UNIQUE (obj_id);


--
-- Name: boknings_objekt_obj_id_key; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX boknings_objekt_obj_id_key ON boknings_objekt USING btree (obj_id);


--
-- Name: typ_1_grupprum_obj_id_key; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX typ_1_grupprum_obj_id_key ON typ_1_grupprum USING btree (obj_id);


--
-- Name: typ_2_datorer_obj_id_key; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX typ_2_datorer_obj_id_key ON typ_2_datorer USING btree (obj_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: bokning; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE bokning FROM PUBLIC;
REVOKE ALL ON TABLE bokning FROM postgres;
GRANT ALL ON TABLE bokning TO postgres;
GRANT SELECT ON TABLE bokning TO postgres;
GRANT SELECT ON TABLE bokning TO postgres;


--
-- Name: bokning_backup; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE bokning_backup FROM PUBLIC;
REVOKE ALL ON TABLE bokning_backup FROM postgres;
GRANT ALL ON TABLE bokning_backup TO postgres;
GRANT SELECT ON TABLE bokning_backup TO postgres;
GRANT SELECT ON TABLE bokning_backup TO postgres;


--
-- Name: boknings_objekt; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE boknings_objekt FROM PUBLIC;
REVOKE ALL ON TABLE boknings_objekt FROM postgres;
GRANT ALL ON TABLE boknings_objekt TO postgres;
GRANT SELECT ON TABLE boknings_objekt TO postgres;
GRANT SELECT ON TABLE boknings_objekt TO postgres;


--
-- Name: typ_1_grupprum; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE typ_1_grupprum FROM PUBLIC;
REVOKE ALL ON TABLE typ_1_grupprum FROM postgres;
GRANT ALL ON TABLE typ_1_grupprum TO postgres;
GRANT SELECT ON TABLE typ_1_grupprum TO postgres;
GRANT SELECT ON TABLE typ_1_grupprum TO postgres;


--
-- Name: dag_ordning; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dag_ordning FROM PUBLIC;
REVOKE ALL ON TABLE dag_ordning FROM postgres;
GRANT ALL ON TABLE dag_ordning TO postgres;
GRANT SELECT ON TABLE dag_ordning TO postgres;
GRANT SELECT ON TABLE dag_ordning TO postgres;


--
-- Name: dagar; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dagar FROM PUBLIC;
REVOKE ALL ON TABLE dagar FROM postgres;
GRANT ALL ON TABLE dagar TO postgres;
GRANT SELECT ON TABLE dagar TO postgres;
GRANT SELECT ON TABLE dagar TO postgres;


--
-- Name: gamla_bokningar; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE gamla_bokningar FROM PUBLIC;
REVOKE ALL ON TABLE gamla_bokningar FROM postgres;
GRANT ALL ON TABLE gamla_bokningar TO postgres;
GRANT SELECT ON TABLE gamla_bokningar TO postgres;
GRANT SELECT ON TABLE gamla_bokningar TO postgres;


--
-- Name: gamla_openhours; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE gamla_openhours FROM PUBLIC;
REVOKE ALL ON TABLE gamla_openhours FROM postgres;
GRANT ALL ON TABLE gamla_openhours TO postgres;
GRANT SELECT ON TABLE gamla_openhours TO postgres;
GRANT SELECT ON TABLE gamla_openhours TO postgres;


--
-- Name: lokal; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE lokal FROM PUBLIC;
REVOKE ALL ON TABLE lokal FROM postgres;
GRANT ALL ON TABLE lokal TO postgres;
GRANT SELECT ON TABLE lokal TO postgres;
GRANT SELECT ON TABLE lokal TO postgres;


--
-- Name: lokal_sort; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE lokal_sort FROM PUBLIC;
REVOKE ALL ON TABLE lokal_sort FROM postgres;
GRANT ALL ON TABLE lokal_sort TO postgres;
GRANT SELECT ON TABLE lokal_sort TO postgres;
GRANT SELECT ON TABLE lokal_sort TO postgres;


--
-- Name: openhours; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE openhours FROM PUBLIC;
REVOKE ALL ON TABLE openhours FROM postgres;
GRANT ALL ON TABLE openhours TO postgres;
GRANT SELECT ON TABLE openhours TO postgres;
GRANT SELECT ON TABLE openhours TO postgres;


--
-- Name: typ_info; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE typ_info FROM PUBLIC;
REVOKE ALL ON TABLE typ_info FROM postgres;
GRANT ALL ON TABLE typ_info TO postgres;
GRANT SELECT ON TABLE typ_info TO postgres;
GRANT SELECT ON TABLE typ_info TO postgres;


--
-- Name: typ_2_datorer; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE typ_2_datorer FROM PUBLIC;
REVOKE ALL ON TABLE typ_2_datorer FROM postgres;
GRANT ALL ON TABLE typ_2_datorer TO postgres;
GRANT SELECT ON TABLE typ_2_datorer TO postgres;
GRANT SELECT ON TABLE typ_2_datorer TO postgres;


--
-- Name: typ_3_lasstudio; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE typ_3_lasstudio FROM PUBLIC;
REVOKE ALL ON TABLE typ_3_lasstudio FROM postgres;
GRANT ALL ON TABLE typ_3_lasstudio TO postgres;
GRANT SELECT ON TABLE typ_3_lasstudio TO postgres;
GRANT SELECT ON TABLE typ_3_lasstudio TO postgres;


--
-- PostgreSQL database dump complete
--

