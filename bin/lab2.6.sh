#!/bin/bash

source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/pause.sh

oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API} ; pause

oc new-project ${RHT_OCP4_DEV_USER}-app-config ; pause

oc new-app --as-deployment-config --name myapp --build-env npm_config_registry=http://${RHT_OCP4_NEXUS_SERVER}/repository/nodejs nodejs:12~https://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#app-config --context-dir app-config ; pause

# oc logs -f bc/myapp
oc logs bc/myapp ; pause

oc get pods ; pause

oc expose svc myapp ; pause

oc get route ; pause

curl http://myapp-${RHT_OCP4_DEV_USER}-app-config.${RHT_OCP4_WILDCARD_DOMAIN} ; pause

oc create configmap myappconf --from-literal APP_MSG="Test Message" ; pause

oc describe cm/myappconf ; pause

oc create secret generic myappfilesec --from-file /home/student/DO288-apps/app-config/myapp.sec ; pause

oc get secret/myappfilesec -o json ; pause
