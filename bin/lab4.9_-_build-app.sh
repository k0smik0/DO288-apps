#!/bin/bash


lab_name="build-app"
lab_number="4.9"

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
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "login::" "_oc_login"
	___oc_login
___pause

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "3" "create new project::" "oc new-project ${project_name}"
	oc new-project ${project_name}
___pause
}

app_name="simple"

function __2() {
	local lab_chap="2"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "create the application"
	___pause
	
	# 2
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "execute the /home/student/DO288/labs/build-app/oc-new-app.sh" '/home/student/DO288/labs/build-app/oc-new-app.sh'
	/home/student/DO288/labs/build-app/oc-new-app.sh
	___pause
}

function __3() {
	local lab_chap="3"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Verify that the application build fails. Set the correct value for the npm_config_registry variable in the application build configuration to fix the problem."
	___pause

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "check the reason" "oc logs -f bc/${app_name}"
	oc logs -f bc/${app_name}
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
	oc get route/${app_name} -o jsonpath='{.spec.host}{\"\n\"}'
	___pause
}

function __5() {
	local lab_chap="5"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Start a new build and verify that the application is ready and running. Verify that the application is accessible using the route URL you obtained in the previous step."
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "start a new build" "oc start-build ${app_name} -F"
	oc start-build ${app_name}
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "verify it is ready/running" "curl BLA BLA from 4.8.4.2 (the route)"
	local target=$(oc get route/${app_name} -o jsonpath='{.spec.host}{\"\n\"}')
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
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "Get the secret for the webhook by running the oc get bc command, and pass the -o json option to dump the build config details in JSON." "oc get bc ${app_name} | grep secret or whatever..."
	oc get bc ${app_name}
	echo "really, fix the last command"
	___pause
	
	# ___commandWithDescriptionPrint ${lab_number} ${lab_chap} "3" "Get the generic webhook URL that starts a new build, with the oc describe command." "oc describe bc ${app_name}"
	# oc describe bc ${app_name}
	# ___pause
}

function __7() {
	echo "4.8.5.1:: clean up"
	oc delete project ${RHT_OCP4_DEV_USER}-post-commit
}

function __end() {
	lab ${lab_name} finish
}


___execute $1
