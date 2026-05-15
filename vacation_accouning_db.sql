-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION pg_database_owner;

-- DROP TYPE public."leave_portion";

CREATE TYPE public."leave_portion" AS ENUM (
	'Full',
	'Morning',
	'Afternoon');

-- DROP TYPE public."leave_status";

CREATE TYPE public."leave_status" AS ENUM (
	'Pending',
	'Approved',
	'Declined');

-- DROP TYPE public."leave_visibility";

CREATE TYPE public."leave_visibility" AS ENUM (
	'All',
	'Department only',
	'Admins only');

-- DROP TYPE public."user_role";

CREATE TYPE public."user_role" AS ENUM (
	'Admin',
	'Manager',
	'User');

-- DROP TYPE public."user_status";

CREATE TYPE public."user_status" AS ENUM (
	'Active',
	'Inactive');

-- DROP TYPE public."week_start_day";

CREATE TYPE public."week_start_day" AS ENUM (
	'Monday',
	'Sunday');

-- DROP SEQUENCE public.department_id_seq;

CREATE SEQUENCE public.department_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.holiday_id_seq;

CREATE SEQUENCE public.holiday_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.leave_policies_id_seq;

CREATE SEQUENCE public.leave_policies_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.leave_request_id_seq;

CREATE SEQUENCE public.leave_request_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.leave_type_id_seq;

CREATE SEQUENCE public.leave_type_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.leaves_balance_id_seq;

CREATE SEQUENCE public.leaves_balance_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.main_account_id_seq;

CREATE SEQUENCE public.main_account_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.organization_id_seq;

CREATE SEQUENCE public.organization_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.user_account_id_seq;

CREATE SEQUENCE public.user_account_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;-- public.main_account definition

-- Drop table

-- DROP TABLE public.main_account;

CREATE TABLE public.main_account (
	id serial4 NOT NULL,
	"name" varchar(255) NOT NULL,
	CONSTRAINT main_account_pkey PRIMARY KEY (id)
);


-- public.organization definition

-- Drop table

-- DROP TABLE public.organization;

CREATE TABLE public.organization (
	id serial4 NOT NULL,
	main_account_id int4 NOT NULL,
	"name" varchar(255) NOT NULL,
	logo_url text NULL,
	country varchar(100) NULL,
	timezone varchar(50) NULL,
	week_starts_on public."week_start_day" DEFAULT 'Monday'::week_start_day NOT NULL,
	default_working_days int2 DEFAULT 31 NOT NULL,
	CONSTRAINT organization_pkey PRIMARY KEY (id),
	CONSTRAINT fk_organization_main_account FOREIGN KEY (main_account_id) REFERENCES public.main_account(id) ON DELETE CASCADE
);


-- public.department definition

-- Drop table

-- DROP TABLE public.department;

CREATE TABLE public.department (
	id serial4 NOT NULL,
	organization_id int4 NOT NULL,
	"name" varchar(255) NOT NULL,
	CONSTRAINT department_pkey PRIMARY KEY (id),
	CONSTRAINT fk_department_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE
);


-- public.holiday definition

-- Drop table

-- DROP TABLE public.holiday;

CREATE TABLE public.holiday (
	id serial4 NOT NULL,
	organization_id int4 NOT NULL,
	"name" varchar(255) NOT NULL,
	"date" date NOT NULL,
	CONSTRAINT holiday_pkey PRIMARY KEY (id),
	CONSTRAINT uk_holiday_org_date UNIQUE (organization_id, date),
	CONSTRAINT fk_holiday_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE
);


-- public.leave_policies definition

-- Drop table

-- DROP TABLE public.leave_policies;

CREATE TABLE public.leave_policies (
	id serial4 NOT NULL,
	organization_id int4 NOT NULL,
	default_annual_allowance int2 DEFAULT 20 NOT NULL,
	carry_forward_limit int2 DEFAULT 0 NOT NULL,
	allow_carry_forward bool DEFAULT false NOT NULL,
	CONSTRAINT leave_policies_pkey PRIMARY KEY (id),
	CONSTRAINT uk_leave_policies_organization UNIQUE (organization_id),
	CONSTRAINT fk_leave_policies_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE
);


-- public.leave_type definition

-- Drop table

-- DROP TABLE public.leave_type;

CREATE TABLE public.leave_type (
	id serial4 NOT NULL,
	organization_id int4 NOT NULL,
	"name" varchar(255) NOT NULL,
	color varchar(7) DEFAULT '#FFFFFF'::character varying NOT NULL,
	icon_url text NULL,
	allowance_limit int2 NULL,
	is_paid bool DEFAULT true NOT NULL,
	requires_approval bool DEFAULT true NOT NULL,
	visibility public."leave_visibility" DEFAULT 'All'::leave_visibility NOT NULL,
	CONSTRAINT leave_type_pkey PRIMARY KEY (id),
	CONSTRAINT fk_leave_type_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE
);


-- public.user_account definition

-- Drop table

-- DROP TABLE public.user_account;

CREATE TABLE public.user_account (
	id serial4 NOT NULL,
	organization_id int4 NOT NULL,
	department_id int4 NULL,
	approver_id int4 NULL,
	"name" varchar(255) NOT NULL,
	email varchar(255) NOT NULL,
	password_hash text NOT NULL,
	avatar_url text NULL,
	"role" public."user_role" DEFAULT 'User'::user_role NOT NULL,
	status public."user_status" DEFAULT 'Active'::user_status NOT NULL,
	CONSTRAINT uk_user_account_email UNIQUE (email),
	CONSTRAINT user_account_pkey PRIMARY KEY (id),
	CONSTRAINT fk_user_account_approver FOREIGN KEY (approver_id) REFERENCES public.user_account(id) ON DELETE SET NULL,
	CONSTRAINT fk_user_account_department FOREIGN KEY (department_id) REFERENCES public.department(id) ON DELETE SET NULL,
	CONSTRAINT fk_user_account_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE RESTRICT
);


-- public.leave_request definition

-- Drop table

-- DROP TABLE public.leave_request;

CREATE TABLE public.leave_request (
	id serial4 NOT NULL,
	leave_type_id int4 NOT NULL,
	user_id int4 NOT NULL,
	approver_id int4 NULL,
	start_date date NOT NULL,
	end_date date NOT NULL,
	start_portion public."leave_portion" DEFAULT 'Full'::leave_portion NOT NULL,
	end_portion public."leave_portion" DEFAULT 'Full'::leave_portion NOT NULL,
	status public."leave_status" DEFAULT 'Pending'::leave_status NOT NULL,
	user_comment text NULL,
	approver_comment text NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	total_days numeric(4, 1) NOT NULL,
	CONSTRAINT chk_leave_request_dates CHECK ((start_date <= end_date)),
	CONSTRAINT leave_request_pkey PRIMARY KEY (id),
	CONSTRAINT fk_leave_request_approver FOREIGN KEY (approver_id) REFERENCES public.user_account(id) ON DELETE SET NULL,
	CONSTRAINT fk_leave_request_type FOREIGN KEY (leave_type_id) REFERENCES public.leave_type(id) ON DELETE RESTRICT,
	CONSTRAINT fk_leave_request_user FOREIGN KEY (user_id) REFERENCES public.user_account(id) ON DELETE CASCADE
);


-- public.leaves_balance definition

-- Drop table

-- DROP TABLE public.leaves_balance;

CREATE TABLE public.leaves_balance (
	id serial4 NOT NULL,
	user_id int4 NOT NULL,
	"year" int2 NOT NULL,
	annual_allowance int2 NOT NULL,
	carried_over_days int2 DEFAULT 0 NOT NULL,
	time_in_lieu int2 DEFAULT 0 NOT NULL,
	CONSTRAINT leaves_balance_pkey PRIMARY KEY (id),
	CONSTRAINT uk_leaves_balance_user_year UNIQUE (user_id, year),
	CONSTRAINT fk_leaves_balance_user FOREIGN KEY (user_id) REFERENCES public.user_account(id) ON DELETE CASCADE
);