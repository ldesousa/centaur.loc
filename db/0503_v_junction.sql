-- Set search path to desired schema
SET search_path TO coimbra, public;

DROP VIEW v_flooded CASCADE;
DROP VIEW v_junction CASCADE;

CREATE OR REPLACE VIEW v_junction AS
SELECT n.id AS id_node,
       n.elevation,
       n.name,
       n.geom,
       j.max_depth,
       j.init_depth,
       j.sur_depth,
       j.aponded,
       COALESCE(c.energy_slope, 0) AS energy_slope
  FROM node n,
       junction j
  LEFT JOIN v_conduit c
    ON j.id_node = c.id_node_to
 WHERE j.id_node = n.id;

-- SELECT COUNT(*) FROM v_junction;

CREATE OR REPLACE VIEW v_flooded AS
SELECT f.id_flooded,
       f.id_node as id_node_candidate,
       l.id,
       l.name,
       l.id_node_from,
       l.id_node_to,
       l.geom
  FROM flooded f,
       link l	
 WHERE f.id_link = l.id;