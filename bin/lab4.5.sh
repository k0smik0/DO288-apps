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

