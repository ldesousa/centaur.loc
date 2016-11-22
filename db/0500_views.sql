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


CREATE OR REPLACE VIEW v_conduit_common AS
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
       (nf.elevation - nt.elevation) / 
        sqrt((st_y(st_pointn(l.geom, 2)) - st_y(st_pointn(l.geom, 1)))^2 + 
             (st_x(st_pointn(l.geom, 2)) - st_x(st_pointn(l.geom, 1)))^2) AS slope
  FROM conduit c,
       link l,
       xsection x,
       node nf,
       node nt
 WHERE c.id_link = l.id
   AND x.id_link = l.id
   AND nf.id = l.id_node_from
   AND nt.id = l.id_node_to;

-- SELECT * FROM v_conduit_common;

CREATE OR REPLACE VIEW v_conduit AS
SELECT c.*,
       area,
       perimeter,
       area * c.length AS volume,
       1.0/0.015 * power(area / perimeter, 2.0/3.0) * power(abs(slope), 1.0/2.0) AS q_max
  FROM v_conduit_common c,
       xsection x,
       LATERAL (SELECT pi() * ((x.geom1/2) ^ 2),
                       2 * pi() * (x.geom1/2) )
		    AS s1(area, perimeter)
 WHERE x.id_link = c.id
   AND x.shape LIKE 'CIRC%'
   AND x.geom1 IS NOT NULL
 UNION
SELECT c.*,
       area,
       perimeter,
       area * c.length AS volume,
       1.0/0.015 * power(area / perimeter, 2.0/3.0) * power(abs(slope), 1.0/2.0) AS q_max
  FROM v_conduit_common c,
       xsection x,
       LATERAL (SELECT x.geom1 * x.geom2,
                       2 * x.geom1 + 2 * x.geom2 )
		    AS s1(area, perimeter)
 WHERE x.id_link = c.id
   AND x.shape LIKE 'RECT%'
   AND x.geom1 IS NOT NULL;

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
SELECT n.id,
       n.elevation,
       n.name,
       n.geom,
       j.max_depth,
       j.init_depth,
       j.sur_depth,
       j.aponded,
       (c.q_max * 0.015 / ((c.area / c.perimeter) ^ (2/3))) ^ 2 AS energy_slope
  FROM junction j,
       node n,
       v_conduit c,
       link l	
 WHERE j.id_node = n.id
   AND n.id = l.id_node_from
   AND c.id = l.id;

CREATE OR REPLACE VIEW v_candidate_volume AS
SELECT c.id_node, 
       SUM(l.volume * COALESCE(f.volume_fraction, 1)) AS flooded_volume
  FROM candidate c,
       flooded f,
       v_conduit l	
 WHERE l.id = f.id_link
   AND c.id_node = f.id_node
 GROUP BY(c.id_node);

CREATE OR REPLACE VIEW v_candidate_contribution AS
SELECT c.id_node,
       COALESCE(SUM(b.value), 0) AS contributions
  FROM candidate c
  LEFT JOIN contribution b
    ON c.id_node = b.id_node
 GROUP BY(c.id_node);

CREATE OR REPLACE VIEW v_candidate AS
SELECT n.id, 
       c.outflow_elevation,
       n.name,
       n.geom,
       v.flooded_volume,
       c.served_area,
       b.contributions,
       m.count AS num_subcatchments
  FROM candidate c,
       node n,
       v_candidate_volume v,
       v_candidate_contribution b,
       (SELECT t.id_node, 
               COUNT(*) AS count 
          FROM contribution t 
         GROUP BY t.id_node) m
 WHERE c.id_node = n.id
   AND c.id_node = v.id_node
   AND c.id_node = b.id_node
   AND (n.taken = FALSE OR n.taken IS NULL)
   AND c.id_node = m.id_node;

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


-- Check volumes
SELECT c.id, sum(l.volume)
  FROM v_candidate c,
       flooded f,
       v_conduit l
 WHERE l.id = f.id_link
   AND c.id = f.id_node
 GROUP BY(c.id);



--SELECT * FROM coimbra.v_conduit;
