SET search_path TO coimbra, public;

-- Links flooded be a certain node
SELECT f.name,
       f.energy_line_offset,
       p.roughness,
       p.area,
       p.perimeter,
       p.slope,
       p.volume,
       p.q_max,
       p.q_p
  FROM v_flooded f
       v_conduit p
 WHERE f.id = p.id
   AND c.name LIKE '64';


 
 -- Nodes flooded by a certain node
SELECT n2.id, n2.name
  FROM coimbra.flooded f,
       coimbra.node n,
       coimbra.link l,
       coimbra.node n2
 WHERE n.name LIKE '75'
   AND n.id = f.id_node
   AND l.id = f.id_link
   AND n2.id = l.id_node_to;
   
-- Links arriving at a certain node   
SELECT *
FROM coimbra.link
WHERE id_node_to = -488094952

 -- Links flooded by nodes upstream of node 517
SELECT n.name as node, 
	   l.name as link
  FROM coimbra.flooded f,
  	   coimbra.node n,
  	   coimbra.link l
 WHERE n.name IN ('112', '113', '137', '144', '206', '308', '320',
				  '363', '369', '515', '1040', '1_561', '1_668')
   AND n.id = f.id_node
   AND l.id = f.id_link;
   
 
SELECT * FROM coimbra.f_optimal(554472168, false, false)

SELECT v.id_node
  FROM v_candidate v
  JOIN f_node_subgraph(554472168) s
    ON (v.id_node = s.id)
 ORDER BY v.norm_flooded_volume DESC;

SELECT coimbra.f_node_subgraph(554472168);

SELECT * from v_candidate where name like '64';

SELECT * from v_conduit where q_p IS NOt NULL;


