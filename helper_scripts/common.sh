#!/usr/bin/env bash

function wait_server_provisoning_done(){
    CMD_UNIQUE_ID=$1
    STATUS_FILE="/tmp/initial_provisioning_done"
    # wait until the server installation is done
    while [ ! -f $STATUS_FILE ]; do echo "File $STATUS_FILE not found - Initial Server provisoning still in progress...Sleeping for 10 seconds. For progress details, check: /var/log/user-data.log"; sleep 10; done
    echo "initial_provisioning_done!!! moving forward...";
}

function wait_cce_installation_done(){
    CMD_UNIQUE_ID=$1
    STATUS_FILE="/tmp/provision_ccserver.done.status_$CMD_UNIQUE_ID"
    # wait until the CCE installation is done
    while [ ! -f $STATUS_FILE  ]; do echo "File $STATUS_FILE not found - provision_ccserver still in progress...Sleeping for 10 seconds."; sleep 10; done
    echo "provision_ccserver done!!!";
    ##"provision_ccserver.fail.status_$CMD_UNIQUE_ID"
}

function wait_cce_configuration_done(){
    CMD_UNIQUE_ID=$1
    STATUS_FILE="/tmp/configure_ccserver.done.status_$CMD_UNIQUE_ID"
    # wait until the process is done
    while [ ! -f $STATUS_FILE  ]; do echo "File $STATUS_FILE not found - configure_ccserver still in progress - Sleeping for 10 seconds."; sleep 10; done
    echo "configure_ccserver done!!!";
}