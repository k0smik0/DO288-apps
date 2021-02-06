#!/bin/bash

function __help() {
	echo "global help:"
	echo "- $(basename $0) 'list' :list available functions"
	echo "- $(basename $0) <function_number> : call me with function number to execute specific function"
	echo "- $(basename $0) 'all' : call me with 'all' to execute all"
}

function __list() {
	echo "available commands: "
}

function __localHelp() { 
	echo "specific help:"; 
}

function _execute() {
	"__${1}"
}
