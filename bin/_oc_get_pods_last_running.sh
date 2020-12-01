#!/bin/bash

function oc_get_pods_last_running() {
 pod=$(oc get pods | grep Running | tail -n 1 | awk '{print $1}')
 echo $pod
}
