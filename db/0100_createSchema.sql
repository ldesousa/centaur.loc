-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.8.2-alpha1
-- PostgreSQL version: 9.4
-- Project Site: pgmodeler.com.br
-- Model Author: ---


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: <schema> | type: DATABASE --
-- -- DROP DATABASE IF EXISTS <schema>;
-- CREATE DATABASE <schema>
-- ;
-- -- ddl-end --
-- 

-- object: <schema> | type: SCHEMA --
-- DROP SCHEMA IF EXISTS <schema> CASCADE;
CREATE SCHEMA <schema>;
-- ddl-end --
ALTER SCHEMA <schema> OWNER TO <user>;
-- ddl-end --

SET search_path TO pg_catalog,public,<schema>;
-- ddl-end --

-- object: <schema>.curve | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.curve CASCADE;
CREATE TABLE <schema>.curve(
	id integer NOT NULL,
	name varchar,
	type varchar,
	CONSTRAINT pk_curve PRIMARY KEY (id),
	CONSTRAINT unq_curve UNIQUE (name)

);
-- ddl-end --
ALTER TABLE <schema>.curve OWNER TO <user>;
-- ddl-end --

-- object: <schema>.curve_parameter | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.curve_parameter CASCADE;
CREATE TABLE <schema>.curve_parameter(
	id serial NOT NULL,
	x numeric,
	y numeric,
	id_curve integer,
	CONSTRAINT pk_curve_parameter PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE <schema>.curve_parameter OWNER TO <user>;
-- ddl-end --

-- object: <schema>.node | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.node CASCADE;
CREATE TABLE <schema>.node(
	id serial NOT NULL,
	elevation numeric,
	name varchar,
	taken boolean,
	CONSTRAINT pk_node PRIMARY KEY (id),
	CONSTRAINT unq_node UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN <schema>.node.taken IS 'True if this node is already being used by a gate or flooded by one.';
-- ddl-end --
ALTER TABLE <schema>.node OWNER TO <user>;
-- ddl-end --

-- object: <schema>.link | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.link CASCADE;
CREATE TABLE <schema>.link(
	id serial NOT NULL,
	name varchar,
	id_node_from integer,
	id_node_to integer,
	CONSTRAINT pk_link PRIMARY KEY (id),
	CONSTRAINT unq_link_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE <schema>.link OWNER TO <user>;
-- ddl-end --

-- object: <schema>.conduit | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.conduit CASCADE;
CREATE TABLE <schema>.conduit(
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
COMMENT ON COLUMN <schema>.conduit.length IS 'This can be calculated from the junctions coordinates';
-- ddl-end --
ALTER TABLE <schema>.conduit OWNER TO <user>;
-- ddl-end --

-- object: <schema>.pump | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.pump CASCADE;
CREATE TABLE <schema>.pump(
	id_link integer NOT NULL,
	id_curve integer,
	status varchar,
	startup numeric,
	shutoff numeric,
	CONSTRAINT pk_pump PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE <schema>.pump OWNER TO <user>;
-- ddl-end --

-- object: <schema>.junction | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.junction CASCADE;
CREATE TABLE <schema>.junction(
	id_node integer NOT NULL,
	max_depth numeric,
	init_depth numeric,
	sur_depth numeric,
	aponded numeric,
	CONSTRAINT pk_junction PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE <schema>.junction OWNER TO <user>;
-- ddl-end --

-- object: <schema>.weir | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.weir CASCADE;
CREATE TABLE <schema>.weir(
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
ALTER TABLE <schema>.weir OWNER TO <user>;
-- ddl-end --

-- object: <schema>.outfall | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.outfall CASCADE;
CREATE TABLE <schema>.outfall(
	id_node integer NOT NULL,
	type varchar,
	stage_date varchar,
	gated boolean,
	route_to varchar,
	CONSTRAINT pk_outfall PRIMARY KEY (id_node)

);
-- ddl-end --
COMMENT ON TABLE <schema>.outfall IS 'This is a special kind of junction';
-- ddl-end --
ALTER TABLE <schema>.outfall OWNER TO <user>;
-- ddl-end --

-- object: <schema>.storage | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.storage CASCADE;
CREATE TABLE <schema>.storage(
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
ALTER TABLE <schema>.storage OWNER TO <user>;
-- ddl-end --

-- object: <schema>.xsection | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.xsection CASCADE;
CREATE TABLE <schema>.xsection(
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
ALTER TABLE <schema>.xsection OWNER TO <user>;
-- ddl-end --

-- object: <schema>.raingage | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.raingage CASCADE;
CREATE TABLE <schema>.raingage(
	id integer NOT NULL,
	format varchar,
	"interval" varchar,
	scf numeric,
	source varchar,
	CONSTRAINT pk_raingage PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE <schema>.raingage OWNER TO <user>;
-- ddl-end --

-- object: <schema>.subcatchment | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.subcatchment CASCADE;
CREATE TABLE <schema>.subcatchment(
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
COMMENT ON COLUMN <schema>.subcatchment.imperv IS 'This field is a percentage (<= 100)';
-- ddl-end --
COMMENT ON COLUMN <schema>.subcatchment.slope IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE <schema>.subcatchment OWNER TO <user>;
-- ddl-end --

-- object: <schema>.subarea | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.subarea CASCADE;
CREATE TABLE <schema>.subarea(
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
COMMENT ON COLUMN <schema>.subarea.pct_zero IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE <schema>.subarea OWNER TO <user>;
-- ddl-end --

-- object: <schema>.coordinates | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.coordinates CASCADE;
CREATE TABLE <schema>.coordinates(
	id_node integer NOT NULL,
	x numeric,
	y numeric,
	CONSTRAINT pk_coordinates PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE <schema>.coordinates OWNER TO <user>;
-- ddl-end --

-- object: <schema>.polygon | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.polygon CASCADE;
CREATE TABLE <schema>.polygon(
	id serial NOT NULL,
	id_subcatchment integer,
	x numeric,
	y numeric,
	CONSTRAINT pk_polygon PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE <schema>.polygon OWNER TO <user>;
-- ddl-end --

-- object: <schema>.candidate | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.candidate CASCADE;
CREATE TABLE <schema>.candidate(
	id_node integer NOT NULL,
	outflow_elevation numeric NOT NULL,
	volume numeric,
	CONSTRAINT pk_candidate PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE <schema>.candidate OWNER TO <user>;
-- ddl-end --

-- object: <schema>.flooded | type: TABLE --
-- DROP TABLE IF EXISTS <schema>.flooded CASCADE;
CREATE TABLE <schema>.flooded(
	id_flooded serial NOT NULL,
	id_node integer NOT NULL,
	id_link integer NOT NULL,
	volume_fraction numeric,
	q_prac numeric,
	energy_line_offset numeric,
	CONSTRAINT pk_flooded PRIMARY KEY (id_flooded),
	CONSTRAINT unq_flooded UNIQUE (id_node,id_link)

);
-- ddl-end --
COMMENT ON COLUMN <schema>.flooded.q_prac IS 'Practical flow calculated for this conduit';
-- ddl-end --
COMMENT ON COLUMN <schema>.flooded.energy_line_offset IS 'The offset in upstream height induced by the energy line';
-- ddl-end --
ALTER TABLE <schema>.flooded OWNER TO <user>;
-- ddl-end --

-- object: fk_curve_parameter_curve | type: CONSTRAINT --
-- ALTER TABLE <schema>.curve_parameter DROP CONSTRAINT IF EXISTS fk_curve_parameter_curve CASCADE;
ALTER TABLE <schema>.curve_parameter ADD CONSTRAINT fk_curve_parameter_curve FOREIGN KEY (id_curve)
REFERENCES <schema>.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_from | type: CONSTRAINT --
-- ALTER TABLE <schema>.link DROP CONSTRAINT IF EXISTS fk_link_node_from CASCADE;
ALTER TABLE <schema>.link ADD CONSTRAINT fk_link_node_from FOREIGN KEY (id_node_from)
REFERENCES <schema>.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_to | type: CONSTRAINT --
-- ALTER TABLE <schema>.link DROP CONSTRAINT IF EXISTS fk_link_node_to CASCADE;
ALTER TABLE <schema>.link ADD CONSTRAINT fk_link_node_to FOREIGN KEY (id_node_to)
REFERENCES <schema>.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_conduit_link | type: CONSTRAINT --
-- ALTER TABLE <schema>.conduit DROP CONSTRAINT IF EXISTS fk_conduit_link CASCADE;
ALTER TABLE <schema>.conduit ADD CONSTRAINT fk_conduit_link FOREIGN KEY (id_link)
REFERENCES <schema>.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_link | type: CONSTRAINT --
-- ALTER TABLE <schema>.pump DROP CONSTRAINT IF EXISTS fk_pump_link CASCADE;
ALTER TABLE <schema>.pump ADD CONSTRAINT fk_pump_link FOREIGN KEY (id_link)
REFERENCES <schema>.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_curve | type: CONSTRAINT --
-- ALTER TABLE <schema>.pump DROP CONSTRAINT IF EXISTS fk_pump_curve CASCADE;
ALTER TABLE <schema>.pump ADD CONSTRAINT fk_pump_curve FOREIGN KEY (id_curve)
REFERENCES <schema>.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_junction_node | type: CONSTRAINT --
-- ALTER TABLE <schema>.junction DROP CONSTRAINT IF EXISTS fk_junction_node CASCADE;
ALTER TABLE <schema>.junction ADD CONSTRAINT fk_junction_node FOREIGN KEY (id_node)
REFERENCES <schema>.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_weir_link | type: CONSTRAINT --
-- ALTER TABLE <schema>.weir DROP CONSTRAINT IF EXISTS fk_weir_link CASCADE;
ALTER TABLE <schema>.weir ADD CONSTRAINT fk_weir_link FOREIGN KEY (id_link)
REFERENCES <schema>.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_outfall_node | type: CONSTRAINT --
-- ALTER TABLE <schema>.outfall DROP CONSTRAINT IF EXISTS fk_outfall_node CASCADE;
ALTER TABLE <schema>.outfall ADD CONSTRAINT fk_outfall_node FOREIGN KEY (id_node)
REFERENCES <schema>.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_node | type: CONSTRAINT --
-- ALTER TABLE <schema>.storage DROP CONSTRAINT IF EXISTS fk_storage_node CASCADE;
ALTER TABLE <schema>.storage ADD CONSTRAINT fk_storage_node FOREIGN KEY (id_node)
REFERENCES <schema>.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_curve | type: CONSTRAINT --
-- ALTER TABLE <schema>.storage DROP CONSTRAINT IF EXISTS fk_storage_curve CASCADE;
ALTER TABLE <schema>.storage ADD CONSTRAINT fk_storage_curve FOREIGN KEY (id_curve)
REFERENCES <schema>.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_xsection_link | type: CONSTRAINT --
-- ALTER TABLE <schema>.xsection DROP CONSTRAINT IF EXISTS fk_xsection_link CASCADE;
ALTER TABLE <schema>.xsection ADD CONSTRAINT fk_xsection_link FOREIGN KEY (id_link)
REFERENCES <schema>.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_raingage | type: CONSTRAINT --
-- ALTER TABLE <schema>.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_raingage CASCADE;
ALTER TABLE <schema>.subcatchment ADD CONSTRAINT fk_subcatchment_raingage FOREIGN KEY (id_raingage)
REFERENCES <schema>.raingage (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_node | type: CONSTRAINT --
-- ALTER TABLE <schema>.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_node CASCADE;
ALTER TABLE <schema>.subcatchment ADD CONSTRAINT fk_subcatchment_node FOREIGN KEY (id_node_outlet)
REFERENCES <schema>.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subarea_subcatchment | type: CONSTRAINT --
-- ALTER TABLE <schema>.subarea DROP CONSTRAINT IF EXISTS fk_subarea_subcatchment CASCADE;
ALTER TABLE <schema>.subarea ADD CONSTRAINT fk_subarea_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES <schema>.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_coordinates_node | type: CONSTRAINT --
-- ALTER TABLE <schema>.coordinates DROP CONSTRAINT IF EXISTS fk_coordinates_node CASCADE;
ALTER TABLE <schema>.coordinates ADD CONSTRAINT fk_coordinates_node FOREIGN KEY (id_node)
REFERENCES <schema>.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_polygon_subcatchment | type: CONSTRAINT --
-- ALTER TABLE <schema>.polygon DROP CONSTRAINT IF EXISTS fk_polygon_subcatchment CASCADE;
ALTER TABLE <schema>.polygon ADD CONSTRAINT fk_polygon_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES <schema>.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_candidate_node | type: CONSTRAINT --
-- ALTER TABLE <schema>.candidate DROP CONSTRAINT IF EXISTS fk_candidate_node CASCADE;
ALTER TABLE <schema>.candidate ADD CONSTRAINT fk_candidate_node FOREIGN KEY (id_node)
REFERENCES <schema>.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_link | type: CONSTRAINT --
-- ALTER TABLE <schema>.flooded DROP CONSTRAINT IF EXISTS fk_flooded_link CASCADE;
ALTER TABLE <schema>.flooded ADD CONSTRAINT fk_flooded_link FOREIGN KEY (id_link)
REFERENCES <schema>.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_candidate | type: CONSTRAINT --
-- ALTER TABLE <schema>.flooded DROP CONSTRAINT IF EXISTS fk_flooded_candidate CASCADE;
ALTER TABLE <schema>.flooded ADD CONSTRAINT fk_flooded_candidate FOREIGN KEY (id_node)
REFERENCES <schema>.candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --


