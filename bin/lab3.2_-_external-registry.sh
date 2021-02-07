#!/bin/bash

source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/_pause.sh
source $HOME/DO288-apps/bin/_main.sh
source $HOME/DO288-apps/bin/_oc_get_pods_last_running.sh




function __1() {
echo "insert your quay password"
podman login -u ${RHT_OCP4_QUAY_USER} quay.io
___pause
skopeo copy oci:/home/student/DO288/labs/external-registry/ubi-sleep docker://quay.io/${RHT_OCP4_QUAY_USER}/ubi-sleep:1.0
___pause
podman search quay.io/ubi-sleep
___pause
skopeo inspect docker://quay.io/${RHT_OCP4_QUAY_USER}/ubi-sleep:1.0
}

function __2() {
sudo podman login -u ${RHT_OCP4_QUAY_USER} quay.io
___pause
sudo podman run -d --name sleep quay.io/${RHT_OCP4_QUAY_USER}/ubi-sleep:1.0
___pause
sudo podman ps
___pause
sudo podman logs sleep
___pause
sudo podman stop sleep
___pause
sudo podman rm sleep
}

function __3() {
oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
___pause
oc new-project ${RHT_OCP4_DEV_USER}-external-registry
___pause
oc new-app --as-deployment-config --name sleep --docker-image quay.io/${RHT_OCP4_QUAY_USER}/ubi-sleep:1.0
___pause
oc create secret generic quayio --from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json --type kubernetes.io/dockerconfigjson
___pause
oc secrets link default quayio --for pull
___pause
oc new-app --as-deployment-config --name sleep --docker-image quay.io/${RHT_OCP4_QUAY_USER}/ubi-sleep:1.0
___pause
oc get pods
___pause
pod=$(oc_get_pods_last_running); oc logs $pod
}

function __4() {
oc delete project ${RHT_OCP4_DEV_USER}-external-registry
___pause
skopeo delete docker://quay.io/${RHT_OCP4_QUAY_USER}/ubi-sleep:1.0
}



[ $# -lt 1 ] && ___help && exit 1

___execute $1
