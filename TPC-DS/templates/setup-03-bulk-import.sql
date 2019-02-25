SET SCHEMA ##SCHEMA##;
elapsedtime on;

CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CALL_CENTER', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/call_center', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CATALOG_PAGE', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/catalog_page', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CATALOG_RETURNS', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/catalog_returns', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CATALOG_SALES', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/catalog_sales', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CUSTOMER', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/customer', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CUSTOMER_ADDRESS', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/customer_address', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CUSTOMER_DEMOGRAPHICS', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/customer_demographics', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'DATE_DIM', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/date_dim', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'HOUSEHOLD_DEMOGRAPHICS', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/household_demographics', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'INCOME_BAND', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/income_band', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'INVENTORY', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/inventory', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'ITEM', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/item', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'PROMOTION', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/promotion', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'REASON', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/reason', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'SHIP_MODE', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/ship_mode', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'STORE', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/store', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'STORE_RETURNS', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/store_returns', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'STORE_SALES', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/store_sales', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'TIME_DIM', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/time_dim', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WAREHOUSE', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/warehouse', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WEB_PAGE', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/web_page', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WEB_RETURNS', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/web_returns', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WEB_SALES', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/web_sales', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WEB_SITE', null, 's3a://splice-benchmark-data/flat/TPCDS/##SCALE##/original/web_site', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);

