#!/usr/bin/python
import re
from multiprocessing import Process

def avgList(list):
    min = list[0]
    max  = list[0]
    for val in list:
        if val< min:
            min=val
        if val > max:
            max=val
    list.remove(min)
    list.remove(max)
    cummulated = 0
    count = 0
    for val in list:
        cummulated = cummulated+val
        count = count+1
    avg = float(cummulated)/count
    return avg

def parsAndFillList(fileName, refString, list):
    startingMinute=0
    startingSeconds=0
    startingHoure=0
    f = open(fileName, 'r')
    for line in f:
        if refString in line:
            startingHoure = int(line[9:11])
            startingMinute = int(line[12:14])
            startingSeconds = int(line[15:17])
            break
    startingMeasuresSecond = startingSeconds+30
    startingMeasuresMinute = startingMinute
    startingMeasuresHoure = startingHoure
    if startingMeasuresSecond > 60 :
        startingMeasuresMinute = startingMeasuresMinute+1
        startingMeasuresSecond = startingMeasuresSecond - 60
    if startingMeasuresMinute >=60:
        startingMeasuresMinute = startingMeasuresMinute-60
        startingMeasuresHoure = startingMeasuresHoure+1
#    print startingMeasuresHoure, startingMeasuresMinute, startingMeasuresSecond
    counter = 0
    f = open(fileName, 'r')
    for line in f:
        if refString in line:
            houre = int(line[9:11])
            minute = int(line[12:14])
            seconds = int(line[15:17])
            if minute == startingMeasuresMinute:
                if seconds>= startingMeasuresSecond:
                    match = re.search(r"[^a-zA-Z](node)[^a-zA-Z]", line)
                    if not line[match.end():] in list:
                        list.append(line[match.end():])
                        counter= counter+1
            if minute > startingMeasuresMinute and minute <= startingMeasuresMinute+1:
                if seconds < startingMeasuresSecond:
                    match = re.search(r"[^a-zA-Z](node)[^a-zA-Z]", line)
                    if not line[match.end():] in list:
                        list.append(line[match.end():])
                        counter=counter+1
            if startingMeasuresMinute==59:
                if houre > startingMeasuresHoure and minute < 1:
                    if seconds < startingMeasuresSecond:
                        match = re.search(r"[^a-zA-Z](node)[^a-zA-Z]", line)
                        if not line[match.end():] in list:
                            counter=counter+1
                            list.append(line[match.end():])
    return counter

def countFromList(fileName, refString, list):
    #print fileName, refString, list
    startingMinute=0
    startingSeconds=0
    startingHoure=0
    f = open(fileName, 'r')
    for line in f:
        #if refString in line:
        startingHoure = int(line[9:11])
        startingMinute = int(line[12:14])
        startingSeconds = int(line[15:17])
        break
    startingMeasuresSecond = startingSeconds+30
    startingMeasuresMinute = startingMinute
    startingMeasuresHoure = startingHoure
    if startingMeasuresSecond > 60 :
        startingMeasuresMinute = startingMeasuresMinute+1
        startingMeasuresSecond = startingMeasuresSecond - 60
    if startingMeasuresMinute >=60:
        startingMeasuresMinute = startingMeasuresMinute-60
        startingMeasuresHoure = startingMeasuresHoure+1
#    print startingMeasuresHoure, startingMeasuresMinute, startingMeasuresSecond
    counter = 0
    alreadySeen=[]
    f = open(fileName, 'r')
    for line in f:
        if refString in line:
            houre = int(line[9:11])
            minute = int(line[12:14])
            seconds = int(line[15:17])
            #if minute == startingMeasuresMinute:
                #if seconds>= startingMeasuresSecond:
            match = re.search(r"[^a-zA-Z](node)[^a-zA-Z]", line)
            s=line[match.end():]
            #print s
            if s in list:
                #print "in"
                if not line[match.end():] in alreadySeen:
                    alreadySeen.append(line[match.end():])
                    counter= counter+1
                    #print counter, refString
            #if minute > startingMeasuresMinute and minute <= startingMeasuresMinute+1:
            #    if seconds < startingMeasuresSecond:
            #        match = re.search(r"[^a-zA-Z](node)[^a-zA-Z]", line)
            #        if line[match.end():] in list:
            #            if not line[match.end():] in alreadySeen:
            #                alreadySeen.append(line[match.end():])
            #                counter= counter+1
            #if startingMeasuresMinute==59:
            #    if houre > startingMeasuresHoure and minute < 1:
            #        if seconds < startingMeasuresSecond:
            #            match = re.search(r"[^a-zA-Z](node)[^a-zA-Z]", line)
            #            if line[match.end():] in list:
            #                if not line[match.end():] in alreadySeen:
            #                    alreadySeen.append(line[match.end():])
            #                    counter= counter+1
    return counter

def count(k,i, p):
    listClientHandle=[]
    listRTHandle=[]
    listRTHandleBeforeCommit=[]
    listSCHandle = []
    listSCTringer = []
    listCommit = []
    listTest = []
    totalNBNM = i
    theoricalNBHB = float(totalNBNM)*60/3
    count=0
    threads=[]
    for runNB in range(1,6):
        count=count+1
        listHb=[]
        clientThreads = []
        rtThreads = []
        scThreads = []
        clientHandle=0
        resourceTrackerHandle=0
        schedulerHandle=0
        for j in range(0,k+1):
            fileName = 'results2/xp_rt' + str(j) + '_' + str(k) + '_' + str(i) + '_' + str(runNB) + '.log'
            #print fileName
            clientHandle = clientHandle + parsAndFillList(fileName, "sent heartbeat", listHb)
            #print clientHandle
            #print len(listHb)
            
            #resourceTrackerHandle =resourceTrackerHandle + countFromList(fileName, "persisting heartbeat", listHb)
            
            
        fileName = 'results2/xp_scheduler_' + str(k) + '_' + str(i) + '_' + str(runNB) + '.log'
        schedulerHandle = countFromList(fileName, "hb handled",listHb)
        
        listSCHandle.append(schedulerHandle)
        #listRTHandle.append(resourceTrackerHandle)
        listClientHandle.append(clientHandle)
        
    #print "rt"
    #averageResourceTrackerHandle=avgList(listRTHandle)
    #print "sc"
    averageSchedulerHandle=avgList(listSCHandle)
    #print "client"
    averageClientHandle=avgList(listClientHandle)
    
    #averagePercentageHBRT=float(averageResourceTrackerHandle)/theoricalNBHB
    averagePrecentageHBSC=float(averageSchedulerHandle)/theoricalNBHB
    averagepercentageHBClient=float(averageClientHandle)/theoricalNBHB
    if(p!=None):
        p.join()
    print totalNBNM, averageSchedulerHandle, averageClientHandle, theoricalNBHB, averagepercentageHBClient,averagePrecentageHBSC
    #result=str(totalNBNM) + "\t" + str(averageSchedulerHandle) + "\t" + str(averageClientHandle) + "\t" + str(theoricalNBHB) + "\t" + str(averagepercentageHBClient) + "\t" + str(averagePrecentageHBSC)
    

for k in range(0,1):
    print k
    listProcess=[]
    p=None
    for i in [2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500,9000,9500,10000,11000,12000,14000,15000,16000,17000,18000,19000,20000,30000]:
#,40000,50000,60000,70000,80000,90000,100000]:
        p=Process(target=count,args=(k,i,p))
        p.start()
        listProcess.append(p)
    for p in listProcess:
        p.join()
        #print t.getString()
