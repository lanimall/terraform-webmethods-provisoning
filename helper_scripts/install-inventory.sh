#!/usr/bin/env bash

# wait until the userdata provisoning is done
while [ ! -f /tmp/intial_provisoning_done ]; do sleep 10; done

## apply env
if [ -f ${HOME}/cce-inventory.sh ]; then
    echo "applying inventory file to the shell"
    . ${HOME}/cce-inventory.sh
fi

cd ${HOME}/webMethods-devops-provisioning

# Install IS
export TARGET_HOST=$webmethods_integration1
./scripts/provision_is_stateless.sh