#!/usr/bin/env bash

##CCE install and configure -- done at initial step instead
#nohup /bin/bash ./cce-install-configure.sh > ~/nohup-cce-install-configure.log 2>&1 &

##wM products install and configure
nohup /bin/bash ./inventory-install.sh > ~/nohup-inventory-install.log 2>&1 &

echo "Done!"