SET SCHEMA ##SCHEMA##;
elapsedtime on;
-- TPC-DS QUERY 69

/* put the exists subquery with its outer table into a derived table helps to flatten the not exists subquery */
/* query that couldn't finish in 8.7 mins now can finish in ~40s */
select top 100
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3
from --splice-properties joinOrder=fixed
(select * from 
   (select * from customer c
    where exists (select *
                  from store_sales,date_dim
                  where c.c_customer_sk = ss_customer_sk and
                        ss_sold_date_sk = d_date_sk and
                        d_year = 1999 and
                        d_moy between 1 and 1+2)) c
 where
 not exists (select *
            from web_sales,date_dim
            where c.c_customer_sk = ws_bill_customer_sk and
                  ws_sold_date_sk = d_date_sk and
                  d_year = 1999 and
                  d_moy between 1 and 1+2)
 and 
 not exists (select *
            from catalog_sales,date_dim
            where c.c_customer_sk = cs_ship_customer_sk and
                  cs_sold_date_sk = d_date_sk and
                  d_year = 1999 and
                  d_moy between 1 and 1+2)
) as C, customer_address ca,customer_demographics
 where
  c.c_current_addr_sk = ca.ca_address_sk and
  ca_state in ('CO','IL','MN') and
  cd_demo_sk = c.c_current_cdemo_sk 
 group by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating
 order by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating
 ;    
