set schema ##SCHEMA##;
elapsedtime on;
call SYSCS_UTIL.COLLECT_SCHEMA_STATISTICS('##SCHEMA##', false);
