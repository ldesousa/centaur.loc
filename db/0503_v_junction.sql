-- Set search path to desired schema
SET search_path TO alcantara, public;

-- DROP VIEW v_flooded CASCADE;
-- DROP VIEW v_junction CASCADE;

CREATE OR REPLACE VIEW v_junction AS
SELECT n.id AS id_node,
       n.elevation,
       n.name,
       n.geom,
       j.max_depth,
       j.init_depth,
       j.sur_depth,
       j.aponded,
       c.energy_line_offset
  FROM node n,
       junction j
  LEFT JOIN (SELECT c.id_node_from,
                    MAX(energy_line_offset) AS energy_line_offset
               FROM v_conduit c
              GROUP BY c.id_node_from) c
    ON j.id_node = c.id_node_from
 WHERE j.id_node = n.id;

-- SELECT COUNT(*) FROM v_junction;

-- DROP VIEW v_flooded; 
CREATE OR REPLACE VIEW v_flooded AS
SELECT f.id_flooded,
       f.id_node as id_node_candidate,
       l.id,
       l.name as link_name,
       l.id_node_from,
       l.id_node_to,
       f.q_prac,
       f.energy_line_offset,
       l.geom
  FROM flooded f,
       link l	
 WHERE f.id_link = l.id;
 
-- SELECT * FROM v_flooded WHERE id_node_candidate = -545475706;
 
 