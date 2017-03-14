--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: approval_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE approval_states (
    id integer NOT NULL,
    user_id integer NOT NULL,
    approval_order integer DEFAULT 0,
    status integer DEFAULT 0,
    form_locked boolean DEFAULT false,
    mail_sent boolean DEFAULT false,
    approvable_id integer NOT NULL,
    approvable_type character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: approval_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE approval_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: approval_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE approval_states_id_seq OWNED BY approval_states.id;


--
-- Name: leave_request_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE leave_request_emails (
    id integer NOT NULL,
    leave_request_id integer,
    cn character varying(255),
    email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: leave_request_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE leave_request_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leave_request_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE leave_request_emails_id_seq OWNED BY leave_request_emails.id;


--
-- Name: leave_request_extras; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE leave_request_extras (
    id integer NOT NULL,
    leave_request_id integer,
    work_days integer,
    work_hours numeric(5,2) DEFAULT 0,
    basket_coverage boolean,
    covering character varying(255),
    hours_professional numeric(5,2) DEFAULT 0,
    hours_professional_desc text,
    hours_professional_role character varying(255),
    hours_administrative numeric(5,2) DEFAULT 0,
    hours_administrative_desc text,
    hours_administrative_role character varying(255),
    funding_no_cost boolean,
    funding_no_cost_desc text,
    funding_approx_cost numeric,
    funding_split boolean,
    funding_split_desc text,
    funding_grant character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: leave_request_extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE leave_request_extras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leave_request_extras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE leave_request_extras_id_seq OWNED BY leave_request_extras.id;


--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE leave_requests (
    id integer NOT NULL,
    form_user character varying(255),
    form_email character varying(255),
    start_date date,
    start_hour character varying(255),
    start_min character varying(255),
    end_date date,
    end_hour character varying(255),
    end_min character varying(255),
    "desc" text,
    hours_vacation numeric(5,2) DEFAULT 0,
    hours_sick numeric(5,2) DEFAULT 0,
    hours_other numeric(5,2) DEFAULT 0,
    hours_other_desc text,
    hours_training numeric(5,2) DEFAULT 0,
    hours_training_desc text,
    hours_comp numeric(5,2) DEFAULT 0,
    hours_comp_desc text,
    has_extra boolean,
    need_travel boolean DEFAULT false,
    status integer DEFAULT 0,
    user_id integer,
    mail_sent boolean DEFAULT false,
    mail_final_sent boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: leave_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE leave_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leave_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE leave_requests_id_seq OWNED BY leave_requests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: travel_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE travel_files (
    id integer NOT NULL,
    travel_request_id integer,
    user_file_id integer
);


--
-- Name: travel_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE travel_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: travel_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE travel_files_id_seq OWNED BY travel_files.id;


--
-- Name: travel_request_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE travel_request_emails (
    id integer NOT NULL,
    travel_request_id integer,
    cn character varying(255),
    email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: travel_request_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE travel_request_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: travel_request_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE travel_request_emails_id_seq OWNED BY travel_request_emails.id;


--
-- Name: travel_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE travel_requests (
    id integer NOT NULL,
    form_user character varying(255),
    form_email character varying(255),
    dest_desc text,
    air_use boolean DEFAULT false,
    air_desc character varying(255),
    ffid text,
    dest_depart_date date,
    dest_depart_hour character varying(255),
    dest_depart_min character varying(255),
    dest_arrive_hour character varying(255),
    dest_arrive_min character varying(255),
    preferred_airline text,
    menu_notes text,
    additional_travelers integer,
    ret_depart_date date,
    ret_depart_hour character varying(255),
    ret_depart_min character varying(255),
    ret_arrive_hour character varying(255),
    ret_arrive_min character varying(255),
    other_notes text,
    car_rental boolean DEFAULT false,
    car_arrive date,
    car_arrive_hour character varying(255),
    car_arrive_min character varying(255),
    car_depart date,
    car_depart_hour character varying(255),
    car_depart_min character varying(255),
    car_rental_co text,
    lodging_use boolean DEFAULT false,
    lodging_card_type text,
    lodging_card_desc text,
    lodging_name text,
    lodging_phone character varying(255),
    lodging_arrive_date date,
    lodging_depart_date date,
    lodging_additional_people text,
    lodging_other_notes text,
    conf_prepayment boolean,
    conf_desc text,
    expense_card_use boolean DEFAULT false,
    expense_card_type character varying(255),
    expense_card_desc character varying(255),
    status integer DEFAULT 0,
    user_id integer,
    leave_request_id integer,
    mail_sent boolean DEFAULT false,
    mail_final_sent boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: travel_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE travel_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: travel_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE travel_requests_id_seq OWNED BY travel_requests.id;


--
-- Name: user_default_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_default_emails (
    id integer NOT NULL,
    user_id integer,
    cn character varying(255),
    email character varying(255),
    displayname character varying(255),
    role_id integer DEFAULT 1,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approval_order integer DEFAULT 0
);


--
-- Name: user_default_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_default_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_default_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_default_emails_id_seq OWNED BY user_default_emails.id;


--
-- Name: user_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_files (
    id integer NOT NULL,
    uploaded_file_file_name character varying(255),
    uploaded_file_content_type character varying(255),
    uploaded_file_file_size integer,
    uploaded_file_updated_at timestamp without time zone,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_files_id_seq OWNED BY user_files.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    login character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    remember_token character varying(255),
    is_admin boolean DEFAULT false,
    timezone character varying(255) DEFAULT 'America/Los_Angeles'::character varying,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sn character varying(255),
    is_ldap boolean DEFAULT true
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone,
    object_changes text
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY approval_states ALTER COLUMN id SET DEFAULT nextval('approval_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY leave_request_emails ALTER COLUMN id SET DEFAULT nextval('leave_request_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY leave_request_extras ALTER COLUMN id SET DEFAULT nextval('leave_request_extras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY leave_requests ALTER COLUMN id SET DEFAULT nextval('leave_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY travel_files ALTER COLUMN id SET DEFAULT nextval('travel_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY travel_request_emails ALTER COLUMN id SET DEFAULT nextval('travel_request_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY travel_requests ALTER COLUMN id SET DEFAULT nextval('travel_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_default_emails ALTER COLUMN id SET DEFAULT nextval('user_default_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_files ALTER COLUMN id SET DEFAULT nextval('user_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: approval_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY approval_states
    ADD CONSTRAINT approval_states_pkey PRIMARY KEY (id);


--
-- Name: leave_request_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY leave_request_emails
    ADD CONSTRAINT leave_request_emails_pkey PRIMARY KEY (id);


--
-- Name: leave_request_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY leave_request_extras
    ADD CONSTRAINT leave_request_extras_pkey PRIMARY KEY (id);


--
-- Name: leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: travel_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY travel_files
    ADD CONSTRAINT travel_files_pkey PRIMARY KEY (id);


--
-- Name: travel_request_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY travel_request_emails
    ADD CONSTRAINT travel_request_emails_pkey PRIMARY KEY (id);


--
-- Name: travel_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY travel_requests
    ADD CONSTRAINT travel_requests_pkey PRIMARY KEY (id);


--
-- Name: user_default_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_default_emails
    ADD CONSTRAINT user_default_emails_pkey PRIMARY KEY (id);


--
-- Name: user_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_files
    ADD CONSTRAINT user_files_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_approval_states_on_approvable_type_and_approvable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_approval_states_on_approvable_type_and_approvable_id ON approval_states USING btree (approvable_type, approvable_id);


--
-- Name: index_user_default_emails_on_role_order; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_default_emails_on_role_order ON user_default_emails USING btree (approval_order);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20111207234303');

INSERT INTO schema_migrations (version) VALUES ('20111207234322');

INSERT INTO schema_migrations (version) VALUES ('20111209205125');

INSERT INTO schema_migrations (version) VALUES ('20111214185238');

INSERT INTO schema_migrations (version) VALUES ('20111216235625');

INSERT INTO schema_migrations (version) VALUES ('20111221001357');

INSERT INTO schema_migrations (version) VALUES ('20120206183848');

INSERT INTO schema_migrations (version) VALUES ('20120206184141');

INSERT INTO schema_migrations (version) VALUES ('20120206184204');

INSERT INTO schema_migrations (version) VALUES ('20130115215501');

INSERT INTO schema_migrations (version) VALUES ('20130312155948');

INSERT INTO schema_migrations (version) VALUES ('20130523172048');

INSERT INTO schema_migrations (version) VALUES ('20130523173226');

INSERT INTO schema_migrations (version) VALUES ('20130819172119');

INSERT INTO schema_migrations (version) VALUES ('20131203221734');

INSERT INTO schema_migrations (version) VALUES ('20140404172459');

INSERT INTO schema_migrations (version) VALUES ('20140423163554');

INSERT INTO schema_migrations (version) VALUES ('20140506162219');

INSERT INTO schema_migrations (version) VALUES ('20140507214058');

INSERT INTO schema_migrations (version) VALUES ('20140514173147');