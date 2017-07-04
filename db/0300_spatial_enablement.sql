-- SELECT postgis_full_version();

-- Set search path to desired schema
SET search_path TO <schema>, public;

-- Enable PostGIS (includes raster)
CREATE EXTENSION postgis;
-- Enable Topology
CREATE EXTENSION postgis_topology;

-- Columns
ALTER TABLE node ADD COLUMN geom GEOMETRY(Point,3035);
ALTER TABLE link ADD COLUMN geom GEOMETRY(Linestring,3035);
ALTER TABLE subcatchment ADD COLUMN geom GEOMETRY(Polygon,3035);

-- Indexes
CREATE INDEX node_gix ON node USING GIST (geom);
CREATE INDEX link_gix ON link USING GIST (geom);
CREATE INDEX subcatchment_gix ON subcatchment USING GIST (geom);

-- Create nodes
CREATE OR REPLACE FUNCTION create_nodes() RETURNS NUMERIC AS $$
  DECLARE
    ret NUMERIC;
  BEGIN
	UPDATE node n
	   SET geom = ST_SetSRID(ST_MakePoint(c.x, c.y), 3035)
	  FROM coordinates c
	 WHERE c.id_node = n.id;
	 SELECT COUNT(*) INTO ret FROM node WHERE geom IS NULL;
	 RETURN ret;
  END;
$$ LANGUAGE plpgsql;


-- Create polygons
CREATE OR REPLACE FUNCTION create_polygons() RETURNS NUMERIC AS $$
  DECLARE
    subcatch_rec RECORD;
    poly_rec RECORD;
    line GEOMETRY;
    ret NUMERIC;
  BEGIN
    FOR subcatch_rec IN SELECT id FROM subcatchment LOOP

	-- Initialise line
	line := ST_GeomFromText('LINESTRING(0 0, 0 0)', 3035);

	-- Loop through the points of this catchment
	FOR poly_rec IN 
	  SELECT x,y 
	    FROM polygon 
	   WHERE id_subcatchment = subcatch_rec.id
        LOOP
          line := ST_AddPoint(line, 
		ST_GeomFromText('POINT(' || poly_rec.x || ' ' || poly_rec.y || ')', 3035));
        END LOOP;

	-- Remove initialising points
	line := ST_RemovePoint(line, 0);
	line := ST_RemovePoint(line, 0);
                        
	UPDATE subcatchment 
           SET geom = ST_MakePolygon(ST_AddPoint(line, ST_StartPoint(line)))
         WHERE id = subcatch_rec.id;

    END LOOP;
    
    SELECT COUNT(*) INTO ret FROM subcatchment WHERE geom IS NULL;
    RETURN ret;
  END;
$$ LANGUAGE plpgsql;


-- Create links
CREATE OR REPLACE FUNCTION create_links() RETURNS NUMERIC AS $$
  DECLARE
    ret NUMERIC;
  BEGIN
	UPDATE link l
	   SET geom = ST_SetSRID(ST_LineFromMultiPoint(ST_Union(
		 (SELECT geom FROM node WHERE id = l.id_node_from),
		 (SELECT geom FROM node WHERE id = l.id_node_to))),
		3035);
	SELECT COUNT(*) INTO ret FROM link WHERE geom IS NULL;
	RETURN ret;
  END;
$$ LANGUAGE plpgsql;

