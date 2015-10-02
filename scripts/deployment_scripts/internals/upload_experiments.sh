#!/bin/bash
# Author: Salman Niazi 2014
# This script broadcasts all files required for running a HOP instance.
# A password-less sign-on should be setup prior to calling this script

source deployment.properties

#upload Experiments

        echo "***   Copying the Experiment to $HOP_Experiments_Dist_Folder  on ${HOP_Experiments_Machine_List[*]}***"
	for machine in ${HOP_Experiments_Machine_List[*]}
	do
		 connectStr="$HOP_User@$machine"
		 ssh $connectStr 'mkdir -p '$HOP_Experiments_Dist_Folder
	done
		
	JarFileName=hop-experiments-1.0-SNAPSHOT-jar-with-dependencies.jar
	temp_folder=/tmp/hop_exp_distro
	rm -rf $temp_folder
	mkdir -p $temp_folder	
	cp $HOP_Experiments_Folder/target/$JarFileName $temp_folder/
	RunScriptFile=$temp_folder/run.sh	
	touch $RunScriptFile
        echo  \#\!/bin/bash >                  $RunScriptFile
        echo  $HOP_Dist_Folder/bin/hadoop jar   $JarFileName  $\* >>   $RunScriptFile
        chmod +x $RunScriptFile
                 
	parallel-rsync -arz -H "${HOP_Experiments_Machine_List[*]}" --user $HOP_User     $temp_folder/   $HOP_Experiments_Dist_Folder  


