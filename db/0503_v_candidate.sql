SET search_path TO coimbra, public;

CREATE OR REPLACE VIEW v_candidate_volume AS
SELECT c.id_node, 
       SUM(l.volume * COALESCE(f.volume_fraction, 1)) AS flooded_volume
  FROM candidate c,
       flooded f,
       v_conduit l	
 WHERE l.id = f.id_link
   AND c.id_node = f.id_node
 GROUP BY(c.id_node);

-- This view needs to materialised, otherwise it takes took long to run.
-- DROP MATERIALIZED VIEW v_candidate_upstream;
CREATE MATERIALIZED VIEW v_candidate_upstream AS
SELECT n.id, 
       (SELECT SUM(c.area * c.imperv / 100)
          FROM subcatchment c,
               (SELECT DISTINCT s.id 
                  FROM f_node_subgraph(n.id) s
		 UNION
		SELECT n.id) u
         WHERE c.id_node_outlet = u.id) 
         AS served_area,
       (SELECT COUNT(*)
          FROM subcatchment c,
               (SELECT DISTINCT s.id 
                  FROM f_node_subgraph(n.id) s
		 UNION
		SELECT n.id) u
         WHERE c.id_node_outlet = u.id) 
         AS num_subcatchments
  FROM node n;

-- Refresh if needed
-- REFRESH MATERIALIZED VIEW v_candidate_upstream;

-- v_candidate: a wrapper around v_candidate_upstream because of the taken flag
-- DROP VIEW v_candidate;
CREATE OR REPLACE VIEW v_candidate AS
SELECT n.id, 
       c.outflow_elevation,
       n.name,
       n.geom,
       v.flooded_volume,
       u.served_area,
       u.num_subcatchments
  FROM candidate c,
       node n,
       v_candidate_volume v,
       v_candidate_upstream u
 WHERE c.id_node = n.id
   AND c.id_node = v.id_node
   AND c.id_node = u.id
   AND u.served_area IS NOT NULL
   AND u.num_subcatchments > 0
   AND (n.taken = FALSE OR n.taken IS NULL);
   
  
