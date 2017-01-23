SET search_path TO coimbra, public;


-- ############################################################################
-- Inspired on: http://stackoverflow.com/a/54362/2066215
-- Related: http://stackoverflow.com/q/38975449/2066215
-- Returns the sub-network upstream of a given node
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

-- Testing
SELECT * FROM f_node_subgraph(101355);


-- ############################################################################
-- Returns the id of the node with the maximum value for the expression: 
-- upstream storage volume * contributing area / number of sub-catchments
-- Contributing area and number of sub-catchment are optional
-- $1 : id of node of interest - if not null, only the upstream sub-network is considered
-- $2 : if true use the contributing area
-- $3 : if true use the number of sub-catchments
CREATE OR REPLACE FUNCTION f_optimal (INTEGER, BOOLEAN, BOOLEAN)
RETURNS INTEGER AS
$BODY$
DECLARE max NUMERIC;
	query VARCHAR;
BEGIN
	query := 'SELECT v.id'       ||
		 '  FROM v_candidate v ';

	-- Is there a node of interest?
	IF $1 IS NOT NULL THEN
		query := query ||
		 '  JOIN f_node_subgraph(' || $1 || ') s ' ||
		 '    ON (v.id = s.id)';
	END IF;

	IF $2 AND $3 THEN
		query := query ||	   
		 ' ORDER BY v.flooded_volume * v.served_area / v.num_subcatchments DESC ';
	ELSIF $2 THEN
		query := query ||	   
		 ' ORDER BY v.flooded_volume * v.served_area DESC ';
	ELSIF $3 THEN
		query := query ||	   
		 ' ORDER BY v.flooded_volume / v.num_subcatchments DESC ';
	ELSE 
		query := query ||	   
		 ' ORDER BY v.flooded_volume DESC ';
	END IF;

	query := query || ' LIMIT 1';
	EXECUTE query INTO max;
	RAISE NOTICE 'The query: % ', query ;
	RETURN max;	
END;
$BODY$ LANGUAGE plpgsql STABLE;



-- ############################################################################
-- Help queries

SELECT v.id, v.flooded_volume, v.contributions, v.flooded_volume * v.contributions AS rank
  FROM v_candidate v 
  JOIN node_subgraph(101355) s
    ON (v.id = s.id)
 ORDER BY rank DESC 
 LIMIT 1;

SELECT * FROM v_candidate WHERE contributions < 0;

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




