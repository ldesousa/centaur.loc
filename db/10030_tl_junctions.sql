DELETE FROM toulouse.junction;
DELETE FROM toulouse.node WHERE id < 1000000;


-- Make sure SRID is correct
SELECT UpdateGeometrySRID('veolia', 'junction','geom', 3035);

-- Insert nodes
INSERT INTO toulouse.node (id, geom, elevation, name)
SELECT gid, 
       ST_Force2d(geom), 
       ST_Z(geom), 
       gid 
  FROM veolia.junction;

-- Insert outfalls
INSERT INTO toulouse.junction (id_node, max_depth)
SELECT gid, 
       profondeur
  FROM veolia.junction;

