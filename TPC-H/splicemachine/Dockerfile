# works, but lame:
FROM murray/test-openjdk8

# Nik/brews is using:
# FROM openjdk:8-jdk

# TODO: get a better jdk8 base
#FROM 8-jre-alpine3.7
#FROM alpine:3.6
#FROM durdn/minimal-java8:stripped

MAINTAINER Murray Brown <mbrown@splicemachine.com>

# -----
# TODO: merge all benchmarks into one image?  for now only TPCH

# -----


## TODO: figure out versioning of sqlshell url
# TODO: uncomment this once DB-6899 is done
#ARG SQLSHELL_URL:="https://s3.amazonaws.com/splice-releases/2.6.1.1735/sqlshell/sqlshell-2.6.1.1735.tar.gz"

ENV JDBC_URL="jdbc:splice://localhost:1527/splicedb;user=admin;password=splice"
ENV SCALE=1
ENV LABEL=""
ENV SCHEMA_SUFFIX=""
ENV ITERATIONS=1

# install bash and sqlshell

RUN	\
        apk update && apk add bash sed \
# TODO: uncomment this once DB-6899 is done
# &&      wget -q -O - $SQLSHELL_URL | tar -xzf - \
&&      rm -rf /var/cache/apk/* 

# TODO: once DB-6899 gets to cloud service, update to the SQLSHELL_URL
COPY ./sqlshell /sqlshell
COPY ./templates /templates
COPY ./run-benchmark.sh /run-benchmark.sh

#ENTRYPOINT ["/run-benchmark.sh", "-u $JDBC_URL", "-s $SCALE", "-i $ITERATIONS", "-D", "-V"]
#ENTRYPOINT ["/run-benchmark.sh", "-h localhost", "-s $SCALE", "-i $ITERATIONS", "-D", "-V"]
ENTRYPOINT ["/bin/bash", "-c", "/run-benchmark.sh \"$@\"", "--"]
