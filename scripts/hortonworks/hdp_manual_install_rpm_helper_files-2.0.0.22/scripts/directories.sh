#!/bin/sh

#
# Directories Script
#
# 1. To use this script, you must edit the TODO variables below for your environment.
#
# 2. Warning: Leave the other parameters as the default values. Changing these default values will require you to
#    change values in other configuration files.
#

#
# Hadoop Service - HDFS
#

# Space separated list of directories where NameNode will store file system image. For example, /grid/hadoop/hdfs/nn /grid1/hadoop/hdfs/nn
DFS_NAME_DIR="TODO-LIST-OF-NAMENODE-DIRS";

# Space separated list of directories where DataNodes will store the blocks. For example, /grid/hadoop/hdfs/dn /grid1/hadoop/hdfs/dn /grid2/hadoop/hdfs/dn
DFS_DATA_DIR="TODO-LIST-OF-DATA-DIRS";

# Space separated list of directories where SecondaryNameNode will store checkpoint image. For example, /grid/hadoop/hdfs/snn /grid1/hadoop/hdfs/snn /grid2/hadoop/hdfs/snn
FS_CHECKPOINT_DIR="TODO-LIST-OF-SECONDARY-NAMENODE-DIRS";



# Directory to store the HDFS logs.
HDFS_LOG_DIR="/var/log/hadoop/hdfs";

# Directory to store the HDFS process ID.
HDFS_PID_DIR="/var/run/hadoop/hdfs";

# Directory to store the Hadoop configuration files.
HADOOP_CONF_DIR="/etc/hadoop/conf";

#
# Hadoop Service - YARN 
#

# Space separated list of directories where YARN will store temporary data. For example, /grid/hadoop/yarn /grid1/hadoop/yarn /grid2/hadoop/yarn
YARN_LOCAL_DIR="TODO-LIST-OF-YARN-LOCAL-DIRS";

# Directory to store the YARN logs.
YARN_LOG_DIR="/var/log/hadoop/yarn"; 

# Directory to store the YARN process ID.
YARN_PID_DIR="/var/run/hadoop/yarn";

# Hadoop Service - MAPRED
MAPRED_LOG_DIR="/var/log/hadoop/mapred";

#
# Hadoop Service - Tez
#

export TEZ_LOG_DIR=/var/log/tez
export TEZ_PID_DIR=/var/run/tez
export TEZ_HOME=/usr/lib/tez
export TEZ_CONF_DIR=/etc/tez/conf

#
# Hadoop Service - Hive
#

# Directory to store the Hive configuration files.
HIVE_CONF_DIR="/etc/hive/conf";

# Directory to store the Hive logs.
HIVE_LOG_DIR="/var/log/hive";

# Directory to store the Hive process ID.
HIVE_PID_DIR="/var/run/hive";

#
# Hadoop Service - WebHCat (Templeton)
#

# Directory to store the WebHCat (Templeton) configuration files.
WEBHCAT_CONF_DIR="/etc/hcatalog/conf/webhcat";

# Directory to store the WebHCat (Templeton) logs.
WEBHCAT_LOG_DIR="var/log/webhcat";

# Directory to store the WebHCat (Templeton) process ID.
WEBHCAT_PID_DIR="/var/run/webhcat";

#
# Hadoop Service - HBase
#

# Directory to store the HBase configuration files.
HBASE_CONF_DIR="/etc/hbase/conf";

# Directory to store the HBase logs.
HBASE_LOG_DIR="/var/log/hbase";

# Directory to store the HBase logs.
HBASE_PID_DIR="/var/run/hbase";

#
# Hadoop Service - ZooKeeper
#

# Directory where ZooKeeper will store data. For example, /grid1/hadoop/zookeeper/data
ZOOKEEPER_DATA_DIR="TODO-ZOOKEEPER-DATA-DIR";

# Directory to store the ZooKeeper configuration files.
ZOOKEEPER_CONF_DIR="/etc/zookeeper/conf";

# Directory to store the ZooKeeper logs.
ZOOKEEPER_LOG_DIR="/var/log/zookeeper";

# Directory to store the ZooKeeper process ID.
ZOOKEEPER_PID_DIR="/var/run/zookeeper";

#
# Hadoop Service - Pig
#

# Directory to store the Pig configuration files.
PIG_CONF_DIR="/etc/pig/conf";

# Directory to store the Pig logs.
PIG_LOG_DIR="/var/log/pig";

# Directory to store the Pig process ID.
PIG_PID_DIR="/var/run/pig";

export HADOOP_HOME=/usr/lib/hadoop
export HADOOP_LIBEXEC_DIR=/usr/lib/hadoop/libexec
export HADOOP_MAPRED_HOME=/usr/lib/hadoop-mapreduce
export HADOOP_MAPRED_LOG_DIR=/var/log/hadoop/mapred
export HIVE_JAR_DIR=/apps/hive/tez-ampool-jars