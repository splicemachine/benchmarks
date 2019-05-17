SET SCHEMA ##SCHEMA##;
elapsedtime on;

call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'LINEITEM', null, '##DSRC##/TPCH/##SCALE##/lineitem', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'ORDERS',   null, '##DSRC##/TPCH/##SCALE##/orders',   '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CUSTOMER', null, '##DSRC##/TPCH/##SCALE##/customer', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'PARTSUPP', null, '##DSRC##/TPCH/##SCALE##/partsupp', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'SUPPLIER', null, '##DSRC##/TPCH/##SCALE##/supplier', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'PART',     null, '##DSRC##/TPCH/##SCALE##/part',     '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'REGION',   null, '##DSRC##/TPCH/##SCALE##/region',   '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
call SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'NATION',   null, '##DSRC##/TPCH/##SCALE##/nation',   '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
