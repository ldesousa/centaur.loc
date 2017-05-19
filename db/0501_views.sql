-- Set search path to desired schema
SET search_path TO <schema>, public;

-- DROP VIEW v_weir CASCADE;
-- DROP VIEW v_pump CASCADE;
-- DROP VIEW v_conduit CASCADE;
-- DROP VIEW v_outfall CASCADE;
-- DROP VIEW v_storage CASCADE;
-- DROP VIEW v_junction CASCADE;
-- DROP VIEW v_flooded CASCADE;


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






