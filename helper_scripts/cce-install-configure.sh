#!/usr/bin/env bash

##get the params passed-in
CMD_PREREQS=$1
CMD_INSTALL=$2
CMD_CONFIGURE=$3
CMD_UNIQUE_ID=$4

## apply common functions
if [ -f ${HOME}/common.sh ]; then
    . ${HOME}/common.sh
fi

echo "Starting install/configure of SoftwareAG webMethods Command Central"
wait_server_provisoning_done $CMD_UNIQUE_ID

if [ -f ${HOME}/setenv_cce_devops.sh ]; then
    echo "applying cce devops env to the shell"
    . ${HOME}/setenv_cce_devops.sh
fi

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

    echo "Pre-requisites for Command Central provisoning is done."
fi

if [ "$CMD_INSTALL" = "true" ]; then
    # Install command central
    echo "Installing webMethods Command Central (logs are available at ~/nohup-wmprovisioning-provision_ccserver.log)"
    
    cd ${CCE_DEVOPS_INSTALL_DIR}
    nohup /bin/bash ./scripts/provision_ccserver.sh $CMD_UNIQUE_ID > ~/nohup-wmprovisioning-provision_ccserver.log 2>&1 &

    #wait for installation
    wait_cce_installation_done $CMD_UNIQUE_ID
    echo "Installation webMethods Command Central is done."
fi

if [ "$CMD_CONFIGURE" = "true" ]; then
    # Configure command central
    echo "Configuring webMethods Command Central (logs are available at ~/nohup-wmprovisioning-configure_ccserver.log)"
    wait_cce_installation_done $CMD_UNIQUE_ID
    
    cd ${CCE_DEVOPS_INSTALL_DIR}
    nohup /bin/bash ./scripts/configure_ccserver.sh $CMD_UNIQUE_ID > ~/nohup-wmprovisioning-configure_ccserver.log 2>&1 &

    ## clear sensitive files from CCE_DEVOPS_INSTALL_USER home
    sudo rm -f /home/${CCE_DEVOPS_INSTALL_USER}/.setenv_cce_secrets.sh
    sudo rm -f /home/${CCE_DEVOPS_INSTALL_USER}/sag_licenses.zip

    #wait for configuration
    wait_cce_configuration_done $CMD_UNIQUE_ID
    echo "Configuration of webMethods Command Central is done."
fi

#mark the end of the script
echo "End"