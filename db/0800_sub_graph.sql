-- ######################################################3

-- Inspired on: http://stackoverflow.com/a/54362/2066215
-- Related: http://stackoverflow.com/q/38975449/2066215

CREATE OR REPLACE FUNCTION f_node_subgraph (INTEGER)
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
	-- RAISE NOTICE 'Going after node %', upstream.id;
        FOR temp IN SELECT * FROM f_node_subgraph(upstream.id)
        LOOP
          RETURN NEXT temp;
        END LOOP;
      END LOOP;
  END IF;
  RETURN;
END;
$BODY$ LANGUAGE plpgsql STABLE;


SELECT * FROM f_node_subgraph(101355);

-- Get max volume * area id 
CREATE OR REPLACE FUNCTION f_max_volume_area (INTEGER)
RETURNS INTEGER AS
$BODY$
BEGIN
	IF $1 IS NULL THEN
		RETURN (SELECT v.id
			  FROM v_candidate v 
			 ORDER BY v.flooded_volume * v.served_area DESC 
			 LIMIT 1);
	ELSE
		RETURN (SELECT v.id
			  FROM v_candidate v 
			  JOIN node_subgraph($1) s
			    ON (v.id = s.id)
			 ORDER BY v.flooded_volume * v.served_area DESC 
			 LIMIT 1);
	END IF;
END;
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM f_max_volume_area(101355);



-- Help queries

SELECT v.id, v.flooded_volume, v.served_area, v.flooded_volume * v.served_area AS rank
  FROM v_candidate v 
  JOIN node_subgraph(101355) s
    ON (v.id = s.id)
 ORDER BY rank DESC 
 LIMIT 1;

SELECT MAX(c.flooded_volume * c.contributions) 
  FROM v_candidate c 
 WHERE c.id IN (SELECT id FROM f_node_subgraph(101355));


SELECT v.id, v.flooded_volume, v.served_area, v.flooded_volume * v.served_area
  FROM v_candidate v 
  JOIN node_subgraph(101355) s
    ON (v.id = s.id);


-- ############################################################
-- Solution with a single query

with recursive path(id_from, id_to, path, cycle) as (
    select 
      l.id_node_from, l.id_node_to, array[l.id_node_from, l.id_node_to], false 
    from link l
  union all
    select
      p.id_from, l.id_node_to, p.path || l.id_node_to, l.id_node_to = any(p.path)
    from link l
    join path p on l.id_node_from = p.id_to and not cycle
)
select * from path where id_to = 101355;




