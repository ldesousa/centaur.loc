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
CREATE SCHEMA centaur;
-- ddl-end --
ALTER SCHEMA centaur OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,centaur;
-- ddl-end --

-- object: centaur.curve | type: TABLE --
-- DROP TABLE IF EXISTS centaur.curve CASCADE;
CREATE TABLE centaur.curve(
	id integer NOT NULL,
	name varchar,
	type varchar,
	CONSTRAINT pk_curve PRIMARY KEY (id),
	CONSTRAINT unq_curve UNIQUE (name)

);
-- ddl-end --
ALTER TABLE centaur.curve OWNER TO postgres;
-- ddl-end --

-- object: centaur.curve_parameter | type: TABLE --
-- DROP TABLE IF EXISTS centaur.curve_parameter CASCADE;
CREATE TABLE centaur.curve_parameter(
	id serial NOT NULL,
	x numeric,
	y numeric,
	id_curve integer,
	CONSTRAINT pk_curve_parameter PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE centaur.curve_parameter OWNER TO postgres;
-- ddl-end --

-- object: centaur.node | type: TABLE --
-- DROP TABLE IF EXISTS centaur.node CASCADE;
CREATE TABLE centaur.node(
	id serial NOT NULL,
	elevation numeric,
	name varchar,
	taken boolean,
	CONSTRAINT pk_node PRIMARY KEY (id),
	CONSTRAINT unq_node UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN centaur.node.taken IS 'True if this node is already being used by a gate or flooded by one.';
-- ddl-end --
ALTER TABLE centaur.node OWNER TO postgres;
-- ddl-end --

-- object: centaur.link | type: TABLE --
-- DROP TABLE IF EXISTS centaur.link CASCADE;
CREATE TABLE centaur.link(
	id serial NOT NULL,
	name varchar,
	id_node_from integer,
	id_node_to integer,
	CONSTRAINT pk_link PRIMARY KEY (id),
	CONSTRAINT unq_link_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE centaur.link OWNER TO postgres;
-- ddl-end --

-- object: centaur.conduit | type: TABLE --
-- DROP TABLE IF EXISTS centaur.conduit CASCADE;
CREATE TABLE centaur.conduit(
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
COMMENT ON COLUMN centaur.conduit.length IS 'This can be calculated from the junctions coordinates';
-- ddl-end --
ALTER TABLE centaur.conduit OWNER TO postgres;
-- ddl-end --

-- object: centaur.pump | type: TABLE --
-- DROP TABLE IF EXISTS centaur.pump CASCADE;
CREATE TABLE centaur.pump(
	id_link integer NOT NULL,
	id_curve integer,
	status varchar,
	startup numeric,
	shutoff numeric,
	CONSTRAINT pk_pump PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE centaur.pump OWNER TO postgres;
-- ddl-end --

-- object: centaur.junction | type: TABLE --
-- DROP TABLE IF EXISTS centaur.junction CASCADE;
CREATE TABLE centaur.junction(
	id_node integer NOT NULL,
	max_depth numeric,
	init_depth numeric,
	sur_depth numeric,
	aponded numeric,
	CONSTRAINT pk_junction PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE centaur.junction OWNER TO postgres;
-- ddl-end --

-- object: centaur.weir | type: TABLE --
-- DROP TABLE IF EXISTS centaur.weir CASCADE;
CREATE TABLE centaur.weir(
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
ALTER TABLE centaur.weir OWNER TO postgres;
-- ddl-end --

-- object: centaur.outfall | type: TABLE --
-- DROP TABLE IF EXISTS centaur.outfall CASCADE;
CREATE TABLE centaur.outfall(
	id_node integer NOT NULL,
	type varchar,
	stage_date varchar,
	gated boolean,
	route_to varchar,
	CONSTRAINT pk_outfall PRIMARY KEY (id_node)

);
-- ddl-end --
COMMENT ON TABLE centaur.outfall IS 'This is a special kind of junction';
-- ddl-end --
ALTER TABLE centaur.outfall OWNER TO postgres;
-- ddl-end --

-- object: centaur.storage | type: TABLE --
-- DROP TABLE IF EXISTS centaur.storage CASCADE;
CREATE TABLE centaur.storage(
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
ALTER TABLE centaur.storage OWNER TO postgres;
-- ddl-end --

-- object: centaur.xsection | type: TABLE --
-- DROP TABLE IF EXISTS centaur.xsection CASCADE;
CREATE TABLE centaur.xsection(
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
ALTER TABLE centaur.xsection OWNER TO postgres;
-- ddl-end --

-- object: centaur.raingage | type: TABLE --
-- DROP TABLE IF EXISTS centaur.raingage CASCADE;
CREATE TABLE centaur.raingage(
	id integer NOT NULL,
	format varchar,
	"interval" varchar,
	scf numeric,
	source varchar,
	CONSTRAINT pk_raingage PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE centaur.raingage OWNER TO postgres;
-- ddl-end --

-- object: centaur.subcatchment | type: TABLE --
-- DROP TABLE IF EXISTS centaur.subcatchment CASCADE;
CREATE TABLE centaur.subcatchment(
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
COMMENT ON COLUMN centaur.subcatchment.imperv IS 'This field is a percentage (<= 100)';
-- ddl-end --
COMMENT ON COLUMN centaur.subcatchment.slope IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE centaur.subcatchment OWNER TO postgres;
-- ddl-end --

-- object: centaur.subarea | type: TABLE --
-- DROP TABLE IF EXISTS centaur.subarea CASCADE;
CREATE TABLE centaur.subarea(
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
COMMENT ON COLUMN centaur.subarea.pct_zero IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE centaur.subarea OWNER TO postgres;
-- ddl-end --

-- object: centaur.coordinates | type: TABLE --
-- DROP TABLE IF EXISTS centaur.coordinates CASCADE;
CREATE TABLE centaur.coordinates(
	id_node integer NOT NULL,
	x numeric,
	y numeric,
	CONSTRAINT pk_coordinates PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE centaur.coordinates OWNER TO postgres;
-- ddl-end --

-- object: centaur.polygon | type: TABLE --
-- DROP TABLE IF EXISTS centaur.polygon CASCADE;
CREATE TABLE centaur.polygon(
	id serial NOT NULL,
	id_subcatchment integer,
	x numeric,
	y numeric,
	CONSTRAINT pk_polygon PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE centaur.polygon OWNER TO postgres;
-- ddl-end --

-- object: centaur.candidate | type: TABLE --
-- DROP TABLE IF EXISTS centaur.candidate CASCADE;
CREATE TABLE centaur.candidate(
	id_node integer NOT NULL,
	outflow_elevation numeric NOT NULL,
	served_area numeric,
	volume numeric,
	CONSTRAINT pk_candidate PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE centaur.candidate OWNER TO postgres;
-- ddl-end --

-- object: centaur.flooded | type: TABLE --
-- DROP TABLE IF EXISTS centaur.flooded CASCADE;
CREATE TABLE centaur.flooded(
	id_flooded serial NOT NULL,
	id_node integer NOT NULL,
	id_link integer NOT NULL,
	volume_fraction numeric,
	CONSTRAINT pk_flooded PRIMARY KEY (id_flooded),
	CONSTRAINT unq_flooded UNIQUE (id_node,id_link)

);
-- ddl-end --
ALTER TABLE centaur.flooded OWNER TO postgres;
-- ddl-end --

-- object: fk_curve_parameter_curve | type: CONSTRAINT --
-- ALTER TABLE centaur.curve_parameter DROP CONSTRAINT IF EXISTS fk_curve_parameter_curve CASCADE;
ALTER TABLE centaur.curve_parameter ADD CONSTRAINT fk_curve_parameter_curve FOREIGN KEY (id_curve)
REFERENCES centaur.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_from | type: CONSTRAINT --
-- ALTER TABLE centaur.link DROP CONSTRAINT IF EXISTS fk_link_node_from CASCADE;
ALTER TABLE centaur.link ADD CONSTRAINT fk_link_node_from FOREIGN KEY (id_node_from)
REFERENCES centaur.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_to | type: CONSTRAINT --
-- ALTER TABLE centaur.link DROP CONSTRAINT IF EXISTS fk_link_node_to CASCADE;
ALTER TABLE centaur.link ADD CONSTRAINT fk_link_node_to FOREIGN KEY (id_node_to)
REFERENCES centaur.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_conduit_link | type: CONSTRAINT --
-- ALTER TABLE centaur.conduit DROP CONSTRAINT IF EXISTS fk_conduit_link CASCADE;
ALTER TABLE centaur.conduit ADD CONSTRAINT fk_conduit_link FOREIGN KEY (id_link)
REFERENCES centaur.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_link | type: CONSTRAINT --
-- ALTER TABLE centaur.pump DROP CONSTRAINT IF EXISTS fk_pump_link CASCADE;
ALTER TABLE centaur.pump ADD CONSTRAINT fk_pump_link FOREIGN KEY (id_link)
REFERENCES centaur.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_curve | type: CONSTRAINT --
-- ALTER TABLE centaur.pump DROP CONSTRAINT IF EXISTS fk_pump_curve CASCADE;
ALTER TABLE centaur.pump ADD CONSTRAINT fk_pump_curve FOREIGN KEY (id_curve)
REFERENCES centaur.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_junction_node | type: CONSTRAINT --
-- ALTER TABLE centaur.junction DROP CONSTRAINT IF EXISTS fk_junction_node CASCADE;
ALTER TABLE centaur.junction ADD CONSTRAINT fk_junction_node FOREIGN KEY (id_node)
REFERENCES centaur.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_weir_link | type: CONSTRAINT --
-- ALTER TABLE centaur.weir DROP CONSTRAINT IF EXISTS fk_weir_link CASCADE;
ALTER TABLE centaur.weir ADD CONSTRAINT fk_weir_link FOREIGN KEY (id_link)
REFERENCES centaur.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_outfall_node | type: CONSTRAINT --
-- ALTER TABLE centaur.outfall DROP CONSTRAINT IF EXISTS fk_outfall_node CASCADE;
ALTER TABLE centaur.outfall ADD CONSTRAINT fk_outfall_node FOREIGN KEY (id_node)
REFERENCES centaur.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_node | type: CONSTRAINT --
-- ALTER TABLE centaur.storage DROP CONSTRAINT IF EXISTS fk_storage_node CASCADE;
ALTER TABLE centaur.storage ADD CONSTRAINT fk_storage_node FOREIGN KEY (id_node)
REFERENCES centaur.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_curve | type: CONSTRAINT --
-- ALTER TABLE centaur.storage DROP CONSTRAINT IF EXISTS fk_storage_curve CASCADE;
ALTER TABLE centaur.storage ADD CONSTRAINT fk_storage_curve FOREIGN KEY (id_curve)
REFERENCES centaur.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_xsection_link | type: CONSTRAINT --
-- ALTER TABLE centaur.xsection DROP CONSTRAINT IF EXISTS fk_xsection_link CASCADE;
ALTER TABLE centaur.xsection ADD CONSTRAINT fk_xsection_link FOREIGN KEY (id_link)
REFERENCES centaur.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_raingage | type: CONSTRAINT --
-- ALTER TABLE centaur.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_raingage CASCADE;
ALTER TABLE centaur.subcatchment ADD CONSTRAINT fk_subcatchment_raingage FOREIGN KEY (id_raingage)
REFERENCES centaur.raingage (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_node | type: CONSTRAINT --
-- ALTER TABLE centaur.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_node CASCADE;
ALTER TABLE centaur.subcatchment ADD CONSTRAINT fk_subcatchment_node FOREIGN KEY (id_node_outlet)
REFERENCES centaur.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subarea_subcatchment | type: CONSTRAINT --
-- ALTER TABLE centaur.subarea DROP CONSTRAINT IF EXISTS fk_subarea_subcatchment CASCADE;
ALTER TABLE centaur.subarea ADD CONSTRAINT fk_subarea_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES centaur.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_coordinates_node | type: CONSTRAINT --
-- ALTER TABLE centaur.coordinates DROP CONSTRAINT IF EXISTS fk_coordinates_node CASCADE;
ALTER TABLE centaur.coordinates ADD CONSTRAINT fk_coordinates_node FOREIGN KEY (id_node)
REFERENCES centaur.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_polygon_subcatchment | type: CONSTRAINT --
-- ALTER TABLE centaur.polygon DROP CONSTRAINT IF EXISTS fk_polygon_subcatchment CASCADE;
ALTER TABLE centaur.polygon ADD CONSTRAINT fk_polygon_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES centaur.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_candidate_node | type: CONSTRAINT --
-- ALTER TABLE centaur.candidate DROP CONSTRAINT IF EXISTS fk_candidate_node CASCADE;
ALTER TABLE centaur.candidate ADD CONSTRAINT fk_candidate_node FOREIGN KEY (id_node)
REFERENCES centaur.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_link | type: CONSTRAINT --
-- ALTER TABLE centaur.flooded DROP CONSTRAINT IF EXISTS fk_flooded_link CASCADE;
ALTER TABLE centaur.flooded ADD CONSTRAINT fk_flooded_link FOREIGN KEY (id_link)
REFERENCES centaur.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_candidate | type: CONSTRAINT --
-- ALTER TABLE centaur.flooded DROP CONSTRAINT IF EXISTS fk_flooded_candidate CASCADE;
ALTER TABLE centaur.flooded ADD CONSTRAINT fk_flooded_candidate FOREIGN KEY (id_node)
REFERENCES centaur.candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --


