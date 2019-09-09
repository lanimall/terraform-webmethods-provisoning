#!/usr/bin/env bash

# wait until the userdata provisoning is done
echo "Starting install/configure of SoftwareAG webMethods Command Central"
while [ ! -f /tmp/initial_provisioning_done ]; do echo "Initial Server provisoning still in progress...Sleeping for 10 seconds."; sleep 10; done

if [ -f ${HOME}/setenv_cce_devops.sh ]; then
    echo "applying cce devops env to the shell"
    . ${HOME}/setenv_cce_devops.sh
fi

##check target user
getent passwd ${CCE_DEVOPS_INSTALL_USER} > /dev/null
if [ $? -ne 0 ]; then
    echo "User [${CCE_DEVOPS_INSTALL_USER}] does not exist. Exiting."
    exit 2;
fi

## creating target directory for the code
if [ ! -d ${CCE_DEVOPS_INSTALL_DIR} ]; then
    echo "Directory [${CCE_DEVOPS_INSTALL_DIR}] does not exist - Creating..."
    sudo mkdir -p ${CCE_DEVOPS_INSTALL_DIR}
fi

if [ ! -d ${CCE_DEVOPS_INSTALL_DIR} ]; then
    echo "${CCE_DEVOPS_INSTALL_DIR} does not exists. exiting."
    exit 2;
fi

# clone webmethods provisoning project
echo "Getting the webMethods-devops-provisioning project from github"
sudo /bin/git clone --recursive -b rel103 https://github.com/lanimall/webMethods-devops-provisioning.git ${CCE_DEVOPS_INSTALL_DIR}

## applying user/group on the target directory
sudo chown -R ${CCE_DEVOPS_INSTALL_USER}:${CCE_DEVOPS_INSTALL_USER} ${CCE_DEVOPS_INSTALL_DIR}

##copy the provisoning "secrets" in the home of the target CCE_DEVOPS_INSTALL_USER user so the provisoning scripts can use it
sudo mv ${HOME}/setenv_cce_secrets.sh /home/${CCE_DEVOPS_INSTALL_USER}/.setenv_cce_secrets.sh

echo "Moving to webMethods-devops-provisioning folder"
cd ${CCE_DEVOPS_INSTALL_DIR}

# Install command central
echo "Installing webMethods Command Central (logs are available at ~/nohup-provision_ccserver.log)"
nohup /bin/bash ./scripts/provision_ccserver.sh > ~/nohup-provision_ccserver.log 2>&1  & tail -f ~/nohup-provision_ccserver.log
touch /tmp/cce_provisioning_done

# Configure command central
echo "Configuring webMethods Command Central (logs are available at ~/nohup-configure_ccserver.log)"
nohup /bin/bash ./scripts/configure_ccserver.sh > ~/nohup-configure_ccserver.log 2>&1 & tail -f ~/nohup-configure_ccserver.log
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