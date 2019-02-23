# TPC-H based workflow
This directory contains validation queries for the TPC-H benchmark specification.  This set of script attempts to demonstrate the process for loading the data and executing \[queries based on\] the 22 TPC-H queries for the 100GB scale factor. 

The basic flow is as follows:

1. create tables
2. load data
3. create indexes
4. run a major compaction of the underlying hbase tables
5. analyze tables/collect statistics
6. count tables (verify data loaded matchtes row counts from files)
7. run explain for each query
8. execute each query
