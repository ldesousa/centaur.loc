-- Set search path to desired schema
SET search_path TO coimbra, public;

DROP VIEW v_weir CASCADE;
DROP VIEW v_pump CASCADE;
DROP VIEW v_conduit CASCADE;
DROP VIEW v_outfall CASCADE;
DROP VIEW v_storage CASCADE;
DROP VIEW v_junction CASCADE;
DROP VIEW v_flooded CASCADE;


CREATE OR REPLACE VIEW v_weir AS
SELECT l.id,
       l.name,
       l.id_node_from,
       l.id_node_to,
       l.geom,
       w.type,
       w.crest_height,
       w.q_coeff,
       w.gated,
       w.end_con,
       w.end_coeff,
       w.surcharge
  FROM weir w,
       link l	
 WHERE w.id_link = l.id;

CREATE OR REPLACE VIEW v_pump AS
SELECT l.id,
       l.name,
       l.id_node_from,
       l.id_node_to,
       l.geom,
       p.id_curve,
       p.status,
       p.startup,
       p.shutoff
  FROM pump p,
       link l	
 WHERE p.id_link = l.id;



-- SELECT * FROM v_conduit;

CREATE OR REPLACE VIEW v_outfall AS
SELECT n.id,
       n.elevation,
       n.name,
       n.geom,
       o.type,
       o.stage_date,
       o.gated,
       o.route_to
  FROM outfall o,
       node n	
 WHERE o.id_node = n.id;

CREATE OR REPLACE VIEW v_storage AS
SELECT n.id,
       n.elevation,
       n.name,
       n.geom,
       s.max_depth,
       s.init_depth,
       s.shape,
       s.id_curve,
       s.name_params,
       s.fevap,
       s.psi,
       s.ksat,
       s.imd 
  FROM storage s,
       node n	
 WHERE s.id_node = n.id;

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

SELECT * FROM coimbra.v_junction;


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






