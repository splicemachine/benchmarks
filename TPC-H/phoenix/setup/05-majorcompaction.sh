#!/bin/bash

sudo -su hbase hbase shell <<< "major_compact 'TPCH.REGION'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.NATION'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.SUPPLIER'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.PART'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.PARTSUPP'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.ORDERS'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.CUSTOMER'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.LINEITEM'"

sudo -su hbase hbase shell <<< "major_compact 'TPCH.O_DATE_PRI_KEY_IDX'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.O_CUST_IDX'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.L_SHIPDATE_IDX'"
sudo -su hbase hbase shell <<< "major_compact 'TPCH.L_PART_IDX'"
