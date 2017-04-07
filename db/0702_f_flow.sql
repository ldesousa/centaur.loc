SET search_path TO coimbra, public;

-- Adding new field, only use in testing
-- ALTER TABLE conduit ADD COLUMN q_p NUMERIC;

-- ############################################################################
-- Note that this calculation can only take place when v_conduit_q_max exists.
DROP FUNCTION f_flow(INTEGER);
CREATE OR REPLACE FUNCTION f_flow (INTEGER)
RETURNS void AS
$BODY$
DECLARE 
    down_q_p NUMERIC;
    up_conduits NUMERIC;
    cond v_conduit%ROWTYPE;
    sum_q_p NUMERIC;
    this_q_p NUMERIC;
    this_q_max NUMERIC;
    next_id INTEGER;
BEGIN
	RAISE NOTICE 'Processing conduits upstream of: % ', $1 ;
	-- Downstream flow
	SELECT SUM(c.q_p) INTO down_q_p
	  FROM node n,
	       v_conduit c
	 WHERE c.id_node_from = n.id
	   AND n.id = $1;
	   
	-- Count number of upstream conduits
	SELECT COUNT(*) INTO up_conduits
	  FROM node n,
	       v_conduit c
	 WHERE c.id_node_to = n.id
	   AND n.id = $1;
	 
	-- The case where there is more than one conduit upstream
	IF up_conduits > 1 THEN
		FOR cond IN 
			SELECT * 
			  FROM v_conduit c
			 WHERE c.id_node_to = $1 
		LOOP
		    -- Get the minimum flow for parallel conduits
			SELECT SUM(q_max) INTO sum_q_p
			  FROM node n,
			       v_conduit c
			 WHERE c.id_node_to = n.id
		       AND n.id = $1; 
		    --   AND c.id <> cond.id;
		    -- Update the result
		    IF down_q_p IS NULL THEN
		    	this_q_p := cond.q_max;
		    ELSIF sum_q_p = 0 THEN
		    	this_q_p := 0;
		    ELSE
		    	this_q_p := cond.q_max * down_q_p / sum_q_p; -- down_q_p / (1 + min_q_max / cond.q_max)
		    END IF;
		    UPDATE conduit   
		       SET q_p = this_q_p
		     WHERE id_link = cond.id;
		    IF cond.id_node_from IS NOT NULL THEN
		    	PERFORM f_flow(cond.id_node_from);
		    END IF;
		END LOOP;
	-- The case where there is only one conduit upstream	
	ELSE
		SELECT q_max, id_node_from INTO this_q_max, next_id FROM v_conduit WHERE id_node_to = $1;
		IF down_q_p IS NULL THEN
	    	down_q_p := this_q_max;
	    END IF;
		UPDATE conduit c
	       SET q_p = LEAST(down_q_p, this_q_max)
		 WHERE id_link = (SELECT l.id FROM link l WHERE l.id_node_to = $1);
		IF next_id IS NOT NULL THEN
			PERFORM f_flow(next_id);
	    END IF;		
	END IF;
	RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;

-- Testing with node 64 (Coimbra)
SELECT f_flow(-545475706);

-- Run maximum flow calculation starting on all outlets
SELECT f_flow(id)
  FROM node
 WHERE id NOT IN (SELECT id_node_from 
                    FROM link);  

                    
SELECT id, name, q_p, q_max FROM v_conduit WHERE q_p IS NOT NULL;
