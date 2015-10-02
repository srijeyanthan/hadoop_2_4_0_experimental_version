#!/bin/bash
# Author: Salman Niazi 2014, Jim 2013
# This script broadcasts all files required for running a HOP instance.
# A password-less sign-on should be setup prior to calling this script

source deployment.properties

#All Unique Hosts
All_Hosts=${HOP_Default_NN[*]}" "${HOP_NN_List[*]}" "${HOP_DN_List[*]}" "${HOP_Experiments_Machine_List[*]}" "${YARN_MASTERS[*]}
All_Unique_Hosts=$(echo "${All_Hosts[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

#All Unique Namenodes
All_NNs=${HOP_Default_NN[*]}" "${HOP_NN_List[*]}
All_Unique_NNs=$(echo "${All_NNs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

#All Unique Yran resource manager
All_RMs=${YARN_MASTERS[*]}
All_Unique_RMs=$(echo "${All_RMs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

All_Hosts_Excluding_NNs=${HOP_DN_List[*]}" "${HOP_Experiments_Machine_List[*]}" "${YARN_MASTERS[*]}
All_Unique_Hosts_Excluding_NNs=$(echo "${All_Hosts_Excluding_NNs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

echo "Deploying on ${All_Unique_Hosts[*]}"
echo "Distribution Folder: $HOP_Dist_Folder"


# create remote directories
for machine in $All_Unique_Hosts
do
 connectStr="$HOP_User@$machine"
 ssh $connectStr 'mkdir -p '$HOP_Dist_Folder
done



#if [ -d "$NDB_EVENT_STREAMING_DISTRIBUTION_DIR" ];
#then
 #  echo "*************  hopsndbevent folder is found , removing and creating new for cluster deployment **************"
  # rm -rf       $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/hopsndbevent
#fi

#mkdir $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/hopsndbevent
#cp -rf          $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/include               $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/hopsndbevent
#cp -rf          $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/src                   $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/hopsndbevent
#cp              $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/*.ini    $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/hopsndbevent
#cp -rf          $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/ndbheaders            $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/hopsndbevent
#cp              $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/Makefile              $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/hopsndbevent




# copy data to the remote directories
echo "***   Copying the Distro   ***"
mkdir -p $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/Java
echo "*** cp java ***"
echo $JAVA_Folder
cp -nr    $JAVA_Folder/*                                                         $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/Java                        
echo "*** cp lib ndb *** "                                           
cp       $LIB_NDB_CLIENT_BIN                                                     $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/lib/native
echo "*** cp hop conf ***"
cp -rf   $HOP_Src_Folder/scripts/deployment_scripts/hop_conf                     $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/
echo "*** cp deployment.propertes ***"
cp       $HOP_Src_Folder/scripts/deployment_scripts/deployment.properties        $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/hop_conf/
echo "*** cp stream library ***"
cp -rf   $NDB_EVENT_STREAMING_DISTRIBUTION_DIR/hopsndbevent                      $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/
mkdir $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/hopsndbevent/bin
mkdir $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/hopsndbevent/obj

echo "*** parallel-rsync ***"
parallel-rsync -arz -v -H "${All_Unique_Hosts[*]}" --user $HOP_User    $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/        $HOP_Dist_Folder


# fix scripts on remote NN hosts
echo "***   Fixing address in NameNode configs   ***" 
for i in ${All_Unique_NNs[@]}
do
	connectStr="$HOP_User@$i"
	# running some scripts and commands on the server
	ssh $connectStr 'chmod +x       '$HOP_Dist_Folder'/hop_conf/scripts/*.sh'
	ssh $connectStr                 ''$HOP_Dist_Folder'/hop_conf/scripts/rename.sh   '$HOP_Dist_Folder/hop_conf/deployment.properties'    '$i' '$i' '
done

# fix scripts on remote DN hosts
echo "***   Fixing address in DataNode and Experiments configs   ***" 
for i in ${All_Unique_Hosts_Excluding_NNs[@]}
do
	connectStr="$HOP_User@$i"
	# running some scripts and commands on the server
	ssh $connectStr 'chmod +x       '$HOP_Dist_Folder'/hop_conf/scripts/*.sh'
	ssh $connectStr                 ''$HOP_Dist_Folder'/hop_conf/scripts/rename.sh   '$HOP_Dist_Folder/hop_conf/deployment.properties'    '${HOP_Default_NN[0]}' '$i' '
done

# move config files and scripts to appropriate folders
echo "***   Copying hdfs-site.xml core-site.xml etc to correct folders   ***" 
for i in ${All_Unique_Hosts[@]}
do
	connectStr="$HOP_User@$i"
	#copy the config files to right folders	
	ssh $connectStr cp         $HOP_Dist_Folder/hop_conf/hdfs_configs/*                              $HOP_Dist_Folder/etc/hadoop/
	

	#copying the script files to sbin
	ssh $connectStr cp -r            $HOP_Dist_Folder/hop_conf/scripts                               $HOP_Dist_Folder/sbin/
done

#### hop_disto deployment is done, so lets start compile c++ ndbevent streaming library
#echo "================   NDB Event streaming shared library builiding ========================="
#for i in ${All_Unique_Hosts[@]}
#do
 #   connectStr="$HOP_User@$i"
  #  LIB_NDB_CLIENT_FILE_PATH=$HOP_Dist_Folder/lib/native/libndbclient.so.6.0.0
   # LIB_HOPS_NDB_EVENT_LIBRARY=$HOP_Dist_Folder/lib/native/libhopsndbevent.so


    #echo "========== Perform symbolic link checking for Event Streaming shared library on cloud$i.sics.se =========="
    #if ssh $connectStr stat $LIB_NDB_CLIENT_FILE_PATH \> /dev/null 2\>\&1
    #then
     #   echo "===> $LIB_NDB_CLIENT_FILE_PATH already have the symbolic link"
    #else
     #   echo "===> $LIB_NDB_CLIENT_FILE_PATH is not created symbolic link.. creating now.."
      #  ssh  $connectStr               "cd $HOP_Dist_Folder/lib/native; ln -s libndbclient.so libndbclient.so.6.0.0"
    #fi
    #echo "========== Cleaning up previous libhopsndbevent distribution =========="


    #if ssh $connectStr stat $LIB_HOPS_NDB_EVENT_LIBRARY \> /dev/null 2\>\&1
    #then
     #   ssh  $connectStr                "rm  $HOP_Dist_Folder/lib/native/libhopsndbevent.so"
    #fi

    #ssh  $connectStr                "rm -rf $HOP_Dist_Folder/lib/native/hopsndbevent"
    
   # echo "========== Remote compilation starts now =========="
   # ssh  $connectStr               "cd $HOP_Dist_Folder/hopsndbevent ; make remove; make"
   # echo "========== Compilation is done. copy libhopsndbevent.so to native lib folder =========="

    #ssh  $connectStr               "cp $HOP_Dist_Folder/hopsndbevent/bin/libhopsndbevent.so $HOP_Dist_Folder/lib/native"
#    ssh  $connectStr               "cp $HOP_Dist_Folder/hopsndbevent/EventAPIConfig.ini /home/$HOP_User"
#done
