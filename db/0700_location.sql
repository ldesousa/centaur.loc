-- ############################################################################
-- Find best n gates by area and volume
CREATE OR REPLACE FUNCTION f_best_n_gates_vol_area (n_gates INT) 
RETURNS BOOLEAN AS $$
DECLARE 
	max_id INT;
	f_vol NUMERIC;
	f_area NUMERIC;
	nodes NUMERIC;
	tot_vol NUMERIC;
	tot_nodes INT;
BEGIN
	CREATE TABLE temp_n_gates_vol_area (id INTEGER, vol NUMERIC, n_nodes INTEGER);

	WHILE n_gates > 0 LOOP

		SELECT id INTO max_id
		  FROM centaur.v_candidate 
		 WHERE (flooded_volume * served_area) = 
			   (SELECT MAX(flooded_volume * served_area)
		          FROM centaur.v_candidate
                 WHERE id NOT IN      -- Nodes flooded by existing gates
			           (SELECT l.id_node_to 
                          FROM centaur.flooded f,
                               centaur.link l
                         WHERE f.id_link = l.id
                           AND f.id_node IN 
                               (SELECT id 
                                  FROM temp_n_gates_vol_area)));

		-- Get the storage potential and area
		SELECT flooded_volume, served_area INTO f_vol, f_area
		  FROM centaur.v_candidate 
		 WHERE id = max_id;

		-- Count nodes affected
		SELECT COUNT(*) INTO nodes 
		  FROM centaur.flooded f,
		       centaur.link l
		 WHERE f.id_link = l.id
		   AND f.id_node = max_id;

		INSERT INTO temp_n_gates_vol_area VALUES(max_id, f_vol, nodes);
		RAISE NOTICE E'Selected node % with % m3, serving % ha and flooding % nodes', 
			max_id, ROUND(f_vol,1), ROUND(f_area,1), nodes;
	
		n_gates := n_gates - 1;
	END LOOP;

	SELECT SUM(vol) INTO tot_vol FROM temp_n_gates_vol_area;
	SELECT SUM(n_nodes) INTO tot_nodes FROM temp_n_gates_vol_area;
	RAISE NOTICE E'\nTotal volume: % m3 Nodes affected: %', 
		tot_vol, tot_nodes;

	DROP TABLE temp_n_gates_vol_area;
	RETURN TRUE;

END; $$ LANGUAGE plpgsql;

-- Testing
SELECT f_best_n_gates_vol_area(5);


-- ############################################################################
-- Find best n gates by volume
-- Find best n gates by area and volume
CREATE OR REPLACE FUNCTION f_best_n_gates_vol (n_gates INT) 
RETURNS BOOLEAN AS $$
DECLARE 
	max_id INT;
	f_vol NUMERIC;
	f_area NUMERIC;
	nodes NUMERIC;
	tot_vol NUMERIC;
	tot_nodes INT;
BEGIN
	CREATE TABLE temp_n_gates_vol (id INTEGER, vol NUMERIC, n_nodes INTEGER);

	WHILE n_gates > 0 LOOP

		SELECT id INTO max_id
		  FROM centaur.v_candidate 
		 WHERE flooded_volume = 
			   (SELECT MAX(flooded_volume)
		          FROM centaur.v_candidate
                 WHERE id NOT IN      -- Nodes flooded by existing gates
			           (SELECT l.id_node_to 
                          FROM centaur.flooded f,
                               centaur.link l
                         WHERE f.id_link = l.id
                           AND f.id_node IN 
                               (SELECT id 
                                  FROM temp_n_gates_vol)));

		-- Get the storage potential and area
		SELECT flooded_volume, served_area INTO f_vol, f_area
		  FROM centaur.v_candidate 
		 WHERE id = max_id;

		-- Count nodes affected
		SELECT COUNT(*) INTO nodes 
		  FROM centaur.flooded f,
		       centaur.link l
		 WHERE f.id_link = l.id
		   AND f.id_node = max_id;

		INSERT INTO temp_n_gates_vol VALUES(max_id, f_vol, nodes);
		RAISE NOTICE E'Selected node % with % m3, serving % ha and flooding % nodes', 
			max_id, ROUND(f_vol,1), ROUND(f_area,1), nodes;
	
		n_gates := n_gates - 1;
	END LOOP;

	SELECT SUM(vol) INTO tot_vol FROM temp_n_gates_vol;
	SELECT SUM(n_nodes) INTO tot_nodes FROM temp_n_gates_vol;
	RAISE NOTICE E'\nTotal volume: % m3 Nodes affected: %', 
		tot_vol, tot_nodes;

	DROP TABLE temp_n_gates_vol;
	RETURN TRUE;

END; $$ LANGUAGE plpgsql;

-- Testing
SELECT f_best_n_gates_vol(5);



-- ############################################################################
-- Helper queries

select sum(length) from centaur.conduit;

select sum(flooded_volume) from centaur.v_candidate;

SELECT id, (flooded_volume * served_area) as rank
  FROM centaur.v_candidate
 ORDER BY rank DESC;
-- 144791

SELECT id, MAX(flooded_volume * served_area)
  FROM centaur.v_candidate
 GROUP BY id;



SELECT id 
  FROM centaur.v_candidate 
 WHERE (flooded_volume * served_area) = 
       (SELECT MAX(flooded_volume * served_area)
          FROM centaur.v_candidate);

SELECT c.id, flooded_volume * served_area as rank
  FROM centaur.candidate c,
       centaur.flooded f
 WHERE c.id = f.id_node
   AND 
 ORDER BY rank DESC;

-- Find nodes flooded by a candidate
SELECT l.id_node_to
  FROM centaur.flooded f,
       centaur.link l
 WHERE f.id_link = l.id
   AND f.id_node = 144791;

-- Find best excluding the ones already flooded
SELECT id, (flooded_volume * served_area) as rank
  FROM centaur.v_candidate
 WHERE id NOT IN (SELECT l.id_node_to
                    FROM centaur.flooded f,
                         centaur.link l
                   WHERE f.id_link = l.id
                     AND f.id_node = 144791)
 ORDER BY rank DESC;



