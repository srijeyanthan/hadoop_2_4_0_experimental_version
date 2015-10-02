#!/bin/sh

if [ -z $1 ]; then
	echo "please, specify user name. i.e. ./kill.sh kthfs"
	exit
fi

username=$1

machinename=$2


echo "** Killing existing datanodes/namenodes on $machinename"
for i in `ps -ef | grep $username | grep datanode | awk '{print $2}'`
do
kill -9 $i > /dev/null 2>&1
done

for i in `ps -ef | grep $username | grep namenode | awk '{print $2}'`
do
kill -9 $i > /dev/null 2>&1
done


