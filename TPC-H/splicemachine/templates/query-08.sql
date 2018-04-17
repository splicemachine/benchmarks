SET SCHEMA ##SCHEMA##;
elapsedtime on;
-- QUERY 08
select
	o_year,
	sum(case
		when nation = 'BRAZIL' then volume
		else 0
	end) / sum(volume) as mkt_share
from
	(
		select
			year(o_orderdate) as o_year,
			l_extendedprice * (1 - l_discount) as volume,
			n2.n_name as nation

                from --SPLICE-PROPERTIES joinOrder=FIXED
                         lineitem --SPLICE-PROPERTIES index=L_PART_IDX
                         ,part --SPLICE-PROPERTIES joinStrategy=MERGE
                         ,supplier --SPLICE-PROPERTIES joinStrategy=BROADCAST
                         ,orders --SPLICE-PROPERTIES joinStrategy=BROADCAST
                         ,customer --SPLICE-PROPERTIES joinStrategy=BROADCAST
                         ,nation n1 --SPLICE-PROPERTIES joinStrategy=BROADCAST
                         ,nation n2 --SPLICE-PROPERTIES joinStrategy=BROADCAST
                         ,region --SPLICE-PROPERTIES joinStrategy=BROADCAST
		where
			p_partkey = l_partkey
			and s_suppkey = l_suppkey
			and l_orderkey = o_orderkey
			and o_custkey = c_custkey
			and c_nationkey = n1.n_nationkey
			and n1.n_regionkey = r_regionkey
			and r_name = 'AMERICA'
			and s_nationkey = n2.n_nationkey
			and o_orderdate between date('1995-01-01') and date('1996-12-31')
			and p_type = 'ECONOMY ANODIZED STEEL'
	) as all_nations
group by
	o_year
order by
	o_year
-- END OF QUERY
;
