#!/bin/bash

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
sqldir=${basedir}/explain
logdir=${basedir}/logs/explain_$(date '+%Y%m%d_%H%M%S')
timeout=0

test ! -e ${logdir} && mkdir -p ${logdir}

HOST="localhost"
PORT="1527"
USER="splice"
PASS="admin"

##     CDH
HBASE_LIB_DIR="/opt/cloudera/parcels/CDH/lib/hbase/lib"
##     MAPR
#HBASE_VERSION="$(cat /opt/mapr/hbase/hbaseversion)"
#HBASE_LIB_DIR="/opt/mapr/hbase/hbase-${HBASE_VERSION}/lib"
##     HDP 2.1 and 2.2
#HBASE_LIB_DIR="/usr/hdp/current/hbase-regionserver/lib"
#HBASE_LIB_DIR="/usr/lib/hbase/lib"

# default to CDH if we don't have an explicit CLASSPATH set
#   the ": ..." is equivalent to "true ..." to keep from evaling var check as a cmd
#   the ${VAR:="val"} should set a default if $VAR is not set/is NULL
: ${CLASSPATH:="${HBASE_LIB_DIR}/*"}
export CLASSPATH

declare IJ_SYS_ARGS
IJ_SYS_ARGS+="-Djdbc.drivers=com.splicemachine.db.jdbc.ClientDriver"
IJ_SYS_ARGS+=" -Dij.connection.splice=jdbc:splice://${HOST}:${PORT}/splicedb;user=${USER};password=${PASS}"
IJ_SYS_ARGS+=" -Dij.maximumDisplayWidth=50"

run_explainplan()
# takes a single argument -- the name of the query file, prepends sqldir
{
	local queryfile=${sqldir}/${1}
	local outfile=${logdir}/${1//sql/out}

	if [ "${timeout}" -eq 0 ]; then
		java ${IJ_SYS_ARGS} -Dij.outfile=${outfile} com.splicemachine.db.tools.ij ${queryfile}
	else
		java ${IJ_SYS_ARGS} -Dij.outfile=${outfile} com.splicemachine.db.tools.ij ${queryfile} &
		# wait until job finishes or timeout which ever comes first
		qpid=$(jobs -p)
		local queryruntime=0
		while [ "${queryruntime}" -le "${timeout}" ]; do
			ps --no-headers ${qpid} >/dev/null
			local jobstatus=$?
			if [ "${jobstatus}" -eq 0 ]; then
				((queryruntime++))
			else
				break
			fi
			sleep 1
		done
		ps --no-headers ${qpid} >/dev/null
		jobrunning=$?
		if [ "${jobrunning}" -eq 0 ]; then
			java ${IJ_SYS_ARGS} -Dij.outfile=${outfile}.timeout com.splicemachine.db.tools.ij <<< "call SYSCS_UTIL.SYSCS_KILL_ALL_STATEMENTS();"
		fi
	fi
}

echo "EXPLAIN PLAN SCRIPT STARTED AT: $(date '+%Y/%m/%d %H:%M:%S')" 
run_explainplan 01.sql
run_explainplan 02.sql
run_explainplan 03.sql
run_explainplan 04.sql
run_explainplan 05.sql
run_explainplan 06.sql
run_explainplan 07.sql
run_explainplan 08.sql
run_explainplan 09.sql
run_explainplan 10.sql
run_explainplan 11.sql
run_explainplan 12.sql
run_explainplan 13.sql
run_explainplan 14.sql
run_explainplan 15.sql
run_explainplan 16.sql
run_explainplan 17.sql
run_explainplan 18.sql
run_explainplan 19.sql
run_explainplan 20.sql
run_explainplan 21.sql
run_explainplan 22.sql
echo "EXPLAIN PLAN SCRIPT FINISHED AT: $(date '+%Y/%m/%d %H:%M:%S')" 
