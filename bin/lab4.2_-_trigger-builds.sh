#!/bin/bash

lab_name="trigger-builds"

# do not touch - begin #
source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/pause.sh
source $HOME/DO288-apps/bin/_main.sh
source $HOME/DO288-apps/bin/_oc_get_pods_last_running.sh
# do not touch - end #

function __list() { 
	echo "$(basename $0) available commands"; 
}

function __localHelp() {
	echo "eventually run 'pre' for: 'lab ${lab_name} finish/start'"
}

# do not touch - begin #
[ $# -lt 1 ] && echo "not enough arguments" && echo &&  __help && __localHelp && exit 1
# do not touch - end #


### the business from here ###

function __pre() {
	cd $HOME/DO288-apps

	lab ${lab_name} finish
	lab ${lab_name} start
}

# app_container_name="php-info"
app_resource_name="jhost"
source_file=$HOME/DO288-apps/java-serverhost/src/main/java/com/redhat/training/example/javaserverhost/rest/ServerHostEndPoint.java

function __1() {
	echo "login:: $HOME/DO288-apps/bin/_oc_login.sh"
	$HOME/DO288-apps/bin/_oc_login.sh
	#oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
pause
	echo "create new project:: oc new-project ${RHT_OCP4_DEV_USER}-${lab_name}"
	oc new-project ${RHT_OCP4_DEV_USER}-${lab_name}
pause
}


function __2() {
	echo "2:: Add a image stream to the project to be used with the new application."
	echo "2.1:: login to podman: podman login -u ${RHT_OCP4_QUAY_USER} quay.io"
	podman login -u ${RHT_OCP4_QUAY_USER} quay.io
pause	
	echo "2.2:: Push the original PHP 7.0 builder image to your Quay.io public registry."
	echo "2.2:: cd /home/student/DO288/labs/trigger-builds; skopeo copy docker-archive:php-70-rhel7-original.tar.gz docker://quay.io/${RHT_OCP4_QUAY_USER}/php-70-rhel7:latest"
	cd /home/student/DO288/labs/trigger-builds; 
	skopeo copy docker-archive:php-70-rhel7-original.tar.gz docker://quay.io/${RHT_OCP4_QUAY_USER}/php-70-rhel7:latest
	pause
	echo "2.3:: The Quay.io registry defaults to private images, so you will have to add a secret to a the builder service account in order to access it."
	pause
	echo "2.3.1:: Create a secret from the container registry API access token that was stored by Podman."
	echo "2.3.1:: oc create secret generic quay-registry --from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json --type kubernetes.io/dockerconfigjson"
	oc create secret generic quay-registry --from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json --type kubernetes.io/dockerconfigjson
	pause
	echo "2.3.2:: Add the Quay.io registry secret to the builder service account."
	echo "2.3.2:: oc secrets link builder quay-registry"
	oc secrets link builder quay-registry
	pause
	echo "2.4:: Update the php image stream to fetch the metadata for the new container image. The external registry uses the docker-distribution package and does not notify OpenShift about image changes."
	echo "2.4:: oc import-image php --from quay.io/${RHT_OCP4_QUAY_USER}/php-70-rhel7 --confirm"
	oc import-image php --from quay.io/${RHT_OCP4_QUAY_USER}/php-70-rhel7 --confirm
	pause
}

deployed_app_name="trigger"

function __3() {
	echo "3.1:: Create a new application from sources in Git. Name the application as trigger."
	echo "3.1 - oc new-app --as-deployment-config --name ${deployed_app_name} php~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps --context-dir ${lab_name}"
	oc new-app --as-deployment-config --name ${deployed_app_name} php~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps --context-dir ${lab_name}
	pause
	echo "oc logs -f bc/${deployed_app_name}"
	oc logs -f bc/${deployed_app_name}
	pause
	echo "oc get pods"
	oc get pods
	echo "oc describe bc/trigger | grep Triggered"
	oc describe bc/trigger | grep Triggered
	pause
}

	
function __4() {
	echo "4.1:: upload the new version of the PHP S2I builder image to the Quay.io registry"
	echo "4.1:: skopeo copy docker-archive:php-70-rhel7-newer.tar.gz docker://quay.io/${RHT_OCP4_QUAY_USER}/php-70-rhel7:latest"
	skopeo copy docker-archive:php-70-rhel7-newer.tar.gz docker://quay.io/${RHT_OCP4_QUAY_USER}/php-70-rhel7:latest
pause
	echo "4.2:: Update the php image stream to fetch the metadata for the new container image."
	echo "4.2:: oc import-image php"
	oc import-image php
pause
}

function __5() {
	echo "5.1:: update all build, verify the second has started building"
	echo "5.1:: oc get builds"
	oc get builds
	
	echo "5.2:: oc describe build trigger-2 | grep cause"
	oc describe build trigger-2 | grep cause
}

function __6() {
	cd $HOME
	skopeo delete docker://quay.io/${RHT_OCP4_QUAY_USER}/php-70-rhel7
}
	
#function __end() {
	lab ${lab_name} finish
}


_execute $1
