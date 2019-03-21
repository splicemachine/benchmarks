SET SCHEMA ##SCHEMA##;
elapsedtime on;
-- TPC-DS QUERY 41
--select top 100 distinct(i_product_name)
 select top 100 i_product_name
 from item i1 ,
 (select distinct i_manufact
        from item
        where (
        ((i_category = 'Women' and
        (i_color = 'orchid' or i_color = 'papaya') and
        (i_units = 'Pound' or i_units = 'Lb') and
        (i_size = 'petite' or i_size = 'medium')
        ) or
        (i_category = 'Women' and
        (i_color = 'burlywood' or i_color = 'navy') and
        (i_units = 'Bundle' or i_units = 'Each') and
        (i_size = 'N/A' or i_size = 'extra large')
        ) or
        (i_category = 'Men' and
        (i_color = 'bisque' or i_color = 'azure') and
        (i_units = 'N/A' or i_units = 'Tsp') and
        (i_size = 'small' or i_size = 'large')
        ) or
        (i_category = 'Men' and
        (i_color = 'chocolate' or i_color = 'cornflower') and
        (i_units = 'Bunch' or i_units = 'Gross') and
        (i_size = 'petite' or i_size = 'medium')
        ))) or
       (
        ((i_category = 'Women' and
        (i_color = 'salmon' or i_color = 'midnight') and
        (i_units = 'Oz' or i_units = 'Box') and
        (i_size = 'petite' or i_size = 'medium')
        ) or
        (i_category = 'Women' and
        (i_color = 'snow' or i_color = 'steel') and
        (i_units = 'Carton' or i_units = 'Tbl') and
        (i_size = 'N/A' or i_size = 'extra large')
        ) or
        (i_category = 'Men' and
        (i_color = 'purple' or i_color = 'gainsboro') and
        (i_units = 'Dram' or i_units = 'Unknown') and
        (i_size = 'small' or i_size = 'large')
        ) or
        (i_category = 'Men' and
        (i_color = 'metallic' or i_color = 'forest') and
        (i_units = 'Gram' or i_units = 'Ounce') and
        (i_size = 'petite' or i_size = 'medium')
        ))) ) AS item_cnt
    where  i_manufact_id between 742 and 742+40
    and i1.i_manufact = item_cnt.i_manufact
    group by i_product_name
 	order by i_product_name
 ;
