oc new-project ${RHT_OCP4_DEV_USER}-common
oc create -f ~/DO288/labs/build-template/php-mysql-ephemeral.json
oc new-project ${RHT_OCP4_DEV_USER}-build-template
oc describe template php-mysql-ephemeral -n ${RHT_OCP4_DEV_USER}-common

