#!/usr/bin/env bash

# wait until the userdata provisoning is done

# check dependencies
if ! type inotifywait &>/dev/null ; then
	echo "You are missing the inotifywait dependency. Install the package inotify-tools (apt-get install inotify-tools)"
	exit 1
fi

echo "Starting configure of SoftwareAG webMethods Command Central"

inotifywait -e close_write,moved_to,create -m /tmp |
while read -r directory events filename; do
  if [ "$filename" = "initial_provisioning_done" ]; then
    echo "initial_provisioning_done!!!";
  fi
done

inotifywait -e close_write,moved_to,create -m /tmp |
while read -r directory events filename; do
  if [ "$filename" = "cce_provisioning_done" ]; then
    echo "cce_provisioning_done!!!";
  fi
done

inotifywait -e close_write,moved_to,create -m /tmp |
while read -r directory events filename; do
  if [ "$filename" = "cce_configuration_done" ]; then
    echo "cce_configuration_done!!!";
  fi
done