SET search_path TO alcantara, public;

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

-- SELECT COUNT(*) FROM v_conduit_slope;

-- Computes the maximum flow of each conduit, using Maning's formula:
-- Qmax = (area/n) * Rh^2/3 * S^1/2
-- Where:
-- n is roughness (0.015 by default)
-- Rh is the hidraulic radius, i.e. area / perimeter
-- S is the slope of the conduit   
CREATE OR REPLACE VIEW v_conduit_q_max AS
SELECT c.id_link,
       s.id_node_from,
       s.id_node_to,
       area,
       perimeter,
       area * c.length::double precision AS volume,
       (1/c.roughness) * area * power(area / perimeter, 2.0/3.0) * sqrt(abs(s.slope)) AS q_max
  FROM conduit c,
       v_conduit_slope s,
       xsection x,
       LATERAL (SELECT pi() * ((x.geom1/2) ^ 2),
                       2 * pi() * (x.geom1/2) )
		    AS s1(area, perimeter)
 WHERE c.id_link = s.id_link
   AND c.id_link = x.id_link
   AND x.shape LIKE 'CIRC%'
   AND x.geom1 IS NOT NULL
 UNION
SELECT c.id_link,
       s.id_node_from,
       s.id_node_to,
       area,
       perimeter,
       area * c.length::double precision AS volume,
       (1/c.roughness) * area * power(area / perimeter, 2.0/3.0) * sqrt(abs(s.slope)) AS q_max
  FROM conduit c,
       v_conduit_slope s,
       xsection x,
       LATERAL (SELECT pi() * ((x.geom1/2) * (x.geom2/2)),
                       2 * pi() * sqrt((x.geom1^2 + x.geom2^2)/2) )
		    AS s1(area, perimeter)
 WHERE c.id_link = s.id_link
   AND c.id_link = x.id_link
   AND x.shape LIKE 'EGG%'
   AND x.geom1 IS NOT NULL
   AND x.geom2 IS NOT NULL
 UNION
SELECT c.id_link,
       s.id_node_from,
       s.id_node_to,
       area,
       perimeter,
       area * c.length::double precision AS volume,
       (1/c.roughness) * area * power(area / perimeter, 2.0/3.0) * sqrt(abs(s.slope)) AS q_max
  FROM conduit c,
       v_conduit_slope s,
       xsection x,
       LATERAL (SELECT x.geom1 * x.geom2,
                       2 * x.geom1 + 2 * x.geom2 )
		    AS s1(area, perimeter)
 WHERE c.id_link = s.id_link
   AND c.id_link = x.id_link
   AND x.shape LIKE 'RECT%'
   AND x.geom1 IS NOT NULL
   AND x.geom2 IS NOT NULL;
   
-- SELECT COUNT(*) FROM v_conduit_q_max;

-- This view computes the heigth offset produced at the upstream node by the
-- energy line (dynamic assumption); this is the energy slope times the pipe
-- length. Note also that the energy slope is calculated by averaging the 
-- maximum flows (q_max) of the pipe itself plus of those immideatly upstream 
-- and downstream.  
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
       c.q_p,
       s.slope,
       q.area,
       q.perimeter,
       q.volume,
       q.q_max,
       ((((q.q_max + COALESCE(lf.q_max, 0) + COALESCE(lt.q_max, 0)) / 
         (1 + COALESCE((lt.q_max + 1) / (lt.q_max + 1), 0) + COALESCE((lt.q_max + 1) / (lt.q_max + 1), 0))) * 
        0.015 / ((q.area / q.perimeter) ^ (2/3::double precision))) ^ 2) * c.length AS energy_line_offset
  FROM conduit c,
       v_conduit_slope s,
       v_conduit_q_max q,
       link l
  LEFT JOIN (SELECT q.id_node_to, 
		    MAX(q.q_max) AS q_max
	       FROM v_conduit_q_max q
	      GROUP BY q.id_node_to) lf
    ON l.id_node_from = lf.id_node_to
  LEFT JOIN (SELECT q.id_node_from, 
		    MAX(q.q_max) AS q_max
	       FROM v_conduit_q_max q
	      GROUP BY q.id_node_from) lt
    ON l.id_node_to = lt.id_node_from
 WHERE c.id_link = l.id
   AND c.id_link = s.id_link
   AND c.id_link = q.id_link;

-- SELECT COUNT(*) FROM v_conduit;
 
-- Check volumes
SELECT c.id, sum(l.volume)
  FROM v_candidate c,
       flooded f,
       v_conduit l
 WHERE l.id = f.id_link
   AND c.id = f.id_node
 GROUP BY(c.id);


