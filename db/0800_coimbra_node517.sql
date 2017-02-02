SELECT v.id_node from v_candidate v where v.name like '517'; 


SELECT v.id_node, v.name, v.flooded_volume, v.served_area
  FROM v_candidate v 
  JOIN f_node_subgraph(554472168) s
    ON (v.id_node = s.id)
 ORDER BY v.norm_flooded_volume DESC;