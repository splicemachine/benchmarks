SET SCHEMA ##SCHEMA##;
elapsedtime on;
-- TPC-DS QUERY 97
with ssci as (
select ss_customer_sk customer_sk
      ,ss_item_sk item_sk
from store_sales,date_dim
where ss_sold_date_sk = d_date_sk
  and d_month_seq between 1212 and 1212 + 11
group by ss_customer_sk
        ,ss_item_sk),
csci as(
 select cs_bill_customer_sk customer_sk
      ,cs_item_sk item_sk
from catalog_sales,date_dim
where cs_sold_date_sk = d_date_sk
  and d_month_seq between 1212 and 1212 + 11
group by cs_bill_customer_sk
        ,cs_item_sk)
select top 100 sum(case when ssci_customer_sk is not null and csci_customer_sk is null then 1 else 0 end) store_only
      ,sum(case when ssci_customer_sk is null and csci_customer_sk is not null then 1 else 0 end) catalog_only
      ,sum(case when ssci_customer_sk is not null and csci_customer_sk is not null then 1 else 0 end) store_and_catalog
from (
  select ssci.customer_sk as ssci_customer_sk, ssci.item_sk as ssci_item_sk,csci.customer_sk as csci_customer_sk,csci.item_sk as csci_item_sk 
  from ssci left outer join csci on (ssci.customer_sk=csci.customer_sk and ssci.item_sk = csci.item_sk) 
  union all select ssci.customer_sk as ssci_customer_sk, ssci.item_sk as ssci_item_sk,csci.customer_sk as csci_customer_sk,csci.item_sk as csci_item_sk 
  from ssci right outer join csci on (ssci.customer_sk=csci.customer_sk and ssci.item_sk = csci.item_sk)
  where ssci.customer_sk is null and ssci.item_sk is null and (csci.customer_sk is not null or csci.item_sk is not null)
) a;

