#!/bin/bash

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
sqldir=${basedir}/queries
logdir=${basedir}/logs/queries_$(date '+%Y%m%d_%H%M%S')
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

run_query()
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

echo "RUN QUERY SCRIPT STARTED AT: $(date '+%Y/%m/%d %H:%M:%S')" 
run_query 01.sql
run_query 02.sql
run_query 03.sql
run_query 04.sql
run_query 05.sql
run_query 06.sql
run_query 07.sql
run_query 08.sql
run_query 09.sql
run_query 10.sql
run_query 11.sql
run_query 12.sql
run_query 13.sql
run_query 14.sql
run_query 15.sql
run_query 16.sql
run_query 17.sql
run_query 18.sql
run_query 19.sql
run_query 20.sql
run_query 21.sql
run_query 22.sql
echo "RUN QUERY SCRIPT FINISHED AT: $(date '+%Y/%m/%d %H:%M:%S')" 
