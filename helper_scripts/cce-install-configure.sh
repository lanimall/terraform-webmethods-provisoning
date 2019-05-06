#!/usr/bin/env bash

# wait until the userdata provisoning is done
while [ ! -f /tmp/intial_provisioning_done ]; do echo "Initial Server provisoning still in progress...Sleeping for 10 seconds."; sleep 10; done

# clone webmethods provisoning project
/bin/git clone --recursive -b rel103 https://github.com/lanimall/webMethods-devops-provisioning.git
cd ${HOME}/webMethods-devops-provisioning

## apply env
if [ -f ${HOME}/setenv_cce_init_secrets.sh ]; then
    . ${HOME}/setenv_cce_init_secrets.sh
fi

# Install command central
./scripts/provision_ccserver.sh

# Configure command central
./scripts/configure_ccserver.sh

#mark the end of the script
touch /tmp/cce_provisioning_done

## clear env
# if [ -f ${HOME}/setenv_cce_remove_secrets.sh ]; then
#     . ${HOME}/setenv_cce_remove_secrets.sh
#     rm -f ${HOME}/setenv_cce_remove_secrets.sh
# fi

# if [ -f ${HOME}/setenv_cce_init_secrets.sh ]; then
#     rm -f ${HOME}/setenv_cce_init_secrets.sh
# fi