#!/bin/bash

runsql()
{
    file=${1}
    /opt/phoenix/default/bin/sqlline.py $(hostname):2181:/hbase-unsecure ${file} > ${file//sql/out} 2>&1
    unset file
}

runsql setup/01-createtables.sql
bash setup/02-loaddata.sh
runsql setup/02-createindexes.sql
bash setup/03-populate-indexes.sh
bash setup/03-majorcompaction.sh
runsql setup/05-counttables.sql
