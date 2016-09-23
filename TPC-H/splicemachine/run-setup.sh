#!/bin/bash

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
sqldir=${basedir}/setup
logdir=${basedir}/logs/setup_$(date '+%Y%m%d_%H%M%S')
timeout=0

test ! -e ${logdir} && mkdir -p ${logdir}

HOST="localhost"
PORT="1527"
USER="splice"
PASS="admin"

##     CDH
HBASE_LIB_DIR="/opt/cloudera/parcels/CDH/lib/hbase/lib"
##     MAPR
# HBASE_VERSION="$(cat /opt/mapr/hbase/hbaseversion)"
# HBASE_LIB_DIR="/opt/mapr/hbase/hbase-${HBASE_VERSION}/lib"
##     HDP 2.1 and 2.2
# HBASE_LIB_DIR="/usr/hdp/current/hbase-regionserver/lib"
# HBASE_LIB_DIR="/usr/lib/hbase/lib"

# default to CDH if we don't have an explicit CLASSPATH set
#   the ": ..." is equivalent to "true ..." to keep from evaling var check as a cmd
#   the ${VAR:="val"} should set a default if $VAR is not set/is NULL
: ${CLASSPATH:="${HBASE_LIB_DIR}/*"}
export CLASSPATH

declare IJ_SYS_ARGS
IJ_SYS_ARGS+="-Djdbc.drivers=com.splicemachine.db.jdbc.ClientDriver"
IJ_SYS_ARGS+=" -Dij.connection.splice=jdbc:splice://${HOST}:${PORT}/splicedb;user=${USER};password=${PASS}"
IJ_SYS_ARGS+=" -Dij.maximumDisplayWidth=50"

echo "IMPORT SCRIPT STARTED AT: $(date '+%Y/%m/%d %H:%M:%S')" 
java ${IJ_SYS_ARGS} -Dij.outfile=${logdir}/01-createtables.out    com.splicemachine.db.tools.ij ${sqldir}/01-createtables.sql
java ${IJ_SYS_ARGS} -Dij.outfile=${logdir}/02-importdata.out      com.splicemachine.db.tools.ij ${sqldir}/02-importdata.sql
java ${IJ_SYS_ARGS} -Dij.outfile=${logdir}/02-createindexes.out   com.splicemachine.db.tools.ij ${sqldir}/02-createindexes.sql
java ${IJ_SYS_ARGS} -Dij.outfile=${logdir}/03-majorcompaction.out com.splicemachine.db.tools.ij ${sqldir}/03-majorcompaction.sql
java ${IJ_SYS_ARGS} -Dij.outfile=${logdir}/04-collectstats.out    com.splicemachine.db.tools.ij ${sqldir}/04-collectstats.sql
java ${IJ_SYS_ARGS} -Dij.outfile=${logdir}/05-counttables.out     com.splicemachine.db.tools.ij ${sqldir}/05-counttables.sql
echo "IMPORT SCRIPT FINISHED AT: $(date '+%Y/%m/%d %H:%M:%S')" 
