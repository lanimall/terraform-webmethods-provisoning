#!/usr/bin/env bash

##get the params passed-in
CMD_INSTALL=$1
CMD_CONFIGURE=$2
CMD_UNIQUE_ID=$3

## apply common functions
if [ -f $HOME/common.sh ]; then
    . $HOME/common.sh
fi

echo "Starting install/configure of SoftwareAG webMethods Command Central"
wait_server_provisioning_done $CMD_UNIQUE_ID

#set devops values
CCE_DEVOPS_INSTALL_DIR="${cc_devops_install_dir}"
CCE_DEVOPS_INSTALL_USER="${cc_devops_install_user}"

if [ "x$CMD_INSTALL" = "x" ]; then
    CMD_INSTALL="true"
fi

if [ "x$CMD_CONFIGURE" = "x" ]; then
    CMD_CONFIGURE="true"
fi

if [ "$CMD_INSTALL" = "true" ]; then
    # Install command central
    echo "Installing webMethods Command Central (logs are available at ~/nohup-wmprovisioning-provision_ccserver.log)"
    
    cd $CCE_DEVOPS_INSTALL_DIR
    nohup /bin/bash ./scripts/provision_ccserver.sh $CMD_UNIQUE_ID > ~/nohup-wmprovisioning-provision_ccserver.log 2>&1 &

    #wait for installation
    wait_cce_installation_done $CMD_UNIQUE_ID
    echo "Installation webMethods Command Central is done."
fi

if [ "$CMD_CONFIGURE" = "true" ]; then
    # Configure command central
    echo "Configuring webMethods Command Central (logs are available at ~/nohup-wmprovisioning-configure_ccserver.log)"
    wait_cce_installation_done $CMD_UNIQUE_ID
    
    cd $CCE_DEVOPS_INSTALL_DIR
    nohup /bin/bash ./scripts/configure_ccserver.sh $CMD_UNIQUE_ID > ~/nohup-wmprovisioning-configure_ccserver.log 2>&1 &

    #wait for configuration
    wait_cce_configuration_done $CMD_UNIQUE_ID
    
    ## clear sensitive files from CCE_DEVOPS_INSTALL_USER home
    sudo rm -f /home/$CCE_DEVOPS_INSTALL_USER/.setenv_cce_secrets.sh
    sudo rm -f /home/$CCE_DEVOPS_INSTALL_USER/sag_licenses.zip

    echo "Configuration of webMethods Command Central is done."
fi

#mark the end of the script
echo "End"