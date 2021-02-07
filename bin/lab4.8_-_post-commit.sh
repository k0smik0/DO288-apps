#!/bin/bash


lab_name="post-commit"
lab_number="4.8"

# do not touch - begin #
source /usr/local/etc/ocp4.config 
source $HOME/DO288-apps/bin/_pause.sh
source $HOME/DO288-apps/bin/_main.sh
source $HOME/DO288-apps/bin/_oc_get_pods_last_running.sh
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

# app_container_name="php-info"
app_resource_name="jhost"
source_file=$HOME/DO288-apps/java-serverhost/src/main/java/com/redhat/training/example/javaserverhost/rest/ServerHostEndPoint.java

function __1() {
	echo "4.8.1.2:: login:: _oc_login"
	#$HOME/DO288-apps/bin/_oc_login.sh
	#oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
	___oc_login
___pause
	echo "4.8.1.3:: create new project:: oc new-project ${RHT_OCP4_DEV_USER}-${lab_name}"
	oc new-project ${RHT_OCP4_DEV_USER}-${lab_name}
___pause
	echo "4.8.1.4:: oc status"
	oc status
}


deployed_app_name="hook"

function __2() {
	local lab_chap="2"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "create a new application."
	
	# 1
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "Create a new application from sources in Git. Name the application as hook and prepend the php:7.3 image stream to the Git repository URL using a tilde (~)." 'oc new-app --deployment-config ${deployed_app_name} php:7.3~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps --context-dir ${lab_name}'
	oc new-app --deployment-config ${deployed_app_name} php:7.3~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps --context-dir ${lab_name}
	___pause
	
	# 2
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "Wait for the build to finish:" 'oc logs -f bc/${deployed_app_name}'
	oc logs -f bc/${deployed_app_name}
	___pause

	# 3
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "3" "Wait for the application to be ready and running:" 'oc get pods'
	oc get pods
	___pause
}

function __3() {
	local lab_chap="3"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Integrate the PHP application build with the builds-for-managers application."

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "inspect the create-hook.sh script )(provided in the /home/student/DO288/labs/post-commit folder) creates a build hook that integrates your PHP application builds with the builds-for-managers application using the curl command." "'oc set build-hook bc/hook --post-commit --command -- \
    bash -c \"curl -s -S -i -X POST http://builds-for-managers-${RHT_OCP4_DEV_USER}-post-commit.${RHT_OCP4_WILDCARD_DOMAIN}/api/builds -f -d \'developer=\${DEVELOPER}&git=\${OPENSHIFT_BUILD_SOURCE}&project=\${OPENSHIFT_BUILD_NAMESPACE}\'\"'"
	cat $HOME/DO288/labs/post-commit/create-hook.sh
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "run the create-hook.sh" "~/DO288/labs/post-commit/create-hook.sh"
	bash -x ~/DO288/labs/post-commit/create-hook.sh
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "3" "Verify that the post-commit build hook was created:" "oc describe bc/hook | grep Post"
	oc describe bc/hook | grep Post
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "4" "Start a new build using the oc start-build command with the -F option enabled to display the logs and verify the HTTP API response code. You will see an HTTP 400 status code returned by the curl command executed by the post-commit hook:" "oc start-build bc/hook -F ---- reason: The builds-for-managers application rejected the HTTP API request because the DEVELOPER environment variable is not defined." "oc start-build bc/hook -F"
	oc start-build bc/hook -F
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "5" "List the builds and verify that one build failed due to a post-commit hook failure:" "oc get builds"
	oc get builds
	___pause
}

function __4() {
	local lab_chap="4"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Fix the missing environment variable problem."
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "Create the DEVELOPER build environment variable using your name with the oc set env command:" "oc set env bc/hook DEVELOPER=\"Your Name\""
	oc set env bc/hook DEVELOPER="Massimiliano"
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "2" "Verify that the DEVELOPER environment variable is available in the hook build configuration:" "oc set env bc/hook --list"
	oc set env bc/hook --list
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "3" "start a new build (as 4.8.4.4) and display the logs to verify the HTTP API response code. You will see an HTTP 200 status code:" "oc start-build bc/hook -F"
	oc start-build bc/hook -F
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "4" "Get the builds-for-managers exposed route:" "oc get route/builds-for-managers -o jsonpath='{.spec.host}{\"\n\"}'"
	oc get route/builds-for-managers -o jsonpath='{.spec.host}{"\n"}'
	oc get router/builds-for-managers
	___pause

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "5" "Open a web browser to access http://builds-for-managers-youruser-post-commit.apps.cluster.domain.example.com. The page displays all the builds and the developer who started each one." "echo xdg http://builds-for-managers-${RHT_OCP4_DEV_USER}-post-commit.apps.ECC"
	echo "xdg http://builds-for-managers-${RHT_OCP4_DEV_USER}-post-commit.apps.ECC"
	___pause
}

function __5() {
	echo "4.8.5.1:: clean up"
	oc delete project ${RHT_OCP4_DEV_USER}-post-commit
}

#function __end() {
	lab ${lab_name} finish
}


___execute $1
