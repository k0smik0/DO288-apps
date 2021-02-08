#!/bin/bash

function ___pause() {
	echo ""
	read -s -n 1 -p "Press any key to continue . . ."
	echo ""
}

function ___oc_login() {
  oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
}

function ___help() {
	echo "global help:"
	echo "- $(basename $0) 'list' :list available functions"
	echo "- $(basename $0) <function_number> : call me with function number to execute specific function"
	echo "- $(basename $0) 'all' : call me with 'all' to execute all"
}

function ___list() {
	echo "available commands: "
}

function ___localHelp() { 
	echo "specific help:"; 
}

function ___execute() {
	"__${1}"
}

function ___chapterDescriptionPrint() {
	local lab_number=$1
	local chapter_number=$2
	local description=$3
	
	echo ""; echo ""
	echo "${lab_number}.${chapter_number}:: $3"
}

function ___commandWithDescriptionPrint() {
	local lab_number=$1
	local chapter_number=$2
	local paragraph_number=$3
	local description=$4
	local command=$5

	echo ""	
	echo "${lab_number}.${chapter_number}.${paragraph_number}:: description: $4"
	echo "${lab_number}.${chapter_number}.${paragraph_number}:: command: $5"
}

function ___oc_get_pods_last_running() {
 pod=$(oc get pods | grep Running | tail -n 1 | awk '{print $1}')
 echo $pod
}