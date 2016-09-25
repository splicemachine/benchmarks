#!/bin/bash

for file in $(find queries -name \*.sql | sort); do
    echo "RUNNING ${file}"
    /opt/phoenix/default/bin/sqlline.py $(hostname):2181:/hbase-unsecure ${file} > ${file//sql/out2} 2>&1
done
echo
