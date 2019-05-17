SET SCHEMA ##SCHEMA##;
elapsedtime on;

CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CALL_CENTER', null, '##DSRC##/TPCDS/##SCALE##/original/call_center.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CATALOG_PAGE', null, '##DSRC##/TPCDS/##SCALE##/original/catalog_page.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CATALOG_RETURNS', null, '##DSRC##/TPCDS/##SCALE##/original/catalog_returns.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CATALOG_SALES', null, '##DSRC##/TPCDS/##SCALE##/original/catalog_sales.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CUSTOMER', null, '##DSRC##/TPCDS/##SCALE##/original/customer.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CUSTOMER_ADDRESS', null, '##DSRC##/TPCDS/##SCALE##/original/customer_address.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'CUSTOMER_DEMOGRAPHICS', null, '##DSRC##/TPCDS/##SCALE##/original/customer_demographics.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'DATE_DIM', null, '##DSRC##/TPCDS/##SCALE##/original/date_dim.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'HOUSEHOLD_DEMOGRAPHICS', null, '##DSRC##/TPCDS/##SCALE##/original/household_demographics.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'INCOME_BAND', null, '##DSRC##/TPCDS/##SCALE##/original/income_band.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'INVENTORY', null, '##DSRC##/TPCDS/##SCALE##/original/inventory.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'ITEM', null, '##DSRC##/TPCDS/##SCALE##/original/item.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'PROMOTION', null, '##DSRC##/TPCDS/##SCALE##/original/promotion.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'REASON', null, '##DSRC##/TPCDS/##SCALE##/original/reason.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'SHIP_MODE', null, '##DSRC##/TPCDS/##SCALE##/original/ship_mode.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'STORE', null, '##DSRC##/TPCDS/##SCALE##/original/store.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'STORE_RETURNS', null, '##DSRC##/TPCDS/##SCALE##/original/store_returns.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'STORE_SALES', null, '##DSRC##/TPCDS/##SCALE##/original/store_sales.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'TIME_DIM', null, '##DSRC##/TPCDS/##SCALE##/original/time_dim.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WAREHOUSE', null, '##DSRC##/TPCDS/##SCALE##/original/warehouse.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WEB_PAGE', null, '##DSRC##/TPCDS/##SCALE##/original/web_page.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WEB_RETURNS', null, '##DSRC##/TPCDS/##SCALE##/original/web_returns.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WEB_SALES', null, '##DSRC##/TPCDS/##SCALE##/original/web_sales.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);
CALL SYSCS_UTIL.BULK_IMPORT_HFILE ('##SCHEMA##', 'WEB_SITE', null, '##DSRC##/TPCDS/##SCALE##/original/web_site.dat', '|', null, null, null, null, 0, '/tmp', true, null, '/tmp/##SCHEMA##_##SCALE##', false);

