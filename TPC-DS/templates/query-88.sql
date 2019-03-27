SET SCHEMA ##SCHEMA##;
elapsedtime on;

--intermediate table
CREATE TABLE intermediate88 AS
  SELECT t_hour,
         t_minute
  FROM   store_sales,
         household_demographics,
         time_dim,
         store
  WHERE  ss_sold_time_sk = time_dim.t_time_sk
         AND ss_hdemo_sk = household_demographics.hd_demo_sk
         AND ss_store_sk = s_store_sk
         AND ( ( household_demographics.hd_dep_count = 3
                 AND household_demographics.hd_vehicle_count <= 3 + 2 )
                OR ( household_demographics.hd_dep_count = 0
                     AND household_demographics.hd_vehicle_count <= 0 + 2 )
                OR ( household_demographics.hd_dep_count = 1
                     AND household_demographics.hd_vehicle_count <= 1 + 2 ) )
         AND store.s_store_name = 'ese';

-- modified query
SELECT *
FROM   (SELECT COUNT(*) h8_30_to_9
        FROM   intermediate88 time_dim
        WHERE  time_dim.t_hour = 8
               AND time_dim.t_minute >= 30) s1,
       (SELECT COUNT(*) h9_to_9_30
        FROM   intermediate88 time_dim
        WHERE  time_dim.t_hour = 9
               AND time_dim.t_minute < 30) s2,
       (SELECT COUNT(*) h9_30_to_10
        FROM   intermediate88 time_dim
        WHERE  time_dim.t_hour = 9
               AND time_dim.t_minute >= 30) s3,
       (SELECT COUNT(*) h10_to_10_30
        FROM   intermediate88 time_dim
        WHERE  time_dim.t_hour = 10
               AND time_dim.t_minute < 30) s4,
       (SELECT COUNT(*) h10_30_to_11
        FROM   intermediate88 time_dim
        WHERE  time_dim.t_hour = 10
               AND time_dim.t_minute >= 30) s5,
       (SELECT COUNT(*) h11_to_11_30
        FROM   intermediate88 time_dim
        WHERE  time_dim.t_hour = 11
               AND time_dim.t_minute < 30) s6,
       (SELECT COUNT(*) h11_30_to_12
        FROM   intermediate88 time_dim
        WHERE  time_dim.t_hour = 11
               AND time_dim.t_minute >= 30) s7,
       (SELECT COUNT(*) h12_to_12_30
        FROM   intermediate88 time_dim
        WHERE  time_dim.t_hour = 12
               AND time_dim.t_minute < 30) s8;

DROP TABLE intermediate88;
