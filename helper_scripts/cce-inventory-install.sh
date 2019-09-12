#!/usr/bin/env bash

##get the params passed-in
CMD_UNIQUE_ID=$1

## apply common functions
if [ -f $HOME/common.sh ]; then
    . $HOME/common.sh
fi

echo "Starting installation of SoftwareAG webMethods products"
wait_server_provisioning_done $CMD_UNIQUE_ID

#set devops values
CCE_DEVOPS_INSTALL_DIR="${cc_devops_install_dir}"
CCE_DEVOPS_INSTALL_USER="${cc_devops_install_user}"

# wait until the provisioning/configuration of CCE is done
wait_cce_installation_done $CMD_UNIQUE_ID
wait_cce_configuration_done $CMD_UNIQUE_ID

##check target directory
if [ ! -d $CCE_DEVOPS_INSTALL_DIR ]; then
    echo "$CCE_DEVOPS_INSTALL_DIR does not exists. exiting."
    exit 2;
fi

##check target user
getent passwd $CCE_DEVOPS_INSTALL_USER > /dev/null
if [ $? -ne 0 ]; then
    echo "User [$CCE_DEVOPS_INSTALL_USER] does not exist. Exiting."
    exit 2;
fi

##first move to provisoning folder
cd $CCE_DEVOPS_INSTALL_DIR

## Install Universal Messaging
echo "Launching Universal Messaging provisioning in the background..."
PROVISION_STACK=um
/bin/bash ./scripts/provision_setparams.sh $PROVISION_STACK "TARGET_HOST" "${webmethods_universalmessaging1}"
/bin/bash ./scripts/provision_setparams.sh $PROVISION_STACK "LICENSE_KEY_ALIAS1" "${webmethods_universalmessaging_license_key_alias}" "true"
nohup /bin/bash ./scripts/provision_stack.sh $PROVISION_STACK $CMD_UNIQUE_ID > ~/nohup-wmprovisioning-provision_stack_$PROVISION_STACK.log 2>&1 &
echo "Universal Messaging provisioning - Check progress at ~/nohup-wmprovisioning-provision_stack_$PROVISION_STACK.log"

## Install Terracotta
echo "Launching Terracotta provisioning in the background..."
PROVISION_STACK=tc
/bin/bash ./scripts/provision_setparams.sh $PROVISION_STACK "TARGET_HOST" "${webmethods_terracotta1}"
/bin/bash ./scripts/provision_setparams.sh $PROVISION_STACK "LICENSE_KEY_ALIAS1" "${webmethods_terracotta_license_key_alias}" "true"
nohup /bin/bash ./scripts/provision_stack.sh $PROVISION_STACK $CMD_UNIQUE_ID > ~/nohup-wmprovisioning-provision_stack_$PROVISION_STACK.log 2>&1 &
echo "Terracotta provisioning - Check progress at ~/nohup-wmprovisioning-provision_stack_$PROVISION_STACK.log"

## Install Integration Server
echo "Launching Integration Server provisioning in the background..."
PROVISION_STACK="is_stateless"
/bin/bash ./scripts/provision_setparams.sh $PROVISION_STACK "TARGET_HOST" "${webmethods_integration1}"
/bin/bash ./scripts/provision_setparams.sh $PROVISION_STACK "LICENSE_KEY_ALIAS1" "${webmethods_integration_license_key_alias}" "true"
nohup /bin/bash ./scripts/provision_stack.sh $PROVISION_STACK $CMD_UNIQUE_ID > ~/nohup-wmprovisioning-provision_stack_$PROVISION_STACK.log 2>&1 &
echo "Integration Server provisioning - Check progress at ~/nohup-wmprovisioning-provision_stack_$PROVISION_STACK.log"

echo "Product provisoning under way..."
echo "To check current status, check the webMethods Command Central Jobs"
echo "Alternativaly, you can also check the provisoning logs on the server (nohup-provision_um.log,nohup-provision_tc.log,nohup-provision_is_stateless.log)"