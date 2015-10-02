#!/bin/bash

config_params=$1
namenode=$2
current=$3

source $config_params

hdfs_site_xml=$HOP_Dist_Folder/hop_conf/hdfs_configs/hdfs-site.xml
core_site_xml=$HOP_Dist_Folder/hop_conf/hdfs_configs/core-site.xml
yarn_site_xml=$HOP_Dist_Folder/hop_conf/hdfs_configs/yarn-site.xml
hadoop_env_sh=$HOP_Dist_Folder/hop_conf/hdfs_configs/hadoop-env.sh
yarn_env_sh=$HOP_Dist_Folder/hop_conf/hdfs_configs/yarn-env.sh

#All Unique Namenodes
All_NNs=${HOP_Default_NN[*]}" "${HOP_NN_List[*]}
All_Unique_NNs=$(echo "${All_NNs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

All_RMs=${YARN_MASTERS[*]}
All_Unique_RMs=$(echo "${All_RMs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

#making changes in core-site.xml
sed -i 's|NN_MACHINE_NAME|'$namenode'|g' $core_site_xml


#making changes in hdfs-site.xml
sed -i 's|NN_MACHINE_NAME|'$namenode'|g' $hdfs_site_xml
sed -i 's|Dfs_Namenode_Logging_Level_Config_Param|'$Dfs_Namenode_Logging_Level_Config_Param'|g' $hdfs_site_xml
port=$Dfs_Port_Param
sed -i 's|Dfs_Namenode_Http_Address_Config_Param|'$port'|g' $hdfs_site_xml
port=$((port + 1))
sed -i 's|Dfs_Namenode_Rpc_Address_Config_Param|'$port'|g' $hdfs_site_xml

namenode_rpc_addresses=""
for i in ${All_Unique_NNs[@]}
do
        if [ "$namenode_rpc_addresses" == "" ]; then
                namenode_rpc_addresses="hdfs://$i:$port"
        else
                namenode_rpc_addresses="$namenode_rpc_addresses,hdfs://$i:$port"
        fi
	
done
sed -i 's|NN_RPC_ADDRESS_LIST|'$namenode_rpc_addresses'|g' $core_site_xml
sed -i 's|Dfs_Namenode_Rpc_Address_Config_Param|'$port'|g' $core_site_xml


port=$((port + 1))
sed -i 's|Dfs_Namenode_Servicerpc_Address_Config_Param|'$port'|g' $hdfs_site_xml
port=$((port + 1))
sed -i 's|Dfs_Datanode_Address_Config_Param|'$port'|g' $hdfs_site_xml
port=$((port + 1))
sed -i 's|Dfs_Datanode_Http_Address_Config_Param|'$port'|g' $hdfs_site_xml
port=$((port + 1))
sed -i 's|Dfs_Datanode_Ipc_Address_Config_Param|'$port'|g' $hdfs_site_xml

sed -i 's|Dfs_BlockSize_Config_Param|'$Dfs_BlockSize_Config_Param'|g' $hdfs_site_xml
sed -i 's|Dfs_Datanode_Data_Dir_Config_Param|'$Dfs_Datanode_Data_Dir_Config_Param'|g' $hdfs_site_xml



#making changes in yarn-site.xml
sed -i 's|YARN_MASTER|0.0.0.0|g' $yarn_site_xml

YARN_MASTERS_LIST=""
for i in ${All_Unique_RMs[@]}
do
echo "<property><name>yarn.resourcemanager.hostname."$i"</name><value>"$i"</value></property>" >> $yarn_site_xml
echo "<property><name>yarn.resourcemanager.address."$i"</name><value>"$i":PORT_2</value></property>" >> $yarn_site_xml

echo "<property><name>yarn.resourcemanager.scheduler.address."$i"</name><value>"$i":PORT_3</value></property>" >> $yarn_site_xml
echo "<property><name>yarn.resourcemanager.resource-tracker.address."$i"</name><value>"$i":PORT_5</value></property>" >> $yarn_site_xml
echo "<property><name>yarn.resourcemanager.admin.address."$i"</name><value>"$i":PORT_6</value></property>" >> $yarn_site_xml
echo "<property><name>yarn.resourcemanager.groupMembership.address."$i"</name><value>"$i":PORT_10</value></property>" >> $yarn_site_xml
echo "<property><name>yarn.resourcemanager.webapp.address."$i"</name><value>"$i":PORT_01</value></property>" >> $yarn_site_xml
YARN_MASTERS_LIST=$i","$YARN_MASTERS_LIST
done

if [ $current = $YARN_MASTER ] 
then
echo "<property><name>yarn.resourcemanager.ha.initializedb</name><value>true</value></property>" >> $yarn_site_xml
else
echo "<property><name>yarn.resourcemanager.ha.initializedb</name><value>false</value></property>" >> $yarn_site_xml
fi

YARN_MASTERS_LIST=${YARN_MASTERS_LIST::-1}
sed -i 's|YARN_RMIDS|'$YARN_MASTERS_LIST'|g' $yarn_site_xml
echo "</configuration>" >> $yarn_site_xml

port=$Yarn_Port_Param
sed -i 's|PORT_01|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_2|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_2|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_3|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_4|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_5|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_6|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_7|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_8|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_9|'$port'|g' $yarn_site_xml
port=$((port + 1))
sed -i 's|PORT_10|'$port'|g' $yarn_site_xml

#makgin changes in hadoop-env.sh
sed -i 's|JAVA_PATH_STRING|'$HOP_Dist_Folder/Java'|g' $hadoop_env_sh

#makgin changes in hadoop-env.sh
sed -i 's|JAVA_PATH_STRING|'$HOP_Dist_Folder/Java'|g' $yarn_env_sh


exit 0
