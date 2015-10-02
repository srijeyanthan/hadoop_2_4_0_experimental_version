#!/bin/bash
# Author: Salman Niazi 2014
# This script broadcasts all files required for running a HOP instance.
# A password-less sign-on should be setup prior to calling this script


#load config parameters
source deployment.properties

#All Unique Hosts
All_Hosts=${HOP_DN_List[*]}
All_Unique_Hosts=$(echo "${All_Hosts[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')


for i in ${All_Unique_Hosts[@]}
do
	connectStr="$HOP_User@$i"
	echo "Starting DN on $i"
	ssh $connectStr  $HOP_Dist_Folder/sbin/hadoop-daemon.sh --script hdfs start datanode &
done 





