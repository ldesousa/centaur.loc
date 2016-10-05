DELETE FROM toulouse.outfall;
DELETE FROM toulouse.node WHERE id < 1000;


-- Make sure SRID is correct
SELECT UpdateGeometrySRID('veolia', 'subcatchment','geom', 3035);

-- Insert nodes
INSERT INTO toulouse.node (id, geom, elevation, name)
SELECT gid + 1000000, 
       ST_Force2d(ST_SetSRID(geom, 3035)), 
       ST_Z(geom), 
       gid 
  FROM veolia.outfall;

-- Insert outfalls
INSERT INTO toulouse.outfall (id_node, type, stage_date, gated)
SELECT gid + 1000000, 
       typres,
       annee_pose,
       NULL
  FROM veolia.outfall;