#!/bin/bash


lab_name="custom-s2i"
lab_number="5.7"

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
	
}

app_name="great"
imagestream="s2i-do288-go"
test_application_container_image="s2i-go-app"
test_container="go-test"

function __2() {
	local lab_chap="2"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "edit the dockerfile adding the command to copy s2i into container."
	___pause
	
	# 1
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "Edit the Dockerfile at ~/DO288/labs/custom-s2i/Dockerfile, adding the command immediately following the TODO comment" "vi /home/student/DO288/labs/custom-s2i/Dockerfile"
  cd /home/student/DO288/labs/custom-s2i/
  echo "entered in: $(pwd)"
  ___pause
	echo add "'COPY ./s2i/bin /usr/libexec/s2i' after TODO"
	___pause
	vi /home/student/DO288/labs/custom-s2i/Dockerfile
	___pause	
}

function __3() {
	local lab_chap="3"
	___chapterDescriptionPrint ${lab_number} ${lab_chap} "Build the S2I builder image. Name the image s2i-do288-go."
	___pause

	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "Create the S2I builder image:" "cd $HOME/DO288/labs/custom-s2i ; sudo podman build --format docker -t ${imagestream} ."
	cd $HOME/DO288/labs/custom-s2i ; pwd; ___pause; sudo podman build --format docker -t ${imagestream} .
	___pause
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "Verify that the builder image was created:" "sudo podman images"
	sudo podman images
	___pause
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
	
	___commandWithDescriptionPrint ${lab_number} ${lab_chap} "1" "login to quay, copy using skopeo..." "sudo podman login -u ${RHT_OCP4_QUAY_USER} quay.io ; sudo skopeo copy containers-storage:localhost/${test_application_container_image} docker://quay.io/${RHT_OCP4_QUAY_USER}/${test_application_container_image}"
	echo "login to quay.io - insert your password"
	sudo podman login -u ${RHT_OCP4_QUAY_USER} quay.io ; sudo skopeo copy containers-storage:localhost/${test_application_container_image} docker://quay.io/${RHT_OCP4_QUAY_USER}/${test_application_container_image}
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
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 5 "(re-)import the image from quay.io" "oc import-image ${test_application_container_image} --from quay.io/${RHT_OCP4_QUAY_USER}/${test_application_container_image} --confirm"
  oc import-image ${test_application_container_image} --from quay.io/${RHT_OCP4_QUAY_USER}/${test_application_container_image} --confirm
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
  
  context_dir="go-hello"
  
  resource_to_test="user1"
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 1 "deploy the new app using s2i from github branch" "oc new-app --as-deployment-config --name ${app_name} s2i-do288-go~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#${lab_name} --context-dir=go-hello"
  oc new-app --as-deployment-config --name ${app_name} s2i-do288-go~http://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#${lab_name} --context-dir=${context_dir}
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "check the logs" "oc logs -f bc/${app_name}"
  oc logs -f bc/greet
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 3 "wait the pods" "oc get pods"
  oc get pods
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 4 "expose the app" "oc expose svc ${app_name}"
  oc expose svc/${app_name}
  ___pause
  
  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 5 "get the route" "oc get route/${app_name} | grep host bla bla"
  target_route=$(oc get route/${app_name} | grep host)
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
  cp -a $HOME/DO288/labs/custom-s2i/s2i/bin/run $HOME/DO288-apps/go-hello/.s2i/bin/
  echo " --lang es" >> $HOME/DO288-apps/go-hello/.s2i/bin/run
  vi $HOME/DO288-apps/go-hello/.s2i/bin/run
  ___pause

  ___commandWithDescriptionPrint ${lab_number} ${lab_chap} 2 "commit" "git ..."
  git commit -m "changed language to go app"; git push origin ${lab_name}
  cd $HOME
  ___pause
}

function __11() {
  local lab_chap=11
  
  ___chapterDescriptionPrint ${lab_number} ${lab_chap} "rebuild the application, the use logs and get to check pods are running"
  oc start-build ${app_name}
  oc log -f bc/${app_name}
  oc get pods
  target_route=$(oc get route/${app_name} | grep host)
  echo ${target_route}
  curl ${target_route}/${resource_to_test}
  ___pause
}


function ___12() {
  lab build-app grade
}

function __end() {
	lab ${lab_name} finish
}


___execute $1
