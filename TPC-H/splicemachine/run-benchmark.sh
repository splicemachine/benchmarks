#!/bin/bash

# Author: Murray Brown <mbrown@splicemachine.com>

usage() {
  echo "Usage: $0 { -h host | -u url } [-b benchmark] [-s scale] [-l label] [-n name] [-i iterations] [-t timeout] [-D] [-V] [-H]"
}

help() {
  usage
  echo -e "\n\ta program to run a benchmark validation queryset against a Splice Machine database"
  echo -e "\t -h host\t\t the hostname of your database. One of host or url is required."
  echo -e "\t -u url\t\t a jdbc url for your database. One of host or url is required."
  echo -e "\t -b benchmark \t\t a benchmark to run. (default: TPCH) {valid: TPCH, TPCC}"
  echo -e "\t -s scale \t\t scale of (default: 1) {valid scales 1, 10, 100, 1000}"
  echo -e "\t -l label \t\t a label to identify the output (default: scale and date)"
  echo -e "\t -n name \t\t a suffix to add to a schema name"
  echo -e "\t -i iterations \t\t how many iterations to run (default: 1)"
  echo -e "\t -t timeout \t\t how many seconds to allow each query to run (default: forever)"
  echo -e "\t -D debug mode \t\t prints debug messaging"
  echo -e "\t -V verbose mode \t prints helpful messaging"
  echo -e "\t -H help \t\t prints this help"
}

BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

debug() {
  local msg="$*"

  if (( $DEBUG )); then
    echo "DEBUG: $msg" >&2
  fi
}

message() {
  local msg="$*"

  if (( $VERBOSE )); then
    echo "$msg"
  fi
}

now() {
  date +%Y%m%d-%H%M
}

START=$(now)

#Defaults
HOST=""
URL=""
BENCH="TPCH"
INTERACTIVE=0
SCALE=1
LABEL=""
SUFFIX=""
ITER=1
TIMEOUT=0
DEBUG=0
VERBOSE=0

# Option Parsing
OPTIND=1
while getopts ":h:u:b:s:l:n:i:t:DVH" opt; do
  case $opt in
    h) HOST=$OPTARG
       ;;
    u) URL=$OPTARG
       ;;
    b) BENCH=$OPTARG
       ;;
    s) SCALE=$OPTARG
       ;;
    l) LABEL=$OPTARG
       ;;
    n) SUFFIX=$OPTARG
       ;;
    i) ITER=$OPTARG
       ;;
    t) TIMEOUT=$OPTARG
       ;;
    D) DEBUG=1
       ;;
    V) VERBOSE=1
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

# concoct schema name from inputs
SCHEMA="$BENCH$SCALE$SUFFIX"

# query directory
SQLDIR="$BASEDIR/$SCHEMA-queries"
if [[ ! -d $SQLDIR ]]; then
  mkdir -p $SQLDIR
fi

# log output directory
LOGDIR="$BASEDIR/logs/$SCHEMA-queries-$START"
if [[ ! -d $LOGDIR ]]; then
  mkdir -p $LOGDIR
fi

# TOODO: implement specific query selection
TPCHMIN=1
TPCHMAX=22

# TOODO: implement actual benchmark

#============
# Argument Checking

# HOST or URL are required
HOSTORURL=""
if [[ "$HOST" == "" && "$URL" == "" ]]; then
  echo "Error: One of host or url must be supplied!"
  usage
  exit 1
elif [[ "$HOST" != "" ]]; then
  HOSTORURL="-h $HOST" 
else
  HOSTORURL="-u $URL" 
fi
debug host-or-url is $HOSTORURL

# TOODO: figure out if URL is 'well-formed'

# check valid benchmark
if [[ "$BENCH" != "TPCH" && "$BENCH" != "TPCC" ]]; then
   echo "Error: benchmark $BENCH is not supported!"
   usage
   exit 2
fi

# check for only valid scales
if [[ "$BENCH" == "TPCH" && "$SCALE" != "1" && "$SCALE" != "10" && "$SCALE" != "100" && "$SCALE" != "1000" ]]; then
   echo "Error: scale of $SCALE is not supported for $BENCH!"
   usage
   exit 2
fi

#  check if label is blank else generate it
if [[ "$LABEL" == "" ]]; then
  LABEL="$BENCH-$SCALE benchmark run started $START"
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

if [[ $TIMEOUT != 0 ]]; then
   # TOODO: test non-zero timeout handling
   echo "umm... i have not tested that yet"
   exit 127
fi

debug exiting arg checks

#============
# Subroutines

# TOODO: global or local file location handling?

# takes a single argument -- the name of the query file, prepends SQLDIR
runQuery() {
  local queryfile=${SQLDIR}/${1}
  local outfile=${LOGDIR}/${1//sql/out}

  if [ "$TIMEOUT" -eq 0 ]; then
    $SQLSHELL -q $HOSTORURL -f $queryfile -o $outfile 
    return $?
  else
    # TOODO: test non-zero timeout
	$SQLSHELL -q $HOSTORURL -f $queryfile -o $outfile &
        echo

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
		$SQLSHELL -q $HOSTORURL <<< "call SYSCS_UTIL.SYSCS_KILL_ALL_STATEMENTS();"
	fi
  fi
}

# only works on a 'one count' query outputfile
countResults() {
  local outfile=$1

  #if [[ ! -f $outfile ]]; then
  #  debug "Error: countResults: no such file $outfile"
  #   return 0
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

# put the schema in front
addSchemaToQuery() {
  local schema=$1
  local file=$2
  local output="$SQLDIR/$file"
  
  echo "SET SCHEMA ${schema};" > $output
  cat $BASEDIR/templates/$file >> $output

}

# validate that a TPCH schema has the right tables
checkTPCHSchema() {
   local schema=$1
   #echo "select count(1) from sys.sysschemas where schemaname = '${schema}';" 

   local query="checkSchema.sql"
   echo "select count(1) from sys.systables t join sys.sysschemas s on s.SCHEMAID=t.SCHEMAID and s.SCHEMANAME='${schema}';" > $SQLDIR/$query
   runQuery $query
   countResults $LOGDIR/${query/sql/out}
   local -i count=$?

   debug "CheckTPCHSchema: found $count from $query"
   if [[ "$count" -ne 8 ]]; then
     debug bad TPCH schema
     return 1
   else
     debug good TPCH schema
     return 0
   fi


   # TODO: check that all the tables in setup-06-count.out  have the 'right' counts

}

# substitution function for templated queries
fillTemplate() {
  local file=$1
  local schema=$2
  local scale=$3

  local input="$BASEDIR/templates/$file"
  local output="$SQLDIR/$file"

  if [[ ! -f $input ]]; then
    debug "Error: there is no template $file"
    return 1
  fi
  cp $input $output
  sed  -e "s/##SCHEMA##/$schema/g" -i $output
  sed  -e "s/##SCALE##/$scale/g" -i $output
}

# create and load the TPCH database for this scale
createTPCHdatabase() {
  local schema=$1
  local scale=$2

  debug "Creating TPCH at $schema for scale $scale"

  # duplicate templates and substitute SCHEMA and SCALE etc
  fillTemplate "setup-01-tables.sql" $schema $scale
  fillTemplate "setup-02-import.sql" $schema $scale
  fillTemplate "setup-03-indexes.sql" $schema $scale
  fillTemplate "setup-04-compact.sql" $schema $scale
  fillTemplate "setup-05-stats.sql" $schema $scale
  fillTemplate "setup-06-count.sql" $schema $scale

  # create the actual database
  runQuery "setup-01-tables.sql"
  runQuery "setup-02-import.sql"
  runQuery "setup-03-indexes.sql"
  runQuery "setup-04-compact.sql"
  runQuery "setup-05-stats.sql"
  runQuery "setup-06-count.sql"

  # TODO: handle s3 load error
  echo "check the db please"
}

# check counts
# TOOD: write a routine to check that TPCH was loaded with correct data

# generate query files for this schema
genTPCHqueries() {
  local schema=$1
  for i in `seq -w $TPCHMIN $TPCHMAX`; do
    debug adding $schema for $i
    addSchemaToQuery $schema "query-$i.sql" 
  done
}

runTPCHQueries() {
  local schema=$1
  for i in `seq -w $TPCHMIN $TPCHMAX`; do
    message "Running TPCH query $i at scale $SCALE"
    runQuery "query-$i.sql"
  done
}

# check a query output for error
checkQueryError() {
  local outfile=$1
  local -i errCount=$(grep ERROR $outfile | wc -l)

  debug checkQueryError: error count is $errCount
  echo $errCount
}

# check a query output for execution time
checkQueryTime() {
  local outfile=$1
  local execTime=$(grep "ELAPSED TIME" $outfile | awk '{print $4,$5}')

  debug checkQueryTime: exec time is $execTime
  echo $execTime
}

checkOneTPCH() {
  local schema=$1
  for i in `seq -w $TPCHMIN $TPCHMAX`; do
    local -i errCount=$(checkQueryError "${LOGDIR}/query-$i.out")
    debug checkOneTPCH errCount $errCount
    if [[ $errCount -eq 0 ]]; then
      local time=$(checkQueryTime "${LOGDIR}/query-$i.out")
      if [[ "$time" != "" ]]; then
        echo "$SCHEMA query-$i.sql took $time"
      else
        echo "$SCHEMA query-$i.sql no errors and no time"
      fi
    else
      echo "$SCHEMA query-$i.sql had $errCount errors"
    fi
  done
}

# TODO: iterate over many results
# checkTPCHOutput() {
# compute min/max/avg/stddev
# }

#============
# Sanity Tests

if [[ ! -d $BASEDIR/templates ]]; then
  echo "Error: $BASEDIR/templates must be present"
  exit 2
fi

# Test for sqlshell
SQLSHELL="/sqlshell/sqlshell.sh"
if [[ ! -f $SQLSHELL ]]; then
   echo "Error: could not find sqlshell <$SQLSHELL>"
   exit 2
fi

# Test that we can connect to a db
testQry="testQry.sql"
testOut="testOut.txt"
echo -e "elapsedtime on;\nselect count(1) from sys.systables;" > $SQLDIR/$testQry
$SQLSHELL -q $HOSTORURL -f $SQLDIR/$testQry -o $testOut
if [[ "$?" != "0" ]]; then
  echo "Error: sqlshell test failed for $SQLSHELL at $JDBC_URL" 
  exit 3
elif (( $VERBOSE )); then
  echo "Test query results follow"
  cat $testOut
  echo
fi

debug now test runQuery subroutine
runQuery $testQry
#TODO: check that runQuery succeeded
if (( $VERBOSE )); then
  cat $LOGDIR/${testQry//sql/out}
  echo
fi

#============
# Main

debug $0 entering Main for $BENCH with scale $SCALE schema $SCHEMA iterations $ITER


if [[ "$BENCH" == "TPCH" ]]; then

  # check for SCHEMA; if not present, make it
  if ( ! checkTPCHSchema $SCHEMA ) then
    createTPCHdatabase $SCHEMA $SCALE
  fi
 
  # bomb out if schema still not present
  if ( ! checkTPCHSchema $SCHEMA ) then
    debug "Error: the schema $SCHEMA no bueno"
    exit 1
  fi
 
  # generate TPCH query files for this SCHEMA
  genTPCHqueries $SCHEMA

  # now start running
  if [[ "$ITER" == "1" ]]; then
    echo "Handle single run"
    runTPCHQueries $SCHEMA

    # output single results
    checkOneTPCH $SCHEMA

  else # many iterations
    for (( i=1; i<=$ITER; i++ )); do
      loopStart=$(now)
      LOGDIR="$BASEDIR/logs/$SCHEMA-queries-$START-iter$i"
      mkdir -p $LOGDIR
      debug running $SCHEMA iter$i
      rv=$(runTPCHQueries $SCHEMA)
      echo $rv
    done
    
    # TODO: behavior: if iterations > 1, provide avg/min/max/stddev
    checkOneTPCH $SCHEMA
  fi


  # possibly send email?
  # possibly write to a table?

elif [[ "$BENCH" == "TPCC" ]]; then

  # TODO: handle benchmark other than TPCH
  echo "Sorry, TPCC is not yet implemented"

fi
