#!/usr/bin/env bash

##get the params passed-in
BOOTSTRAP_INSTALL_CCE="${execute_cce_install}"
BOOTSTRAP_CONFIGURE_CCE="${execute_cce_config}"
BOOTSTRAP_CCE_INSTALL_PRODUCTS="${execute_cce_products_install}"
CMD_UNIQUE_ID="${unique_id}"

## apply common functions
if [ -f $HOME/common.sh ]; then
    . $HOME/common.sh
fi

echo "Bootstrapping SoftwareAG webMethods Provisioning"

if [ "$BOOTSTRAP_INSTALL_CCE" = "true" ]; then
    echo "Executing the CCE installation phase."
    wait_server_provisoning_done $CMD_UNIQUE_ID
    nohup /bin/bash ~/cce-install-configure.sh "true" "true" "false" $CMD_UNIQUE_ID > ~/nohup-bootstrap-cce-install.log 2>&1 &
else
    echo "Not executing the CCE installation phase."
fi

if [ "$BOOTSTRAP_CONFIGURE_CCE" = "true" ]; then
    echo "Executing the CCE configuration phase."
    wait_server_provisoning_done $CMD_UNIQUE_ID
    nohup /bin/bash ~/cce-install-configure.sh "false" "false" "true" $CMD_UNIQUE_ID > ~/nohup-bootstrap-cce-configure.log 2>&1 &
else
    echo "Not executing the CCE configuration phase."
fi

if [ "$BOOTSTRAP_CCE_INSTALL_PRODUCTS" = "true" ]; then
    echo "Executing the CCE wM Products Installation phase."
    wait_server_provisoning_done $CMD_UNIQUE_ID
    nohup /bin/bash ~/cce-inventory-install.sh $CMD_UNIQUE_ID > ~/nohup-bootstrap-cce-inventory-install.log 2>&1 &
else
    echo "Not executing the CCE wM Products Installation phase."
fi

echo "Done!"