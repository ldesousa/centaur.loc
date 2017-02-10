-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.8.2-alpha1
-- PostgreSQL version: 9.4
-- Project Site: pgmodeler.com.br
-- Model Author: ---


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: alcantara | type: DATABASE --
-- -- DROP DATABASE IF EXISTS alcantara;
-- CREATE DATABASE alcantara
-- ;
-- -- ddl-end --
-- 

-- object: alcantara | type: SCHEMA --
-- DROP SCHEMA IF EXISTS alcantara CASCADE;
CREATE SCHEMA alcantara;
-- ddl-end --
ALTER SCHEMA alcantara OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,alcantara;
-- ddl-end --

-- object: alcantara.curve | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.curve CASCADE;
CREATE TABLE alcantara.curve(
	id integer NOT NULL,
	name varchar,
	type varchar,
	CONSTRAINT pk_curve PRIMARY KEY (id),
	CONSTRAINT unq_curve UNIQUE (name)

);
-- ddl-end --
ALTER TABLE alcantara.curve OWNER TO postgres;
-- ddl-end --

-- object: alcantara.curve_parameter | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.curve_parameter CASCADE;
CREATE TABLE alcantara.curve_parameter(
	id serial NOT NULL,
	x numeric,
	y numeric,
	id_curve integer,
	CONSTRAINT pk_curve_parameter PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE alcantara.curve_parameter OWNER TO postgres;
-- ddl-end --

-- object: alcantara.node | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.node CASCADE;
CREATE TABLE alcantara.node(
	id serial NOT NULL,
	elevation numeric,
	name varchar,
	taken boolean,
	CONSTRAINT pk_node PRIMARY KEY (id),
	CONSTRAINT unq_node UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN alcantara.node.taken IS 'True if this node is already being used by a gate or flooded by one.';
-- ddl-end --
ALTER TABLE alcantara.node OWNER TO postgres;
-- ddl-end --

-- object: alcantara.link | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.link CASCADE;
CREATE TABLE alcantara.link(
	id serial NOT NULL,
	name varchar,
	id_node_from integer,
	id_node_to integer,
	CONSTRAINT pk_link PRIMARY KEY (id),
	CONSTRAINT unq_link_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE alcantara.link OWNER TO postgres;
-- ddl-end --

-- object: alcantara.conduit | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.conduit CASCADE;
CREATE TABLE alcantara.conduit(
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
COMMENT ON COLUMN alcantara.conduit.length IS 'This can be calculated from the junctions coordinates';
-- ddl-end --
ALTER TABLE alcantara.conduit OWNER TO postgres;
-- ddl-end --

-- object: alcantara.pump | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.pump CASCADE;
CREATE TABLE alcantara.pump(
	id_link integer NOT NULL,
	id_curve integer,
	status varchar,
	startup numeric,
	shutoff numeric,
	CONSTRAINT pk_pump PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE alcantara.pump OWNER TO postgres;
-- ddl-end --

-- object: alcantara.junction | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.junction CASCADE;
CREATE TABLE alcantara.junction(
	id_node integer NOT NULL,
	max_depth numeric,
	init_depth numeric,
	sur_depth numeric,
	aponded numeric,
	CONSTRAINT pk_junction PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE alcantara.junction OWNER TO postgres;
-- ddl-end --

-- object: alcantara.weir | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.weir CASCADE;
CREATE TABLE alcantara.weir(
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
ALTER TABLE alcantara.weir OWNER TO postgres;
-- ddl-end --

-- object: alcantara.outfall | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.outfall CASCADE;
CREATE TABLE alcantara.outfall(
	id_node integer NOT NULL,
	type varchar,
	stage_date varchar,
	gated boolean,
	route_to varchar,
	CONSTRAINT pk_outfall PRIMARY KEY (id_node)

);
-- ddl-end --
COMMENT ON TABLE alcantara.outfall IS 'This is a special kind of junction';
-- ddl-end --
ALTER TABLE alcantara.outfall OWNER TO postgres;
-- ddl-end --

-- object: alcantara.storage | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.storage CASCADE;
CREATE TABLE alcantara.storage(
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
ALTER TABLE alcantara.storage OWNER TO postgres;
-- ddl-end --

-- object: alcantara.xsection | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.xsection CASCADE;
CREATE TABLE alcantara.xsection(
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
ALTER TABLE alcantara.xsection OWNER TO postgres;
-- ddl-end --

-- object: alcantara.raingage | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.raingage CASCADE;
CREATE TABLE alcantara.raingage(
	id integer NOT NULL,
	format varchar,
	"interval" varchar,
	scf numeric,
	source varchar,
	CONSTRAINT pk_raingage PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE alcantara.raingage OWNER TO postgres;
-- ddl-end --

-- object: alcantara.subcatchment | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.subcatchment CASCADE;
CREATE TABLE alcantara.subcatchment(
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
COMMENT ON COLUMN alcantara.subcatchment.imperv IS 'This field is a percentage (<= 100)';
-- ddl-end --
COMMENT ON COLUMN alcantara.subcatchment.slope IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE alcantara.subcatchment OWNER TO postgres;
-- ddl-end --

-- object: alcantara.subarea | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.subarea CASCADE;
CREATE TABLE alcantara.subarea(
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
COMMENT ON COLUMN alcantara.subarea.pct_zero IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE alcantara.subarea OWNER TO postgres;
-- ddl-end --

-- object: alcantara.coordinates | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.coordinates CASCADE;
CREATE TABLE alcantara.coordinates(
	id_node integer NOT NULL,
	x numeric,
	y numeric,
	CONSTRAINT pk_coordinates PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE alcantara.coordinates OWNER TO postgres;
-- ddl-end --

-- object: alcantara.polygon | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.polygon CASCADE;
CREATE TABLE alcantara.polygon(
	id serial NOT NULL,
	id_subcatchment integer,
	x numeric,
	y numeric,
	CONSTRAINT pk_polygon PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE alcantara.polygon OWNER TO postgres;
-- ddl-end --

-- object: alcantara.candidate | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.candidate CASCADE;
CREATE TABLE alcantara.candidate(
	id_node integer NOT NULL,
	outflow_elevation numeric NOT NULL,
	volume numeric,
	CONSTRAINT pk_candidate PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE alcantara.candidate OWNER TO postgres;
-- ddl-end --

-- object: alcantara.flooded | type: TABLE --
-- DROP TABLE IF EXISTS alcantara.flooded CASCADE;
CREATE TABLE alcantara.flooded(
	id_flooded serial NOT NULL,
	id_node integer NOT NULL,
	id_link integer NOT NULL,
	volume_fraction numeric,
	CONSTRAINT pk_flooded PRIMARY KEY (id_flooded),
	CONSTRAINT unq_flooded UNIQUE (id_node,id_link)

);
-- ddl-end --
ALTER TABLE alcantara.flooded OWNER TO postgres;
-- ddl-end --

-- object: fk_curve_parameter_curve | type: CONSTRAINT --
-- ALTER TABLE alcantara.curve_parameter DROP CONSTRAINT IF EXISTS fk_curve_parameter_curve CASCADE;
ALTER TABLE alcantara.curve_parameter ADD CONSTRAINT fk_curve_parameter_curve FOREIGN KEY (id_curve)
REFERENCES alcantara.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_from | type: CONSTRAINT --
-- ALTER TABLE alcantara.link DROP CONSTRAINT IF EXISTS fk_link_node_from CASCADE;
ALTER TABLE alcantara.link ADD CONSTRAINT fk_link_node_from FOREIGN KEY (id_node_from)
REFERENCES alcantara.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_to | type: CONSTRAINT --
-- ALTER TABLE alcantara.link DROP CONSTRAINT IF EXISTS fk_link_node_to CASCADE;
ALTER TABLE alcantara.link ADD CONSTRAINT fk_link_node_to FOREIGN KEY (id_node_to)
REFERENCES alcantara.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_conduit_link | type: CONSTRAINT --
-- ALTER TABLE alcantara.conduit DROP CONSTRAINT IF EXISTS fk_conduit_link CASCADE;
ALTER TABLE alcantara.conduit ADD CONSTRAINT fk_conduit_link FOREIGN KEY (id_link)
REFERENCES alcantara.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_link | type: CONSTRAINT --
-- ALTER TABLE alcantara.pump DROP CONSTRAINT IF EXISTS fk_pump_link CASCADE;
ALTER TABLE alcantara.pump ADD CONSTRAINT fk_pump_link FOREIGN KEY (id_link)
REFERENCES alcantara.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_curve | type: CONSTRAINT --
-- ALTER TABLE alcantara.pump DROP CONSTRAINT IF EXISTS fk_pump_curve CASCADE;
ALTER TABLE alcantara.pump ADD CONSTRAINT fk_pump_curve FOREIGN KEY (id_curve)
REFERENCES alcantara.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_junction_node | type: CONSTRAINT --
-- ALTER TABLE alcantara.junction DROP CONSTRAINT IF EXISTS fk_junction_node CASCADE;
ALTER TABLE alcantara.junction ADD CONSTRAINT fk_junction_node FOREIGN KEY (id_node)
REFERENCES alcantara.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_weir_link | type: CONSTRAINT --
-- ALTER TABLE alcantara.weir DROP CONSTRAINT IF EXISTS fk_weir_link CASCADE;
ALTER TABLE alcantara.weir ADD CONSTRAINT fk_weir_link FOREIGN KEY (id_link)
REFERENCES alcantara.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_outfall_node | type: CONSTRAINT --
-- ALTER TABLE alcantara.outfall DROP CONSTRAINT IF EXISTS fk_outfall_node CASCADE;
ALTER TABLE alcantara.outfall ADD CONSTRAINT fk_outfall_node FOREIGN KEY (id_node)
REFERENCES alcantara.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_node | type: CONSTRAINT --
-- ALTER TABLE alcantara.storage DROP CONSTRAINT IF EXISTS fk_storage_node CASCADE;
ALTER TABLE alcantara.storage ADD CONSTRAINT fk_storage_node FOREIGN KEY (id_node)
REFERENCES alcantara.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_curve | type: CONSTRAINT --
-- ALTER TABLE alcantara.storage DROP CONSTRAINT IF EXISTS fk_storage_curve CASCADE;
ALTER TABLE alcantara.storage ADD CONSTRAINT fk_storage_curve FOREIGN KEY (id_curve)
REFERENCES alcantara.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_xsection_link | type: CONSTRAINT --
-- ALTER TABLE alcantara.xsection DROP CONSTRAINT IF EXISTS fk_xsection_link CASCADE;
ALTER TABLE alcantara.xsection ADD CONSTRAINT fk_xsection_link FOREIGN KEY (id_link)
REFERENCES alcantara.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_raingage | type: CONSTRAINT --
-- ALTER TABLE alcantara.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_raingage CASCADE;
ALTER TABLE alcantara.subcatchment ADD CONSTRAINT fk_subcatchment_raingage FOREIGN KEY (id_raingage)
REFERENCES alcantara.raingage (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_node | type: CONSTRAINT --
-- ALTER TABLE alcantara.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_node CASCADE;
ALTER TABLE alcantara.subcatchment ADD CONSTRAINT fk_subcatchment_node FOREIGN KEY (id_node_outlet)
REFERENCES alcantara.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subarea_subcatchment | type: CONSTRAINT --
-- ALTER TABLE alcantara.subarea DROP CONSTRAINT IF EXISTS fk_subarea_subcatchment CASCADE;
ALTER TABLE alcantara.subarea ADD CONSTRAINT fk_subarea_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES alcantara.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_coordinates_node | type: CONSTRAINT --
-- ALTER TABLE alcantara.coordinates DROP CONSTRAINT IF EXISTS fk_coordinates_node CASCADE;
ALTER TABLE alcantara.coordinates ADD CONSTRAINT fk_coordinates_node FOREIGN KEY (id_node)
REFERENCES alcantara.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_polygon_subcatchment | type: CONSTRAINT --
-- ALTER TABLE alcantara.polygon DROP CONSTRAINT IF EXISTS fk_polygon_subcatchment CASCADE;
ALTER TABLE alcantara.polygon ADD CONSTRAINT fk_polygon_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES alcantara.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_candidate_node | type: CONSTRAINT --
-- ALTER TABLE alcantara.candidate DROP CONSTRAINT IF EXISTS fk_candidate_node CASCADE;
ALTER TABLE alcantara.candidate ADD CONSTRAINT fk_candidate_node FOREIGN KEY (id_node)
REFERENCES alcantara.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_link | type: CONSTRAINT --
-- ALTER TABLE alcantara.flooded DROP CONSTRAINT IF EXISTS fk_flooded_link CASCADE;
ALTER TABLE alcantara.flooded ADD CONSTRAINT fk_flooded_link FOREIGN KEY (id_link)
REFERENCES alcantara.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_candidate | type: CONSTRAINT --
-- ALTER TABLE alcantara.flooded DROP CONSTRAINT IF EXISTS fk_flooded_candidate CASCADE;
ALTER TABLE alcantara.flooded ADD CONSTRAINT fk_flooded_candidate FOREIGN KEY (id_node)
REFERENCES alcantara.candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --


