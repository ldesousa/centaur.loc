SELECT * 
  FROM coimbra.node
 WHERE name LIKE '75';
 
 -- Nodes flooded by node 64 (or 75)
SELECT n2.id, n2.name
  FROM coimbra.flooded f,
  	   coimbra.node n,
  	   coimbra.link l,
  	   coimbra.node n2
 WHERE n.name LIKE '75'
   AND n.id = f.id_node
   AND l.id = f.id_link
   AND n2.id = l.id_node_to;
   
-- Links arriving at node 55   
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
   
   