#!/usr/bin/env bash

export HADOOP_HOME=/usr/local/hadoop-3.2.1
export HADOOP_LIBEXEC_DIR=$HADOOP_HOME/libexec
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_DIST_CLASSPATH=$(hadoop classpath)

