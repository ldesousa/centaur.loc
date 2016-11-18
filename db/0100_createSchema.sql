-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.8.2-alpha1
-- PostgreSQL version: 9.4
-- Project Site: pgmodeler.com.br
-- Model Author: ---


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: coimbra | type: DATABASE --
-- -- DROP DATABASE IF EXISTS coimbra;
-- CREATE DATABASE coimbra
-- ;
-- -- ddl-end --
-- 

-- object: coimbra | type: SCHEMA --
-- DROP SCHEMA IF EXISTS coimbra CASCADE;
CREATE SCHEMA coimbra;
-- ddl-end --
ALTER SCHEMA coimbra OWNER TO desouslu;
-- ddl-end --

SET search_path TO pg_catalog,public,coimbra;
-- ddl-end --

-- object: coimbra.curve | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.curve CASCADE;
CREATE TABLE coimbra.curve(
	id integer NOT NULL,
	name varchar,
	type varchar,
	CONSTRAINT pk_curve PRIMARY KEY (id),
	CONSTRAINT unq_curve UNIQUE (name)

);
-- ddl-end --
ALTER TABLE coimbra.curve OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.curve_parameter | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.curve_parameter CASCADE;
CREATE TABLE coimbra.curve_parameter(
	id serial NOT NULL,
	x numeric,
	y numeric,
	id_curve integer,
	CONSTRAINT pk_curve_parameter PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE coimbra.curve_parameter OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.node | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.node CASCADE;
CREATE TABLE coimbra.node(
	id integer NOT NULL,
	elevation numeric,
	name varchar,
	taken boolean,
	CONSTRAINT pk_node PRIMARY KEY (id),
	CONSTRAINT unq_node UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN coimbra.node.taken IS 'True if this node is already being used by a gate or flooded by one.';
-- ddl-end --
ALTER TABLE coimbra.node OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.link | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.link CASCADE;
CREATE TABLE coimbra.link(
	id serial NOT NULL,
	name varchar,
	id_node_from integer,
	id_node_to integer,
	CONSTRAINT pk_link PRIMARY KEY (id),
	CONSTRAINT unq_link_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE coimbra.link OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.conduit | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.conduit CASCADE;
CREATE TABLE coimbra.conduit(
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
COMMENT ON COLUMN coimbra.conduit.length IS 'This can be calculated from the junctions coordinates';
-- ddl-end --
ALTER TABLE coimbra.conduit OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.pump | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.pump CASCADE;
CREATE TABLE coimbra.pump(
	id_link integer NOT NULL,
	id_curve integer,
	status varchar,
	startup numeric,
	shutoff numeric,
	CONSTRAINT pk_pump PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE coimbra.pump OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.junction | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.junction CASCADE;
CREATE TABLE coimbra.junction(
	id_node integer NOT NULL,
	max_depth numeric,
	init_depth numeric,
	sur_depth numeric,
	aponded numeric,
	CONSTRAINT pk_junction PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE coimbra.junction OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.weir | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.weir CASCADE;
CREATE TABLE coimbra.weir(
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
ALTER TABLE coimbra.weir OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.outfall | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.outfall CASCADE;
CREATE TABLE coimbra.outfall(
	id_node integer NOT NULL,
	type varchar,
	stage_date varchar,
	gated boolean,
	route_to varchar,
	CONSTRAINT pk_outfall PRIMARY KEY (id_node)

);
-- ddl-end --
COMMENT ON TABLE coimbra.outfall IS 'This is a special kind of junction';
-- ddl-end --
ALTER TABLE coimbra.outfall OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.storage | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.storage CASCADE;
CREATE TABLE coimbra.storage(
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
ALTER TABLE coimbra.storage OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.xsection | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.xsection CASCADE;
CREATE TABLE coimbra.xsection(
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
ALTER TABLE coimbra.xsection OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.raingage | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.raingage CASCADE;
CREATE TABLE coimbra.raingage(
	id integer NOT NULL,
	format varchar,
	"interval" varchar,
	scf numeric,
	source varchar,
	CONSTRAINT pk_raingage PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE coimbra.raingage OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.subcatchment | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.subcatchment CASCADE;
CREATE TABLE coimbra.subcatchment(
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
COMMENT ON COLUMN coimbra.subcatchment.imperv IS 'This field is a percentage (<= 100)';
-- ddl-end --
COMMENT ON COLUMN coimbra.subcatchment.slope IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE coimbra.subcatchment OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.subarea | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.subarea CASCADE;
CREATE TABLE coimbra.subarea(
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
COMMENT ON COLUMN coimbra.subarea.pct_zero IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE coimbra.subarea OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.coordinates | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.coordinates CASCADE;
CREATE TABLE coimbra.coordinates(
	id_node integer NOT NULL,
	x numeric,
	y numeric,
	CONSTRAINT pk_coordinates PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE coimbra.coordinates OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.polygon | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.polygon CASCADE;
CREATE TABLE coimbra.polygon(
	id serial NOT NULL,
	id_subcatchment integer,
	x numeric,
	y numeric,
	CONSTRAINT pk_polygon PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE coimbra.polygon OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.candidate | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.candidate CASCADE;
CREATE TABLE coimbra.candidate(
	id_node integer NOT NULL,
	outflow_elevation numeric NOT NULL,
	served_area numeric,
	volume numeric,
	CONSTRAINT pk_candidate PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE coimbra.candidate OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.flooded | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.flooded CASCADE;
CREATE TABLE coimbra.flooded(
	id_flooded serial NOT NULL,
	id_node integer NOT NULL,
	id_link integer NOT NULL,
	volume_fraction numeric,
	CONSTRAINT pk_flooded PRIMARY KEY (id_flooded),
	CONSTRAINT unq_flooded UNIQUE (id_node,id_link)

);
-- ddl-end --
ALTER TABLE coimbra.flooded OWNER TO desouslu;
-- ddl-end --

-- object: coimbra.contribution | type: TABLE --
-- DROP TABLE IF EXISTS coimbra.contribution CASCADE;
CREATE TABLE coimbra.contribution(
	id serial NOT NULL,
	id_node integer NOT NULL,
	id_subcatchment integer NOT NULL,
	value numeric NOT NULL,
	CONSTRAINT pk_contribution PRIMARY KEY (id),
	CONSTRAINT unq_contribution UNIQUE (id_node,id_subcatchment)

);
-- ddl-end --
ALTER TABLE coimbra.contribution OWNER TO desouslu;
-- ddl-end --

-- object: fk_curve_parameter_curve | type: CONSTRAINT --
-- ALTER TABLE coimbra.curve_parameter DROP CONSTRAINT IF EXISTS fk_curve_parameter_curve CASCADE;
ALTER TABLE coimbra.curve_parameter ADD CONSTRAINT fk_curve_parameter_curve FOREIGN KEY (id_curve)
REFERENCES coimbra.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_from | type: CONSTRAINT --
-- ALTER TABLE coimbra.link DROP CONSTRAINT IF EXISTS fk_link_node_from CASCADE;
ALTER TABLE coimbra.link ADD CONSTRAINT fk_link_node_from FOREIGN KEY (id_node_from)
REFERENCES coimbra.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_to | type: CONSTRAINT --
-- ALTER TABLE coimbra.link DROP CONSTRAINT IF EXISTS fk_link_node_to CASCADE;
ALTER TABLE coimbra.link ADD CONSTRAINT fk_link_node_to FOREIGN KEY (id_node_to)
REFERENCES coimbra.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_conduit_link | type: CONSTRAINT --
-- ALTER TABLE coimbra.conduit DROP CONSTRAINT IF EXISTS fk_conduit_link CASCADE;
ALTER TABLE coimbra.conduit ADD CONSTRAINT fk_conduit_link FOREIGN KEY (id_link)
REFERENCES coimbra.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_link | type: CONSTRAINT --
-- ALTER TABLE coimbra.pump DROP CONSTRAINT IF EXISTS fk_pump_link CASCADE;
ALTER TABLE coimbra.pump ADD CONSTRAINT fk_pump_link FOREIGN KEY (id_link)
REFERENCES coimbra.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_curve | type: CONSTRAINT --
-- ALTER TABLE coimbra.pump DROP CONSTRAINT IF EXISTS fk_pump_curve CASCADE;
ALTER TABLE coimbra.pump ADD CONSTRAINT fk_pump_curve FOREIGN KEY (id_curve)
REFERENCES coimbra.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_junction_node | type: CONSTRAINT --
-- ALTER TABLE coimbra.junction DROP CONSTRAINT IF EXISTS fk_junction_node CASCADE;
ALTER TABLE coimbra.junction ADD CONSTRAINT fk_junction_node FOREIGN KEY (id_node)
REFERENCES coimbra.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_weir_link | type: CONSTRAINT --
-- ALTER TABLE coimbra.weir DROP CONSTRAINT IF EXISTS fk_weir_link CASCADE;
ALTER TABLE coimbra.weir ADD CONSTRAINT fk_weir_link FOREIGN KEY (id_link)
REFERENCES coimbra.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_outfall_node | type: CONSTRAINT --
-- ALTER TABLE coimbra.outfall DROP CONSTRAINT IF EXISTS fk_outfall_node CASCADE;
ALTER TABLE coimbra.outfall ADD CONSTRAINT fk_outfall_node FOREIGN KEY (id_node)
REFERENCES coimbra.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_node | type: CONSTRAINT --
-- ALTER TABLE coimbra.storage DROP CONSTRAINT IF EXISTS fk_storage_node CASCADE;
ALTER TABLE coimbra.storage ADD CONSTRAINT fk_storage_node FOREIGN KEY (id_node)
REFERENCES coimbra.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_curve | type: CONSTRAINT --
-- ALTER TABLE coimbra.storage DROP CONSTRAINT IF EXISTS fk_storage_curve CASCADE;
ALTER TABLE coimbra.storage ADD CONSTRAINT fk_storage_curve FOREIGN KEY (id_curve)
REFERENCES coimbra.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_xsection_link | type: CONSTRAINT --
-- ALTER TABLE coimbra.xsection DROP CONSTRAINT IF EXISTS fk_xsection_link CASCADE;
ALTER TABLE coimbra.xsection ADD CONSTRAINT fk_xsection_link FOREIGN KEY (id_link)
REFERENCES coimbra.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_raingage | type: CONSTRAINT --
-- ALTER TABLE coimbra.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_raingage CASCADE;
ALTER TABLE coimbra.subcatchment ADD CONSTRAINT fk_subcatchment_raingage FOREIGN KEY (id_raingage)
REFERENCES coimbra.raingage (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_node | type: CONSTRAINT --
-- ALTER TABLE coimbra.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_node CASCADE;
ALTER TABLE coimbra.subcatchment ADD CONSTRAINT fk_subcatchment_node FOREIGN KEY (id_node_outlet)
REFERENCES coimbra.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subarea_subcatchment | type: CONSTRAINT --
-- ALTER TABLE coimbra.subarea DROP CONSTRAINT IF EXISTS fk_subarea_subcatchment CASCADE;
ALTER TABLE coimbra.subarea ADD CONSTRAINT fk_subarea_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES coimbra.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_coordinates_node | type: CONSTRAINT --
-- ALTER TABLE coimbra.coordinates DROP CONSTRAINT IF EXISTS fk_coordinates_node CASCADE;
ALTER TABLE coimbra.coordinates ADD CONSTRAINT fk_coordinates_node FOREIGN KEY (id_node)
REFERENCES coimbra.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_polygon_subcatchment | type: CONSTRAINT --
-- ALTER TABLE coimbra.polygon DROP CONSTRAINT IF EXISTS fk_polygon_subcatchment CASCADE;
ALTER TABLE coimbra.polygon ADD CONSTRAINT fk_polygon_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES coimbra.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_candidate_node | type: CONSTRAINT --
-- ALTER TABLE coimbra.candidate DROP CONSTRAINT IF EXISTS fk_candidate_node CASCADE;
ALTER TABLE coimbra.candidate ADD CONSTRAINT fk_candidate_node FOREIGN KEY (id_node)
REFERENCES coimbra.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_link | type: CONSTRAINT --
-- ALTER TABLE coimbra.flooded DROP CONSTRAINT IF EXISTS fk_flooded_link CASCADE;
ALTER TABLE coimbra.flooded ADD CONSTRAINT fk_flooded_link FOREIGN KEY (id_link)
REFERENCES coimbra.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_candidate | type: CONSTRAINT --
-- ALTER TABLE coimbra.flooded DROP CONSTRAINT IF EXISTS fk_flooded_candidate CASCADE;
ALTER TABLE coimbra.flooded ADD CONSTRAINT fk_flooded_candidate FOREIGN KEY (id_node)
REFERENCES coimbra.candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_contribution_candidate | type: CONSTRAINT --
-- ALTER TABLE coimbra.contribution DROP CONSTRAINT IF EXISTS fk_contribution_candidate CASCADE;
ALTER TABLE coimbra.contribution ADD CONSTRAINT fk_contribution_candidate FOREIGN KEY (id_node)
REFERENCES coimbra.candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_contribution_subcatchment | type: CONSTRAINT --
-- ALTER TABLE coimbra.contribution DROP CONSTRAINT IF EXISTS fk_contribution_subcatchment CASCADE;
ALTER TABLE coimbra.contribution ADD CONSTRAINT fk_contribution_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES coimbra.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


