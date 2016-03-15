DROP VIEW centaur.v_weir;
DROP VIEW centaur.v_pump;
DROP VIEW centaur.v_conduit;
DROP VIEW centaur.v_outfall;
DROP VIEW centaur.v_storage;
DROP VIEW centaur.v_junction;
DROP VIEW centaur.v_candidate;
DROP VIEW centaur.v_flooded;

CREATE OR REPLACE VIEW centaur.v_weir AS
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
  FROM centaur.weir w,
       centaur.link l	
 WHERE w.id_link = l.id;

CREATE OR REPLACE VIEW centaur.v_pump AS
SELECT l.id,
       l.name,
       l.id_node_from,
       l.id_node_to,
       l.geom,
       p.id_curve,
       p.status,
       p.startup,
       p.shutoff
  FROM centaur.pump p,
       centaur.link l	
 WHERE p.id_link = l.id;

CREATE OR REPLACE VIEW centaur.v_conduit AS
SELECT l.id,
       l.name,
       l.id_node_from,
       l.id_node_to,
       l.geom,
       c.length,
       c.roughness,
       c.in_offset,
       c.out_offset,
       c.init_flow,
       c.max_flow,
       (st_y(st_pointn(l.geom, 2)) - st_y(st_pointn(l.geom, 1))) / 
       (st_x(st_pointn(l.geom, 2)) - st_x(st_pointn(l.geom, 1))) AS slope,
       pi() * ((x.geom1/2) ^ 2) * c.length AS volume
  FROM centaur.conduit c,
       centaur.link l,
       centaur.xsection x	
 WHERE c.id_link = l.id
   AND x.id_link = l.id
   AND x.shape LIKE 'CIRC%'
 UNION
SELECT l.id,
       l.name,
       l.id_node_from,
       l.id_node_to,
       l.geom,
       c.length,
       c.roughness,
       c.in_offset,
       c.out_offset,
       c.init_flow,
       c.max_flow,
       (st_y(st_pointn(l.geom, 2)) - st_y(st_pointn(l.geom, 1))) / 
       (st_x(st_pointn(l.geom, 2)) - st_x(st_pointn(l.geom, 1))) AS slope,
       x.geom1 * x.geom2 AS volume
  FROM centaur.conduit c,
       centaur.link l,
       centaur.xsection x	
 WHERE c.id_link = l.id
   AND x.id_link = l.id
   AND x.shape LIKE 'RECT%';

CREATE OR REPLACE VIEW centaur.v_outfall AS
SELECT n.id,
       n.elevation,
       n.name,
       n.geom,
       o.type,
       o.stage_date,
       o.gated,
       o.route_to
  FROM centaur.outfall o,
       centaur.node n	
 WHERE o.id_node = n.id;

CREATE OR REPLACE VIEW centaur.v_storage AS
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
  FROM centaur.storage s,
       centaur.node n	
 WHERE s.id_node = n.id;

CREATE OR REPLACE VIEW centaur.v_junction AS
SELECT n.id,
       n.elevation,
       n.name,
       n.geom,
       j.max_depth,
       j.init_depth,
       j.sur_depth,
       j.aponded
  FROM centaur.junction j,
       centaur.node n	
 WHERE j.id_node = n.id;

CREATE OR REPLACE VIEW centaur.v_candidate_volume AS
SELECT c.id_node, 
       sum(l.volume) AS flooded_volume
  FROM centaur.candidate c,
       centaur.flooded f,
       centaur.v_conduit l	
 WHERE l.id = f.id_link
   AND c.id_node = f.id_node
 GROUP BY(c.id_node);

CREATE OR REPLACE VIEW centaur.v_candidate AS
SELECT n.id, 
       c.outflow_elevation,
       n.name,
       n.geom,
       v.flooded_volume
  FROM centaur.candidate c,
       centaur.node n,
       centaur.v_candidate_volume v
 WHERE c.id_node = n.id
   AND c.id_node = v.id_node;

SELECT c.id, sum(l.volume)
  FROM centaur.v_candidate c,
       centaur.flooded f,
       centaur.v_conduit l
 WHERE l.id = f.id_link
   AND c.id_node = f.id_node
 GROUP BY(c.id);

CREATE OR REPLACE VIEW centaur.v_flooded AS
SELECT f.id_flooded,
       f.id_node as id_node_candidate,
       l.id,
       l.name,
       l.id_node_from,
       l.id_node_to,
       l.geom
  FROM centaur.flooded f,
       centaur.link l	
 WHERE f.id_link = l.id;
