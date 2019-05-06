#!/usr/bin/env bash

# Note: This script must run after the install in order to install auto-start services etc...
sudo su

SPM_INSTALL_DIR=/opt/softwareag

/bin/sh $SPM_INSTALL_DIR/bin/afterInstallAsRoot.sh

echo "Restarting host..."
shutdown -r now "restarting node post install"

exit 0;