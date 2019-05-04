#!/usr/bin/env bash

# wait until the userdata provisoning is done
while [ ! -f /tmp/intial_provisoning_done ]; do sleep 10; done

## apply env
if [ -f ${HOME}/inventory-setenv.sh ]; then
    echo "applying inventory to the shell"
    . ${HOME}/inventory-setenv.sh
fi

cd ${HOME}/webMethods-devops-provisioning

# Install Unniversal Messaging
export TARGET_HOST=${webmethods_universalmessaging1}
export LICENSE_KEY_ALIAS1=${webmethods_universalmessaging_license_key_alias}
./scripts/provision_um.sh

# Install Terracotta
#export TARGET_HOST=${webmethods_terracotta1}
#export LICENSE_KEY_ALIAS1=${webmethods_terracotta_license_key_alias}
#./scripts/provision_tc.sh

# Install Integration Server
#export TARGET_HOST=$webmethods_integration1
#export LICENSE_KEY_ALIAS1=${webmethods_integration_license_key_alias}
#./scripts/provision_is_stateless.sh