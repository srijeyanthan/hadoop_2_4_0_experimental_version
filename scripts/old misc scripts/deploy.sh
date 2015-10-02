#!/bin/bash

VERSION=2.0.4-alpha

HOP=/tmp/hop/hadoop
DEPLOY_FILE=hop-$VERSION.tgz
DEPLOY=/var/www/hops/$DEPLOY_FILE

rm $DEPLOY
rm -rf $HOP
mkdir -p $HOP

mvn -f ./../pom.xml clean generate-sources
mvn -f ./../pom.xml  package -Pdist,native -Dtar -DskipTests

HADOOP=hadoop-$VERSION

tar xf ../hadoop-dist/target/$HADOOP.tar.gz -C $HOP
cp -rf $HOP/$HADOOP/* $HOP/

rm -rf $HOP/$HADOOP

cd $HOP
cd ..

tar zcf $DEPLOY_FILE .
#mv $DEPLOY_FILE $DEPLOY
scp  $DEPLOY_FILE glassfish@snurran.sics.se/$DEPLOY
