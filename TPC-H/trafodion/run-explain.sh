#!/bin/bash

for file in $(find explain -name \*.sql | sort); do
    echo "RUNNING ${file}"
    # not able to actually get this to work.. ended up running sql manually with trafci in interactive mode
    trafci -s ${file} > ${file//sql/out} 2>&1
done
echo
