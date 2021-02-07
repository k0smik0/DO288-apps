#!/bin/bash

source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/_pause.sh

oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API} ; ___pause

oc new-project ${RHT_OCP4_DEV_USER}-app-config ; ___pause

oc new-app --as-deployment-config --name myapp --build-env npm_config_registry=http://${RHT_OCP4_NEXUS_SERVER}/repository/nodejs nodejs:12~https://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#app-config --context-dir app-config ; ___pause

# oc logs -f bc/myapp
oc logs bc/myapp ; ___pause

oc get pods ; ___pause

oc expose svc myapp ; ___pause

oc get route ; ___pause

curl http://myapp-${RHT_OCP4_DEV_USER}-app-config.${RHT_OCP4_WILDCARD_DOMAIN} ; ___pause

echo 4.1;
oc create configmap myappconf --from-literal APP_MSG="Test Message" ; ___pause

echo 4.2;
oc describe cm/myappconf ; ___pause

echo 4.4 ;
oc create secret generic myappfilesec --from-file /home/student/DO288-apps/app-config/myapp.sec ; ___pause

oc get secret/myappfilesec -o json ; ___pause

echo 5;
oc set env dc/myapp --from configmap/myappconf ; ___pause

# also from /home/student/DO288/labs/app-config/inject-secret-file.sh
oc set volume dc/myapp --add -t secret -m /opt/app-root/secure --name myappsec-vol --secret-name myappfilesec ; ___pause

echo "6.1"
oc status ; ___pause

echo 6.2 ;
oc get pods ; ___pause ;

echo 6.3 ;
running_pod=$(oc get pods | grep Running | awk '{print $1}') ; oc rsh ${running_pod} env | grep APP_MSG ; ___pause

echo 6.4 ;
curl http://myapp-${RHT_OCP4_DEV_USER}-app-config.${RHT_OCP4_WILDCARD_DOMAIN} ; ___pause

echo 7.1 ;
oc edit cm/myappconf ; ___pause

echo 7.2 ;
oc describe cm/myappconf ; ___pause

echo 7.3 ;
oc rollout latest dc/myapp ; ___pause

echo 7.4 ; 
oc get pods ; ___pause

echo 7.5; 
curl http://myapp-${RHT_OCP4_DEV_USER}-app-config.${RHT_OCP4_WILDCARD_DOMAIN} ; ___pause

