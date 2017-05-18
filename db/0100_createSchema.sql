-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.8.2-alpha1
-- PostgreSQL version: 9.4
-- Project Site: pgmodeler.com.br
-- Model Author: ---


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: test01 | type: DATABASE --
-- -- DROP DATABASE IF EXISTS test01;
-- CREATE DATABASE test01
-- ;
-- -- ddl-end --
-- 

-- object: test01 | type: SCHEMA --
-- DROP SCHEMA IF EXISTS test01 CASCADE;
CREATE SCHEMA test01;
-- ddl-end --
ALTER SCHEMA test01 OWNER TO centaur;
-- ddl-end --

SET search_path TO pg_catalog,public,test01;
-- ddl-end --

-- object: test01.curve | type: TABLE --
-- DROP TABLE IF EXISTS test01.curve CASCADE;
CREATE TABLE test01.curve(
	id integer NOT NULL,
	name varchar,
	type varchar,
	CONSTRAINT pk_curve PRIMARY KEY (id),
	CONSTRAINT unq_curve UNIQUE (name)

);
-- ddl-end --
ALTER TABLE test01.curve OWNER TO centaur;
-- ddl-end --

-- object: test01.curve_parameter | type: TABLE --
-- DROP TABLE IF EXISTS test01.curve_parameter CASCADE;
CREATE TABLE test01.curve_parameter(
	id serial NOT NULL,
	x numeric,
	y numeric,
	id_curve integer,
	CONSTRAINT pk_curve_parameter PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE test01.curve_parameter OWNER TO centaur;
-- ddl-end --

-- object: test01.node | type: TABLE --
-- DROP TABLE IF EXISTS test01.node CASCADE;
CREATE TABLE test01.node(
	id serial NOT NULL,
	elevation numeric,
	name varchar,
	taken boolean,
	CONSTRAINT pk_node PRIMARY KEY (id),
	CONSTRAINT unq_node UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN test01.node.taken IS 'True if this node is already being used by a gate or flooded by one.';
-- ddl-end --
ALTER TABLE test01.node OWNER TO centaur;
-- ddl-end --

-- object: test01.link | type: TABLE --
-- DROP TABLE IF EXISTS test01.link CASCADE;
CREATE TABLE test01.link(
	id serial NOT NULL,
	name varchar,
	id_node_from integer,
	id_node_to integer,
	CONSTRAINT pk_link PRIMARY KEY (id),
	CONSTRAINT unq_link_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE test01.link OWNER TO centaur;
-- ddl-end --

-- object: test01.conduit | type: TABLE --
-- DROP TABLE IF EXISTS test01.conduit CASCADE;
CREATE TABLE test01.conduit(
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
COMMENT ON COLUMN test01.conduit.length IS 'This can be calculated from the junctions coordinates';
-- ddl-end --
ALTER TABLE test01.conduit OWNER TO centaur;
-- ddl-end --

-- object: test01.pump | type: TABLE --
-- DROP TABLE IF EXISTS test01.pump CASCADE;
CREATE TABLE test01.pump(
	id_link integer NOT NULL,
	id_curve integer,
	status varchar,
	startup numeric,
	shutoff numeric,
	CONSTRAINT pk_pump PRIMARY KEY (id_link)

);
-- ddl-end --
ALTER TABLE test01.pump OWNER TO centaur;
-- ddl-end --

-- object: test01.junction | type: TABLE --
-- DROP TABLE IF EXISTS test01.junction CASCADE;
CREATE TABLE test01.junction(
	id_node integer NOT NULL,
	max_depth numeric,
	init_depth numeric,
	sur_depth numeric,
	aponded numeric,
	CONSTRAINT pk_junction PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE test01.junction OWNER TO centaur;
-- ddl-end --

-- object: test01.weir | type: TABLE --
-- DROP TABLE IF EXISTS test01.weir CASCADE;
CREATE TABLE test01.weir(
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
ALTER TABLE test01.weir OWNER TO centaur;
-- ddl-end --

-- object: test01.outfall | type: TABLE --
-- DROP TABLE IF EXISTS test01.outfall CASCADE;
CREATE TABLE test01.outfall(
	id_node integer NOT NULL,
	type varchar,
	stage_date varchar,
	gated boolean,
	route_to varchar,
	CONSTRAINT pk_outfall PRIMARY KEY (id_node)

);
-- ddl-end --
COMMENT ON TABLE test01.outfall IS 'This is a special kind of junction';
-- ddl-end --
ALTER TABLE test01.outfall OWNER TO centaur;
-- ddl-end --

-- object: test01.storage | type: TABLE --
-- DROP TABLE IF EXISTS test01.storage CASCADE;
CREATE TABLE test01.storage(
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
ALTER TABLE test01.storage OWNER TO centaur;
-- ddl-end --

-- object: test01.xsection | type: TABLE --
-- DROP TABLE IF EXISTS test01.xsection CASCADE;
CREATE TABLE test01.xsection(
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
ALTER TABLE test01.xsection OWNER TO centaur;
-- ddl-end --

-- object: test01.raingage | type: TABLE --
-- DROP TABLE IF EXISTS test01.raingage CASCADE;
CREATE TABLE test01.raingage(
	id integer NOT NULL,
	format varchar,
	"interval" varchar,
	scf numeric,
	source varchar,
	CONSTRAINT pk_raingage PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE test01.raingage OWNER TO centaur;
-- ddl-end --

-- object: test01.subcatchment | type: TABLE --
-- DROP TABLE IF EXISTS test01.subcatchment CASCADE;
CREATE TABLE test01.subcatchment(
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
COMMENT ON COLUMN test01.subcatchment.imperv IS 'This field is a percentage (<= 100)';
-- ddl-end --
COMMENT ON COLUMN test01.subcatchment.slope IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE test01.subcatchment OWNER TO centaur;
-- ddl-end --

-- object: test01.subarea | type: TABLE --
-- DROP TABLE IF EXISTS test01.subarea CASCADE;
CREATE TABLE test01.subarea(
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
COMMENT ON COLUMN test01.subarea.pct_zero IS 'This field is a percentage';
-- ddl-end --
ALTER TABLE test01.subarea OWNER TO centaur;
-- ddl-end --

-- object: test01.coordinates | type: TABLE --
-- DROP TABLE IF EXISTS test01.coordinates CASCADE;
CREATE TABLE test01.coordinates(
	id_node integer NOT NULL,
	x numeric,
	y numeric,
	CONSTRAINT pk_coordinates PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE test01.coordinates OWNER TO centaur;
-- ddl-end --

-- object: test01.polygon | type: TABLE --
-- DROP TABLE IF EXISTS test01.polygon CASCADE;
CREATE TABLE test01.polygon(
	id serial NOT NULL,
	id_subcatchment integer,
	x numeric,
	y numeric,
	CONSTRAINT pk_polygon PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE test01.polygon OWNER TO centaur;
-- ddl-end --

-- object: test01.candidate | type: TABLE --
-- DROP TABLE IF EXISTS test01.candidate CASCADE;
CREATE TABLE test01.candidate(
	id_node integer NOT NULL,
	outflow_elevation numeric NOT NULL,
	volume numeric,
	CONSTRAINT pk_candidate PRIMARY KEY (id_node)

);
-- ddl-end --
ALTER TABLE test01.candidate OWNER TO centaur;
-- ddl-end --

-- object: test01.flooded | type: TABLE --
-- DROP TABLE IF EXISTS test01.flooded CASCADE;
CREATE TABLE test01.flooded(
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
COMMENT ON COLUMN test01.flooded.q_prac IS 'Practical flow calculated for this conduit';
-- ddl-end --
COMMENT ON COLUMN test01.flooded.energy_line_offset IS 'The offset in upstream height induced by the energy line';
-- ddl-end --
ALTER TABLE test01.flooded OWNER TO centaur;
-- ddl-end --

-- object: fk_curve_parameter_curve | type: CONSTRAINT --
-- ALTER TABLE test01.curve_parameter DROP CONSTRAINT IF EXISTS fk_curve_parameter_curve CASCADE;
ALTER TABLE test01.curve_parameter ADD CONSTRAINT fk_curve_parameter_curve FOREIGN KEY (id_curve)
REFERENCES test01.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_from | type: CONSTRAINT --
-- ALTER TABLE test01.link DROP CONSTRAINT IF EXISTS fk_link_node_from CASCADE;
ALTER TABLE test01.link ADD CONSTRAINT fk_link_node_from FOREIGN KEY (id_node_from)
REFERENCES test01.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_link_node_to | type: CONSTRAINT --
-- ALTER TABLE test01.link DROP CONSTRAINT IF EXISTS fk_link_node_to CASCADE;
ALTER TABLE test01.link ADD CONSTRAINT fk_link_node_to FOREIGN KEY (id_node_to)
REFERENCES test01.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_conduit_link | type: CONSTRAINT --
-- ALTER TABLE test01.conduit DROP CONSTRAINT IF EXISTS fk_conduit_link CASCADE;
ALTER TABLE test01.conduit ADD CONSTRAINT fk_conduit_link FOREIGN KEY (id_link)
REFERENCES test01.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_link | type: CONSTRAINT --
-- ALTER TABLE test01.pump DROP CONSTRAINT IF EXISTS fk_pump_link CASCADE;
ALTER TABLE test01.pump ADD CONSTRAINT fk_pump_link FOREIGN KEY (id_link)
REFERENCES test01.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_pump_curve | type: CONSTRAINT --
-- ALTER TABLE test01.pump DROP CONSTRAINT IF EXISTS fk_pump_curve CASCADE;
ALTER TABLE test01.pump ADD CONSTRAINT fk_pump_curve FOREIGN KEY (id_curve)
REFERENCES test01.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_junction_node | type: CONSTRAINT --
-- ALTER TABLE test01.junction DROP CONSTRAINT IF EXISTS fk_junction_node CASCADE;
ALTER TABLE test01.junction ADD CONSTRAINT fk_junction_node FOREIGN KEY (id_node)
REFERENCES test01.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_weir_link | type: CONSTRAINT --
-- ALTER TABLE test01.weir DROP CONSTRAINT IF EXISTS fk_weir_link CASCADE;
ALTER TABLE test01.weir ADD CONSTRAINT fk_weir_link FOREIGN KEY (id_link)
REFERENCES test01.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_outfall_node | type: CONSTRAINT --
-- ALTER TABLE test01.outfall DROP CONSTRAINT IF EXISTS fk_outfall_node CASCADE;
ALTER TABLE test01.outfall ADD CONSTRAINT fk_outfall_node FOREIGN KEY (id_node)
REFERENCES test01.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_node | type: CONSTRAINT --
-- ALTER TABLE test01.storage DROP CONSTRAINT IF EXISTS fk_storage_node CASCADE;
ALTER TABLE test01.storage ADD CONSTRAINT fk_storage_node FOREIGN KEY (id_node)
REFERENCES test01.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_storage_curve | type: CONSTRAINT --
-- ALTER TABLE test01.storage DROP CONSTRAINT IF EXISTS fk_storage_curve CASCADE;
ALTER TABLE test01.storage ADD CONSTRAINT fk_storage_curve FOREIGN KEY (id_curve)
REFERENCES test01.curve (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_xsection_link | type: CONSTRAINT --
-- ALTER TABLE test01.xsection DROP CONSTRAINT IF EXISTS fk_xsection_link CASCADE;
ALTER TABLE test01.xsection ADD CONSTRAINT fk_xsection_link FOREIGN KEY (id_link)
REFERENCES test01.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_raingage | type: CONSTRAINT --
-- ALTER TABLE test01.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_raingage CASCADE;
ALTER TABLE test01.subcatchment ADD CONSTRAINT fk_subcatchment_raingage FOREIGN KEY (id_raingage)
REFERENCES test01.raingage (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subcatchment_node | type: CONSTRAINT --
-- ALTER TABLE test01.subcatchment DROP CONSTRAINT IF EXISTS fk_subcatchment_node CASCADE;
ALTER TABLE test01.subcatchment ADD CONSTRAINT fk_subcatchment_node FOREIGN KEY (id_node_outlet)
REFERENCES test01.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_subarea_subcatchment | type: CONSTRAINT --
-- ALTER TABLE test01.subarea DROP CONSTRAINT IF EXISTS fk_subarea_subcatchment CASCADE;
ALTER TABLE test01.subarea ADD CONSTRAINT fk_subarea_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES test01.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_coordinates_node | type: CONSTRAINT --
-- ALTER TABLE test01.coordinates DROP CONSTRAINT IF EXISTS fk_coordinates_node CASCADE;
ALTER TABLE test01.coordinates ADD CONSTRAINT fk_coordinates_node FOREIGN KEY (id_node)
REFERENCES test01.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_polygon_subcatchment | type: CONSTRAINT --
-- ALTER TABLE test01.polygon DROP CONSTRAINT IF EXISTS fk_polygon_subcatchment CASCADE;
ALTER TABLE test01.polygon ADD CONSTRAINT fk_polygon_subcatchment FOREIGN KEY (id_subcatchment)
REFERENCES test01.subcatchment (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_candidate_node | type: CONSTRAINT --
-- ALTER TABLE test01.candidate DROP CONSTRAINT IF EXISTS fk_candidate_node CASCADE;
ALTER TABLE test01.candidate ADD CONSTRAINT fk_candidate_node FOREIGN KEY (id_node)
REFERENCES test01.node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_link | type: CONSTRAINT --
-- ALTER TABLE test01.flooded DROP CONSTRAINT IF EXISTS fk_flooded_link CASCADE;
ALTER TABLE test01.flooded ADD CONSTRAINT fk_flooded_link FOREIGN KEY (id_link)
REFERENCES test01.link (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_flooded_candidate | type: CONSTRAINT --
-- ALTER TABLE test01.flooded DROP CONSTRAINT IF EXISTS fk_flooded_candidate CASCADE;
ALTER TABLE test01.flooded ADD CONSTRAINT fk_flooded_candidate FOREIGN KEY (id_node)
REFERENCES test01.candidate (id_node) MATCH FULL
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --


