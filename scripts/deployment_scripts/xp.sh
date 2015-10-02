#!/bin/bash

#for i in {10..100..3}
for i in 30 
#20 30 40 50 60 70 80 90 100 110
do
    #start the cluster
    ./start_all_services.sh

    #wait for the cluster to be out of safemode
    sleep 60s
    rmProcess=$(ssh cloud3 "jps" | grep ResourceManager | awk '{print $1}')
    
    echo "========== starting bench $i =========="
    ssh cloud1 "/home/gautier/HiBench/sleep/bin/run-load_and_maintain.sh $i" &

#start computation of pi    
#    ssh cloud1 "/home/gautier/hop_distro/hadoop-2.4.0/bin/yarn jar /home/gautier/hop_distro/hadoop-2.4.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar pi 30 1000000000" | grep "Job Finished" >> results &
    
    sleep $i
    
#    echo "kill $rmProcess"
#    ssh cloud3 "kill $rmProcess"
    #wait long enoug for the xp to run
    sleep 300s
    #xps taking more time are considered as failed 
    #stop the cluster
    ./stop_all_services.sh 
    sleep 10
    #dl logs
    ./download_logs.sh "logs_$i"
    ./wipe_logs.sh
done
