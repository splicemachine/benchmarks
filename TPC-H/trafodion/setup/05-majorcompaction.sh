#!/bin/bash

sudo -su hbase hbase shell <<< "major_compact 'TRAFODION.TPCH.REGION'"
sudo -su hbase hbase shell <<< "major_compact 'TRAFODION.TPCH.NATION'"
sudo -su hbase hbase shell <<< "major_compact 'TRAFODION.TPCH.SUPPLIER'"
sudo -su hbase hbase shell <<< "major_compact 'TRAFODION.TPCH.CUSTOMER'"
sudo -su hbase hbase shell <<< "major_compact 'TRAFODION.TPCH.PART'"
sudo -su hbase hbase shell <<< "major_compact 'TRAFODION.TPCH.PARTSUPP'"
sudo -su hbase hbase shell <<< "major_compact 'TRAFODION.TPCH.ORDERS'"
sudo -su hbase hbase shell <<< "major_compact 'TRAFODION.TPCH.LINEITEM'"
