#!/bin/bash


lab_name="review-template"
lab_number="6.5"

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

function __1() {
	local lab_chap="1"
	
  echo "copied $HOME/DO288/labs/review-template/todo-template.yaml into $HOME and fixed, adding the missing parameters at the end, and replaced placeholder into file content"
}

# 4
# test_application_container_image="s2i-go-app"
# test_container="go-test"
# # 5 6 ...
# imagestream="s2i-do288-go"
# 3
app_name="todoapp"

function __2() {
	local lab_chap="2"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Create a new project and deploy the To Do List application using the template definition file you completed during the previous step."
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "copy/rearrange/use the oc-new-app.sh from $HOME/DO288/labs/review-template/" "cp $HOME/DO288/labs/review-template/oc-new-app.sh $HOME"
  cp $HOME/DO288/labs/review-template/oc-new-app.sh $HOME
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "add missing parameters to the $HOME/oc-new-app.sh" "echo add HOSTNAME and SECRET to parameters list"
  echo "add/rearrange HOSTNAME=${RHT_OCP4_DEV_USER}-todo.${RHT_OCP4_WILDCARD_DOMAIN} and DATABASE=true" >> $HOME/DO288/labs/review-template/oc-new-app.sh
  vi $HOME/DO288/labs/review-template/oc-new-app.sh
  ___pause
  
	# echo add "'COPY ./s2i/bin /usr/libexec/s2i' after TODO"
	# ___pause
	# vi /home/student/DO288/labs/custom-s2i/Dockerfile
	# ___pause
}

function __3() {
	local lab_chap="3"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Test the To Do List application using either a web browser or the command line. Do not forget to source the variables from the /usr/local/etc/ocp4.config before logging in to OpenShift."
	___pause

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "source the config and login" "__oc_login"
	___oc_login
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 3 "create the project" "oc new-project ${project_name}"
  oc new-project ${project_name}
	___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 4 "run the $HOME/oc-new-app.sh" "echo bash $HOME/oc-new-app.sh"
  bash $HOME/oc-new-app.sh
	___pause
  
  echo "wait for building finish, show the pods, get the route"
  oc logs -f bc/${app_name}
  ___pause
  oc get pods
  ___pause
  the_route=$(oc get route/${app_name} | grep ${app_name} | awk '{print $2}'); echo "route: ${the_route}"
  ___pause
  echo "test the app"
  firefox http://${the_route}/todo/index.html &
}

function __4() {
	local lab_chap="4"
	lab review-template grade
	___pause
}

function __end() {
	lab ${lab_name} finish
}


___execute $1
