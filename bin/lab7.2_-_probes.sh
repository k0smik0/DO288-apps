#!/bin/bash

lab_name="probes"
lab_number="7.2"

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

# ${myuser}-custom-s2i
project_name="${RHT_OCP4_DEV_USER}-${lab_name}"
app_name="probes"

function __1() {
	local lab_chap="1"
	
  ___chapterDescriptionPrint ${lab_number} ${lab_chap} "Create a new project, and then deploy the sample application in the probes subdirectory of the Git repository to an OpenShift cluster."
  ___pause
  
  echo "creating the project"
  ___oc_login
  oc new-project ${project_name}
  ___pause
  
  echo "deploy the app 'probes'"
  oc new-app --as-deployment-config --name ${app_name} --build-env npm_config_registry=http://${RHT_OCP4_NEXUS_SERVER}/repository/nodejs nodejs:12~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps --context-dir ${app_name}
  ___pause
  
  echo "view logs, pods, ecc"
  oc logs -f bc/${app_name}
  oc get pods
}

function __2() {
	local lab_chap="2"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Manually test the application's /ready and /healthz endpoints."
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "expose the app" "oc expose svc ${app_name}"
  oc expose svc ${app_name}
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "test the /ready" "curl -i ${project_name}-${RHT_OCP4_DEV_USER}-${app_name}.${RHT_OCP4_WILDCARD_DOMAIN}/ready"
  curl -i ${project_name}-${RHT_OCP4_DEV_USER}-${app_name}.${RHT_OCP4_WILDCARD_DOMAIN}/ready
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 3 "test the /healthz" "curl -i ${project_name}-${RHT_OCP4_DEV_USER}-${app_name}.${RHT_OCP4_WILDCARD_DOMAIN}/healthz"
  curl -i ${project_name}-${RHT_OCP4_DEV_USER}-${app_name}.${RHT_OCP4_WILDCARD_DOMAIN}/healthz
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 4 "test the app response" "curl -i ${project_name}-${RHT_OCP4_DEV_USER}-${app_name}.${RHT_OCP4_WILDCARD_DOMAIN}"
  curl -i ${project_name}-${RHT_OCP4_DEV_USER}-${app_name}.${RHT_OCP4_WILDCARD_DOMAIN}
  ___pause
}

function __3() {
	local lab_chap="3"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Activate readiness and liveness probes for the application."
	___pause

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "the liveness" "oc set probe dc/${app_name} --liveness --get-url=http://:8080/healthz --initial-delay-seconds=2 --timeout-seconds=2"
	oc set probe dc/${app_name} --liveness --get-url=http://:8080/healthz --initial-delay-seconds=2 --timeout-seconds=2
	___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "the readiness" "oc set probe dc/${app_name} --readiness --get-url=http://:8080/healthz --initial-delay-seconds=2 --timeout-seconds=2"
	oc set probe dc/${app_name} --readiness --get-url=http://:8080/healthz --initial-delay-seconds=2 --timeout-seconds=2
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 3 "verify the livenesProbe and readinessProbe" "oc describe dc/${app_name} | egrep -e \"Liveness|Readiness\""
  oc describe dc/${app_name} | egrep -e "Liveness|Readiness"
	___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 4 "wait for redeploy" "[various] oc get pods"
  oc get pods
  echo "wait 30 sec"
  sleep 30
  oc get pods
	___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 5 "check the logs" "oc logs -f dc/${app_name}"
  echo "do not terminate the shell, open another one and continue from there"
  ___pause
  oc logs -f dc/${app_name}
  ___pause
}

function __4() {
	local lab_chap="4"
  
  ___chapterDescriptionPrint ${lab_number} ${lab_chap} "simulate failure(s)"
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "kill something" "~/DO288/labs/probes/kill.sh"
  ~/DO288/labs/probes/kill.sh
  echo "see logs in previous console - wait for 'info ok' at the end of the log"
	___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 3 "check the pods" "oc get pods dc/${app_name}"
  oc get pods dc/${app_name}
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 5 "check the logs again" "oc logs -f dc/${app_name}"
  oc logs -f dc/${app_name}
  ___pause
}

function __5() {
	local lab_chap="5"
  
  echo "Verify that the failure of the liveness probe is seen in the event log "
  
  echo "run: oc get pods"
  oc get pods
  
  echo "check the last probes-XXX-asdjalskjd running pod, it should be the -3"
  echo "run: oc descript pods/${app_name}-XXX-asdasdjaskd"
}

function __end() {
	lab ${lab_name} finish
}


___execute $1
