#!/bin/bash

# defaults
URL=""
HOST="localhost"
PORT="1527"
USER="splice"
PASS="admin"
SCRIPT=""
OUTPUT=""
QUIET=0

# Splice Machine SQL Shell
message() {
   local msg="$*"

   if (( ! $QUIET )); then
      echo -en $msg
   fi
}

show_help() {
        echo "Splice Machine SQL client wrapper script"
        echo "Usage: $(basename $BASH_SOURCE) [-U url] [-h host] [-p port ] [-u username] [-s password] [-f scriptfile]"
        echo -e "\t-U full JDBC URL for Splice Machine database"
        echo -e "\t-h IP address or hostname of Splice Machine (HBase RegionServer)"
        echo -e "\t-p Port which Splice Machine is listening on, defaults to 1527"
        echo -e "\t-u username for Splice Machine database"
        echo -e "\t-s password for Splice Machine database"
        echo -e "\t-f sql file to be executed"
        echo -e "\t-o file for output"
        echo -e "\t-q quiet mode"
}

# Process command line args
while getopts "U:h:p:u:s:f:o:q" opt; do
    case $opt in
        U)
            URL="${OPTARG}"
            ;;
        h)
            HOST="${OPTARG}"
            ;;
        p)
            PORT="${OPTARG}"
            ;;
        u)
            USER="${OPTARG}"
            ;;
        s)
            PASS="${OPTARG}"
            ;;
        f)
            SCRIPT="${OPTARG}"
            ;;
        o)
            OUTPUT="${OPTARG}"
            ;;
        q)
            QUIET=1
            ;; 
        \?)
            show_help
            exit 1
            ;;
    esac
done

#Get the directory where this script resides
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export CLASSPATH="${CURDIR}/lib/*"

GEN_SYS_ARGS="-Djava.awt.headless=true"

IJ_SYS_ARGS="-Djdbc.drivers=com.splicemachine.db.jdbc.ClientDriver"

# TODO: figure out if OUTPUT directory exists
if [[ "$OUTPUT" != "" ]]; then
  IJ_SYS_ARGS+=" -Dij.outfile=${OUTPUT}"
fi

if [[ "$URL" != "" ]]; then
  IJ_SYS_ARGS+=" -Dij.connection.splice=${URL}"
else
  IJ_SYS_ARGS+=" -Dij.connection.splice=jdbc:splice://${HOST}:${PORT}/splicedb;user=${USER};password=${PASS}"
fi

if [ ! -z "${CLIENT_SSL_KEYSTORE}" ]; then
SSL_ARGS="-Djavax.net.ssl.keyStore=${CLIENT_SSL_KEYSTORE} \
    -Djavax.net.ssl.keyStorePassword=${CLIENT_SSL_KEYSTOREPASSWD} \
    -Djavax.net.ssl.trustStore=${CLIENT_SSL_TRUSTSTORE} \
    -Djavax.netDjavax.net.ssl.trustStore.ssl.trustStorePassword=${CLIENT_SSL_TRUSTSTOREPASSWD}"
fi

if hash rlwrap 2>/dev/null; then
   message "\n ========= rlwrap detected and enabled.  Use up and down arrow keys to scroll through command line history. ======== \n\n"
   RLWRAP=rlwrap
else
   message "\n ========= rlwrap not detected.  Consider installing for command line history capabilities. ========= \n\n"
   RLWRAP=
fi

message "Running Splice Machine SQL shell"
message "For help: \"splice> help;\""
${RLWRAP} java ${GEN_SYS_ARGS} ${SSL_ARGS} ${IJ_SYS_ARGS} com.splicemachine.db.tools.ij ${SCRIPT}

