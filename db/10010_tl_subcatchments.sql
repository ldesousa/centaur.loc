DELETE FROM toulouse.subcatchment;

-- Identify duplicate names
SELECT id, COUNT(*) AS count 
  FROM veolia.subcatchment 
 GROUP BY id 
HAVING COUNT(*) > 1;

-- Fix duplicates
UPDATE veolia.subcatchment
   SET id = id + 10000000
 WHERE gid = (SELECT gid 
                FROM veolia.subcatchment 
               WHERE id = 14021 
               LIMIT 1);

UPDATE veolia.subcatchment
   SET id = id + 10000000
 WHERE gid = (SELECT gid 
                FROM veolia.subcatchment 
               WHERE id = 22008 
               LIMIT 1);

UPDATE veolia.subcatchment
   SET id = id + 10000000
 WHERE gid = (SELECT gid 
                FROM veolia.subcatchment 
               WHERE id = 27035 
               LIMIT 1);

UPDATE veolia.subcatchment
   SET id = id + 10000000
 WHERE gid = (SELECT gid 
                FROM veolia.subcatchment 
               WHERE id = 35062 
               LIMIT 1);


-- Make sure SRID is correct
SELECT UpdateGeometrySRID('veolia', 'subcatchment','geom', 3035);

-- Insert the data
INSERT INTO toulouse.subcatchment (id, name, geom)
SELECT gid, id, (ST_DUMP(geom)).geom::geometry(Polygon, 3035)
  FROM veolia.subcatchment;

-- Calculate areas
UPDATE toulouse.subcatchment
   SET area = ST_Area(geom);





