#!/usr/bin/env bash

##wM products install and configure
nohup /bin/bash ./inventory-install.sh > ~/nohup-inventory-install.log 2>&1 &

echo "Done!"