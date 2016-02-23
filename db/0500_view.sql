
DROP VIEW centaur.v_weir;
DROP VIEW centaur.v_pump;
DROP VIEW centaur.v_conduit;
DROP VIEW centaur.v_outfall;
DROP VIEW centaur.v_storage;
DROP VIEW centaur.v_junction;


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
       c.max_flow 
  FROM centaur.conduit c,
       centaur.link l	
 WHERE c.id_link = l.id;

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
