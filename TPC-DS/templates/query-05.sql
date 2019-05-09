SET SCHEMA ##SCHEMA##;	
elapsedtime on;	
-- TPC-DS QUERY 05
##EXPLAIN##
with ssr as
(select s_store_id,
   sum(sales_price) as sales,
   sum(profit) as profit,
   sum(return_amt) as returns,
   sum(net_loss) as profit_loss
 from
   ( select  s_store_id,
       ss_sold_date_sk  as date_sk,
       ss_ext_sales_price as sales_price,
       ss_net_profit as profit,
       cast(0 as decimal(7,2)) as return_amt,
       cast(0 as decimal(7,2)) as net_loss
     from store_sales, store, date_dim
     where s_store_sk = ss_store_sk and
           ss_sold_date_sk = d_date_sk
           and d_date between cast('1998-08-04' as date)
           and (cast('1998-08-04' as date) + 14 )

     union all
     select s_store_id,
       sr_returned_date_sk as date_sk,
       cast(0 as decimal(7,2)) as sales_price,
       cast(0 as decimal(7,2)) as profit,
       sr_return_amt as return_amt,
       sr_net_loss as net_loss
     from store_returns, store, date_dim
     where s_store_sk = sr_store_sk and
           sr_returned_date_sk = d_date_sk
           and d_date between cast('1998-08-04' as date)
           and (cast('1998-08-04' as date) + 14 )
   ) salesreturns
 group by s_store_id)
  ,
    csr as
  (select cp_catalog_page_id,
     sum(sales_price) as sales,
     sum(profit) as profit,
     sum(return_amt) as returns,
     sum(net_loss) as profit_loss
   from
     ( select  cp_catalog_page_id,
         cs_sold_date_sk  as date_sk,
         cs_ext_sales_price as sales_price,
         cs_net_profit as profit,
         cast(0 as decimal(7,2)) as return_amt,
         cast(0 as decimal(7,2)) as net_loss
       from catalog_sales, date_dim, catalog_page
       where cs_sold_date_sk = d_date_sk
             and d_date between cast('1998-08-04' as date)
             and (cast('1998-08-04' as date) + 14 )
             and cs_catalog_page_sk = cp_catalog_page_sk
       union all
       select cp_catalog_page_id,
         cr_returned_date_sk as date_sk,
         cast(0 as decimal(7,2)) as sales_price,
         cast(0 as decimal(7,2)) as profit,
         cr_return_amount as return_amt,
         cr_net_loss as net_loss
       from catalog_returns, date_dim, catalog_page
       where cr_returned_date_sk = d_date_sk
             and d_date between cast('1998-08-04' as date)
             and (cast('1998-08-04' as date) + 14 )
             and cp_catalog_page_sk = cr_catalog_page_sk

     ) salesreturns
   group by cp_catalog_page_id)
  ,
    wsr as
  (select web_site_id,
     sum(sales_price) as sales,
     sum(profit) as profit,
     sum(return_amt) as returns,
     sum(net_loss) as profit_loss
   from
     ( select  web_site_id,
         ws_sold_date_sk  as date_sk,
         ws_ext_sales_price as sales_price,
         ws_net_profit as profit,
         cast(0 as decimal(7,2)) as return_amt,
         cast(0 as decimal(7,2)) as net_loss
       from web_sales, date_dim, web_site
       where ws_sold_date_sk = d_date_sk
             and d_date between cast('1998-08-04' as date)
             and (cast('1998-08-04' as date) + 14 )
             and web_site_sk = ws_web_site_sk

       union all
       select web_site_id,
         wr_returned_date_sk as date_sk,
         cast(0 as decimal(7,2)) as sales_price,
         cast(0 as decimal(7,2)) as profit,
         wr_return_amt as return_amt,
         wr_net_loss as net_loss
       from web_returns left outer join web_sales on
                                                    ( wr_item_sk = ws_item_sk
                                                      and wr_order_number = ws_order_number), date_dim, web_site
       where wr_returned_date_sk = d_date_sk
             and d_date between cast('1998-08-04' as date)
             and (cast('1998-08-04' as date) + 14 )
             and web_site_sk = ws_web_site_sk

     ) salesreturns
   group by web_site_id)
select top 100 channel
  , id
  , sum(sales) as sales
  , sum(returns) as returns
  , sum(profit) as profit
from
  (select 'store channel' as channel
     , 'store' || s_store_id as id
     , sales
     , returns
     , (profit - profit_loss) as profit
   from   ssr
   union all
   select 'catalog channel' as channel
     , 'catalog_page' || cp_catalog_page_id as id
     , sales
     , returns
     , (profit - profit_loss) as profit
   from  csr
   union all
   select 'web channel' as channel
     , 'web_site' || web_site_id as id
     , sales
     , returns
     , (profit - profit_loss) as profit
   from   wsr
  ) x
group by rollup (channel, id)
order by channel
  ,id
;
