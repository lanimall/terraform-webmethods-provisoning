#!/usr/bin/env bash

# wait until the userdata provisoning is done
while [ ! -f /tmp/intial_provisoning_done ]; do sleep 10; done

# clone webmethods provisoning project
/bin/git clone --recursive -b rel103 https://github.com/lanimall/webMethods-devops-provisioning.git
cd ${HOME}/webMethods-devops-provisioning

## apply env
if [ -f ${HOME}/setenv_cce_init_secrets.sh ]; then
    . ${HOME}/setenv_cce_init_secrets.sh
fi

## apply env
if [ -f ${HOME}/setenv_inventory.sh ]; then
    . ${HOME}/setenv_inventory.sh
fi

# Run the install steps

# 1 - Install command central
./scripts/provision_ccserver.sh

# 2 - Configure command central
./scripts/configure_ccserver.sh

## clear env
# if [ -f ${HOME}/setenv_cce_remove_secrets.sh ]; then
#     . ${HOME}/setenv_cce_remove_secrets.sh
#     rm -f ${HOME}/setenv_cce_remove_secrets.sh
# fi

# if [ -f ${HOME}/setenv_cce_init_secrets.sh ]; then
#     rm -f ${HOME}/setenv_cce_init_secrets.sh
# fi