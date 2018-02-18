-- User (it must be super user to create the Postgis extension
-- DROP ROLE centaur
CREATE ROLE centaur PASSWORD 'secret' SUPERUSER;

-- Database: centaur
-- DROP DATABASE centaur;
CREATE DATABASE centaur
  WITH OWNER = centaur
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_GB.UTF-8'
       LC_CTYPE = 'en_GB.UTF-8'
       CONNECTION LIMIT = -1;