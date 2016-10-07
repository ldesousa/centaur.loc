DELETE FROM toulouse.junction;
DELETE FROM toulouse.node WHERE id IN (SELECT id FROM veolia.junction);


-- Make sure SRID is correct
SELECT UpdateGeometrySRID('veolia', 'junction','geom', 3035);

-- Undo matching ids
UPDATE veolia.junction
   SET id = id + 10000000
 WHERE id IN (SELECT o.id 
		FROM veolia.outfall o,
		     veolia.junction j
	       WHERE o.id = j.id);

-- Insert nodes
INSERT INTO toulouse.node (id, geom, elevation, name)
SELECT id, 
       ST_Force2d(geom), 
       ST_Z(geom), 
       id 
  FROM veolia.junction;

-- Insert outfalls
INSERT INTO toulouse.junction (id_node, max_depth)
SELECT id, 
       profondeur
  FROM veolia.junction;

