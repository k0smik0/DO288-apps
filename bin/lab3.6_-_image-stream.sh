#!/bin/bash

# do not touch - begin #
source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/_pause.sh
source $HOME/DO288-apps/bin/_main.sh
source $HOME/DO288-apps/bin/_oc_get_pods_last_running.sh

[ $# -lt 1 ] && echo "not enough arguments" && echo &&  __help && localHelp && exit 1

# do not touch - end #

### the business from here ###

function localHelp() {
	echo "eventually run 'pre' for: 'lab expose-registry finish/start'"
}

function __pre() {
	lab image-stream finish
	lab image-stream start
}

function __1() {
	$HOME/DO288-apps/bin/_oc_login.sh
# oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
  oc new-project ${RHT_OCP4_DEV_USER}-common
}


function __2() {
	skopeo inspect docker://quay.io/redhattraining/hello-world-nginx
pause
	oc import-image hello-world --confirm --from quay.io/redhattraining/hello-world-nginx
pause
	oc get istag
pause
	oc describe is hello-world
}

function __3() {
	oc new-project ${RHT_OCP4_DEV_USER}-image-stream
pause
	oc new-app --as-deployment-config --name hello -i ${RHT_OCP4_DEV_USER}-common/hello-world
pause
	oc get pod
pause
	oc expose svc hello
pause
	oc get route
pause
	curl http://hello-${RHT_OCP4_DEV_USER}-image-stream.${RHT_OCP4_WILDCARD_DOMAIN}
}

function __4() {
	oc delete project ${RHT_OCP4_DEV_USER}-image-stream
	oc delete project ${RHT_OCP4_DEV_USER}-common
}

function __end() {
	lab image-stream finish
}


_execute $1
