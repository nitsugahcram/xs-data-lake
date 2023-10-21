#!/bin/bash


export HADOOP_OPTS="$HADOOP_OPTS \
-Xmx${HIVE_METASTORE_MEMORY} \
-Dcom.sun.management.jmxremote \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.sun.management.jmxremote.port=8808"


${HIVE_HOME}/bin/schematool -dbType postgres -initSchema --verbose

sleep 10

${HIVE_HOME}/bin/start-metastore

exec $@
