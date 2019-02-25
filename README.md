# benchmarks

This repository now contains two of the standard TPC benchmarks as implemented to run on Splice Machine.

The output of this coding effort is a Docker image which should contain all of the needed.

Data is provided on public-read s3 buckets, but was generated using the standard TPC Datagen tools, so could easily be re-generated.


to read the current help message:
./run-benchmark -H

to run the current docker image against a particular region server:
sudo docker run -v /home/centos/logs:/logs splicemachine/benchmark:latest -h 10.11.2.14  -b TPCH -s 1 -m linear -i 3 -l /logs

to run the current docker image against a 'standalone' e.g. on a mac laptop:
docker run -v /Users/admin/code/benchmarks/dlogs:/logs splicemachine/benchmark:latest -h 192.168.1.86  -b TPCDS -s 1 -l /logs

