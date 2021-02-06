#!/bin/bash

lab_name="manage-builds"

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
	
	git branch -l | grep "*" | grep ${lab_name} || echo "go into ${lab_name} branch (ensure it has been branched from master"

	lab ${lab_name} finish
	lab ${lab_name} start
}

# app_container_name="php-info"
app_resource_name="jhost"
source_file=$HOME/DO288-apps/java-serverhost/src/main/java/com/redhat/training/example/javaserverhost/rest/ServerHostEndPoint.java

function __1() {
	$HOME/DO288-apps/bin/_oc_login.sh
	oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
pause
	ls ${source_file}
pause
}


function __2() {
	oc new-project ${RHT_OCP4_DEV_USER}-${lab_name}
pause	
}

deployed_app_name="jhost"

function __3() {
	# 3.1 
	# Create a new application from sources in Git. Use the branch you created in a previous step. 
	# Name the application jhost and use the --build-env option from the oc new-app command to define a build environment 
	#		variable with the maven repository location.
	echo "3.1 - deployed_app_name: jhost"
	oc new-app --as-deployment-config --name ${deployed_app_name} --build-env MAVEN_MIRROR_URL=http://${RHT_OCP4_NEXUS_SERVER}/repository/java \
-i redhat-openjdk18-openshift:1.5 \
https://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#${lab_name} \
--context-dir java-serverhost
	echo
pause

	echo 4.1.3.2
	oc logs -f bc/${deployed_app_name}
pause

	echo 4.1.3.3
	oc get pods
pause

	echo 4.1.3.4
	oc expose svc/${deployed_app_name}
pause
	
	echo 4.1.3.5
	oc get route
pause
	
	echo 4.1.3.6
	echo "executing: curl http://${deployed_app_name}-${RHT_OCP4_DEV_USER}-${lab_name}.${RHT_OCP4_WILDCARD_DOMAIN}"
	curl http://${deployed_app_name}-${RHT_OCP4_DEV_USER}-${lab_name}.${RHT_OCP4_WILDCARD_DOMAIN}
pause
}

function __4() {
	oc get bc
pause
	oc get builds
pause
}

# Update the application to version 2.0.
function __5() {
	echo "update to version 2"
	echo "'String msg = \"I am running on server \"+host+\" Version 2.0 \\n\";'" >> ${source_file}
	echo "open ${source_file} and rearrange the last line: use it to replace the original"
	vi ${source_file}
pause
	cd java-serverhost
	git commit -a -m 'Update the version'
pause
	# 4.1.5.3 ...
	oc start-build bc/jhost
pause
	oc cancel-build bc/jhost
pause
	oc get builds
pause
	git push
pause
	oc start-build bc/jhost
pause
	oc get builds
pause
	oc logs -f build/jhost-3
	oc get pods
pause
	curl http://jhost-${RHT_OCP4_DEV_USER}-${lab_name}.${RHT_OCP4_WILDCARD_DOMAIN}
}	

function __6() {
	oc delete project ${RHT_OCP4_DEV_USER}-${lab_name}
pause
}

function __end() {
	lab ${lab_name} finish
}


_execute $1
