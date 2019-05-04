#!/usr/bin/env bash

# wait until the userdata provisoning is done
while [ ! -f /tmp/intial_provisoning_done ]; do sleep 10; done

cd ${HOME}/webMethods-devops-provisioning

## apply env
if [ -f ${HOME}/setenv_cce_init_secrets.sh ]; then
    . ${HOME}/setenv_cce_init_secrets.sh
fi

# Configure command central
./scripts/configure_ccserver.sh