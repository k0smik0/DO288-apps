#!/bin/bash

lab_name="expose-image"

# do not touch - begin #
source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/_pause.sh
source $HOME/DO288-apps/bin/_main.sh
source $HOME/DO288-apps/bin/_oc_get_pods_last_running.sh
# do not touch - end #

function __list() { 
	echo "$(basename $0) available commands"; 
}

function __localHelp() {
	echo "eventually run 'pre' for: 'lab $lab_name finish/start'"
}

# do not touch - begin #
[ $# -lt 1 ] && echo "not enough arguments" && echo &&  ___help && ___localHelp && exit 1
# do not touch - end #


### the business from here ###

function __pre() {
	lab $lab_name finish
	lab $lab_name start
}

app_container_name="php-info"
app_resource_name="info"

function __1() {
	$HOME/DO288-apps/bin/_oc_login.sh
	oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
___pause
	podman login -u ${RHT_OCP4_QUAY_USER} quay.io
___pause
	skopeo copy oci:/home/student/DO288/labs/${lab_name}/${app_container_name} docker://quay.io/${RHT_OCP4_QUAY_USER}/${app_container_name}
___pause
	skopeo inspect docker://quay.io/${RHT_OCP4_QUAY_USER}/${app_container_name}
___pause
}


function __2() {
	oc new-project ${RHT_OCP4_DEV_USER}-common
___pause	
	oc create secret generic quayio --from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json --type kubernetes.io/dockerconfigjson
___pause	
	oc import-image ${app_container_name} --confirm --from quay.io/${RHT_OCP4_QUAY_USER}/${app_container_name}
___pause
	oc get istag
}

function __3() {
	oc new-project ${RHT_OCP4_DEV_USER}-${lab_name}
___pause
	# Grant service accounts from the new youruser-expose-image project access to image streams from the youruser-common project.
	oc policy add-role-to-group -n ${RHT_OCP4_DEV_USER}-common system:image-puller system:serviceaccounts:${RHT_OCP4_DEV_USER}-${lab_name}
___pause
	oc new-app --as-deployment-config --name ${app_resource_name} -i ${RHT_OCP4_DEV_USER}-common/${app_container_name}
___pause
	oc get pods
___pause	
}

function __4() {
	oc expose svc "info"
___pause
	oc get route "info"	
___pause
	curl http://info-${RHT_OCP4_DEV_USER}-${lab_name}.${RHT_OCP4_WILDCARD_DOMAIN}
___pause
}

function __5() {
	lab ${lab_name} grade
___pause	
}	

function __6() {
	oc delete project ${RHT_OCP4_DEV_USER}-${lab_name}
___pause
	oc delete project ${RHT_OCP4_DEV_USER}-common
___pause
	skopeo delete docker://quay.io/${RHT_OCP4_QUAY_USER}/${app_container_name}:latest
}

function __end() {
	lab ${lab_name} finish
}


___execute $1
