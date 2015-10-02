#!/bin/bash
if [ $# -ne 1 ] ; then
 echo "usage: $0 clusterj-version"
 exit 1
fi

version=$1
if [ ! -f ./clusterj-$version.jar ] ; then
 echo "Copy clusterj-$version.jar to the current directory."
 exit 1
fi

mvn  deploy:deploy-file -Durl=scpexe://kompics.i.sics.se/home/maven/repository \
                       -DrepositoryId=sics-release-repository \
                       -Dfile=./clusterj-$version.jar \
                       -DgroupId=se.sics.ndb \
                       -DartifactId=clusterj \
                       -Dversion=$version \
                       -Dpackaging=jar \
                       -DpomFile=./pom.xml \
                       -DgeneratePom.description="Ndb Clusterj connector" \
