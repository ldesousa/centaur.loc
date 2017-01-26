SET search_path TO coimbra, public;

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
       LATERAL (SELECT pi() * ((x.geom1/2) * (x.geom2/2)),
                       2 * pi() * sqrt((x.geom1^2 + x.geom2^2)/2) )
		    AS s1(area, perimeter)
 WHERE x.id_link = c.id
   AND x.shape LIKE 'EGG%'
   AND x.geom1 IS NOT NULL
   AND x.geom2 IS NOT NULL
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
   AND x.geom1 IS NOT NULL
   AND x.geom2 IS NOT NULL;
   
 
-- Check volumes
SELECT c.id, sum(l.volume)
  FROM v_candidate c,
       flooded f,
       v_conduit l
 WHERE l.id = f.id_link
   AND c.id = f.id_node
 GROUP BY(c.id);
