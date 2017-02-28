SET search_path TO luzern,pg_catalog,public;

-- DROP TABLE simulation
CREATE TABLE simulation
(
	id   SERIAL,
	name VARCHAR NOT NULL,
	details VARCHAR,
	date DATE,
	CONSTRAINT pk_sim PRIMARY KEY (id),
	CONSTRAINT unq_sim UNIQUE (name)
);

-- DROP TABLE sim_node
CREATE TABLE sim_node
(
	id_node INTEGER,
	id_sim  INTEGER,
	average NUMERIC,
	stddev  NUMERIC,
	max     NUMERIC,
	min     NUMERIC,
	CONSTRAINT pk_sim_node PRIMARY KEY (id_node, id_sim)
);

ALTER TABLE sim_node ADD CONSTRAINT fk_sim_node_node FOREIGN KEY (id_node)
REFERENCES node (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE sim_node ADD CONSTRAINT fk_sim_node_sim FOREIGN KEY (id_sim)
REFERENCES simulation (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;


CREATE OR REPLACE VIEW v_sim_node AS
SELECT n.id,
       n.geom,
       s.id_sim,
       s.average,
       s.stddev,
       s.max,
       s.min
  FROM node n,
       sim_node s
 WHERE n.id = s.id_node;
