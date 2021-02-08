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
	__oc_login
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
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Build a Dockerfile for an application container image that combines the S2I builder image and the application source code locally on the workstation VM in the /home/student/DO288/labs/custom-s2i/test/test-app directory."
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "create and go to ${test_application_container_image}" "mkdir/cd ${test_application_container_image}"
	[ -d $HOME/${test_application_container_image} ] || mkdir $HOME/${test_application_container_image}
	cd $HOME/DO288/labs/${lab_name}
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "Use the s2i build command to produce a Dockerfile for the application container image:" "s2i build test/test-app ${test_application_container_image} --as-dockerfile $HOME/${test_application_container_image}/Dockerfile"
	s2i build test/test-app ${test_application_container_image} --as-dockerfile $HOME/${test_application_container_image}/Dockerfile
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 3 "Build a test container image from the generated Dockerfile." "'sudo podman build ...' from $HOME/${test_application_container_image}/"
	cd $HOME/${test_application_container_image}/
	sudo podman build -t ${test_application_container_image} .
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 4 "Verify that the builder image was created:" "sudo podman images"
	sudo podman images
	___pause
	
	# from track
	# Ensure that when you test the container you use a random user ID, such as 1234, to simulate running on an OpenShift cluster.
	# Bind the container port 8080 to local port 8080.
	local_user=1234
	bind_port=8080
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 5 "test the image run as container, locally" "sudo podman run --name go-test -u ${local_user} -p ${bind_port}:${bind_port} -d ${test_application_container_image}"
	sudo podman run --name ${test_container} -u ${local_user} -p ${bind_port}:${bind_port} -d ${test_application_container_image}
	___pause
	
	# The application returns a greeting based on the URL that made the request. For example:
	# http://localhost:8080/user1, returns the following response:
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 6 "verify the container started" "sudo podman ps"
	sudo podman ps
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 7 "verify the container works well" "curl http://localhost:8080/user1"
	curl http://localhost:8080/user1
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 8 "stop the container" "sudo podman stop ${test_container}"
	sudo podman stop ${test_container}
	___pause
}

function __5() {
	local lab_chap="5"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Push the s2i-do288-go S2I builder image to your personal Quay.io account."
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "login to quay, copy using skopeo..." "sudo podman login -u ${RHT_OCP4_QUAY_USER} quay.io ; sudo skopeo copy containers-storage:localhost/${imagestream} docker://quay.io/${RHT_OCP4_QUAY_USER}/${imagestream}"
	echo "login to quay.io - insert your password"
	sudo podman login -u ${RHT_OCP4_QUAY_USER} quay.io ; sudo skopeo copy containers-storage:localhost/${imagestream} docker://quay.io/${RHT_OCP4_QUAY_USER}/${imagestream}
	___pause
}

function __6() {
	local lab_chap="6"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Create an image stream called s2i-do288-go for the s2i-do288-go S2I builder image. Create the image stream in a project named youruser-custom-s2i."
	
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "login to oc" "___oc_login"
  ___oc_login
  ___pause
  
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "create the project" "oc new-project ${project_name}"
	oc new-project ${project_name}
	___pause
	
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "login to quay *without* sudo, so export YOUR auth" "podman login -u ${RHT_OCP4_QUAY_USER} quay.io"
	podman login -u ${RHT_OCP4_QUAY_USER} quay.io
	___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 3 "create the secret" "(type: generic, name: quayio):: oc create secret generic quayio --from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json --type=kubernetes.io/dockerconfigjson"  
  oc create secret generic quayio --from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json --type=kubernetes.io/dockerconfigjson
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 4 "link the secret" "oc secrets link builder quayio"
  oc secrets link builder quayio
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 5 "(re-)import the image from quay.io" "oc import-image ${imagestream} --from quay.io/${RHT_OCP4_QUAY_USER}/${imagestream} --confirm"
  oc import-image ${imagestream} --from quay.io/${RHT_OCP4_QUAY_USER}/${imagestream} --confirm
  ___pause

  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 6 "verify the is" "oc get is"
  oc get is
  ___pause
}

function __7() {
	local lab_chap="7"
  
  ___chapterDescriptionPrint ${lab_number} ${lab_chap} "checkout master branch"
  cd $HOME/DO288-apps
  git checkout master
	echo "do manually the following:\ngit checkout -b ${lab_name} ; git checkout chap_5 -- bin ; git push origin ${lab_name}"
  ___pause
}


function __8() {
	local lab_chap="8"
	
  ___chapterDescriptionPrint ${lab_number} ${lab_chap} "branched from master, bla bla"
  echo "did the following:\ngit checkout -b ${lab_name}; git checkout chap_5 -- bin ; git push origin ${lab_name}"
  cd $HOME
  ___pause  
}

function __9() {
  local lab_chap=9
  ___chapterDescriptionPrint ${lab_number} ${lab_chap} "Deploy and test the go-hello application from your personal GitHub fork of the DO288-apps repository to the classroom OpenShift cluster. Be sure to reference the custom-s2i branch you created in the previous step when you deploy the application. The application echoes back a greeting to the resource requested by the HTTP request. For example, invoking the application with the following URL: http://greet-youruser-custom-s2i.apps.cluster.domain.example.com/user1, returns the following response: 'Hello user1!. Welcome!'"
	___pause
  
  context_dir="go-hello"
  
  resource_to_test="user1"
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "deploy the new app using s2i from github branch" "oc new-app --as-deployment-config --name ${app_name} s2i-do288-go~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#${lab_name} --context-dir=go-hello"
  oc new-app --as-deployment-config --name ${app_name} ${imagestream}~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#${lab_name} --context-dir=${context_dir}
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "check the logs" "oc logs -f bc/${app_name}"
  oc logs -f bc/${app_name}
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 3 "wait the pods" "oc get pods"
  oc get pods
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 4 "expose the app" "oc expose svc ${app_name}"
  oc expose svc/${app_name}
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 5 "get the route" "oc get route/${app_name} | grep host bla bla"
	target_route=$(oc get route/${app_name} | grep host | grep -v generated | awk '{print $2}' | uniq | sed 's/[",]//g')
  echo ${target_route}
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 6 "check the running" "curl ${target_route}/${resource_to_test}"
  curl ${target_route}/${resource_to_test}
  ___pause
}

function __10() {
  local lab_chap=10
  ___chapterDescriptionPrint ${lab_number} ${lab_chap} "customize the 'run' script for the 's2i-do288-go', adding a --lang es' as startup argument"
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "add --lang es at the end of 'run'"
  mkdir -p $HOME/DO288-apps/go-hello/.s2i/bin
	local new_run="$HOME/DO288-apps/go-hello/.s2i/bin/run"
  cp -a $HOME/DO288/labs/custom-s2i/s2i/bin/run $local_run
  echo " --lang es" >> $local_run
  vi $local_run
  ___pause

  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "commit" "git ..."
	cd $HOME/DO288-apps/go-hello/
  git add . ; add git commit -m "changed language to go app"; git push origin ${lab_name}
  cd $HOME
  ___pause
}

function __11() {
  local lab_chap=11
  
  ___chapterDescriptionPrint ${lab_number} ${lab_chap} "rebuild the application, the use logs and get to check pods are running"
  oc start-build ${app_name}
  oc logs -f bc/${app_name}
  oc get pods
  #target_route=$(oc get route/${app_name} | grep host)
  echo ${target_route}
  curl ${target_route}/${resource_to_test}
  ___pause
}


function __12() {
  lab ${lab_name} grade
}

function __13() {
	echo "clean/delete various"
	
	oc delete project ${RHT_OCP4_DEV_USER}-custom-s2i ;
	sudo podman rm go-test ;
	sudo podman rmi -f localhost/s2i-go-app localhost/s2i-do288-go registry.access.redhat.com/ubi8/ubi:8.0 ;
	sudo skopeo delete docker://quay.io/${RHT_OCP4_QUAY_USER}/s2i-do288-go:latest ;
}

function __end() {
	lab ${lab_name} finish
}


___execute $1
