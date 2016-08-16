-- ######################################################3

-- Inspired on: http://stackoverflow.com/a/54362/2066215
-- Related: http://stackoverflow.com/q/38975449/2066215


create or replace function node_subtree (integer)
returns setof node as
$BODY$
DECLARE results record;
        upstream record;
	temp RECORD;
BEGIN
  SELECT INTO results n.id, n.elevation, n.name, n.taken, n.geom 
    FROM node n,
	 link l
   WHERE l.id_node_to = $1
     AND l.id_node_from = n.id;
  IF FOUND THEN
    RETURN NEXT results;
    FOR upstream IN SELECT id_node_from AS id
                      FROM link
                     WHERE id_node_to = $1
      LOOP
        FOR temp IN SELECT * FROM node_subtree(upstream.id)
        LOOP
          RETURN NEXT temp;
        END LOOP;
      END LOOP;
  END IF;
  --RETURN NEXT ;
END;
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM node_subgraph(101355);




