-- ################################################
-- Annotations related to spatial enablement
-- No need to run these to get the database running

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