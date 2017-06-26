FROM singularities/hadoop:2.7
MAINTAINER Singularities

# Version
ENV SPARK_VERSION=2.0.2

# set up TTY
ENV TERM=xterm-256color

# Set home
ENV SPARK_HOME=/usr/local/spark-$SPARK_VERSION

# Install dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install \
    -yq --no-install-recommends  \
      python python3 vim sqlite3 r-base p7zip net-tools \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install GridLAB-D
COPY gridlabd_3.2.0-2_amd64.deb /opt/util/gridlabd_3.2.0-2_amd64.deb
RUN dpkg -i /opt/util/gridlabd_3.2.0-2_amd64.deb \
  && rm /opt/util/gridlabd_3.2.0-2_amd64.deb

# Install Spark
RUN mkdir -p "${SPARK_HOME}" \
  && export ARCHIVE=spark-$SPARK_VERSION-bin-hadoop2.7.tgz \
  && export DOWNLOAD_PATH=mirror/apache/dist/spark/spark-$SPARK_VERSION/$ARCHIVE \
  && curl -sSL http://mirror.switch.ch/$DOWNLOAD_PATH | \
    tar -xz -C $SPARK_HOME --strip-components 1 \
  && sed 's/log4j.rootCategory=INFO/log4j.rootCategory=WARN/g' $SPARK_HOME/conf/log4j.properties.template >$SPARK_HOME/conf/log4j.properties \
  && rm -rf $ARCHIVE
COPY spark-env.sh $SPARK_HOME/conf/spark-env.sh
ENV PATH=$PATH:$SPARK_HOME/bin

# Remove duplicate SLF4J bindings
RUN mv /usr/local/spark-2.0.2/jars/slf4j-log4j12-1.7.16.jar /usr/local/spark-2.0.2/jars/slf4j-log4j12-1.7.16.jar.hide

# Ports
EXPOSE 6066 7077 8080 8081 10000 10004

# Copy start script
COPY start-spark /opt/util/bin/start-spark

# Fix Java native library path
# avoid WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
COPY spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf
RUN ldconfig

# Fix environment for other users
RUN echo "export SPARK_HOME=$SPARK_HOME" >> /etc/bash.bashrc \
  && echo 'export PATH=$PATH:$SPARK_HOME/bin'>> /etc/bash.bashrc \
  && echo "alias ll='ls -alF'">> /etc/bash.bashrc

# Add deprecated commands
RUN echo '#!/usr/bin/env bash' > /usr/bin/master \
  && echo 'start-spark master' >> /usr/bin/master \
  && chmod +x /usr/bin/master \
  && echo '#!/usr/bin/env bash' > /usr/bin/worker \
  && echo 'start-spark worker $1' >> /usr/bin/worker \
  && chmod +x /usr/bin/worker
