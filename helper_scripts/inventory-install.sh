#!/usr/bin/env bash

#get now date/time in milli precision
now=`date +%Y%m%d_%H%M%S%3N`

# wait until the userdata provisoning is done
echo "Starting install/configure of SoftwareAG webMethods products"
while [ ! -f /tmp/initial_provisioning_done ]; do echo "Initial Server provisoning still in progress...Sleeping for 10 seconds."; sleep 10; done

## apply env
if [ -f ${HOME}/setenv_cce_devops.sh ]; then
    echo "applying cce devops env to the shell"
    . ${HOME}/setenv_cce_devops.sh
fi

if [ -f ${HOME}/inventory-setenv.sh ]; then
    echo "applying inventory to the shell"
    . ${HOME}/inventory-setenv.sh
fi

if [ ! -d ${CCE_DEVOPS_INSTALL_DIR} ]; then
    echo "${CCE_DEVOPS_INSTALL_DIR} does not exists. exiting."
    exit 2;
fi

echo "Moving to webMethods-devops-provisioning folder"
cd ${CCE_DEVOPS_INSTALL_DIR}

# Install Universal Messaging
echo "Launching Universal Messaging provisoning in the background..."
export TARGET_HOST=${webmethods_universalmessaging1}
export LICENSE_KEY_ALIAS1=${webmethods_universalmessaging_license_key_alias}
nohup /bin/bash ./scripts/provision_um.sh $now > ~/nohup-provision_um.log 2>&1 &

# Install Terracotta
echo "Launching Terracotta provisoning in the background..."
export TARGET_HOST=${webmethods_terracotta1}
export LICENSE_KEY_ALIAS1=${webmethods_terracotta_license_key_alias}
nohup /bin/bash ./scripts/provision_tc.sh $now > ~/nohup-provision_tc.log 2>&1 &

# Install Integration Server
echo "Launching Integration Server provisoning in the background..."
export TARGET_HOST=${webmethods_integration1}
export LICENSE_KEY_ALIAS1=${webmethods_integration_license_key_alias}
nohup /bin/bash ./scripts/provision_is_stateless.sh $now > ~/nohup-provision_is_stateless.log 2>&1 &

echo "Product provisoning under way..."
echo "To check current status, check the webMethods Command Central Jobs"
echo "Alternativaly, you can also check the provisoning logs on the server (nohup-provision_um.log,nohup-provision_tc.log,nohup-provision_is_stateless.log)"