#!/bin/bash

source /usr/local/etc/ocp4.config
echo "executing: 'oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}'"

oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
