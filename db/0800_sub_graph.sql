-- ######################################################3

-- Inspired on: http://stackoverflow.com/a/54362/2066215
-- Related: http://stackoverflow.com/q/38975449/2066215

CREATE OR REPLACE FUNCTION node_subgraph (INTEGER)
RETURNS SETOF node AS
$BODY$
DECLARE upstream record;
	temp RECORD;
BEGIN
  RETURN QUERY
  SELECT n.id, n.elevation, n.name, n.taken, n.geom 
    FROM node n,
	 link l
   WHERE l.id_node_to = $1
     AND l.id_node_from = n.id;
  IF FOUND THEN
    FOR upstream IN SELECT id_node_from AS id
                      FROM link
                     WHERE id_node_to = $1
      LOOP
	RAISE NOTICE 'Going after node %', upstream.id;
        FOR temp IN SELECT * FROM node_subgraph(upstream.id)
        LOOP
          RETURN NEXT temp;
        END LOOP;
      END LOOP;
  END IF;
  RETURN;
END;
$BODY$ LANGUAGE plpgsql STABLE;


SELECT * FROM node_subgraph(101355);


