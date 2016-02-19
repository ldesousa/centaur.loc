
-- Identify outlets
SELECT *
  FROM centaur.node
 WHERE id
NOT IN (SELECT id_node_from
          FROM centaur.link);

SELECT * FROM centaur.outfall;


-- Gawasser-See

SELECT *
  FROM centaur.link
 WHERE id_node_to = 2047439543;