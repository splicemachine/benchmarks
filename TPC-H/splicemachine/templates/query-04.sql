SET SCHEMA ##SCHEMA##;
elapsedtime on;
-- QUERY 04
select
	o_orderpriority,
	count(*) as order_count
from
	orders
where
	o_orderdate >= date('1993-07-01')
	and o_orderdate < add_months('1993-07-01',3)
	and exists (
		select
			*
		from
			lineitem
		where
			l_orderkey = o_orderkey
			and l_commitdate < l_receiptdate
	)
group by
	o_orderpriority
order by
	o_orderpriority
-- END OF QUERY
;
