#!/usr/bin/python
import os
import time

USER="ubuntu"
SCHEDULER="54.155.165.22"
NODE_LIST=["54.155.193.223","54.170.35.239"]
PRIVATE_NODE_LIST=["10.197.34.252","10.197.69.223"]

print "init db"
os.system("mysql -u kthfs -pkthfs -h " + SCHEDULER + " -P 3306 -e 'drop database hops_gautier;'")
os.system("mysql -u kthfs -pkthfs -h " + SCHEDULER + " -P 3306 -e 'create database hops_gautier;'")
os.system("mysql -u kthfs -pkthfs -h " + SCHEDULER + " -P 3306 hops_gautier < ../../schema/hayarn.sql")

for k in range(0,1):
    for i in [2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500,9000,9500,10000,11000,12000,13000,14000,15000,16000,17000,18000,19000,20000,21000,22000,24000,25000]:
        runNb=0
        totalRT=0
        totalSC=0
        while True:
            oldtotal = totalRT
            runNb = runNb+1
            print "========= format yarn"
            os.system("ssh " + USER + "@" + SCHEDULER + " \"/home/" + USER + "/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval format\"")

            print "============ start scheduler"
            os.system("ssh " + USER + "@" + SCHEDULER + " \"rm /home/" + USER + "/hop_distro/hadoop-2.4.0/logs/yarn.log\"")
            os.system("ssh " + USER + "@" + SCHEDULER + " \"ulimit -c unlimited && /home/" + USER + "/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval run 1000\" &")

            time.sleep( 10 )

            for l in range(0,k+1):
                os.system("ssh " + USER + "@" + NODE_LIST[l] + " \"rm /home/" + USER + "/hop_distro/hadoop-2.4.0/logs/yarn.log\"")
                os.system("ssh " + USER + "@" + NODE_LIST[l] + " \"/home/" + USER + "/hop_distro/hadoop-2.4.0/bin/yarn rmRTEval run 1000\" &")
            time.sleep( 10 )
            print "starting biench " + str(k) + " " + str(i) + " " + str(runNb) + "=========="
            for l in range(0, k+1):
                nbRT=k+1
                nbNMRT=i/nbRT
                os.system("ssh " + USER + "@" + NODE_LIST[l] + " \"/home/" + USER + "/hop_distro/hadoop-2.4.0/bin/yarn rmClientEval run " + PRIVATE_NODE_LIST[l] + " " + str(nbNMRT) + " 3000 120000 6666 " + str(i) + " results" + str(l) + "_" + str(k) + "_" + str(runNb) + "\" &")
        
            for l in range(0, k+1):
                pid = os.popen("ssh " + USER + "@" + NODE_LIST[l] + " \"jps\" | grep DistributedRTClientEvaluation | awk '{print $1}'")
                while pid.read() != "":
                    time.sleep(10)
                    pid = os.popen("ssh " + USER + "@" + NODE_LIST[l] + " \"jps\" | grep DistributedRTClientEvaluation | awk '{print $1}'")

            print "killing"
            for l in range(0,k+1):
                pid = os.popen("ssh " + USER + "@" + NODE_LIST[l] + " \"jps\" | grep DistributedRTRMEvaluation | awk '{print $1}'")
                while pid.read() != "":
                    os.system("ssh " + USER + "@" + NODE_LIST[l] + " \"killall java\"")
                    pid = os.popen("ssh " + USER + "@" + NODE_LIST[l] + " \"jps\" | grep DistributedRTRMEvaluation | awk '{print $1}'")
            pid = os.popen("ssh " + USER + "@" + SCHEDULER + " \"jps\" | grep DistributedRTRMEvaluation | awk '{print $1}'")
            while pid.read() != "":
                os.system("ssh " + USER + "@" + SCHEDULER + " \"killall java\"")
                pid = os.popen("ssh " + USER + "@" + SCHEDULER + " \"jps\" | grep DistributedRTRMEvaluation | awk '{print $1}'")
            print "copy log"
            subtotalRT=0
            subtotalSC=0

            os.system("scp " + USER + "@" + SCHEDULER + ":/home/" + USER + "/hop_distro/hadoop-2.4.0/logs/yarn.log results2/xp_sc_" + str(k) + "_" + str(i) + "_" + str(runNb))
            for l in range(0,k+1):
                os.system("scp " + USER + "@" + NODE_LIST[l] + ":/home/" + USER + "/hop_distro/hadoop-2.4.0/logs/yarn.log results2/xp_rt_" + str(k) + "_" + str(i) + "_" + str(runNb))
                os.system("scp " + USER + "@" + NODE_LIST[l] + ":/home/" + USER + "/results* results2/")
                fileName = "results2/results" + str(l) + "_" + str(k) + "_" +  str(runNb)
                f=open(fileName)
                for line in f:
                    l = line.split("\t")
                    if l[0] == str(i):
                        subtotalRT = subtotalRT + float(l[len(l)-2])
                        subtotalSC = subtotalSC + float(l[len(l)-1])
                        break
                
            totalRT = totalRT + (subtotalRT/(k+1))
            totalSC = totalSC + (subtotalSC/(k+1))
            avg = totalRT/runNb
            oldavg=0
            if runNb>1:
                oldavg = oldtotal/(runNb-1)
            variation=0
            if avg>oldavg:
                variation=(avg-oldavg)
            else:
                variation=(oldavg-avg)
            print str(avg) + "\t" + str(variation)
            if runNb>=3 and variation < 0.001:
                fileName="results_eval"
                f=open(fileName, "a")
                avgSC = totalSC/runNb
                f.write(str(i) + "\t" + str(avg) + "\t" + str(avgSC)+"\n")
                f.close()
                print str(i) + "\t" + str(avg) + "\t" + str(avgSC)
                break
                    
