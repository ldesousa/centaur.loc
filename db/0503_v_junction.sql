-- Set search path to desired schema
SET search_path TO alcantara, public;

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
       c.energy_slope
  FROM junction j,
       node n,
       (SELECT id_node_from, 
               MAX((q_max * 0.015 / ((area / perimeter) ^ (2/3))) ^ 2) AS energy_slope
          FROM v_conduit 
         GROUP BY id_node_from) c	
 WHERE j.id_node = n.id
   AND j.id_node = c.id_node_from
 UNION
SELECT n.id AS id_node,
       n.elevation,
       n.name,
       n.geom,
       j.max_depth,
       j.init_depth,
       j.sur_depth,
       j.aponded,
       0 AS energy_slope
  FROM junction j,
       node n 	
 WHERE j.id_node = n.id
   AND j.id_node NOT IN (SELECT id_node_from FROM link);


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