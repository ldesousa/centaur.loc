SELECT postgis_full_version();

-- Enable PostGIS (includes raster)
CREATE EXTENSION postgis;
-- Enable Topology
CREATE EXTENSION postgis_topology;

-- Columns
ALTER TABLE centaur.node ADD COLUMN geom GEOMETRY(Point,3035);
ALTER TABLE centaur.link ADD COLUMN geom GEOMETRY(Linestring,3035);
ALTER TABLE centaur.subcatchment ADD COLUMN geom GEOMETRY(Polygon,3035);

-- Indexes
CREATE INDEX node_gix ON centaur.node USING GIST (geom);
CREATE INDEX link_gix ON centaur.link USING GIST (geom);
CREATE INDEX subcatchment_gix ON centaur.subcatchment USING GIST (geom);

-- Import nodes
UPDATE centaur.node n
   SET geom = ST_SetSRID(ST_MakePoint(c.x, c.y), 3035)
  FROM centaur.coordinates c
 WHERE c.id_node = n.id;

-- Check if something was missing
SELECT COUNT(*) FROM centaur.node WHERE geom IS NULL;

-- Import polygns: does not work
UPDATE centaur.subcatchment s
   SET geom = ST_Union(ST_GeomFromText('POINT(' || p.x || ' ' || p.y || ')'))
  FROM centaur.polygon p
 WHERE p.id_subcatchment = s.id;

-- Create polygons
CREATE OR REPLACE FUNCTION centaur.create_polygons() RETURNS VOID AS $$
  DECLARE
    subcatch_rec RECORD;
    line GEOMETRY;
  BEGIN
    FOR subcatch_rec IN SELECT id FROM centaur.subcatchment LOOP

        line := (SELECT ST_SetSRID(ST_LineFromMultiPoint(
                         ST_Union(ST_GeomFromText('POINT(' || x || ' ' || y || ')'))),
			 3035)
                   FROM centaur.polygon 
                  WHERE id_subcatchment = subcatch_rec.id);
                        
	UPDATE centaur.subcatchment 
           SET geom = ST_MakePolygon(ST_AddPoint(line, ST_StartPoint(line)))
         WHERE id = subcatch_rec.id;

    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql;

SELECT centaur.create_polygons();

-- Import links
SELECT array_to_string(array(select (x, y) from centaur.polygon where id_subcatchment = 1655765), ',');

select (x, y) from centaur.polygon where id_subcatchment = 464779544; 

SELECT ST_GeomFromEWKT('POINT(' || x || ' ' || y || ')') FROM centaur.polygon WHERE id_subcatchment = 1655765;

SELECT ST_MakePolygon(ST_Union(ST_GeomFromText('POINT(' || x || ' ' || y || ')'))) 
  FROM centaur.polygon 
 WHERE id_subcatchment = 2102470699;

SELECT ST_AsText(ST_Union(ST_GeomFromText('POINT(' || x || ' ' || y || ')')))
  FROM centaur.polygon 
 WHERE id_subcatchment = 2102470699;

SELECT ST_AsText(ST_MakePolygon(ST_AddPoint(
	ST_LineFromMultiPoint(ST_Union(ST_GeomFromText('POINT(' || x || ' ' || y || ')'))),
	ST_StartPoint(ST_LineFromMultiPoint(ST_Union(ST_GeomFromText('POINT(' || x || ' ' || y || ')'))))
	)))
  FROM centaur.polygon 
 WHERE id_subcatchment = 2102470699;


SELECT ST_AsText(geom)
  FROM centaur.subcatchment 
 WHERE id = 2102470699;

SELECT ST_Union(ST_GeomFromText('POINT(' || x || ' ' || y || ')')) FROM centaur.polygon;