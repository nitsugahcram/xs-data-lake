ARG BASE_CONTAINER=ubuntu:jammy
FROM $BASE_CONTAINER
ARG NB_USER=metastore
ARG NB_UID=1000
ARG NB_GID=100
# default password for user
ARG PW=metastore123
## Base on https://techjogging.com/standalone-hive-metastore-presto-docker.html

# Option1: Using unencrypted password/ specifying password
RUN groupadd -g ${NB_GID} -o ${NB_GROUP:-${NB_USER}}
RUN useradd -m ${NB_USER} --uid=${NB_UID} -g ${NB_GID}  && echo "${NB_USER}:${PW}" | chpasswd

# Configure environment
ENV SHELL=/bin/bash \
    USER=${NB_USER} \
    UID=${NB_UID} \
    GID=${NB_GID} \
    HOME=/home/${NB_USER}

USER root

RUN mkdir -p /usr/share/man/man1 && \
    apt-get -y update && \
    apt-get install --no-install-recommends -y openjdk-17-jre-headless ca-certificates-java lsof jattach \
    wget curl libpostgresql-jdbc-java procps libsasl2-modules libsasl2-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/

ENV HADOOP_VERSION=3.3.6
RUN curl -L https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar xfz - -C /opt/ --owner root --group root --no-same-owner && \
    mv /opt/hadoop-${HADOOP_VERSION} /opt/hadoop

ENV HADOOP_HOME=/opt/hadoop \
    PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin



# Install Apache Hive

ENV HIVE_VERSION=3.0.0 \
    HIVE_HOME=/opt/metastore \
    HIVE_CONF_DIR=${HIVE_HOME}/conf \
    PATH=${PATH}:${HIVE_HOME}/bin

ARG HIVE_PACKAGE=hive-standalone-metastore-${HIVE_VERSION}
ARG HIVE_FOLDER=apache-hive-metastore-${HIVE_VERSION}-bin

RUN curl -L https://downloads.apache.org/hive/${HIVE_PACKAGE}/${HIVE_PACKAGE}-bin.tar.gz | \
    tar xfz - -C /opt && \
    chown -R root:root /opt/${HIVE_FOLDER} && \
    mv /opt/${HIVE_FOLDER} $HIVE_HOME \
    && mkdir -p ${HIVE_HOME}/hcatalog/var/log \
    && mkdir -p ${HIVE_HOME}/var/log \
    && mkdir -p /data/hive/ \
    && mkdir -p ${HIVE_CONF_DIR} \
    && chmod 777 ${HIVE_HOME}/hcatalog/var/log \
    && chmod 777 ${HIVE_HOME}/var/log 


# Pull Dependecies 

RUN curl https://jdbc.postgresql.org/download/postgresql-42.5.4.jar -o ${HIVE_HOME}/lib/postgresql-42.5.4.jar
RUN rm ${HIVE_HOME}/lib/guava-19.0.jar && \
    cp ${HADOOP_HOME}/share/hadoop/hdfs/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib/ && \ 
    cp ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.3.6.jar ${HIVE_HOME}/lib && \
    cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.12.367.jar ${HIVE_HOME}/lib && \
    cp ${HADOOP_HOME}/share/hadoop/common/hadoop-common-3.3.6.jar ${HIVE_HOME}/lib

# Configuration


# # Log4j WA 

# RUN  rm -v /opt/hadoop/share/hadoop/common/lib/log4j-1.2.17.jar \
#         /opt/hadoop/share/hadoop/common/lib/slf4j-log4j12-1.7.30.jar \
#         /opt/hadoop/share/hadoop/hdfs/lib/log4j-1.2.17.jar \
#         /opt/metastore/lib/log4j-1.2-api-2.8.2.jar \
#         /opt/metastore/lib/log4j-api-2.8.2.jar \
#         /opt/metastore/lib/log4j-core-2.8.2.jar \
#         /opt/metastore/lib/log4j-slf4j-impl-2.8.2.jar


# RUN  curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-1.2-api/2.17.1/log4j-1.2-api-2.17.1.jar -o \
#         /opt/metastore/lib/log4j-1.2-api-2.17.1.jar && \
#      curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.17.1/log4j-api-2.17.1.jar -o \
#         /opt/metastore/lib/log4j-api-2.17.1.jar && \
#      curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.17.1/log4j-core-2.17.1.jar -o \
#         /opt/metastore/lib/log4j-core-2.17.1.jar && \
#      curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-slf4j-impl/2.17.1/log4j-slf4j-impl-2.17.1.jar -o \
#         /opt/metastore/lib/log4j-slf4j-impl-2.17.1.jar 



COPY wait-for-it.sh /etc/boot/wait-for-it.sh
RUN chmod +x /etc/boot/wait-for-it.sh
ADD resources/metastore-site.xml ${HIVE_CONF_DIR}/hive-site.xml
ADD resources/entrypoint_hive.sh /
RUN chmod +x /entrypoint_hive.sh
ADD resources/hive-log4j.properties.template ${HIVE_CONF_DIR}/hive-log4j.properties.template

EXPOSE 9083

ENTRYPOINT ["./entrypoint_hive.sh"]
