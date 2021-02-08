#!/bin/bash


lab_name="apache-s2i"
lab_number="5.6"

# do not touch - begin #
source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/_main.sh
# do not touch - end #

function ___list() { 
	echo "$(basename $0) available commands"; 
}

function ___localHelp() {
	echo "eventually run 'pre' for: 'lab ${lab_name} finish/start'"
}

# do not touch - begin #
[ $# -lt 1 ] && echo "not enough arguments" && echo &&  ___help && ___localHelp && exit 1
# do not touch - end #


### the business from here ###

function __pre() {
	cd $HOME/DO288-apps

	lab ${lab_name} finish
	lab ${lab_name} start
}

project_name="${RHT_OCP4_DEV_USER}-${lab_name}"
# app_container_name="php-info"
# app_resource_name="jhost"
# source_file=$HOME/DO288-apps/java-serverhost/src/main/java/com/redhat/training/example/javaserverhost/rest/ServerHostEndPoint.java

function __1() {
	local lab_chap="1"
	
	# ___chapterDescriptionPrint ${lab_number} ${lab_chap} "Explore the S2I scripts packaged in the rhscl/httpd-24-rhel7 builder image."
	# ___pause
	
	# ___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "On the workstation VM, run the rhscl/httpd-24-rhel7 image from a terminal window, and override the container entry point to run a shell:" "sudo podman run --name test -it rhscl/httpd-24-rhel7 bash"
	# echo "after entering into pod, cat the files: /usr/libexec/s2i/assemble /usr/libexec/s2i/run /usr/libexec/s2i/usage - then exit"
	# ___pause
	# sudo podman run --name test -it rhscl/httpd-24-rhel7 bash
	# ___pause
}

app_name="simple"

function __2() {
	local lab_chap="2"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Use the s2i command to create the template files and directories needed for the S2I builder image."
	___pause
	
	# 2
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "On the workstation VM, use the s2i create command to create the template files for the builder image in the /home/student/ directory:" "s2i create s2i-do288-httpd s2i-do288-httpd"
	 s2i create s2i-do288-httpd s2i-do288-httpd
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "Verify that the template files have been created. The s2i create command creates the following directory structure:" "tree -a s2i-do288-httpd"
	tree -a s2i-do288-httpd
	___pause
}

function __3() {
	local lab_chap="3"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Create the Apache HTTP server S2I builder image."
	___pause

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "An example Dockerfile for the Apache HTTP server builder image is provided for you at ~/DO288/labs/apache-s2i/Dockerfile. Briefly review this file:" "cat ~/DO288/labs/apache-s2i/Dockerfile"
	cat ~/DO288/labs/apache-s2i/Dockerfile
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "read the wrong env:" "oc set env bc ${app_name} --list"
	oc set env bc ${app_name} --list
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "3" "fix the wrong env, now using the right host address (really, u set the complete url address" "oc set env bc ${app_name} npm_config_registry=http://${RHT_OCP4_NEXUS_SERVER}/repository/nodejs"
	oc set env bc ${app_name} npm_config_registry="http://${RHT_OCP4_NEXUS_SERVER}/repository/nodejs"
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "4" "verify again the env" "oc set env bc ${app_name} --list"
	oc set env bc ${app_name} --list
	___pause
}

function __4() {
	local lab_chap="4"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Expose the application service for external access and obtain the route URL."
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "expose the app" "oc expose svc/${app_name}"
	oc expose svc/${app_name}
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "get the route" "oc get route/${app_name} -o jsonpath='{.spec.host}{\"\n\"}'"
	oc get route/${app_name} -o jsonpath='{.spec.host}{"\n"}'
	oc get route | grep ${app_name} | awk '{print $2}'
	___pause
}

function __5() {
	local lab_chap="5"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Start a new build and verify that the application is ready and running. Verify that the application is accessible using the route URL you obtained in the previous step."
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "start a new build" "oc start-build ${app_name} -F"
	oc start-build ${app_name}
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "verify it is ready/running" "curl BLA BLA from 4.8.4.2 (the route)"
	local target=$(oc get route/${app_name} -o jsonpath='{.spec.host}{"\n"}')
	local target=$(oc get route | grep ${app_name} | awk '{print $2}')
	echo "curl the url got from oc get route bla bla, that is also: 'simple-${RHT_OCP4_DEV_USER}-build-app.${RHT_OCP4_WILDCARD_DOMAIN}'"
	curl ${target}
	___pause
}

function __6() {
	local lab_chap="6"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Use the generic webhook for the build configuration to start a new application build."
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "Get the generic webhook URL that starts a new build, with the oc describe command." "oc describe bc ${app_name}"
	oc describe bc ${app_name}
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "Get the secret for the webhook by running the oc get bc command, and pass the -o json option to dump the build config details in JSON." "oc get bc ${app_name} ...blabla..."
	echo "using (internal) jsonpath: 'oc get bc simple -o jsonpath=\"{.spec.triggers[*].generic.secret}{\'\n\'}\"'"
	oc get bc simple -o jsonpath="{.spec.triggers[*].generic.secret}{'\n'}"
	echo "using grep+awk: oc get bc ${app_name} -o yaml | grep -A10 generic | grep secret | awk '{print $2}'"
	oc get bc ${app_name} -o yaml | grep -A10 generic | grep secret | awk '{print $2}'
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "3" "Start a new build using the webhook URL, and the secret discovered from the output of the previous steps. The error message about 'invalid Content-Type on payload' can be safely ignored." "curl -X POST -k ${RHT_OCP4_MASTER_API}/apis/build.openshift.io/v1/namespaces/${RHT_OCP4_DEV_USER}-${lab_name}/buildconfigs/${app_name}/webhooks/${app_generic_secret}/generic"
	local app_generic_secret=$(oc get bc ${app_name} -o yaml | grep -A10 generic | grep secret | awk '{print $2}')
	RHT_OCP4_MASTER_API=$(echo ${RHT_OCP4_MASTER_API} | sed 's/\///g')
	curl -X POST -k ${RHT_OCP4_MASTER_API}/apis/build.openshift.io/v1/namespaces/${RHT_OCP4_DEV_USER}-${lab_name}/buildconfigs/${app_name}/webhooks/${app_generic_secret}/generic
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "4" "list for builds" "oc get builds"
	oc get builds
	___pause

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "5" "wait for builds finishing" "oc logs -f bc/${app_name}"
	oc logs -f bc/${app_name}
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "6" "check pods" "oc get pods"
	oc get pods
	___pause
}

function __7() {
	local lab_chap="7"
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "grade" "lab build-app grade"
	lab build-app grade
}

function __8() {
	local lab_chap="8"
	oc delete project ${RHT_OCP4_DEV_USER}-${lab_name}
}

function __end() {
	lab ${lab_name} finish
}


___execute $1
