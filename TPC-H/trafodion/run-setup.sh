#!/bin/bash

runsql()
{
    file=${1}
    # not able to actually get this to work.. ended up running sql manually with trafci in interactive mode
    trafci -s ${file} > ${file//sql/out} 2>&1
    unset file
}

runhivesql()
{
    file=${1}
    beeline -u 'jdbc:hive2://localhost:10000 hive hive' -f  ${file} > ${file//sql/out} 2>&1
    unset file
}

runsql setup/01-createtables.sql
runhivesqlsetup/02-createhivetables.sql
runsql setup/03-loaddata.sql
runsql setup/04-createindexes.sql
bash setup/05-majorcompaction.sh
runsql setup/06-collectstats.sql
runsql setup/07-counttables.sql
