SET SCHEMA ##SCHEMA##;
elapsedtime on;

call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'LINEITEM', null, 's3a://splice-benchmark-data/flat/TPCH/##SCALE##/lineitem', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'ORDERS',   null, 's3a://splice-benchmark-data/flat/TPCH/##SCALE##/orders',   '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CUSTOMER', null, 's3a://splice-benchmark-data/flat/TPCH/##SCALE##/customer', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'PARTSUPP', null, 's3a://splice-benchmark-data/flat/TPCH/##SCALE##/partsupp', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'SUPPLIER', null, 's3a://splice-benchmark-data/flat/TPCH/##SCALE##/supplier', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'PART',     null, 's3a://splice-benchmark-data/flat/TPCH/##SCALE##/part',     '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'REGION',   null, 's3a://splice-benchmark-data/flat/TPCH/##SCALE##/region',   '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'NATION',   null, 's3a://splice-benchmark-data/flat/TPCH/##SCALE##/nation',   '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
