DELETE FROM toulouse.conduit;
DELETE FROM toulouse.link WHERE id IN (SELECT id FROM veolia.conduit);


-- Make sure SRID is correct
SELECT UpdateGeometrySRID('veolia', 'conduit','geom', 3035);


-- Missing nodes
SELECT id_up
  FROM veolia.conduit
 WHERE id_up NOT IN (SELECT id FROM toulouse.node);

SELECT id_down
  FROM veolia.conduit
 WHERE id_up NOT IN (SELECT id FROM toulouse.node);


-- Insert links
INSERT INTO toulouse.link (id, geom, id_node_from, id_node_to)
SELECT id, 
       ST_Force2D((ST_DUMP(geom)).geom)::geometry(LineString, 3035), 
       id_up, 
       id_down 
  FROM veolia.conduit
 WHERE id_up IN (SELECT id FROM toulouse.node)
   AND id_down IN (SELECT id FROM toulouse.node);


-- Insert sections
SELECT DISTINCT(shape) FROM veolia.conduit; 

INSERT INTO toulouse.xsection (id_link, shape, geom1)
SELECT id, 'CIRCULAR', diameter
  FROM veolia.conduit
 WHERE (shape LIKE 'Circular'
    OR  shape LIKE 'Unknown')
   AND id_up IN (SELECT id FROM toulouse.node)
   AND id_down IN (SELECT id FROM toulouse.node);

INSERT INTO toulouse.xsection (id_link, shape, geom1, geom2)
SELECT id, 
       'SQUARE', 
       CAST (width AS NUMERIC), 
       CAST (height AS NUMERIC)
  FROM veolia.conduit
 WHERE shape LIKE 'Square'
   AND id_up IN (SELECT id FROM toulouse.node)
   AND id_down IN (SELECT id FROM toulouse.node);


-- Insert conduits
INSERT INTO toulouse.conduit (id_link, length)
SELECT id, 
       ST_Length(geom)
  FROM veolia.conduit
 WHERE id_up IN (SELECT id FROM toulouse.node)
   AND id_down IN (SELECT id FROM toulouse.node);


SELECT COUNT(*) FROM toulouse.conduit;

SELECT COUNT(*) FROM veolia.conduit;


