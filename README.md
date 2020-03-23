# Apache Spark

An [Apache Spark](http://spark.apache.org/) container image. The image is meant to be used for creating an standalone cluster with multiple workers.

## Custom commands

This image contains a script named `start-spark` (included in the PATH). This script is used to initialize the master and the workers.

### HDFS user

The custom commands require an HDFS user to be set. The user's name if read from the `HDFS_USER` environment variable and the user is automatically created by the commands.

### Starting a master

To start a master run the following command:

```sh
start-spark master
```

### Starting a worker

To start a worker run the following command:

```sh
start-spark worker [MASTER]
```

## Creating a Cluster with Docker Compose

The easiest way to create a standalone cluster with this image is by using [Docker Compose](https://docs.docker.com/compose). The following snippet can be used as a `docker-compose.yml` for a simple cluster:

```YAML
version: "2"

services:
  master:
    image: derrickoswald/spark-docker
    command: start-spark master
    hostname: master
    ports:
      - "4040:4040" # Cluster Manager Web UI
      - "6066:6066" # Standalone Master REST port (spark.master.rest.port)
      - "7077:7077" # Driver to Standalone Master, as in master = spark://sandbox:7077
      - "8020:8020" # DFS Namenode IPC, e.g. hdfs dfs -fs hdfs://sandbox:8020 -ls
      - "8080:8080" # Standalone Master Web UI
      - "8081:8081" # Standalone Worker Web UI
      - "10000:10000" # Thriftserver JDBC port
      - "10001:10001" # Thriftserver HTTP protocol JDBC port
      - "50010:50010" # DFS Datanode data transfer
      - "50070:50070" # DFS Namenode Web UI
      - "50075:50075" # DFS Datanode Web UI
  worker:
    image: derrickoswald/spark-docker
    command: start-spark worker master
    environment:
      SPARK_WORKER_CORES: 1
      SPARK_WORKER_MEMORY: 2g
    links:
      - master
```

### Persistence

The image has a volume mounted at `/opt/hdfs`. To maintain states between restarts, mount a volume at this location.
This should be done for the master and the workers.

### Scaling

If you wish to increase the number of workers scale the `worker` service by running the `scale` command like follows:

```sh
docker-compose scale worker=2
```

The workers will automatically register themselves with the master.
