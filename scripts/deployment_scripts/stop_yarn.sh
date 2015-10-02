#!/bin/bash
# Author: Salman Niazi 2014
# This script broadcasts all files required for running a HOP instance.
# A password-less sign-on should be setup prior to calling this script


#load config parameters
source deployment.properties

All_Masters=${YARN_MASTERS[*]}
All_Unique_Masters=$(echo "${All_Masters[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

for i in ${All_Unique_Masters[@]}
do
    connectStr="$HOP_User@$i"
    echo "Stopping ResourceManager, ProxyServer and HistoryServer on $i"
    ssh $connectStr  $HOP_Dist_Folder/sbin/yarn-daemon.sh stop resourcemanager &
    ssh $connectStr  $HOP_Dist_Folder/sbin/yarn-daemon.sh stop proxyserver &
    ssh $connectStr  $HOP_Dist_Folder/sbin/mr-jobhistory-daemon.sh stop historyserver &
done

for i in ${HOP_DN_List[@]}
do
	echo "Stopping NodeManager on $i"
	connectStr="$HOP_User@$i"
	ssh $connectStr  $HOP_Dist_Folder/sbin/yarn-daemon.sh stop nodemanager &
done
