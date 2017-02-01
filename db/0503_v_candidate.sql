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

--DROP VIEW v_candidate_volume_normalised;
CREATE OR REPLACE VIEW v_candidate_volume_normalised AS
SELECT v.id_node,
       v.flooded_volume,
       v.flooded_volume / (SELECT MAX(flooded_volume) 
                             FROM v_candidate_volume) AS norm_flooded_volume
  FROM v_candidate_volume v;

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


-- DROP VIEW v_candidate_volume_normalised;
CREATE OR REPLACE VIEW v_candidate_area_normalised AS
SELECT v.id as id_node,
       v.served_area,
       v.served_area / (SELECT MAX(served_area) 
                          FROM v_candidate_upstream) AS norm_served_area
  FROM v_candidate_upstream v;

-- DROP VIEW v_candidate_subcatchments_normalised;
CREATE OR REPLACE VIEW v_candidate_subcatchments_normalised AS
SELECT v.id as id_node,
       v.num_subcatchments,
       v.num_subcatchments::FLOAT / (SELECT MAX(num_subcatchments) 
                                FROM v_candidate_upstream) AS norm_num_subcatchments
  FROM v_candidate_upstream v;


-- v_candidate: a wrapper around v_candidate_upstream because of the taken flag
-- DROP VIEW v_candidate;
CREATE OR REPLACE VIEW v_candidate AS
SELECT c.id_node, 
       c.outflow_elevation,
       n.name,
       n.geom,
       v.flooded_volume,
       a.served_area,
       s.num_subcatchments,
       v.norm_flooded_volume,
       a.norm_served_area,
       s.norm_num_subcatchments
  FROM candidate c,
       node n,
       v_candidate_volume_normalised v,
       v_candidate_area_normalised a,
       v_candidate_subcatchments_normalised s
 WHERE c.id_node = n.id
   AND c.id_node = v.id_node
   AND c.id_node = a.id_node
   AND c.id_node = s.id_node
   AND a.served_area IS NOT NULL
   AND s.num_subcatchments > 0
   AND (n.taken = FALSE OR n.taken IS NULL);