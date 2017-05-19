SET search_path TO <schema>, public;

-- ############################################################################
-- Returns the id of the node with the maximum value for the expression: 
-- upstream storage volume * served area / number of sub-catchments
-- Served area and number of sub-catchment are optional.
-- $1 : id of node of interest - if not null, only the upstream sub-network is considered
-- $2 : if true use the served area
-- $3 : if true use the number of sub-catchments

CREATE OR REPLACE FUNCTION f_optimal (INTEGER, BOOLEAN, BOOLEAN)
RETURNS INTEGER AS
$BODY$
DECLARE max NUMERIC;
	query VARCHAR;
BEGIN
	query := 'SELECT v.id_node'       ||
		 '  FROM v_candidate v ';

	-- Is there a node of interest?
	IF $1 IS NOT NULL THEN
		query := query ||
		 '  JOIN f_node_subgraph(' || $1 || ') s ' ||
		 '    ON (v.id_node = s.id)';
	END IF;

	IF $2 AND $3 THEN
		query := query ||	   
		 ' ORDER BY v.norm_flooded_volume * v.norm_served_area / ' ||
		 ' v.norm_num_subcatchments DESC ';
	ELSIF $2 THEN
		query := query ||	   
		 ' ORDER BY v.norm_flooded_volume * v.norm_served_area DESC ';
	ELSIF $3 THEN
		query := query ||	   
		 ' ORDER BY v.norm_flooded_volume / v.norm_num_subcatchments DESC ';
	ELSE 
		query := query ||	   
		 ' ORDER BY v.norm_flooded_volume DESC ';
	END IF;

	query := query || ' LIMIT 1';
	EXECUTE query INTO max;
	RAISE NOTICE 'The query: % ', query ;
	RETURN max;	
END;
$BODY$ LANGUAGE plpgsql STABLE;


-- ############################################################################
-- Returns the id of the node with the maximum value for the expression: 
-- upstream storage volume / served area 
-- $1 : id of node of interest - if not null, only the upstream sub-network is considered

CREATE OR REPLACE FUNCTION f_optimal_over_area (INTEGER)
RETURNS INTEGER AS
$BODY$
DECLARE max NUMERIC;
	query VARCHAR;
BEGIN
	query := 'SELECT v.id_node'       ||
		     '  FROM v_candidate v ';

	-- Is there a node of interest?
	IF $1 IS NOT NULL THEN
		query := query ||
		 '  JOIN f_node_subgraph(' || $1 || ') s ' ||
		 '    ON (v.id_node = s.id)';
	END IF;

	query := query ||
	     ' WHERE v.norm_served_area > 0 '
		 ' ORDER BY v.norm_flooded_volume / v.norm_served_area DESC ';

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






