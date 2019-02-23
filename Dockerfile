FROM openjdk:8-jre-alpine

MAINTAINER Murray Brown <mbrown@splicemachine.com>

# -----
# TODO: merge all benchmarks into one image?  for now only TPCH and TPCDS
# -----

## TODO: figure out versioning of sqlshell url

# TODO: uncomment this once DB-6899 is done
#ARG SQLSHELL_URL:="https://s3.amazonaws.com/splice-releases/2.6.1.1735/sqlshell/sqlshell-2.6.1.1735.tar.gz"

# install bash and sqlshell
RUN	\
        apk update && apk add bash sed \
# TODO: uncomment this once DB-6899 is done
# &&      wget -q -O - $SQLSHELL_URL | tar -xzf - \
&&      rm -rf /var/cache/apk/* 

# TODO: once DB-6899 gets to cloud service, update to the SQLSHELL_URL
COPY ./sqlshell /sqlshell
COPY ./TPC-H/splicemachine/templates /TPC-H/templates
COPY ./TPC-DS/splicemachine/templates /TPC-DS/templates
COPY ./run-benchmark.sh /run-benchmark.sh

ENTRYPOINT ["/bin/bash", "-c", "/run-benchmark.sh \"$@\"", "--"]
