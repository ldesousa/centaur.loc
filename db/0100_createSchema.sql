-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.8.2-alpha1
-- PostgreSQL version: 9.4
-- Project Site: pgmodeler.com.br
-- Model Author: ---


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: centaur | type: DATABASE --
-- -- DROP DATABASE IF EXISTS centaur;
-- CREATE DATABASE centaur
-- ;
-- -- ddl-end --
-- 

-- object: centaur | type: SCHEMA --
-- DROP SCHEMA IF EXISTS centaur CASCADE;
CREATE SCHEMA coimbra;
-- ddl-end --
ALTER SCHEMA coimbra OWNER TO desouslu;
-- ddl-end --

SET search_path TO coimbra,public,pg_catalog;
-- ddl-end --

-- object: curve | type: TABLE --
-- DROP TABLE IF EXISTS curve CASCADE;
CREATE TABLE curve(
	id integer NOT NULL,
	name varchar,
	type varchar,
	CONSTRAINT pk_curve PRIMARY KEY (id),
	CONSTRAINT unq_curve UNIQUE (name)

);
-- ddl-end --
ALTER TABLE curve OWNER TO postgres;
-- ddl-end --

-- object: curve_parameter | type: TABLE --
-- DROP TABLE IF EXISTS curve_parameter CASCADE;
CREATE TABLE curve_parameter(
	id serial NOT NULL,
	x numeric,
	y numeric,
	id_curve integer,
	CONSTRAINT pk_curve_parameter PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE curve_parameter OWNER TO postgres;
-- ddl-end --

-- object: node | type: TABLE --
-- DROP TABLE IF EXISTS node CASCADE;
CREATE TABLE node(
	id serial NOT NULL,
	elevation numeric,
	name varchar,
	taken boolean,
	CONSTRAINT pk_node PRIMARY KEY (id),
	CONSTRAINT unq_node UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN node.taken IS 'True if this node is already being used by a gate or flooded by one.';
-- ddl-end --
ALTER TABLE node OWNER TO postgres;
-- ddl-end --

-- object: link | type: TABLE --
-- DROP TABLE IF EXISTS link CASCADE;
CREATE TABLE link(
	id serial NOT NULL,
	name varchar,
	id_node_from integer,
	id_node_to integer,
	CONSTRAINT pk_link PRIMARY KEY (id),
	CONSTRAINT unq_link_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE link OWNER TO postgres;
-- ddl-end --

-- object: conduit | type: TABLE --
-- DROP TABLE IF EXISTS conduit CASCADE;
CREATE TABLE conduit(
	id_link integer NOT NULL,
	length numeric,
	roughness numeric,
	in_offset numeric,
	out_offset numeric,
	init_flow numeric,
	max_flow numeric,
	CONSTRAINT pk_conduit PRIMARY KEY (id_link)

);
-- ddl-end --
COMMENT ON COLUMN conduit.length IS 'This can be calculated from the junctions coordinates';
-- ddl-end --
ALTER TABLE conduit OWNER TO postgres;
-- ddl-end --

-- object: pump | type: TABLE --
-- DROP TABLE IF EXISTS pump CASCADE;
CREATE TABLE pump(
	id_link integer NOT NULL,
	id_curve integer,
	status varchar,
	startup numeric,
	shutoff numeric,
	CONSTRAINT pk_pump PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE pump OWNER TO postgres;
-- ddl-end --

-- object: junction | type: TABLE --
-- DROP TABLE IF EXISTS junction CASCADE;
CREATE TABLE junction(
	id_node integer NOT NULL,
	max_depth numeric,
	init_depth numeric,
	sur_depth numeric,
	aponded numeric,
	CONSTRAINT pk_junction PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE junction OWNER TO postgres;
-- ddl-end --

-- object: weir | type: TABLE --
-- DROP TABLE IF EXISTS weir CASCADE;
CREATE TABLE weir(
	id_link integer NOT NULL,
	type varchar,
	crest_height numeric,
	q_coeff numeric,
	gated boolean,
	end_con numeric,
	end_coeff numeric,
	surcharge boolean,
	CONSTRAINT pk_weir PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE weir OWNER TO postgres;
-- ddl-end --

-- object: outfall | type: TABLE --
-- DROP TABLE IF EXISTS outfall CASCADE;
CREATE TABLE outfall(
	id_node integer NOT NULL,
	type varchar,
	stage_date varchar,
	gated boolean,
	route_to varchar,
	CONSTRAINT pk_outfall PRIMARY KEY (id_node)

);
-- ddl-end --
COMMENT ON TABLE outfall IS 'This is a special kind of junction';
-- ddl-end --
ALTER TABLE outfall OWNER TO postgres;
-- ddl-end --

-- object: storage | type: TABLE --
-- DROP TABLE IF EXISTS storage CASCADE;
CREATE TABLE storage(
	id_node integer NOT NULL,
	max_depth numeric,
	init_depth numeric,
	shape varchar,
	id_curve integer,
	name_params integer,
	fevap numeric,
	psi numeric,
	ksat numeric,
	imd numeric,
	CONSTRAINT pk_storage PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE storage OWNER TO postgres;
-- ddl-end --

-- object: xsection | type: TABLE --
-- DROP TABLE IF EXISTS xsection CASCADE;
CREATE TABLE xsection(
	id_link integer NOT NULL,
	shape varchar,
	geom1 numeric,
	geom2 numeric,
	geom3 numeric,
	geom4 numeric,
	barrels numeric,
	culvert numeric,
	CONSTRAINT pk_xsection PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE xsection OWNER TO postgres;
-- ddl-end --

-- object: raingage | type: TABLE --
-- DROP TABLE IF EXISTS raingage CASCADE;
CREATE TABLE raingage(
	id integer NOT NULL,
	format varchar,
	"interval" varchar,
	scf numeric,
	source varchar,
	CONSTRAINT pk_raingage PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE raingage OWNER TO postgres;
-- ddl-end --

-- object: subcatchment | type: TABLE --
-- DROP TABLE IF EXISTS subcatchment CASCADE;
CREATE TABLE subcatchment(
	id serial NOT NULL,
	name varchar,
	id_node_outlet integer,
	id_raingage integer,
	area numeric,
	imperv numeric(13,10),
	width numeric,
	slope numeric(12,10),
	curb_len numeric,
	snow_pack varchar,
	CONSTRAINT pk_subcatchment PRIMARY KEY (id),
	CONSTRAINT unq_subcatchment_name UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN subcatchment.imperv IS 'This field is a percentage (<= 100)';
-- ddl-end --
COMMENT ON COLUMN subcatchment.slope IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE subcatchment OWNER TO postgres;
-- ddl-end --

-- object: subarea | type: TABLE --
-- DROP TABLE IF EXISTS subarea CASCADE;
CREATE TABLE subarea(
	id_subcatchment serial NOT NULL,
	n_imperv numeric,
	n_perv numeric,
	s_imperv numeric,
	s_perv numeric,
	pct_zero numeric(12,10),
	route_to varchar,
	pct_routed numeric(12,10),
	CONSTRAINT pk_subarea PRIMARY KEY (id_subcatchment)

);
-- ddl-end --
COMMENT ON COLUMN subarea.pct_zero IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE subarea OWNER TO postgres;
-- ddl-end --

-- object: coordinates | type: TABLE --
-- DROP TABLE IF EXISTS coordinates CASCADE;
CREATE TABLE coordinates(
	id_node integer NOT NULL,
	x numeric,
	y numeric,
	CONSTRAINT pk_coordinates PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE coordinates OWNER TO postgres;
-- ddl-end --

-- object: polygon | type: TABLE --
-- DROP TABLE IF EXISTS polygon CASCADE;
CREATE TABLE polygon(
	id serial NOT NULL,
	id_subcatchment integer,
	x numeric,
	y numeric,
	CONSTRAINT pk_polygon PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE polygon OWNER TO postgres;
-- ddl-end --

-- object: candidate | type: TABLE --
-- DROP TABLE IF EXISTS candidate CASCADE;
CREATE TABLE candidate(
	id_node integer NOT NULL,
	outflow_elevation numeric NOT NULL,
	served_area numeric,
	volume numeric,
	CONSTRAINT pk_candidate PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE candidate OWNER TO postgres;
-- ddl-end --

-- object: flooded | type: TABLE --
-- DROP TABLE IF EXISTS flooded CASCADE;
CREATE TABLE flooded(
	id_flooded serial NOT NULL,
	id_node integer NOT NULL,
	id_link integer NOT NULL,
	volume_fraction numeric,
	CONSTRAINT pk_flooded PRIMARY KEY (id_flooded),
	CONSTRAINT unq_flooded UNIQUE (id_node,id_link)

);
-- ddl-end --
ALTER TABLE flooded OWNER TO postgres;
-- ddl-end --

-- object: contribution | type: TABLE --
-- DROP TABLE IF EXISTS contribution CASCADE;
CREATE TABLE contribution(
	id serial NOT NULL,
	id_node integer NOT NULL,
	id_subcatchment integer NOT NULL,
	value numeric NOT NULL,
	CONSTRAINT pk_contribution PRIMARY KEY (id),
	CONSTRAINT unq_contribution UNIQUE (id_node,id_subcatchment)

);
-- ddl-end --
ALTER TABLE contribution OWNER TO postgres;
-- ddl-end --

-- object: fk_curve_parameter_curve | type: CONSTRAINT --
-- ALTER TABLE curve_parameter DROP CONSTRAINT IF EXISTS fk_curve_parameter_curve CASCADE;
ALTER TABLE curve_parameter ADD CONSTRAINT fk_curve_parameter_curve FOREIGN KEY (id_curve)
REFERENCES curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_from | type: CONSTRAINT --
-- ALTER TABLE link DROP CONSTRAINT IF EXISTS fk_link_node_from CASCADE;
ALTER TABLE link ADD CONSTRAINT fk_link_node_from FOREIGN KEY (id_node_from)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_to | type: CONSTRAINT --
-- ALTER TABLE link DROP CONSTRAINT IF EXISTS fk_link_node_to CASCADE;
ALTER TABLE link ADD CONSTRAINT fk_link_node_to FOREIGN KEY (id_node_to)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_conduit_link | type: CONSTRAINT --
-- ALTER TABLE conduit DROP CONSTRAINT IF EXISTS fk_conduit_link CASCADE;
ALTER TABLE conduit ADD CONSTRAINT fk_conduit_link FOREIGN KEY (id_link)
REFERENCES link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_link | type: CONSTRAINT --
-- ALTER TABLE pump DROP CONSTRAINT IF EXISTS fk_pump_link CASCADE;
ALTER TABLE pump ADD CONSTRAINT fk_pump_link FOREIGN KEY (id_link)
REFERENCES link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_curve | type: CONSTRAINT --
-- ALTER TABLE pump DROP CONSTRAINT IF EXISTS fk_pump_curve CASCADE;
ALTER TABLE pump ADD CONSTRAINT fk_pump_curve FOREIGN KEY (id_curve)
REFERENCES curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_junction_node | type: CONSTRAINT --
-- ALTER TABLE junction DROP CONSTRAINT IF EXISTS fk_junction_node CASCADE;
ALTER TABLE junction ADD CONSTRAINT fk_junction_node FOREIGN KEY (id_node)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_weir_link | type: CONSTRAINT --
-- ALTER TABLE weir DROP CONSTRAINT IF EXISTS fk_weir_link CASCADE;
ALTER TABLE weir ADD CONSTRAINT fk_weir_link FOREIGN KEY (id_link)
REFERENCES link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_outfall_node | type: CONSTRAINT --
-- ALTER TABLE outfall DROP CONSTRAINT IF EXISTS fk_outfall_node CASCADE;
ALTER TABLE outfall ADD CONSTRAINT fk_outfall_node FOREIGN KEY (id_node)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_node | type: CONSTRAINT --
-- ALTER TABLE storage DROP CONSTRAINT IF EXISTS fk_storage_node CASCADE;
ALTER TABLE storage ADD CONSTRAINT fk_storage_node FOREIGN KEY (id_node)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_curve | type: CONSTRAINT --
-- ALTER TABLE storage DROP CONSTRAINT IF EXISTS fk_storage_curve CASCADE;
ALTER TABLE storage ADD CONSTRAINT fk_storage_curve FOREIGN KEY (id_curve)
REFERENCES curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_xsection_link | type: CONSTRAINT --
-- ALTER TABLE xsection DROP CONSTRAINT IF EXISTS fk_xsection_link CASCADE;
ALTER TABLE xsection ADD CONSTRAINT fk_xsection_link FOREIGN KEY (id_link)
REFERENCES link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_raingage | type: CONSTRAINT --
-- ALTER TABLE subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_raingage CASCADE;
ALTER TABLE subcatchment ADD CONSTRAINT fk_subcatchment_raingage FOREIGN KEY (id_raingage)
REFERENCES raingage (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_node | type: CONSTRAINT --
-- ALTER TABLE subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_node CASCADE;
ALTER TABLE subcatchment ADD CONSTRAINT fk_subcatchment_node FOREIGN KEY (id_node_outlet)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subarea_subcatchment | type: CONSTRAINT --
-- ALTER TABLE subarea DROP CONSTRAINT IF EXISTS fk_subarea_subcatchment CASCADE;
ALTER TABLE subarea ADD CONSTRAINT fk_subarea_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_coordinates_node | type: CONSTRAINT --
-- ALTER TABLE coordinates DROP CONSTRAINT IF EXISTS fk_coordinates_node CASCADE;
ALTER TABLE coordinates ADD CONSTRAINT fk_coordinates_node FOREIGN KEY (id_node)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_polygon_subcatchment | type: CONSTRAINT --
-- ALTER TABLE polygon DROP CONSTRAINT IF EXISTS fk_polygon_subcatchment CASCADE;
ALTER TABLE polygon ADD CONSTRAINT fk_polygon_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_candidate_node | type: CONSTRAINT --
-- ALTER TABLE candidate DROP CONSTRAINT IF EXISTS fk_candidate_node CASCADE;
ALTER TABLE candidate ADD CONSTRAINT fk_candidate_node FOREIGN KEY (id_node)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_link | type: CONSTRAINT --
-- ALTER TABLE flooded DROP CONSTRAINT IF EXISTS fk_flooded_link CASCADE;
ALTER TABLE flooded ADD CONSTRAINT fk_flooded_link FOREIGN KEY (id_link)
REFERENCES link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_candidate | type: CONSTRAINT --
-- ALTER TABLE flooded DROP CONSTRAINT IF EXISTS fk_flooded_candidate CASCADE;
ALTER TABLE flooded ADD CONSTRAINT fk_flooded_candidate FOREIGN KEY (id_node)
REFERENCES candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_contribution_candidate | type: CONSTRAINT --
-- ALTER TABLE contribution DROP CONSTRAINT IF EXISTS fk_contribution_candidate CASCADE;
ALTER TABLE contribution ADD CONSTRAINT fk_contribution_candidate FOREIGN KEY (id_node)
REFERENCES candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_contribution_subcatchment | type: CONSTRAINT --
-- ALTER TABLE contribution DROP CONSTRAINT IF EXISTS fk_contribution_subcatchment CASCADE;
ALTER TABLE contribution ADD CONSTRAINT fk_contribution_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


