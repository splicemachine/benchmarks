EXPLAIN SELECT
  N_NAME,
  SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS REVENUE
FROM
  TPCH.CUSTOMER,
  TPCH.ORDERS,
  TPCH.LINEITEM,
  TPCH.SUPPLIER,
  TPCH.NATION,
  TPCH.REGION
WHERE
  C_CUSTKEY = O_CUSTKEY
  AND L_ORDERKEY = O_ORDERKEY
  AND L_SUPPKEY = S_SUPPKEY
  AND C_NATIONKEY = S_NATIONKEY
  AND S_NATIONKEY = N_NATIONKEY
  AND N_REGIONKEY = R_REGIONKEY
  AND R_NAME = 'ASIA'
  AND O_ORDERDATE >= TO_DATE('1994-01-01')
  AND O_ORDERDATE < TO_DATE('1995-01-01')
GROUP BY
  N_NAME
ORDER BY
  REVENUE DESC
;
