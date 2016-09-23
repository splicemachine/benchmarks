set schema TPCH;
elapsedtime on;
call SYSCS_UTIL.COLLECT_SCHEMA_STATISTICS('TPCH', false);
