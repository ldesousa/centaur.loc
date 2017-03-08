SET search_path TO alcantara, public;

CREATE OR REPLACE VIEW v_node_degree AS
SELECT f.id_node_from AS id_node,
       COALESCE(f.count, 0) + COALESCE(t.count, 0) AS degree
  FROM  (SELECT id_node_from, COUNT(*) 
	   FROM alcantara.link 
	  GROUP BY id_node_from) f
  FULL OUTER JOIN	
        (SELECT id_node_to, COUNT(*) 
	   FROM alcantara.link 
	  GROUP BY id_node_to) t
    ON t.id_node_to = f.id_node_from;  

SELECT AVG(degree),
       STDDEV(degree),       
       MAX(degree),
       MIN(degree) 
  FROM v_node_degree;



