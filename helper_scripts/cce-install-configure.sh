#!/usr/bin/env bash

# wait until the userdata provisoning is done
echo "Starting install/configure of SoftwareAG webMethods Command Central"
while [ ! -f /tmp/initial_provisioning_done ]; do echo "Initial Server provisoning still in progress...Sleeping for 10 seconds."; sleep 10; done

# clone webmethods provisoning project
echo "Getting the webMethods-devops-provisioning project from github"
/bin/git clone --recursive -b rel103 https://github.com/lanimall/webMethods-devops-provisioning.git

echo "Moving to webMethods-devops-provisioning folder"
cd ${HOME}/webMethods-devops-provisioning

## apply env
if [ -f ${HOME}/setenv_cce_init_secrets.sh ]; then
    echo "applying cce secrets to the shell"
    . ${HOME}/setenv_cce_init_secrets.sh
fi

# Install command central
echo "Installing webMethods Command Central (logs are available at ~/nohup-provision_ccserver.log)"
nohup /bin/bash ./scripts/provision_ccserver.sh > ~/nohup-provision_ccserver.log 2>&1
touch /tmp/cce_provisioning_done

# Configure command central
echo "Configuring webMethods Command Central (logs are available at ~/nohup-configure_ccserver.log)"
nohup /bin/bash ./scripts/configure_ccserver.sh > ~/nohup-configure_ccserver.log 2>&1
touch /tmp/cce_configuration_done

#mark the end of the script
echo "Installation and Configuration of webMethods Command Central is done."

## clear env
# if [ -f ${HOME}/setenv_cce_remove_secrets.sh ]; then
#     . ${HOME}/setenv_cce_remove_secrets.sh
#     rm -f ${HOME}/setenv_cce_remove_secrets.sh
# fi

# if [ -f ${HOME}/setenv_cce_init_secrets.sh ]; then
#     rm -f ${HOME}/setenv_cce_init_secrets.sh
# fi