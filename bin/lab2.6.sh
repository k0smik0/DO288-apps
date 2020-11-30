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

echo 4.1;
oc create configmap myappconf --from-literal APP_MSG="Test Message" ; pause

echo 4.2;
oc describe cm/myappconf ; pause

echo 4.4 ;
oc create secret generic myappfilesec --from-file /home/student/DO288-apps/app-config/myapp.sec ; pause

oc get secret/myappfilesec -o json ; pause

echo 5;
oc set env dc/myapp --from configmap/myappconf ; pause

# also from /home/student/DO288/labs/app-config/inject-secret-file.sh
oc set volume dc/myapp --add -t secret -m /opt/app-root/secure --name myappsec-vol --secret-name myappfilesec ; pause

echo "6.1"
oc status ; pause

echo 6.2 ;
oc get pods ; pause ;

echo 6.3 ;
running_pod=$(oc get pods | grep Running | awk '{print $1}') ; oc rsh ${running_pod} env | grep APP_MSG ; pause

echo 6.4 ;
curl http://myapp-${RHT_OCP4_DEV_USER}-app-config.${RHT_OCP4_WILDCARD_DOMAIN} ; pause

echo 7.1 ;
oc edit cm/myappconf ; pause

echo 7.2 ;
oc describe cm/myappconf ; pause

echo 7.3 ;
oc rollout latest dc/myapp ; pause

echo 7.4 ; 
oc get pods ; pause

echo 7.5; 
curl http://myapp-${RHT_OCP4_DEV_USER}-app-config.${RHT_OCP4_WILDCARD_DOMAIN} ; pause

