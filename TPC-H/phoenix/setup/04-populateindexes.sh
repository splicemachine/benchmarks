#!/bin/bash

populateindex()
{
    schema=${1}
    table=${2}
    index=${3}
    outputpath=${4}
    sudo -su hbase hbase org.apache.phoenix.mapreduce.index.IndexTool --schema ${schema} --data-table ${table} --index-table ${index} --output-path ${outputpath}
    sleep 180
}

populateindex "TPCH" "LINEITEM" "L_SHIPDATE_IDX" "L_SHIPTATE_IDX_FILES"
populateindex "TPCH" "LINEITEM" "L_PART_IDX" "L_PART_IDX_HFILES"
