#!/bin/bash
echo "format"
mysql -u hop -phop -h cloud1.sics.se -P 3307 -e 'drop database hops_gautier;'
mysql -u hop -phop -h cloud1.sics.se -P 3307 -e 'create database hops_gautier;'
mysql -u hop -phop -h cloud1.sics.se -P 3307 hops_gautier < ../../schema/hayarn.sql
ssh cloud7 "/home/gautier/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval format"

echo "start scheduler"
ssh cloud7 "rm /home/gautier/hop_distro/hadoop-2.4.0/logs/yarn.log"
ssh cloud7 "/home/gautier/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval run 500" &
SCHED_PID=$(ssh cloud7 "jps" | grep DistributedRTRMEvaluation | awk '{print $1}')

duration=120
nbrt=1;
sleep 10s
for l in $(seq 1 1 $nbrt)
do
    ssh cloud$l "rm /home/gautier/hop_distro/hadoop-2.4.0/logs/yarn.log"
    ssh cloud$l "/home/gautier/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval run 500" &
done

sleep 10s
    
echo "========== starting bench $k $i =========="
for l in $(seq 1 1 $nbrt)
do
    t=$(expr $duration \* 1000)
    echo $t
    ssh cloud$l "/home/gautier/hop_distro/hadoop-2.4.0/bin/yarn rmClientEval run cloud$l.sics.se 750 3000 $t 1 750 results" &
done
 
sleep $duration\s
sleep 30s
ssh cloud7 "kill $SCHED_PID"

for l in $(seq 1 1 $nbrt)
do
    SCHED_PID2=$(ssh cloud$l "jps" | grep DistributedRTRMEvaluation | awk '{print $1}')	    
    ssh cloud$l "kill $SCHED_PID2"
done

echo "copy logs"
scp cloud7:/home/gautier/hop_distro/hadoop-2.4.0/logs/yarn.log results/xp_scheduler.log
for l in $(seq 1 1 $nbrt)
do
    scp cloud$l:/home/gautier/hop_distro/hadoop-2.4.0/logs/yarn.log results/xp_rt$l.log
done
