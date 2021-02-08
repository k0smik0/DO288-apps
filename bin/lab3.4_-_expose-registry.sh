#!/bin/bash

# do not touch - begin #
source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/_pause.sh
source $HOME/DO288-apps/bin/_main.sh
source $HOME/DO288-apps/bin/_oc_get_pods_last_running.sh

[ $# -lt 1 ] && echo "not enough arguments" && echo &&  ___help && localHelp && exit 1

# do not touch - end #

### the business from here ###

function localHelp() {
	echo "eventually run 'pre' for: 'lab expose-registry finish/start'"
}

function __pre() {
	lab expose-registry finish
	lab expose-registry start
}

function __1() {
	$HOME/DO288-apps/bin/_oc_login.sh
# oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
	oc get route -n openshift-image-registry
	INTERNAL_REGISTRY=$( oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}' )
	echo ${INTERNAL_REGISTRY}
}

# from old

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




___execute $1
