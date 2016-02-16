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

-- Create polygons
CREATE OR REPLACE FUNCTION centaur.create_polygons() RETURNS VOID AS $$
  DECLARE
    subcatch_rec RECORD;
    poly_rec RECORD;
    line GEOMETRY;
  BEGIN
    FOR subcatch_rec IN SELECT id FROM centaur.subcatchment LOOP

	-- Initialise line
	line := ST_GeomFromText('LINESTRING(0 0, 0 0)', 3035);

	-- Loop through the points of this catchment
	FOR poly_rec IN 
	  SELECT x,y 
	    FROM centaur.polygon 
	   WHERE id_subcatchment = subcatch_rec.id
        LOOP
          line := ST_AddPoint(line, 
		ST_GeomFromText('POINT(' || poly_rec.x || ' ' || poly_rec.y || ')', 3035));
        END LOOP;

	-- Remove initialising points
	line := ST_RemovePoint(line, 0);
	line := ST_RemovePoint(line, 0);
                        
	UPDATE centaur.subcatchment 
           SET geom = ST_MakePolygon(ST_AddPoint(line, ST_StartPoint(line)))
         WHERE id = subcatch_rec.id;

    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql;

SELECT centaur.create_polygons();

-- Check if something was missing
SELECT COUNT(*) FROM centaur.subcatchment WHERE geom IS NULL;

-- Create links
UPDATE centaur.link l
   SET geom = ST_SetSRID(ST_LineFromMultiPoint(ST_Union(
	 (SELECT geom FROM centaur.node WHERE id = l.id_node_from),
	 (SELECT geom FROM centaur.node WHERE id = l.id_node_to))),
	3035);

-- Check if something was missing
SELECT COUNT(*) FROM centaur.link WHERE geom IS NULL;





-- Annotations - do not run these
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


SELECT ST_GeomFromText('', 3035);


SELECT COUNT(*), id_subcatchment FROM centaur.polygon GROUP BY id_subcatchment ORDER BY count;

SELECT * FROM centaur.polygon WHERE id_subcatchment = 1416155336;

CREATE TABLE centaur.poly_temp
( 
  id SERIAL NOT NULL,
  geom GEOMETRY(POLYGON,3035),
  CONSTRAINT pk_poly_temp PRIMARY KEY (id)
);

INSERT INTO centaur.poly_temp (geom) VALUES
(ST_GeomFromText(
'POLYGON((667327.838 210139.157,
         667337.661 210132.281, 
         667344.373 210136.865, 
         667343.227 210149.961,
         667327.838 210139.157))', 3035));