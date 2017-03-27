SET search_path TO coimbra, public;

DROP VIEW v_conduit CASCADE;
DROP VIEW v_conduit_q_max;
DROP VIEW v_conduit_slope;

CREATE OR REPLACE VIEW v_conduit_slope AS
SELECT c.id_link,
       l.id_node_from,
       l.id_node_to,
       (nf.elevation - nt.elevation) / 
        sqrt((st_y(st_pointn(l.geom, 2)) - st_y(st_pointn(l.geom, 1)))^2 + 
             (st_x(st_pointn(l.geom, 2)) - st_x(st_pointn(l.geom, 1)))^2) AS slope
  FROM conduit c,
       link l,
       node nf,
       node nt
 WHERE c.id_link = l.id
   AND nf.id = l.id_node_from
   AND nt.id = l.id_node_to;


CREATE OR REPLACE VIEW v_conduit_q_max AS
SELECT c.id_link,
       s.id_node_from,
       s.id_node_to,
       area,
       perimeter,
       area * c.length AS volume,
       1.0/0.015 * area * power(area / perimeter, 2.0/3.0) * power(abs(s.slope), 1.0/2.0) AS q_max
  FROM conduit c,
       xsection x,
       v_conduit_slope s,
       LATERAL (SELECT pi() * ((x.geom1/2) ^ 2),
                       2 * pi() * (x.geom1/2) )
		    AS s1(area, perimeter)
 WHERE x.id_link = c.id_link
   AND x.shape LIKE 'CIRC%'
   AND x.geom1 IS NOT NULL
 UNION
SELECT c.id_link,
       s.id_node_from,
       s.id_node_to,
       area,
       perimeter,
       area * c.length AS volume,
       1.0/0.015 * power(area / perimeter, 2.0/3.0) * power(abs(s.slope), 1.0/2.0) AS q_max
  FROM conduit c,
       xsection x,
       v_conduit_slope s,
       LATERAL (SELECT pi() * ((x.geom1/2) * (x.geom2/2)),
                       2 * pi() * sqrt((x.geom1^2 + x.geom2^2)/2) )
		    AS s1(area, perimeter)
 WHERE x.id_link = c.id_link
   AND x.shape LIKE 'EGG%'
   AND x.geom1 IS NOT NULL
   AND x.geom2 IS NOT NULL
 UNION
SELECT c.id_link,
       s.id_node_from,
       s.id_node_to,
       area,
       perimeter,
       area * c.length AS volume,
       1.0/0.015 * power(area / perimeter, 2.0/3.0) * power(abs(s.slope), 1.0/2.0) AS q_max
  FROM conduit c,
       xsection x,
       v_conduit_slope s,
       LATERAL (SELECT x.geom1 * x.geom2,
                       2 * x.geom1 + 2 * x.geom2 )
		    AS s1(area, perimeter)
 WHERE x.id_link = c.id_link
   AND x.shape LIKE 'RECT%'
   AND x.geom1 IS NOT NULL
   AND x.geom2 IS NOT NULL;
   
   
CREATE OR REPLACE VIEW v_conduit AS
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
       s.slope,
       q.area,
       q.perimeter,
       (((q.q_max + lf.q_max + lt.q_max) / 3) * 0.015 / ((q.area / q.perimeter) ^ (2/3))) ^ 2 AS energy_slope
  FROM conduit c,
       link l,
       v_conduit_slope s,
       v_conduit_q_max q,
       (SELECT q.id_node_to, 
               MAX(q.q_max) AS q_max
          FROM v_conduit_q_max q
         GROUP BY q.id_node_to) lf,
       (SELECT q.id_node_from, 
               MAX(q.q_max) AS q_max
          FROM v_conduit_q_max q
         GROUP BY q.id_node_from) lt
 WHERE c.id_link = l.id
   AND c.id_link = s.id_link
   AND c.id_link = q.id_link
   AND lf.id_node_to = l.id_node_from
   AND lt.id_node_from = l.id_node_to;
   
 
-- Check volumes
SELECT c.id, sum(l.volume)
  FROM v_candidate c,
       flooded f,
       v_conduit l
 WHERE l.id = f.id_link
   AND c.id = f.id_node
 GROUP BY(c.id);
