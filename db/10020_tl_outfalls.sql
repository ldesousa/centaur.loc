DELETE FROM toulouse.outfall;
DELETE FROM toulouse.node WHERE id IN (SELECt id FROM veolia.outfall);


-- Make sure SRID is correct
SELECT UpdateGeometrySRID('veolia', 'outfall','geom', 3035);

-- Insert nodes
INSERT INTO toulouse.node (id, geom, elevation, name)
SELECT id, 
       ST_Force2d(ST_SetSRID(geom, 3035)), 
       ST_Z(geom), 
       id 
  FROM veolia.outfall;

-- Insert outfalls
INSERT INTO toulouse.outfall (id_node, type, stage_date, gated)
SELECT id, 
       typres,
       annee_pose,
       NULL
  FROM veolia.outfall;