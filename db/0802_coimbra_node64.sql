-- Nodes flooded by node 64
SELECT n2.id, n2.name
  FROM coimbra.flooded f,
  	   coimbra.node n,
  	   coimbra.link l,
  	   coimbra.node n2
 WHERE n.name LIKE '64'
   AND n.id = f.id_node
   AND l.id = f.id_link
   AND n2.id = l.id_node_to;
   
-- Links arriving at node 55   
SELECT *
FROM coimbra.link
WHERE id_node_to = -488094952