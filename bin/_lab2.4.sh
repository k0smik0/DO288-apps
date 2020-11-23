#!/bin/bash

source /usr/local/etc/ocp4.config

cp -vaf container-build/Dockerfile.unprivileged container-build/Dockerfile

oc new-app --as-deployment-config --name hola \
https://github.com/${RHT_OCP4_GITHUB_USER}/DO288-apps#container-build \
--context-dir container-build
