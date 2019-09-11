#!/usr/bin/env bash

#get now date/time in milli precision
now=`date +%Y%m%d_%H%M%S%3N`

# wait until the userdata provisoning is done
echo "Starting install/configure of SoftwareAG webMethods Command Central"
while [ ! -f /tmp/initial_provisioning_done ]; do echo "Initial Server provisoning still in progress...Sleeping for 10 seconds. For progress details, check: /var/log/user-data.log"; sleep 10; done
echo "initial_provisioning_done!!! moving forward...";

if [ -f ${HOME}/setenv_cce_devops.sh ]; then
    echo "applying cce devops env to the shell"
    . ${HOME}/setenv_cce_devops.sh
fi

##get the params passed-in
CMD_PREREQS=$1
CMD_INSTALL=$2
CMD_CONFIGURE=$3

if [ "x$CMD_PREREQS" = "x" ]; then
    CMD_PREREQS="true"
fi

if [ "x$CMD_INSTALL" = "x" ]; then
    CMD_INSTALL="true"
fi

if [ "x$CMD_CONFIGURE" = "x" ]; then
    CMD_CONFIGURE="true"
fi

if [ "$CMD_PREREQS" = "true" ]; then  
    echo "Setting up pre-requisites for Command Central provisoning..."

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

    ##move the provisoning "secrets" in the home of the target CCE_DEVOPS_INSTALL_USER user so the provisoning scripts can use it
    sudo cp -f ${HOME}/setenv_cce_secrets.sh /home/${CCE_DEVOPS_INSTALL_USER}/.setenv_cce_secrets.sh

    ##move the product licenses package in the home of the target CCE_DEVOPS_INSTALL_USER user so the provisoning scripts can use it
    sudo cp -f ${HOME}/sag_licenses.zip /home/${CCE_DEVOPS_INSTALL_USER}/
fi

if [ "$CMD_INSTALL" = "true" ]; then
    # Install command central
    echo "Installing webMethods Command Central (logs are available at ~/nohup-provision_ccserver.log)"
    cd ${CCE_DEVOPS_INSTALL_DIR}
    nohup /bin/bash ./scripts/provision_ccserver.sh $now > ~/nohup-provision_ccserver.log 2>&1 &

    # wait until the process is done
    while [ ! -f /tmp/provision_ccserver.done.status_$now  ]; do echo "provision_ccserver still in progress...Sleeping for 10 seconds. For progress details, check: ~/nohup-provision_ccserver.log"; sleep 10; done
    echo "provision_ccserver done!!!";
    ##"provision_ccserver.fail.status_$now"
fi

if [ "$CMD_CONFIGURE" = "true" ]; then
    # Configure command central
    echo "Configuring webMethods Command Central (logs are available at ~/nohup-configure_ccserver.log)"
    cd ${CCE_DEVOPS_INSTALL_DIR}
    nohup /bin/bash ./scripts/configure_ccserver.sh $now > ~/nohup-configure_ccserver.log 2>&1 &

    # wait until the process is done
    while [ ! -f /tmp/configure_ccserver.done.status_$now  ]; do echo "configure_ccserver still in progress...Sleeping for 10 seconds. For progress details, check: ~/nohup-configure_ccserver.log"; sleep 10; done
    echo "configure_ccserver done!!!";

    ## clear sensitive files from CCE_DEVOPS_INSTALL_USER home
    sudo rm -f /home/${CCE_DEVOPS_INSTALL_USER}/.setenv_cce_secrets.sh
    sudo rm -f /home/${CCE_DEVOPS_INSTALL_USER}/sag_licenses.zip
fi

#mark the end of the script
echo "Installation and Configuration of webMethods Command Central is done."