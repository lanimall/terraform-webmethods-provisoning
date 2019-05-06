#!/usr/bin/env bash

# wait until the userdata provisoning is done
echo "Starting install/configure of SoftwareAG webMethods products"
while [ ! -f /tmp/initial_provisioning_done ]; do echo "Initial Server provisoning still in progress...Sleeping for 10 seconds."; sleep 10; done

while [ ! -f /tmp/cce_provisioning_done ]; do echo "Initial Command Central provisoning still in progress...Sleeping for 10 seconds."; sleep 10; done

while [ ! -f /tmp/cce_configuration_done ]; do echo "Initial Command Central configuration still in progress...Sleeping for 10 seconds."; sleep 10; done

## apply env
if [ -f ${HOME}/inventory-setenv.sh ]; then
    echo "applying inventory to the shell"
    . ${HOME}/inventory-setenv.sh
fi

echo "Moving to webMethods-devops-provisioning folder"
cd ${HOME}/webMethods-devops-provisioning

# Install Universal Messaging
echo "Launching Universal Messaging provisoning in the background..."
export TARGET_HOST=${webmethods_universalmessaging1}
export LICENSE_KEY_ALIAS1=${webmethods_universalmessaging_license_key_alias}
#./scripts/provision_um.sh
nohup /bin/bash ./scripts/provision_um.sh > ~/nohup-provision_um.log 2>&1 &

# Install Terracotta
echo "Launching Terracotta provisoning in the background..."
export TARGET_HOST=${webmethods_terracotta1}
export LICENSE_KEY_ALIAS1=${webmethods_terracotta_license_key_alias}
#./scripts/provision_tc.sh
nohup /bin/bash ./scripts/provision_tc.sh > ~/nohup-provision_tc.log 2>&1 &

# Install Integration Server
echo "Launching Integration Server provisoning in the background..."
export TARGET_HOST=$webmethods_integration1
export LICENSE_KEY_ALIAS1=${webmethods_integration_license_key_alias}
#./scripts/provision_is_stateless.sh
nohup /bin/bash ./scripts/provision_is_stateless.sh > ~/nohup-provision_is_stateless.log 2>&1 &

#./scripts/provision_is_stateless_messaging.sh

echo "Product provisoning under way..."
echo "To check current status, check the webMEthods Command Central Jobs"
echo "Alternativaly, you can also check the provisoning logs on the server (nohup-provision_um.log,nohup-provision_tc.log,nohup-provision_is_stateless.log)"