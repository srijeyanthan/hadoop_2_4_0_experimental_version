#!/bin/bash
# Author: Salman Niazi 2014
# This script broadcasts all files required for running a HOP instance.
# A password-less sign-on should be setup prior to calling this script


#load config parameters
source deployment.properties

if [ -z $1 ]; then
	echo "please, specify the process name"
	exit
fi

#All Unique Hosts
All_Hosts=${HOP_Default_NN[*]}" "${HOP_NN_List[*]}" "${HOP_DN_List[*]}" "${HOP_Experiments_Machine_List[*]}
All_Unique_Hosts=$(echo "${All_Hosts[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')


for i in ${All_Unique_Hosts[@]}
do
	connectStr="$HOP_User@$i"
	echo "Killing  $1 on $i"
        pids=`ssh $connectStr pgrep -u $HOP_User $1`
        echo "PIDS to kill "$pids
	ssh $connectStr  kill -9 $pids 
done

