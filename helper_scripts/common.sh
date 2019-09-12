#!/usr/bin/env bash

function wait_server_provisioning_done(){
    CMD_UNIQUE_ID=$1
    STATUS_FILE="/tmp/initial_provisioning_done"
    # wait until the server installation is done
    while [ ! -f $STATUS_FILE ]; do echo "File $STATUS_FILE not found - Initial Server provisoning still in progress...Sleeping for 10 seconds. For progress details, check: /var/log/user-data.log"; sleep 10; done
    echo "initial_provisioning_done!!! moving forward...";
}

function set_server_provisioning_done(){
    CMD_UNIQUE_ID=$1
    STATUS_FILE="/tmp/initial_provisioning_done"
    touch $STATUS_FILE
}

function wait_cce_installation_done(){
    CMD_UNIQUE_ID=$1
    if [ "x$CMD_UNIQUE_ID" != "x" ]; then
        CMD_UNIQUE_ID="_$CMD_UNIQUE_ID"
    fi
    STATUS_FILE="/tmp/provision_ccserver.done.status$CMD_UNIQUE_ID"
    while [ ! -f $STATUS_FILE  ]; do echo "File $STATUS_FILE not found - provision_ccserver still in progress...Sleeping for 10 seconds."; sleep 10; done
    echo "File $STATUS_FILE found!!! Moving on.";
    ##"provision_ccserver.fail.status_$CMD_UNIQUE_ID"
}

function wait_cce_configuration_done(){
    CMD_UNIQUE_ID=$1
    if [ "x$CMD_UNIQUE_ID" != "x" ]; then
        CMD_UNIQUE_ID="_$CMD_UNIQUE_ID"
    fi
    STATUS_FILE="/tmp/configure_ccserver.done.status$CMD_UNIQUE_ID"
    while [ ! -f $STATUS_FILE  ]; do echo "File $STATUS_FILE not found - configure_ccserver still in progress - Sleeping for 10 seconds."; sleep 10; done
    echo "File $STATUS_FILE found!!! Moving on.";
}