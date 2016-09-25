#!/bin/bash

runloader()
{
    schema=${1}
    table=${2}
    filepath=${3}
    sudo -su hbase HADOOP_CLASSPATH=/usr/hdp/current/phoenix-client/lib/hbase-protocol.jar:/etc/hbase/conf yarn jar /opt/phoenix/default/phoenix-4.8.0-HBase-1.1-client.jar org.apache.phoenix.mapreduce.CsvBulkLoadTool --table ${schema}.${table} --delimiter '|' --input ${filepath} > load-${table}.out 2>&1
    sleep 180
}

runloader "TPCH" "REGION"   "hdfs:///TPCH/100/region/region.tbl"
runloader "TPCH" "NATION"   "hdfs:///TPCH/100/nation/nation.tbl"
runloader "TPCH" "SUPPLIER" "hdfs:///TPCH/100/supplier/supplier.tbl"
runloader "TPCH" "PART"     "hdfs:///TPCH/100/part/part.tbl"
runloader "TPCH" "PARTSUPP" "hdfs:///TPCH/100/partsupp/partsupp.tbl"
runloader "TPCH" "ORDERS"   "hdfs:///TPCH/100/orders/orders.tbl"
runloader "TPCH" "CUSTOMER" "hdfs:///TPCH/100/customer/customer.tbl"
runloader "TPCH" "LINEITEM" "hdfs:///TPCH/100/lineitem/lineitem.tbl"
