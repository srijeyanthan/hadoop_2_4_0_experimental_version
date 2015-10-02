#!/bin/bash
USER=ubuntu
SCHEDULER=54.170.149.72
NODE_LIST=(54.170.16.186 54.155.55.74)
PRIVATE_NODE_LIST=(10.13.8.131 10.81.11.33)


mysql -u kthfs -pkthfs -h $SCHEDULER -P 3306 -e 'drop database hops_gautier;'
mysql -u kthfs -pkthfs -h $SCHEDULER -P 3306 -e 'create database hops_gautier;'
mysql -u kthfs -pkthfs -h $SCHEDULER -P 3306 hops_gautier < ../../schema/hayarn.sql


for k in {0..0}
do
    for runNb in {2..5}
    do
	for i in 2000 2500 3000 3500 4000 4500 5000 5500 6000 6500 7000 7500 8000 8500 9000 9500 10000 11000 12000 13000 14000 15000 16000 17000 18000 19000 20000 30000 
#40000 50000 60000 70000 80000 90000 100000
	do
	    #start the scheduler 
	    #echo "=========== format mysql = $(date)"
	    

	    echo "========= format yarn = $(date)"
	    echo "$USER@$SCHEDULER /home/$USER/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval format"
	    ssh $USER@$SCHEDULER "/home/$USER/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval format"
	    
	    echo "============ start scheduler = $(date)"
	    ssh $USER@$SCHEDULER "rm /home/$USER/hop_distro/hadoop-2.4.0/logs/yarn.log"
	    ssh $USER@$SCHEDULER "ulimit -c unlimited && /home/$USER/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval run 1000" &
	    SCHED_PID=$(ssh $USER@$SCHEDULER "jps" | grep DistributedRTRMEvaluation | awk '{print $1}')
	    
	    sleep 10s
	    for l in $(seq 0 1 $k)
	    do
		ssh $USER@${NODE_LIST[$l]} "rm /home/$USER/hop_distro/hadoop-2.4.0/logs/yarn.log"
		ssh $USER@${NODE_LIST[$l]} "/home/$USER/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval run 1000" &
	    done
	    
	    #wait for the cluster to be out of safemode
	    sleep 10s
	    
	    echo "========== starting bench $k $i $runNb =========="
	    echo $(date)
	    nbNMTotal=$i
	    for l in $(seq 0 1 $k)
	    do
		nbRT=$(expr $k + 1)
		nbNMRT=$(expr $(expr $nbNMTotal / $nbRT))
		echo "/home/$USER/hop_distro/hadoop-2.4.0/bin/yarn rmClientEval run ${PRIVATE_NODE_LIST[$l]} $nbNMRT 3000 120000 6666 $nbNMTotal results$k"
		ssh $USER@${NODE_LIST[$l]} "/home/$USER/hop_distro/hadoop-2.4.0/bin/yarn rmClientEval run ${PRIVATE_NODE_LIST[$l]} $nbNMRT 3000 120000 6666 $nbNMTotal results$l_$k\_$runNb" &
	    done

	    for l in $(seq 0 1 $k)
	    do
		PID=$(ssh $USER@${NODE_LIST[$l]} "jps" | grep DistributedRTClientEvaluation | awk '{print $1}')
		while [ "$PID" != "" ]
		do
		    sleep 10s
		    PID=$(ssh $USER@${NODE_LIST[$l]} "jps" | grep DistributedRTClientEvaluation | awk '{print $1}')
		done
	    done
	     
	    
	    echo "killing rts"
	    for l in $(seq 0 1 $k)
	    do
		SCHED_PID2=$(ssh $USER@${NODE_LIST[$l]} "jps" | grep DistributedRTRMEvaluation | awk '{print $1}')
		while [ "$SCHED_PID2" != "" ]
		do
		    ssh $USER@${NODE_LIST[$l]} "kill $SCHED_PID2"
		    ssh $USER@${NODE_LIST[$l]} "killall java"
		    SCHED_PID2=$(ssh $USER@${NODE_LIST[$l]} "jps" | grep DistributedRTRMEvaluation | awk '{print $1}')
		done
	    done
	    while [ "$SCHED_PID" != "" ]
	    do
		SCHED_PID=$(ssh $USER@$SCHEDULER "jps" | grep DistributedRTRMEvaluation | awk '{print $1}')
		if [ "$SCHED_PID" -eq "" ]
		then
		    echo "FAIL"
		fi
		ssh $USER@$SCHEDULER "kill $SCHED_PID"
		ssh $USER@$SCHEDULER "killall java"
		SCHED_PID=$(ssh $USER@$SCHEDULER "jps" | grep DistributedRTRMEvaluation | awk '{print $1}')
	    done

	    echo "copy logs"
	    scp $USER@$SCHEDULER:/home/$USER/hop_distro/hadoop-2.4.0/logs/yarn.log results2/xp_scheduler_$k\_$i\_$runNb.log
	    for l in $(seq 0 1 $k)
	    do
		scp $USER@${NODE_LIST[$l]}:/home/$USER/hop_distro/hadoop-2.4.0/logs/yarn.log results2/xp_rt$l\_$k\_$i\_$runNb.log
		scp $USER@${NODE_LIST[$l]}:/home/$USER/results* results2/
	    done
	done
    done
done
