SET SCHEMA ##SCHEMA##;
elapsedtime on;

-- TODO: create any needed TPC-DS indexes here when loading data before creating indexes

create index web_sales_idx1 ON  web_sales (ws_order_number, ws_warehouse_sk);