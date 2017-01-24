SET search_path TO coimbra, public;

-- ############################################################################
-- Harbours the temporary contribution data during computation.
-- Every time a gate is sited the contributions much subtracted to account for
-- the rain water volume already under control.

-- DROP TABLE contribution_temp;

CREATE TABLE contribution_temp
(
  id serial NOT NULL,
  id_node integer NOT NULL,
  id_subcatchment integer NOT NULL,
  value numeric NOT NULL,
  CONSTRAINT pk_contribution_temp PRIMARY KEY (id),
  CONSTRAINT fk_contribution_temp_candidate FOREIGN KEY (id_node)
      REFERENCES coimbra.candidate (id_node) MATCH FULL
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT fk_contribution_temp_subcatchment FOREIGN KEY (id_subcatchment)
      REFERENCES coimbra.subcatchment (id) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT unq_contribution_temp UNIQUE (id_node, id_subcatchment)
);

-- ############################################################################
-- Resets the temporary contribution data

CREATE OR REPLACE FUNCTION p_reset_contributions ()
RETURNS void AS $$
BEGIN
    DELETE FROM contribution_temp;

    INSERT INTO contribution_temp
		(id, id_node, id_subcatchment, value)
    SELECT id, id_node, id_subcatchment, value
      FROM contribution;
END;
$$ LANGUAGE plpgsql;


-- ############################################################################
-- Helper queries

SELECT COUNT(*) FROM contribution;

SELECT COUNT(*) FROM contribution_temp;

SELECT SUM(value) FROM contribution;

SELECT SUM(value) FROM contribution_temp;

SELECT FROM p_reset_contributions();