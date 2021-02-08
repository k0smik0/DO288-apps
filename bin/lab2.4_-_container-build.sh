#!/bin/bash

echo "eventually run: 'lab container-build start'"

source /usr/local/etc/ocp4.config

oc login -u ${RHT_OCP4_DEV_USER}  -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}



oc new-project ${RHT_OCP4_DEV_USER}-container-build

cp -vaf container-build/Dockerfile.unprivileged container-build/Dockerfile

oc new-app --as-deployment-config --name hola https://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#container-build --context-dir container-build

oc expose svc/hola

curl http://hola-${RHT_OCP4_DEV_USER}-container-build.${RHT_OCP4_WILDCARD_DOMAIN}

echo "eventually run: lab containeir-build finish"
