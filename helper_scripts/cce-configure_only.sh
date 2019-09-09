#!/usr/bin/env bash

# wait until the userdata provisoning is done
echo "Starting configure of SoftwareAG webMethods Command Central"
while [ ! -f /tmp/initial_provisioning_done ]; do echo "Initial Server provisoning still in progress...Sleeping for 10 seconds."; sleep 10; done
while [ ! -f /tmp/cce_provisioning_done ]; do echo "Initial Command Central provisoning still in progress...Sleeping for 10 seconds."; sleep 10; done

CCE_DEVOPS_INSTALL_DIR=/opt/webMethods-devops-provisioning
CCE_DEVOPS_INSTALL_USER=saguser

## apply env
if [ -f ${HOME}/setenv_cce_init_secrets.sh ]; then
    echo "applying cce secrets to the shell"
    . ${HOME}/setenv_cce_init_secrets.sh
fi

echo "Moving to webMethods-devops-provisioning folder"
cd ${CCE_DEVOPS_INSTALL_DIR}

# Configure command central
echo "Configuring webMethods Command Central (logs are available at ~/nohup-configure_ccserver.log)"
nohup /bin/bash ./scripts/configure_ccserver.sh >> ~/nohup-configure_ccserver.log 2>&1 & tail -f ~/nohup-configure_ccserver.log
touch /tmp/cce_configuration_done

#mark the end of the script
echo "Configuration of webMethods Command Central is done."