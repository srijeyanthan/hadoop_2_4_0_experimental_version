#!/bin/bash
# Author: Salman Niazi 2014
# This script broadcasts all files required for running a HOP instance.
# A password-less sign-on should be setup prior to calling this script


#load config parameters
source deployment.properties


	connectStr="$HOP_User@${HOP_Default_NN[0]}"
	echo "Starting NN on ${HOP_Default_NN[0]}"
	ssh $connectStr $HOP_Dist_Folder/bin/hdfs namenode -format






