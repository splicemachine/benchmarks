SET SCHEMA ##SCHEMA##;
elapsedtime on;
-- TPC-DS QUERY 14
##EXPLAIN##
with avg_sales as
 (select avg(quantity*list_price) average_sales
  from (select ss_quantity quantity
             ,ss_list_price list_price
       from store_sales
           ,date_dim
       where ss_sold_date_sk = d_date_sk
         and d_year between 1998 and 1998 + 2
       union all
       select cs_quantity quantity
             ,cs_list_price list_price
       from catalog_sales
           ,date_dim
       where cs_sold_date_sk = d_date_sk
         and d_year between 1998 and 1998 + 2
       union all
       select ws_quantity quantity
             ,ws_list_price list_price
       from web_sales
           ,date_dim
       where ws_sold_date_sk = d_date_sk
         and d_year between 1998 and 1998 + 2) x)
  select top 100 channel, i_brand_id,i_class_id,i_category_id,sum(sales), sum(number_sales)
 from
 (
       select 'store' channel, i_brand_id,i_class_id
             ,i_category_id,sum(ss_quantity*ss_list_price) sales
             , count(*) number_sales
       from store_sales
           ,item
           ,date_dim
       where ss_item_sk = i_item_sk
         and ss_sold_date_sk = d_date_sk
         and d_year = 1998+2
         and d_moy = 11
       group by i_brand_id,i_class_id,i_category_id
       having sum(ss_quantity*ss_list_price) > (select average_sales from avg_sales)
       union all
       select 'catalog' channel, i_brand_id,i_class_id,i_category_id, sum(cs_quantity*cs_list_price) sales, count(*) number_sales
       from catalog_sales
           ,item
           ,date_dim
       where cs_item_sk = i_item_sk
         and cs_sold_date_sk = d_date_sk
         and d_year = 1998+2
         and d_moy = 11
       group by i_brand_id,i_class_id,i_category_id
       having sum(cs_quantity*cs_list_price) > (select average_sales from avg_sales)
       union all
       select 'web' channel, i_brand_id,i_class_id,i_category_id, sum(ws_quantity*ws_list_price) sales , count(*) number_sales
       from web_sales
           ,item
           ,date_dim
       where ws_item_sk = i_item_sk
         and ws_sold_date_sk = d_date_sk
         and d_year = 1998+2
         and d_moy = 11
       group by i_brand_id,i_class_id,i_category_id
       having sum(ws_quantity*ws_list_price) > (select average_sales from avg_sales)
 ) y
 where exists (select 1
 	from store_sales
     ,item iss
     ,date_dim d1
 	where ss_item_sk = iss.i_item_sk
   and ss_sold_date_sk = d1.d_date_sk
   and d1.d_year between 1998 AND 1998 + 2
   and iss.i_brand_id = y.i_brand_id
   and iss.i_class_id = y.i_class_id
   and iss.i_category_id = y.i_category_id
	)
 and exists ( select 1
 from catalog_sales
     ,item ics
     ,date_dim d2
 where cs_item_sk = ics.i_item_sk
   and cs_sold_date_sk = d2.d_date_sk
   and d2.d_year between 1998 AND 1998 + 2
   and ics.i_brand_id = y.i_brand_id
   and ics.i_class_id = y.i_class_id
   and ics.i_category_id = y.i_category_id
 )
 and exists ( select 1
 from web_sales
     ,item iws
     ,date_dim d3
 where ws_item_sk = iws.i_item_sk
   and ws_sold_date_sk = d3.d_date_sk
   and d3.d_year between 1998 AND 1998 + 2
   and iws.i_brand_id = y.i_brand_id
   and iws.i_class_id = y.i_class_id
   and iws.i_category_id = y.i_category_id
 )
  group by rollup (channel, i_brand_id,i_class_id,i_category_id)
 order by channel,i_brand_id,i_class_id,i_category_id
 ;
