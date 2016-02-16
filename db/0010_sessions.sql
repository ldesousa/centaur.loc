SELECT usesysid, usename FROM pg_stat_activity;

SELECT * FROM pg_stat_activity;

SELECT usename, datname, application_name, query_start, waiting FROM pg_stat_activity;

SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE application_name LIKE '';