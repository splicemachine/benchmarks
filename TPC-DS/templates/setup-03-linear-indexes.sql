SET SCHEMA ##SCHEMA##;
elapsedtime on;

-- TODO: create any needed TPC-DS indexes here when loading data before creating indexes

CREATE INDEX catalog_sales_customer_by_date ON catalog_sales(cs_sold_date_sk, cs_ship_customer_sk);
CREATE INDEX web_sales_customer_by_date ON web_sales(ws_sold_date_sk, ws_bill_customer_sk);
CREATE INDEX store_sales_customer_by_date ON store_sales(ss_sold_date_sk, ss_customer_sk);
