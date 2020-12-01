#!/bin/bash

source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/pause.sh

echo 2 ;

echo 2.2 ;
oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API} ; pause
echo 2.3 ;
oc new-project ${RHT_OCP4_DEV_USER}-design-container ; pause
echo 2.4 ;
oc new-app --as-deployment-config --name elvis https://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#design-container --context-dir hello-java ; pause

echo 4.1
echo "set chgrp 0 recursive to /opt/app-root; set also chmod g=x recursive to it"
vi hello-java/Dockerfile
echo

echo 4.2
oc start-build elvis

oc get pods

echo 7
oc expose svc/elvis ; oc get routes

echo 7.3
#curl http://elvis-${RHT_OCP4_DEV_USER}-design-container.${RHT_OCP4_WILDCARD_DOMAIN}/api/hello
curl "$(oc get route| tail -1 | awk {print $2})/api/hello"

echo 8
oc create configmap appconfig --from-literal APP_MSG="Elvis lives"
oc set env dc/elvis --from configmap/appconfig

echo 9
pod=$(oc get pods | grep Running | awk '{print $1}'); oc rsh $pod env | grep APP_MSG
