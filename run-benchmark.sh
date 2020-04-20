#!/bin/bash

# Author: Murray Brown <mbrown@splicemachine.com>

usage() {
  echo "Usage: $0 { -h host | -u url } [-b benchmark] [-s scale] [-S set] [-m mode] [-d dir] [-L logdir] [-l label] [-n name] [-i iterations] [-t timeout] [-C] [-D] [-V] [-P] [-H]"
}

help() {
  usage
  echo -e "\n\ta script to run a benchmark validation queryset against a Splice Machine database\n"
  echo -e "    Arguments:"
  echo -e "\t -h host\t\t the hostname of your database. One of host or url is required."
  echo -e "\t -u url\t\t\t a jdbc url for your database. One of host or url is required."
  echo -e "    Options:"
  echo -e "\t -b benchmark \t\t a benchmark to run. (default: TPCH) {valid: TPCH, TPCDS, TPCC, HTAP}"
  echo -e "\t -s scale \t\t scale of (default: 1) {valid scales 1, 10, 100, 1000}"
  echo -e "\t -S set \t\t which query set to run (default: good) {valid: good, snow, all, errors}"
  echo -e "\t\t\t\t you can also supply a list of one or more comma-separated query numbers e.g. 01,07,21"
  echo -e "\t -m mode \t\t mode for setup (default: bulk) {valid: bulk or linear}"
  echo -e "\t -d dir \t\t import data source (default: ${DATASOURCE})"
  echo -e "\t -L logdir \t\t a directory to base the logs (default: /logs)"
  echo -e "\t -l label \t\t a label to identify the output (default: scale and date)"
  echo -e "\t -n name \t\t a suffix to add to a schema name"
  echo -e "\t -i iterations \t\t how many iterations to run (default: 1)"
  echo -e "\t -t timeout \t\t how many seconds to allow each query to run (default: forever)"
  echo -e "\t -C create \t\t force database creation and data import (default: ${CREATE})"
  echo -e "\t -D debug mode \t\t prints debug messaging"
  echo -e "\t -V verbose mode \t prints helpful messaging"
  echo -e "\t -P explain mode \t prints queries' plans"
  echo -e "\t -H help \t\t prints this help"
}

debug() {
  local msg="$*"

  if (( $DEBUG )); then
    echo "DEBUG: $msg" >&2
  fi
}

messageBegin() {
  local msg="$*"

  if (( $VERBOSE )); then
    echo -ne "$msg"
  fi
  if (( $DEBUG )); then
    # need a newline to fix messaging when debug to stderr overwrites stdout
    echo
  fi
}

message() {
  local msg="$*"

  if (( $VERBOSE )); then
    echo -e "$msg"
  fi
}

# ensure a path ends in /
fixPath() {
  local path=$1

  local dirlen=${#path}
  local lastchar=${path:dirlen-1:1}
  [[ $lastchar != "/" ]] && path="${path}/";

  echo $path
}

now() {
  date +%Y%m%d-%H%M
}

STARTD=$(now)
STARTS=`date +%s`
BENCH_START=$(date -u +'%Y-%m-%d %H:%M:%S')

#Defaults
HOST=""
URL=""
BENCH="TPCH"
INTERACTIVE=0
SCALE=1
SET="good"
SETSTYLE="words"
CREATE=0
DATASOURCE="s3a://splice-benchmark-data/flat/"
MODE="bulk"
LOGBASE=""
LABEL=""
SUFFIX=""
declare -i ITER=1
declare -i TIMEOUT=0
DEBUG=0
VERBOSE=0
EXPLAIN=0

# Arrays for times and errors
declare -A EXEC_TIME
declare -A EXEC_START_DATE
declare -A EXEC_STATUS

# Option Parsing
OPTIND=1
while getopts ":h:u:b:s:S:m:d:L:l:n:i:t:CDVPH" opt; do
  case $opt in
    h) HOST=$OPTARG
       ;;
    u) URL=$OPTARG
       ;;
    b) BENCH=$OPTARG
       ;;
    s) SCALE=$OPTARG
       ;;
    S) SET=$OPTARG
       ;;
    m) MODE=$OPTARG
       ;;
    d) DATASOURCE=$OPTARG
       ;;
    L) LOGBASE=$OPTARG
       ;;
    l) LABEL=$OPTARG
       ;;
    n) SUFFIX=$OPTARG
       ;;
    i) ITER=$OPTARG
       ;;
    t) TIMEOUT=$OPTARG
       ;;
    C) CREATE=1
       ;;
    D) DEBUG=1
       ;;
    V) VERBOSE=1
       ;;
    P) EXPLAIN=1
       ;;
    H) help
       exit 0
       ;;
    \?) 
       echo "Error: Invalid option: -$OPTARG" 
       usage
       exit 1 
      ;;
    :) echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# concoct all uppercase schema name from inputs
SCHEMA=$(echo ${BENCH}${SCALE}${SUFFIX} | awk '{print toupper($0)}' )

# setup BASEDIR
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASEDIR=$(fixPath $BASEDIR)
#debug basedir ends in / $BASEDIR

# setup VERSION
VERSION=$(cat ${BASEDIR}VERSION)
VERSION_DATE=$(date -r ${BASEDIR}VERSION)
echo "##### Splice Benchmark Harness version: $VERSION ($VERSION_DATE)"

# setup BENCHMARK
BENCHMARK="TPC-H"
if [[ "$BENCH" == "TPCDS" ]]; then
   BENCHMARK="TPC-DS"
fi

# query directory
SQLDIR="${BASEDIR}${SCHEMA}-queries"
if [[ ! -d $SQLDIR ]]; then
  debug making orig sqldir $SQLDIR
  mkdir -p $SQLDIR
fi


# TOODO: implement actual benchmark

#============
# Argument Checking

# Either HOST or URL are required
HOSTORURL=""
if [[ "$HOST" == "" && "$URL" == "" ]]; then
  echo "Error: One of host or url must be supplied!"
  usage
  exit 1
elif [[ "$HOST" != "" ]]; then
  HOSTORURL="-h $HOST" 
else
  HOSTORURL="-U ${URL}" 
fi
debug host-or-url is ${HOSTORURL}

# TOODO: figure out if URL is 'well-formed'

# check valid benchmark
if [[ "$BENCH" != "TPCH" && "$BENCH" != "TPCC" && "$BENCH" != "TPCDS" && "$BENCH" != "HTAP" ]]; then
   echo "Error: benchmark $BENCH is not supported!"
   usage
   exit 2
fi

# fix for TPCH query 11 needing scale factor constant
# TOODO: write a routine for this calculation if it is reusable
QRY11="0.0001000000" # defaults to tpch1g

debug checking scale $SCALE for bench $BENCH
# check for only valid scales
if [[ "$BENCH" == "TPCH"  && "$SCALE" != "1" && "$SCALE" != "10" && "$SCALE" != "100" && "$SCALE" != "1000"  && "$SCALE" != "10000" || \
      "$BENCH" == "TPCDS" && "$SCALE" != "1" && "$SCALE" != "10" && "$SCALE" != "100" && "$SCALE" != "1000" || \
      "$BENCH" == "TPCC"  && "$SCALE" != "1" || \
      "$BENCH" == "HTAP"  && "$SCALE" != "25" ]]; then
   echo "Error: scale of $SCALE is not (yet) supported for $BENCH!"
   usage
   exit 2
elif [[ "$SCALE" == "1" ]]; then
  QRY11="0.0001000000"
elif [[ "$SCALE" == "10" ]]; then
  QRY11="0.0000100000"
elif [[ "$SCALE" == "100" ]]; then
  QRY11="0.0000010000"
elif [[ "$SCALE" == "1000" ]]; then
  QRY11="0.0000001000"
elif [[ "$SCALE" == "10000" ]]; then
  QRY11="0.0000000100"
fi

# defaults for TPCH
TABLECNT=8
INDEXCNT=4
BENCHMIN=1
BENCHMAX=22

if [[ "$BENCH" == "TPCDS" ]]; then
  TABLECNT=24
  INDEXCNT=0
  BENCHMIN=1
  BENCHMAX=99
fi

# The SET argument can also accept a list of query numbers e.g. 01,07,22
validateSet() {
   local set=$1
   local err=0

   debug validateSet for $set

   # reject illegal characters outside [0-9,]+
   local illegal=$( echo "$set" |  sed -E 's/[0-9,]+//g' )
   if [[ "$illegal" != "" ]]; then
      debug rejecting illegal SET values of $illegal
      return 1
   fi

   # split on comma
   local -i qry
   for qry in $(echo $set | sed "s/,/ /g"); do
      if [[ $qry -gt $BENCHMAX || $qry -lt $BENCHMIN ]]; then
         err=$((err + 1))
      fi
   done

   return $err

}

# check the value of SET
if [[ "$SET" != "good" && "$SET" != "snow" && "$SET" != "all" && "$SET" != "errors" && "$SET" != "err" ]]; then
   SETSTYLE="numbers"
   validateSet $SET
   if (( $? != 0 )); then
      echo "Error: set argument $SET is not a valid list of queries for $BENCH"
      usage
      exit 2
   fi
fi

# check SET (good, all, errors, ??)
if [[ "$SET" != "good" && "$SET" != "snow" && "$SET" != "all" && "$SET" != "errors" && "$SET" != "err" && "$SETSTYLE" == "words" ]]; then
   echo "Error: set argument $SET is not supported. Valid values: [ good, snow, all, err, errors ]"
   usage
   exit 2
fi

# check MODE (bulk, linear)
if [[ "$MODE" != "bulk" && "$MODE" != "linear" ]]; then
   echo "Error: mode argument $MODE is not supported. Valid values: [ bulk, linear ]"
   usage
   exit 2
fi


# optionally start log directory at a base 
# e.g. /mnt/mesos/sandbox for docker
if [[ "$LOGBASE" != "" ]]; then
   LOGBASE=$(fixPath $LOGBASE)
   if [[ ! -d $LOGBASE ]]; then 
      echo "Error: specified logdir does not exist: $LOGBASE"
      exit 2
   fi
   LOGDIR="${LOGBASE}logs/$SCHEMA-queries-$STARTD"
else
   LOGBASE=$BASEDIR
   LOGDIR="${LOGBASE}logs/$SCHEMA-queries-$STARTD"
fi

if [[ ! -d $LOGDIR ]]; then
  debug making orig logdir $LOGDIR
  mkdir -p $LOGDIR
fi

#  check if label is blank else generate it
if [[ "$LABEL" == "" ]]; then
  LABEL="$BENCH-$SCALE benchmark run started $STARTD"
  debug generated label $LABEL 
fi

# check that count is an integer
case $ITER in
  0|[1-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9]) ;;
  *)
    echo "Error: iterations must be an integer: $ITER"
    usage
    exit 2
  ;;
esac

# check that TIMEOUT is an integer
case $TIMEOUT in
  0|[1-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9]) ;;
  *)
    echo "Error: timeout must be an integer: $TIMEOUT"
    usage
    exit 2
  ;;
esac

#if [[ $TIMEOUT != 0 ]]; then
   ## TOODO: test non-zero timeout handling
   #echo "umm... i have not tested that yet"
   #exit 127
#fi

debug exiting arg checks

#============
# Subroutines

# TOODO: global or local file location handling?

# use sqlshell find job id
getJobIds() {
  local outfile="${LOGDIR}/getJobId.out"

  $SQLSHELL -q $HOSTORURL -o $outfile <<< "call syscs_util.SYSCS_GET_RUNNING_OPERATIONS();"

  grep "|SPLICE" $outfile  | grep -v "SYSCS_GET_RUNNING_OPERATIONS" | awk '{print $1}'
}

killJob() {
  local jobid=$1

  echo killing $jobid
  $SQLSHELL -q $HOSTORURL -o /dev/null <<< "call syscs_util.SYSCS_KILL_OPERATION('${jobid}');" 
}

# takes a single argument -- the name of the query file, prepends SQLDIR
runQuery() {
   local bench="${1}"
   local queryfile=${SQLDIR}/${1}
   local outfile=${LOGDIR}/${1//sql/out}

   EXEC_START_DATE[$bench]="$(date -u '+%Y-%m-%d %H:%M:%S')"
   local status=0

   # too verbose, so got rid of this
   #message running $queryfile
   if [[ $TIMEOUT -eq 0 ]]; then
      $SQLSHELL -q ${HOSTORURL} -f $queryfile -o $outfile 
      status=$?
   else
      $SQLSHELL -q ${HOSTORURL} -f $queryfile -o $outfile &
      debug backgrounded shell

      # wait until job finishes or timeout whichever comes first
      qpid=$(jobs -p)
      local queryruntime=0
      while [ "${queryruntime}" -le "${TIMEOUT}" ]; do
         ps ${qpid} >/dev/null
         local jobstatus=$?
         if [[ ${jobstatus} -eq 0 ]]; then
            ((queryruntime++))
         else
            break
         fi
         sleep 1
      done
      ps ${qpid} >/dev/null
      jobrunning=$?
      if [[ ${jobrunning} -eq 0 ]]; then
         debug "decided to kill job at time $queryruntime"
         local jobs=$(getJobIds)
         debug "found job(s) $jobs"
         local id
         for id in $jobs; do
           killJob $id
         done
         status=1
      fi
   fi

   EXEC_STATUS[$bench]=$status

   return $status
}

# only works on a 'one count' query outputfile
countResults() {
  local outfile=$1

  #if [[ ! -f $outfile ]]; then
  #  debug "Error: countResults: no such file $outfile"
  #  return 0
  #if

  local -i count
  count=$(grep -A1 "[-][-][-][-][-][-]" $outfile | tail -1)

  if [[ "$count" == "" ]]; then
     debug "Error: countResults: no matching result in $outfile"
     return 0
  else
     debug "Success: countResults: returning $count from $outfile"
     return $count
  fi

}

# check a query output for execution time
checkQueryTime() {
  local outfile=$1
  local execTime=$(grep "ELAPSED TIME" $outfile 2>/dev/null | awk '{sum += $4} END {print sum}' )

  #debug checkQueryTime: exec time is $execTime
  echo $execTime
}

# check a query output for error
checkQueryError() {
  local outfile=$1
  local -i errCount=$(grep ERROR $outfile 2>/dev/null | wc -l )

  #debug checkQueryError: error count is $errCount
  echo $errCount
}

# check if a schema exists
checkSchema() {
   local schema=$1

   local query="checkSchema.sql"
   echo "select count(1) from sys.sysschemas s where s.schemaname='${schema}';" > $SQLDIR/$query
   runQuery $query
   countResults $LOGDIR/${query/sql/out}
   local -i count=$?

   debug "CheckSchema: found $count from $query"
   if [[ "$count" -ne "1" ]]; then
     debug Schema $schema: not present
     return 1
   else
     debug Schema $schema is present
     return 0
   fi
}

# count tables in a schema compare to expect
checkTableCount() {
   local schema=$1
   local -i expect=$2

   local query="checkTableCount.sql"
   echo "select count(1) from sys.systables c join sys.sysschemas s on c.schemaid = s.schemaid where s.schemaname='${schema}';" > $SQLDIR/$query
   runQuery $query
   countResults $LOGDIR/${query/sql/out}
   local -i count=$?

   debug "CheckTableCount: found $count from $query"
   if [[ "$count" -ne "$expect" ]]; then
     debug Schema $schema: incorrect table count $count
     return 1
   else
     debug Schema $schema has $expect tables
     return 0
   fi
}

# check index count
checkIndexCount() {
   local schema=$1
   local -i expect=$2

   local query="checkIndexes.sql"
   echo "select count(1) from sys.sysconglomerates c join sys.sysschemas s on c.schemaid = s.schemaid where s.schemaname='${schema}' and  c.isindex=true;" > $SQLDIR/$query
   runQuery $query
   countResults $LOGDIR/${query/sql/out}
   local -i count=$?

   debug "CheckIndexCount: found $count from $query"
   if [[ "$count" -ne "$expect" ]]; then
     debug Schema $schema: incorrect index count $count
     return 1
   else
     debug Schema $schema has $expect indexes
     return 0
   fi
} 

checkTableRowCounts() {
   local schema=$1
   local scale=$2

   messageBegin "$schema: Counting tables . . ."
   fillQueryTemplate "setup-06-count.sql" $schema $scale
   runQuery "setup-06-count.sql"

   local -i countTime=$(checkQueryTime "${LOGDIR}/setup-06-count.out")
   message " took $countTime milliseconds."
   errCount=$(checkQueryError "${LOGDIR}/setup-06-count.out")
   if [[ $errCount -gt 0 ]]; then
      debug ${LOGDIR}/setup-06-count.out has $errCount errors
      return 1
   fi

   if [[ "$BENCH" == "TPCH" ]]; then
      checkTPCHTableRowCounts $scale "${LOGDIR}/setup-06-count.out"
      return $?
   elif [[ "$BENCH" == "TPCDS" ]]; then
      # TODO: implement checkTPCDSTableRowCounts
      return 0
   else
      return 1
   fi
}

# check specific dataset table counts
checkTPCHTableRowCounts() {
   local scale=$1
   local outfile=$2

   debug entering checkTPCHTableRowCounts at scale $scale checking $outfile
   local tables="CUSTOMER LINEITEM NATION ORDERS PART PARTSUPP REGION SUPPLIER"

   # TOODO: figure out how to do multi-dimensional bash arrays
   local -a answers1=(150000 6001215 25 1500000 200000 800000 5 10000)
   local -a answers10=(1500000 59986052 25 15000000 2000000 8000000 5 100000)
   local -a answers100=(15000000 600037902 25 150000000 20000000 80000000 5 1000000)
   local -a answers1000=(150000000 5999989709 25 1500000000 200000000 800000000 5 10000000)
   local -a answers10000=(1500000000 59999994267 25 15000000000 2000000000 8000000000 5 100000000)

   # get counts from outfile and compare
   local -i i=0;
   local num;
   local -i err=0;
   for table in $tables; do
      num=$(grep -A2 "^${table}[[:space:]]*$" $outfile | tail -1 | awk '{print $1}')

      if [[ "$scale" == "1" ]]; then
         if [[ "${answers1[$i]}" != "$num" ]]; then
            debug checkTPCHTableRowCounts: table $table has $num rows, expected ${answers1[$i]}
            err=$((err+1))
         fi
      elif [[ "$scale" == "10" ]]; then
         if [[ "${answers10[$i]}" != "$num" ]]; then
            debug checkTPCHTableRowCounts: table $table has $num rows, expected ${answers10[$i]}
            err=$((err+1))
         fi
      elif [[ "$scale" == "100" ]]; then
         if [[ "${answers100[$i]}" != "$num" ]]; then
            debug checkTPCHTableRowCounts: table $table has $num rows, expected ${answers100[$i]}
            err=$((err+1))
         fi
      elif [[ "$scale" == "1000" ]]; then
         if [[ "${answers1000[$i]}" != "$num" ]]; then
            debug checkTPCHTableRowCounts: table $table has $num rows, expected ${answers1000[$i]}
            err=$((err+1))
         fi
      elif [[ "$scale" == "10000" ]]; then
         if [[ "${answers10000[$i]}" != "$num" ]]; then
            debug checkTPCHTableRowCounts: table $table has $num rows, expected ${answers10000[$i]}
            err=$((err+1))
         fi
      else # not implemented
         err=$((err+1))
      fi
      i=$((i+1))
   done

   if [[ $err -gt 0 ]]; then
      debug checkTPCHTableRowCounts returning 1
      return 1
   fi
   debug checkTPCHTableRowCounts returning 0
   return 0

}

checkSchemaStats() {
   local schema=$1
   local outfile=""

   # TODO: check that non-zero statistics are present
   # $SQLSHELL -q $HOSTORURL -o  <<< "select sum(stats) from sys.statistics where schemaname = '${schema}';"

   return 1
}

# validate that schema has the schema, tables and indexes; has stats and the right rowcounts
validateSchema() {
   local schema=$1
   local scale=$2

   # check schema exists
   if ( ! checkSchema $schema ); then
      debug Schema $schema does not exist
      return 1
   fi

   # check that tables are present
   if ( ! checkTableCount $schema $TABLECNT ); then
      return 1
   fi

   # check that indexes are present
   if ( ! checkIndexCount $schema $INDEXCNT ); then
      return 1
   fi

   # TOODO: check compaction somehow?

   checkSchemaStats $schema
   local -i statCount=$?
   if [[ $statCount -eq 0 ]]; then
      debug Schema $schema: zero statistics
      return 1
   else
      debug Schema $schema has $statCount stats
   fi

   # check that all the tables have the 'right' counts
   if ( ! checkTableRowCounts $schema $scale); then
      debug Schema $schema: counts mismatch
      return 1
   else
      debug Schema $schema: counts match
   fi

   return 0
}

# substitution function for templated queries
fillQueryTemplate() {
  local file=$1
  local schema=$2
  local scale=$3

  local input="${BASEDIR}${BENCHMARK}/templates/$file"
  local output="$SQLDIR/$file"

  local explain=""
  if (( $EXPLAIN )); then
    explain="maximumdisplaywidth 0; explain "
  fi

  # TODO: add header as template fragment

  if [[ ! -f $input ]]; then
    debug "Error: there is no template $file"
    return 1
  fi
  #debug copying input $input to output $output
  cat $input | sed \
   -e "s/##SCHEMA##/$schema/g" \
   -e "s/##SCALE##/$scale/g" \
   -e "s/##QRY11##/${QRY11}/g" \
   -e "s%##DSRC##%$DATASOURCE%g" \
   -e "s/##EXPLAIN##/$explain/g" \
   > $output

}

## TODO: implement fillExplainTemplate
#fillExplainTemplate() {
#  # TODO: i need love
#}

# create and load the benchmark database for this scale
createDatabase() {
   local schema=$1
   local scale=$2
   local mode=$3
   local start=`date +%s`
   local -i errCount

   debug "Creating $BENCH db at $schema for scale $scale using mode $mode"

   # TODO: move logs for setup to a schema-specific subdir

   messageBegin "$schema: Removing existing schema . . ."
   fillQueryTemplate "setup-01-drop.sql" $schema $scale
   runQuery "setup-01-drop.sql"
   local -i dropTime=$(checkQueryTime "${LOGDIR}/setup-01-drop.out")
   message " took $dropTime milliseconds."

   messageBegin "$schema: Creating tables . . ."
   fillQueryTemplate "setup-01-tables.sql" $schema $scale
   runQuery "setup-01-tables.sql"
   local -i createTime=$(checkQueryTime "${LOGDIR}/setup-01-tables.out")
   message " took $createTime milliseconds."

   errCount=$(checkQueryError "${LOGDIR}/setup-01-tables.out")
   if [[ $errCount -gt 0 ]]; then
      message "Error: errors seen during table create: $errCount"
      exit 1
   elif ( ! checkTableCount $schema $TABLECNT ); then
      message "Error making $TABLECNT tables on $schema"
      exit 1
   fi

   # TOODO: ensure that no current load process is already running

   if [[ "$mode" == "linear" ]]; then
      fillQueryTemplate "setup-02-linear-import.sql" $schema $scale
      fillQueryTemplate "setup-03-linear-indexes.sql" $schema $scale

      messageBegin "$schema: Loading data with IMPORT_DATA . . . "
      runQuery "setup-02-linear-import.sql"
      local -i loadTime=$(checkQueryTime "${LOGDIR}/setup-02-linear-import.out")
      message " took $loadTime milliseconds."
      errCount=$(checkQueryError "${LOGDIR}/setup-02-linear-import.out")
      if [[ $errCount -gt 0 ]]; then
         echo "Error: failure during s3 data load. Is your cluster configured to read from s3?"
         exit 2
      fi

      messageBegin "$schema: Creating linear indexes . . ."
      runQuery "setup-03-linear-indexes.sql"
      local -i indexTime=$(checkQueryTime "${LOGDIR}/setup-03-linear-indexes.out")
      message " took $indexTime milliseconds."
      errCount=$(checkQueryError "${LOGDIR}/setup-03-linear-indexes.out")
      if [[ $errCount -gt 0 ]]; then
         echo "Error: failure during index creation"
         exit 3
      elif ( ! checkIndexCount $schema $INDEXCNT ); then
         echo "Error: $schema is missing $INDEXCNT indexes"
         exit 3
      fi

      messageBegin "$schema: Running compaction . . ."
      fillQueryTemplate "setup-04-compact.sql" $schema $scale
      runQuery "setup-04-compact.sql"
      local -i compactTime=$(checkQueryTime "${LOGDIR}/setup-04-compact.out")
      message " took $compactTime milliseconds."
      errCount=$(checkQueryError "${LOGDIR}/setup-04-compact.out")
      if [[ $errCount -gt 0 ]]; then
         echo "Error: compaction returned an error?"
         exit 4
      fi
   else # i.e. mode=bulk
      # TOODO: complete pre-split-points for indexes

      messageBegin "$schema: Pre-creating indexes . . ."
      fillQueryTemplate "setup-02-bulk-splitindex.sql" $schema $scale
      runQuery "setup-02-bulk-splitindex.sql"
      local -i indexTime=$(checkQueryTime "${LOGDIR}/setup-02-bulk-splitindex.out")
      message " took $indexTime milliseconds."
      errCount=$(checkQueryError "${LOGDIR}/setup-02-bulk-splitindex.out")
      if [[ $errCount -gt 0 ]]; then
         echo "Error: failure during creation of indexes on empty tables"
         exit 2
      elif ( ! checkIndexCount $schema $INDEXCNT ); then
         echo "Error: $schema is missing $INDEXCNT indexes"
         exit 2
      fi

      # hfile bulk load from s3 for faster load
      messageBegin "$schema: Bulk loading data . . ."
      fillQueryTemplate "setup-03-bulk-import.sql" $schema $scale
      runQuery "setup-03-bulk-import.sql"
      local -i loadTime=$(checkQueryTime "${LOGDIR}/setup-03-bulk-import.out")
      message " took $loadTime milliseconds."
      errCount=$(checkQueryError "${LOGDIR}/setup-03-bulk-import.out")
      if [[ $errCount -gt 0 ]]; then
        echo "Error: failure during data bulkload."
        exit 3
      fi

      local -i compactTime=0
   fi

   messageBegin "$schema: Gathering statistics . . ."
   fillQueryTemplate "setup-05-stats.sql" $schema $scale
   runQuery "setup-05-stats.sql"
   checkSchemaStats $schema
   local -i statCount=$?
   local -i statsTime=$(checkQueryTime "${LOGDIR}/setup-05-stats.out")
   message " took $statsTime milliseconds to gather $statCount stats."
   errCount=$(checkQueryError "${LOGDIR}/setup-05-stats.out")
   if [[ $errCount -gt 0 ]]; then
      echo "Error: gathering statistics returned an error?"
      exit 5
   elif [[ $statCount -eq 0 ]]; then
      echo "Error: zero statistics returned"
      exit 5
   fi

   # capture total time and print results
   local -i end=`date +%s`
   runtime=$((end-start))
   message "\t\t\t Times:\tSetup Time,\tCreate,\tIndex,\tLoad,\tCompact,\tStats,\tCount"
   echo -e "$schema setup times:\t${runtime},\t${createTime},\t${indexTime},\t${loadTime},\t${compactTime},\t${statsTime},\t${countTime}"
}

# replace templates with the schema value for this run
genQueries() {
  local schema=$1
  local scale=$2
  local i

  debug generating query sql for $schema

  for i in `seq -w $BENCHMIN $BENCHMAX`; do
    #debug adding $schema for ${i}
    fillQueryTemplate "query-${i}.sql" $schema $scale
  done
}

runQueries() {
   local schema=$1
   local i

   if [[ "$SETSTYLE" == "numbers" ]]; then
      message  Running benchmark $BENCH with query set $SET
      # split on comma
      local qry
      for qry in $(echo $SET | sed "s/,/ /g"); do
         message "Running $BENCH query $qry at scale $SCALE"
         runQuery "query-${qry}.sql"
      done
   else  # evaluate SETSTYLE words
      for i in `seq -w $BENCHMIN $BENCHMAX`; do
         if [[ "$BENCH" == "TPCDS" ]]; then
            if [[ "$SET" == "good" ]]; then  # see SPLICE tickets 1020, 1016
                if [[ "$SCALE" != "1" ]]; then
                   if [[ "$i" == "04" || "$i" == "10" || "$i" == "11" || "$i" == "74" || "$i" == "78" || "$i" == "88" ]]; then
                      message "Set is $SET, so skipping $BENCH query ${i}"
                      continue
                   fi
                fi
            elif [[ "$SET" == "snow" ]]; then # the snowflake 14 - see DB-7892 except q64
               if [[ "$i" != "03" && "$i" != "07" && "$i" != "19" && "$i" != "23" && "$i" != "34" && \
                 "$i" != "36" && "$i" != "42" && "$i" != "52" && "$i" != "53" && "$i" != "55" && \
                 "$i" != "59" && "$i" != "89" ]]; then
                  message "Set is $SET, so skipping $BENCH query ${i}"
                  continue
               fi
            elif [[ "$SET" == "errors" || "$SET" == "err" ]]; then # see SPLICE tickets 1020, 1016
               if [[ "$SCALE" != "1" ]]; then
                  if [[ "$i" != "04" || "$i" != "10" || "$i" != "11" || "$i" != "74" || "$i" != "78" || "$i" != "88" ]]; then
                     message "Set is $SET, so skipping $BENCH query ${i}"
                     continue
                  fi
               fi
            fi
	       fi
	       message "Running $BENCH query ${i} at scale $SCALE"
	       runQuery "query-${i}.sql"
      done
   fi
}

checkBenchResults() {
    local schema=$1
    local iter=$2

    local -a results

    # TODO: handle SETSTYLE adhoc and sets

    local i
    local j=0
    for i in `seq -w $BENCHMIN $BENCHMAX`; do
	    let j++
	    local bench="query-${i}.sql"
	    local -i errCount=$(checkQueryError "${LOGDIR}/query-${i}.out")
	    #debug checkBenchResults errCount $errCount
	    if [[ $errCount -eq 0 ]]; then
            local time=$(checkQueryTime "${LOGDIR}/query-${i}.out")
            if [[ "$time" != "" ]]; then
		        message "$SCHEMA query-${i}.sql took $time milliseconds"
		        results[$j]=$time
		        EXEC_TIME[$bench]=$time
            else
		        message "$SCHEMA query-${i}.sql no errors and no time"
		        results[$j]="Nan"
		        EXEC_STATUS[$bench]="2"
            fi
	    else
            message "$SCHEMA query-${i}.sql had $errCount errors"
            results[$j]="Err"
            EXEC_STATUS[$bench]="3"
	    fi
    done

    # loop over the variable set of results
    echo -n "$SCHEMA results"
    if [[ "$iter" != "0" ]]; then
        echo -n " for run $iter"
    fi
    echo -n ": "
    local -i k=1
    while [ $k -le $j ]; do
        if (( $k == $j )); then
            echo ${results[$k]}
        else
            echo -ne "${results[$k]}, "
        fi
        let k++
    done

    # create report for Jenkins
    for bench in ${!EXEC_START_DATE[@]}; do
        local date=${EXEC_START_DATE[$bench]}
        local elapsed=${EXEC_TIME[$bench]}
        local status="PASS"
        local errorCode=${EXEC_STATUS[$bench]}
        if [[ $errorCode != 0 ]]; then
            status="FAIL"
            BENCH_PASS="FAIL"
        fi
	    echo "$date|$bench|$iter|$status|$errorCode||$elapsed" >> ${LOGBASE}logs/test_run.csv
    done
}

	# TOODO: iterate over many results
	# checkTPCHOutputs() {
	# compute min/max/avg/stddev
	# TOODO: consider global results 2-dimensional array?
	# RESULTS[$i][0] = name
	# RESULTS[$i][1] = count
	# RESULTS[$i][2] = sum
	# RESULTS[$i][3] = sumsq
	# }

	# TOODO: output result as many-row csv file
	# test_run.csv
	#Time	Query	Iteration	Status	Error code	Error msg	Elapsed

	# TOODO: consider pushing to s3
	# s3:splice-performance/ {run,test_run,test_cluster}
	# possibly put in a new place to start

	# TOODO: consider getting a unique id for build run from groovy script in jenkins

	#============
	# Sanity Tests

	if [[ ! -d ${BASEDIR}${BENCHMARK}/templates ]]; then
	  echo "Error: ${BASEDIR}${BENCHMARK}/templates must be present"
	  exit 2
	fi

	# Test for sqlshell
	SQLSHELL="./sqlshell/sqlshell.sh"
	if [[ ! -f $SQLSHELL ]]; then
	   echo "Error: could not find sqlshell <$SQLSHELL>"
	   exit 2
	fi

	# Test that we can connect to a db
	testQry="$SQLDIR/testQry.sql"
	testOut="${LOGDIR}/testOut.txt"
	echo -e "elapsedtime on;\nselect count(1) from sys.systables;" > $testQry
	$SQLSHELL -q ${HOSTORURL} -f $testQry -o $testOut
	if [[ "$?" != "0" ]]; then
	  echo "Error: sqlshell test failed for $SQLSHELL at $JDBC_URL" 
	  exit 3
	elif (( $DEBUG )); then
	  message "Test query results follow"
	  cat $testOut
	  echo
	fi

    # collect SpliceMachine info
    echo -e "call syscs_util.syscs_get_version_info();" > $testQry
    $SQLSHELL -q ${HOSTORURL} -f $testQry -o $testOut
    if [[ "$?" != "0" ]]; then
      echo "Error: sqlshell get_version_info failed for $SQLSHELL at $JDBC_URL"
      exit 3
    fi
    while read -r line; do
      if [[ "$line" = 'HOSTNAME'* ]]; then
        read -r line
        read -r line
        SPLICEMACHINE_VERSION=$(echo $line | cut -d\| -f2 | cut -d- -f1)
        SPLICEMACHINE_IMPL=$(echo $line | cut -d\| -f3)
        break
      fi
    done < $testOut
    debug SPLICEMACHINE_VERSION = $SPLICEMACHINE_VERSION
    debug SPLICEMACHINE_IMPL = $SPLICEMACHINE_IMPL

	#============
	# Main

	debug $0 entering Main for $BENCH with scale $SCALE schema $SCHEMA iterations $ITER


	if [[ "$BENCH" == "TPCH" || "$BENCH" == "TPCDS" ]]; then

	  # check for SCHEMA; if not present, make it
	  if (( $CREATE )); then
          createDatabase $SCHEMA $SCALE $MODE
	  fi
      # bomb out if schema is not good
      if ! validateSchema $SCHEMA $SCALE; then
          message "Error: the schema $SCHEMA has failed validation"
          exit 1
      fi

	  # TODO: generate explain statements
	  # TODO: gather one explain plan for each query

	  # generate query files for this SCHEMA
	  genQueries $SCHEMA $SCALE

	  # TODO: implement TPCH validation checks

	  # now start running
	  BENCH_PASS="PASS"
      > ${LOGBASE}logs/test_run.csv

	  declare -i i=1
	  while [ $i -le $ITER ]; do
	      loopStart=$(now)

	      LOGDIR="${LOGBASE}logs/$SCHEMA-queries-$STARTD-iter$i"
	      mkdir -p $LOGDIR

	      debug running $SCHEMA iter$i at $loopStart
	      runQueries $SCHEMA
	      checkBenchResults $SCHEMA $i

	      let i++
	  done

	  # TOODO: behavior: if iterations > 1, provide avg/min/max/stddev

      BENCH_END=$(date -u +'%Y-%m-%d %H:%M:%S')
      echo "$SPLICEMACHINE_VERSION|$SPLICEMACHINE_IMPL|UNKNOWN_CLUSTER_ID|$BENCH|$SCALE||$ITER|$BENCH_PASS|$BENCH_START|$BENCH_END" > ${LOGBASE}logs/run.csv
      sort -o ${LOGBASE}logs/test_run.csv ${LOGBASE}logs/test_run.csv

      cp $BASEDIR/index.html ${LOGBASE}logs

	elif [[ "$BENCH" == "TPCC" || "$BENCH" == "HTAP"  ]]; then

	  # TOODO: handle benchmarks which run transactional drivers *and* analytic queries
	  echo "Sorry, $BENCH is not yet implemented"

	fi

	# possibly send email?
	# possibly write to a table?

	# TOODO: document docker.for.mac.localhost

	ENDS=`date +%s`
	TOTALS=$((ENDS-STARTS))
echo Total runtime was $TOTALS seconds
