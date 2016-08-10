-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.8.2-alpha1
-- PostgreSQL version: 9.4
-- Project Site: pgmodeler.com.br
-- Model Author: ---


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: luzern | type: DATABASE --
-- -- DROP DATABASE IF EXISTS luzern;
-- CREATE DATABASE luzern
-- ;
-- -- ddl-end --
-- 

-- object: luzern | type: SCHEMA --
-- DROP SCHEMA IF EXISTS luzern CASCADE;
CREATE SCHEMA luzern;
-- ddl-end --
ALTER SCHEMA luzern OWNER TO desouslu;
-- ddl-end --

SET search_path TO pg_catalog,public,luzern;
-- ddl-end --

-- object: luzern.curve | type: TABLE --
-- DROP TABLE IF EXISTS luzern.curve CASCADE;
CREATE TABLE luzern.curve(
	id integer NOT NULL,
	name varchar,
	type varchar,
	CONSTRAINT pk_curve PRIMARY KEY (id),
	CONSTRAINT unq_curve UNIQUE (name)

);
-- ddl-end --
ALTER TABLE luzern.curve OWNER TO desouslu;
-- ddl-end --

-- object: luzern.curve_parameter | type: TABLE --
-- DROP TABLE IF EXISTS luzern.curve_parameter CASCADE;
CREATE TABLE luzern.curve_parameter(
	id serial NOT NULL,
	x numeric,
	y numeric,
	id_curve integer,
	CONSTRAINT pk_curve_parameter PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE luzern.curve_parameter OWNER TO desouslu;
-- ddl-end --

-- object: luzern.node | type: TABLE --
-- DROP TABLE IF EXISTS luzern.node CASCADE;
CREATE TABLE luzern.node(
	id integer NOT NULL,
	elevation numeric,
	name varchar,
	taken boolean,
	CONSTRAINT pk_node PRIMARY KEY (id),
	CONSTRAINT unq_node UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN luzern.node.taken IS 'True if this node is already being used by a gate or flooded by one.';
-- ddl-end --
ALTER TABLE luzern.node OWNER TO desouslu;
-- ddl-end --

-- object: luzern.link | type: TABLE --
-- DROP TABLE IF EXISTS luzern.link CASCADE;
CREATE TABLE luzern.link(
	id serial NOT NULL,
	name varchar,
	id_node_from integer,
	id_node_to integer,
	CONSTRAINT pk_link PRIMARY KEY (id),
	CONSTRAINT unq_link_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE luzern.link OWNER TO desouslu;
-- ddl-end --

-- object: luzern.conduit | type: TABLE --
-- DROP TABLE IF EXISTS luzern.conduit CASCADE;
CREATE TABLE luzern.conduit(
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
COMMENT ON COLUMN luzern.conduit.length IS 'This can be calculated from the junctions coordinates';
-- ddl-end --
ALTER TABLE luzern.conduit OWNER TO desouslu;
-- ddl-end --

-- object: luzern.pump | type: TABLE --
-- DROP TABLE IF EXISTS luzern.pump CASCADE;
CREATE TABLE luzern.pump(
	id_link integer NOT NULL,
	id_curve integer,
	status varchar,
	startup numeric,
	shutoff numeric,
	CONSTRAINT pk_pump PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE luzern.pump OWNER TO desouslu;
-- ddl-end --

-- object: luzern.junction | type: TABLE --
-- DROP TABLE IF EXISTS luzern.junction CASCADE;
CREATE TABLE luzern.junction(
	id_node integer NOT NULL,
	max_depth numeric,
	init_depth numeric,
	sur_depth numeric,
	aponded numeric,
	CONSTRAINT pk_junction PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE luzern.junction OWNER TO desouslu;
-- ddl-end --

-- object: luzern.weir | type: TABLE --
-- DROP TABLE IF EXISTS luzern.weir CASCADE;
CREATE TABLE luzern.weir(
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
ALTER TABLE luzern.weir OWNER TO desouslu;
-- ddl-end --

-- object: luzern.outfall | type: TABLE --
-- DROP TABLE IF EXISTS luzern.outfall CASCADE;
CREATE TABLE luzern.outfall(
	id_node integer NOT NULL,
	type varchar,
	stage_date varchar,
	gated boolean,
	route_to varchar,
	CONSTRAINT pk_outfall PRIMARY KEY (id_node)

);
-- ddl-end --
COMMENT ON TABLE luzern.outfall IS 'This is a special kind of junction';
-- ddl-end --
ALTER TABLE luzern.outfall OWNER TO desouslu;
-- ddl-end --

-- object: luzern.storage | type: TABLE --
-- DROP TABLE IF EXISTS luzern.storage CASCADE;
CREATE TABLE luzern.storage(
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
ALTER TABLE luzern.storage OWNER TO desouslu;
-- ddl-end --

-- object: luzern.xsection | type: TABLE --
-- DROP TABLE IF EXISTS luzern.xsection CASCADE;
CREATE TABLE luzern.xsection(
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
ALTER TABLE luzern.xsection OWNER TO desouslu;
-- ddl-end --

-- object: luzern.raingage | type: TABLE --
-- DROP TABLE IF EXISTS luzern.raingage CASCADE;
CREATE TABLE luzern.raingage(
	id integer NOT NULL,
	format varchar,
	"interval" varchar,
	scf numeric,
	source varchar,
	CONSTRAINT pk_raingage PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE luzern.raingage OWNER TO desouslu;
-- ddl-end --

-- object: luzern.subcatchment | type: TABLE --
-- DROP TABLE IF EXISTS luzern.subcatchment CASCADE;
CREATE TABLE luzern.subcatchment(
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
COMMENT ON COLUMN luzern.subcatchment.imperv IS 'This field is a percentage (<= 100)';
-- ddl-end --
COMMENT ON COLUMN luzern.subcatchment.slope IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE luzern.subcatchment OWNER TO desouslu;
-- ddl-end --

-- object: luzern.subarea | type: TABLE --
-- DROP TABLE IF EXISTS luzern.subarea CASCADE;
CREATE TABLE luzern.subarea(
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
COMMENT ON COLUMN luzern.subarea.pct_zero IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE luzern.subarea OWNER TO desouslu;
-- ddl-end --

-- object: luzern.coordinates | type: TABLE --
-- DROP TABLE IF EXISTS luzern.coordinates CASCADE;
CREATE TABLE luzern.coordinates(
	id_node integer NOT NULL,
	x numeric,
	y numeric,
	CONSTRAINT pk_coordinates PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE luzern.coordinates OWNER TO desouslu;
-- ddl-end --

-- object: luzern.polygon | type: TABLE --
-- DROP TABLE IF EXISTS luzern.polygon CASCADE;
CREATE TABLE luzern.polygon(
	id serial NOT NULL,
	id_subcatchment integer,
	x numeric,
	y numeric,
	CONSTRAINT pk_polygon PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE luzern.polygon OWNER TO desouslu;
-- ddl-end --

-- object: luzern.candidate | type: TABLE --
-- DROP TABLE IF EXISTS luzern.candidate CASCADE;
CREATE TABLE luzern.candidate(
	id_node integer NOT NULL,
	outflow_elevation numeric NOT NULL,
	served_area numeric,
	volume numeric,
	CONSTRAINT pk_candidate PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE luzern.candidate OWNER TO desouslu;
-- ddl-end --

-- object: luzern.flooded | type: TABLE --
-- DROP TABLE IF EXISTS luzern.flooded CASCADE;
CREATE TABLE luzern.flooded(
	id_flooded serial NOT NULL,
	id_node integer NOT NULL,
	id_link integer NOT NULL,
	volume_fraction numeric,
	CONSTRAINT pk_flooded PRIMARY KEY (id_flooded),
	CONSTRAINT unq_flooded UNIQUE (id_node,id_link)

);
-- ddl-end --
ALTER TABLE luzern.flooded OWNER TO desouslu;
-- ddl-end --

-- object: luzern.contribution | type: TABLE --
-- DROP TABLE IF EXISTS luzern.contribution CASCADE;
CREATE TABLE luzern.contribution(
	id serial NOT NULL,
	id_node integer NOT NULL,
	id_subcatchment integer NOT NULL,
	value numeric NOT NULL,
	CONSTRAINT pk_contribution PRIMARY KEY (id),
	CONSTRAINT unq_contribution UNIQUE (id_node,id_subcatchment)

);
-- ddl-end --
ALTER TABLE luzern.contribution OWNER TO desouslu;
-- ddl-end --

-- object: fk_curve_parameter_curve | type: CONSTRAINT --
-- ALTER TABLE luzern.curve_parameter DROP CONSTRAINT IF EXISTS fk_curve_parameter_curve CASCADE;
ALTER TABLE luzern.curve_parameter ADD CONSTRAINT fk_curve_parameter_curve FOREIGN KEY (id_curve)
REFERENCES luzern.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_from | type: CONSTRAINT --
-- ALTER TABLE luzern.link DROP CONSTRAINT IF EXISTS fk_link_node_from CASCADE;
ALTER TABLE luzern.link ADD CONSTRAINT fk_link_node_from FOREIGN KEY (id_node_from)
REFERENCES luzern.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_to | type: CONSTRAINT --
-- ALTER TABLE luzern.link DROP CONSTRAINT IF EXISTS fk_link_node_to CASCADE;
ALTER TABLE luzern.link ADD CONSTRAINT fk_link_node_to FOREIGN KEY (id_node_to)
REFERENCES luzern.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_conduit_link | type: CONSTRAINT --
-- ALTER TABLE luzern.conduit DROP CONSTRAINT IF EXISTS fk_conduit_link CASCADE;
ALTER TABLE luzern.conduit ADD CONSTRAINT fk_conduit_link FOREIGN KEY (id_link)
REFERENCES luzern.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_link | type: CONSTRAINT --
-- ALTER TABLE luzern.pump DROP CONSTRAINT IF EXISTS fk_pump_link CASCADE;
ALTER TABLE luzern.pump ADD CONSTRAINT fk_pump_link FOREIGN KEY (id_link)
REFERENCES luzern.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_curve | type: CONSTRAINT --
-- ALTER TABLE luzern.pump DROP CONSTRAINT IF EXISTS fk_pump_curve CASCADE;
ALTER TABLE luzern.pump ADD CONSTRAINT fk_pump_curve FOREIGN KEY (id_curve)
REFERENCES luzern.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_junction_node | type: CONSTRAINT --
-- ALTER TABLE luzern.junction DROP CONSTRAINT IF EXISTS fk_junction_node CASCADE;
ALTER TABLE luzern.junction ADD CONSTRAINT fk_junction_node FOREIGN KEY (id_node)
REFERENCES luzern.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_weir_link | type: CONSTRAINT --
-- ALTER TABLE luzern.weir DROP CONSTRAINT IF EXISTS fk_weir_link CASCADE;
ALTER TABLE luzern.weir ADD CONSTRAINT fk_weir_link FOREIGN KEY (id_link)
REFERENCES luzern.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_outfall_node | type: CONSTRAINT --
-- ALTER TABLE luzern.outfall DROP CONSTRAINT IF EXISTS fk_outfall_node CASCADE;
ALTER TABLE luzern.outfall ADD CONSTRAINT fk_outfall_node FOREIGN KEY (id_node)
REFERENCES luzern.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_node | type: CONSTRAINT --
-- ALTER TABLE luzern.storage DROP CONSTRAINT IF EXISTS fk_storage_node CASCADE;
ALTER TABLE luzern.storage ADD CONSTRAINT fk_storage_node FOREIGN KEY (id_node)
REFERENCES luzern.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_curve | type: CONSTRAINT --
-- ALTER TABLE luzern.storage DROP CONSTRAINT IF EXISTS fk_storage_curve CASCADE;
ALTER TABLE luzern.storage ADD CONSTRAINT fk_storage_curve FOREIGN KEY (id_curve)
REFERENCES luzern.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_xsection_link | type: CONSTRAINT --
-- ALTER TABLE luzern.xsection DROP CONSTRAINT IF EXISTS fk_xsection_link CASCADE;
ALTER TABLE luzern.xsection ADD CONSTRAINT fk_xsection_link FOREIGN KEY (id_link)
REFERENCES luzern.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_raingage | type: CONSTRAINT --
-- ALTER TABLE luzern.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_raingage CASCADE;
ALTER TABLE luzern.subcatchment ADD CONSTRAINT fk_subcatchment_raingage FOREIGN KEY (id_raingage)
REFERENCES luzern.raingage (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_node | type: CONSTRAINT --
-- ALTER TABLE luzern.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_node CASCADE;
ALTER TABLE luzern.subcatchment ADD CONSTRAINT fk_subcatchment_node FOREIGN KEY (id_node_outlet)
REFERENCES luzern.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subarea_subcatchment | type: CONSTRAINT --
-- ALTER TABLE luzern.subarea DROP CONSTRAINT IF EXISTS fk_subarea_subcatchment CASCADE;
ALTER TABLE luzern.subarea ADD CONSTRAINT fk_subarea_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES luzern.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_coordinates_node | type: CONSTRAINT --
-- ALTER TABLE luzern.coordinates DROP CONSTRAINT IF EXISTS fk_coordinates_node CASCADE;
ALTER TABLE luzern.coordinates ADD CONSTRAINT fk_coordinates_node FOREIGN KEY (id_node)
REFERENCES luzern.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_polygon_subcatchment | type: CONSTRAINT --
-- ALTER TABLE luzern.polygon DROP CONSTRAINT IF EXISTS fk_polygon_subcatchment CASCADE;
ALTER TABLE luzern.polygon ADD CONSTRAINT fk_polygon_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES luzern.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_candidate_node | type: CONSTRAINT --
-- ALTER TABLE luzern.candidate DROP CONSTRAINT IF EXISTS fk_candidate_node CASCADE;
ALTER TABLE luzern.candidate ADD CONSTRAINT fk_candidate_node FOREIGN KEY (id_node)
REFERENCES luzern.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_link | type: CONSTRAINT --
-- ALTER TABLE luzern.flooded DROP CONSTRAINT IF EXISTS fk_flooded_link CASCADE;
ALTER TABLE luzern.flooded ADD CONSTRAINT fk_flooded_link FOREIGN KEY (id_link)
REFERENCES luzern.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_candidate | type: CONSTRAINT --
-- ALTER TABLE luzern.flooded DROP CONSTRAINT IF EXISTS fk_flooded_candidate CASCADE;
ALTER TABLE luzern.flooded ADD CONSTRAINT fk_flooded_candidate FOREIGN KEY (id_node)
REFERENCES luzern.candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_contribution_candidate | type: CONSTRAINT --
-- ALTER TABLE luzern.contribution DROP CONSTRAINT IF EXISTS fk_contribution_candidate CASCADE;
ALTER TABLE luzern.contribution ADD CONSTRAINT fk_contribution_candidate FOREIGN KEY (id_node)
REFERENCES luzern.candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_contribution_subcatchment | type: CONSTRAINT --
-- ALTER TABLE luzern.contribution DROP CONSTRAINT IF EXISTS fk_contribution_subcatchment CASCADE;
ALTER TABLE luzern.contribution ADD CONSTRAINT fk_contribution_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES luzern.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


