SET SCHEMA ##SCHEMA##;
elapsedtime on;
-- TPC-DS QUERY 48

with a as ( select * from  STORE_SALES, CUSTOMER_DEMOGRAPHICS where 
   CD_DEMO_SK = SS_CDEMO_SK
      AND 
         CD_MARITAL_STATUS = 'M'
   AND 
      CD_EDUCATION_STATUS = '4 yr Degree'
         AND 
   SS_SALES_PRICE BETWEEN 100.00 AND 150.00  

union all

select * from STORE_SALES, CUSTOMER_DEMOGRAPHICS where


cd_demo_sk = ss_cdemo_sk
   and 
   cd_marital_status = 'D'
   and 
   cd_education_status = 'Primary'
   and 
ss_sales_price between 50.00 and 100.00 


union all

select * from STORE_SALES, CUSTOMER_DEMOGRAPHICS where

    cd_demo_sk = ss_cdemo_sk
  and 
   cd_marital_status = 'U'
   and 
   cd_education_status = 'Advanced Degree'
   and 
ss_sales_price between 150.00 and 200.00 ),

 b as (select * from a, CUSTOMER_ADDRESS
 where
	SS_ADDR_SK = CA_ADDRESS_SK
	  AND
	  CA_COUNTRY = 'United States'
	  AND
	  (CA_STATE = 'KY' OR CA_STATE = 'GA' OR CA_STATE = 'NM')
	  AND SS_NET_PROFIT BETWEEN 0 AND 2000  

	union all
    select * from a, CUSTOMER_ADDRESS where
	SS_ADDR_SK = CA_ADDRESS_SK
	  AND
	  CA_COUNTRY = 'United States'
	  AND
	  (CA_STATE = 'MT' OR CA_STATE = 'OR' OR CA_STATE = 'IN')
	  AND SS_NET_PROFIT BETWEEN 150 AND 3000 

	union all
    select * from a, CUSTOMER_ADDRESS where
	SS_ADDR_SK = CA_ADDRESS_SK
	  AND
	  CA_COUNTRY = 'United States'
	  AND
	  (CA_STATE = 'WI' OR CA_STATE = 'MO'OR CA_STATE = 'WV')
	  AND SS_NET_PROFIT BETWEEN 50 AND 25000   
)

select SUM(SS_QUANTITY) from  b
, STORE --splice-properties joinStrategy=SORTMERGE
, DATE_DIM --splice-properties joinStrategy=SORTMERGE
where
 S_STORE_SK = SS_STORE_SK
 AND  SS_SOLD_DATE_SK = D_DATE_SK AND D_YEAR = 1998;

