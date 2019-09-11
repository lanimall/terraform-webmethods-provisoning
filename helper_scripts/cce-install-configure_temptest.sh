#!/usr/bin/env bash

#get now date/time in milli precision
now=`date +%Y%m%d_%H%M%S%3N`

# check dependencies
if ! type inotifywait &>/dev/null ; then
	echo "You are missing the inotifywait dependency. Install the package inotify-tools (apt-get install inotify-tools)"
	exit 1
fi

# wait until the userdata provisoning is done
if [ ! -f /tmp/initial_provisioning_done ]; then
    echo "Initial Server provisoning still in progress...waiting..."
    inotifywait -e close_write,moved_to,create -m /tmp |
    while read -r directory events filename; do
    if [ "$filename" = "initial_provisioning_done" ]; then
        echo "initial_provisioning_done!!! Starting configure of SoftwareAG webMethods Command Central";
    fi
    done
fi

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

# check if target dir empty...if not, delete content as there should be nothing unique in there (all should be on github) 
if [ "$(ls -A $CCE_DEVOPS_INSTALL_DIR)" ]; then
     echo "${CCE_DEVOPS_INSTALL_DIR} NOT empty...deleting content."
     sudo rm -Rf ${CCE_DEVOPS_INSTALL_DIR}
     sudo mkdir -p ${CCE_DEVOPS_INSTALL_DIR}
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
nohup /bin/bash ./scripts/provision_ccserver.sh $now > ~/nohup-provision_ccserver.log 2>&1 &

if [ ! -f /tmp/provision_ccserver.done.status_$now ]; then
    echo "provision_ccserver still in progress...waiting..."
    inotifywait -e close_write,moved_to,create -m /tmp |
    while read -r directory events filename; do
    if [ "$filename" = "provision_ccserver.done.status_$now" ]; then
        echo "provision_ccserver done!!!";
    elif [ "$filename" = "provision_ccserver.fail.status_$now" ]; then
        echo "ERROR: provision_ccserver failed!!!";
    fi
    done
fi

# Configure command central
echo "Configuring webMethods Command Central (logs are available at ~/nohup-configure_ccserver.log)"
nohup /bin/bash ./scripts/configure_ccserver.sh $now > ~/nohup-configure_ccserver.log 2>&1 &

if [ ! -f /tmp/configure_ccserver.done.status_$now ]; then
    echo "configure_ccserver still in progress...waiting..."
    inotifywait -e close_write,moved_to,create -m /tmp |
    while read -r directory events filename; do
    if [ "$filename" = "configure_ccserver.done.status_$now" ]; then
        echo "configure_ccserver done!!!";
    elif [ "$filename" = "configure_ccserver.fail.status_$now" ]; then
        echo "ERROR: configure_ccserver failed!!!";
    fi
    done
fi

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