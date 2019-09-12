#!/usr/bin/env bash

##get the params passed-in
BOOTSTRAP_INSTALL_CCE=$1
BOOTSTRAP_CONFIGURE_CCE=$2
BOOTSTRAP_CCE_INSTALL_PRODUCTS=$3
CMD_UNIQUE_ID=$4

if [ "x$BOOTSTRAP_INSTALL_CCE" = "x" ]; then
    BOOTSTRAP_INSTALL_CCE="${execute_cce_install}"
fi

if [ "x$BOOTSTRAP_CONFIGURE_CCE" = "x" ]; then
    BOOTSTRAP_CONFIGURE_CCE="${execute_cce_config}"
fi

if [ "x$BOOTSTRAP_CCE_INSTALL_PRODUCTS" = "x" ]; then
    BOOTSTRAP_CCE_INSTALL_PRODUCTS="${execute_cce_products_install}"
fi

if [ "x$CMD_UNIQUE_ID" = "x" ]; then
    CMD_UNIQUE_ID="${unique_id}"
fi

## apply common functions
if [ -f $HOME/common.sh ]; then
    . $HOME/common.sh
fi

echo "Bootstrapping SoftwareAG webMethods Provisioning"
wait_server_provisioning_done $CMD_UNIQUE_ID

if [ "$BOOTSTRAP_INSTALL_CCE" = "true" ]; then
    echo "Executing the CCE installation phase."
    nohup /bin/bash ~/cce-install-configure.sh "true" "false" $CMD_UNIQUE_ID > ~/nohup-bootstrap-cce-install.log 2>&1 &
else
    echo "Not executing the CCE installation phase."
fi

if [ "$BOOTSTRAP_CONFIGURE_CCE" = "true" ]; then
    echo "Executing the CCE configuration phase."
    nohup /bin/bash ~/cce-install-configure.sh "false" "true" $CMD_UNIQUE_ID > ~/nohup-bootstrap-cce-configure.log 2>&1 &
else
    echo "Not executing the CCE configuration phase."
fi

if [ "$BOOTSTRAP_CCE_INSTALL_PRODUCTS" = "true" ]; then
    echo "Executing the CCE wM Products Installation phase."
    nohup /bin/bash ~/cce-inventory-install.sh $CMD_UNIQUE_ID > ~/nohup-bootstrap-cce-inventory-install.log 2>&1 &
else
    echo "Not executing the CCE wM Products Installation phase."
fi

echo "Done!"