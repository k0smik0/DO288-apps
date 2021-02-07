#!/bin/bash

source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/_pause.sh
source $HOME/DO288-apps/bin/_main.sh
source $HOME/DO288-apps/bin/_oc_get_pods_last_running.sh


function __2() {
 echo 2.2 ;
 oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API} ; pause
 echo 2.3 ;
 oc new-project ${RHT_OCP4_DEV_USER}-design-container ; pause
 echo 2.4 ;
 oc new-app --as-deployment-config --name elvis https://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#design-container --context-dir hello-java ; pause
}

function __4() {
echo 4.1
echo "set chgrp 0 recursive to /opt/app-root; set also chmod g=x recursive to it"
vi hello-java/Dockerfile
echo
echo 4.2
oc start-build elvis
oc get pods
}

function __5() {
 echo 5
 git add hello-java/Dockerfile; git commit -m "fixed Dockerfile for exercise"; git push origin design-container
}

function __6() {
echo 6
oc start-build elvis ; pause
oc logs bc/elvis ; pause
oc get pods ; pause
pod_to_read_log=$(oc_get_pods_last_running)
oc logs $pod_to_read_log
}

function __7() {
echo 7
oc expose svc/elvis ; oc get routes

echo 7.3
#curl http://elvis-${RHT_OCP4_DEV_USER}-design-container.${RHT_OCP4_WILDCARD_DOMAIN}/api/hello
curl "$(oc get route| tail -1 | awk '{print $2}')/api/hello"
}

function __8() {
echo 8
oc create configmap appconfig --from-literal APP_MSG="Elvis lives"
oc set env dc/elvis --from configmap/appconfig
}

function __9() {
echo 9
pod=$(oc get pods | grep Running | awk '{print $1}'); oc rsh $pod env | grep APP_MSG
}

function __10() {
echo 10
curl "$(oc get route| tail -1 | awk '{print $2}')/api/hello"
}

[ $# -lt 1 ] && _help && exit 1

___execute $1
