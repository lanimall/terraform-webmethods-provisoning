#!/usr/bin/env bash

# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

mkdir -p /etc/aws/
cat > /etc/aws/aws.conf <<- EOF
[Global]
Zone = ${availability_zone}
EOF

# Create initial logs config.
cat > ./awslogs.conf <<- EOF
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/messages]
log_stream_name = webmethods-node-{instance_id}
log_group_name = /var/log/messages
file = /var/log/messages
datetime_format = %b %d %H:%M:%S
buffer_duration = 5000
initial_position = start_of_file

[/var/log/user-data.log]
log_stream_name = webmethods-node-{instance_id}
log_group_name = /var/log/user-data.log
file = /var/log/user-data.log
EOF

# Install java
yum install -y java-1.8.0-openjdk-headless

# Install updates
yum update -y

##check target user
getent passwd ${webmethods_linuxuser} > /dev/null
if [ $? -eq 0 ]; then
    echo "${webmethods_linuxuser} user exists"
else
    echo "${webmethods_linuxuser} user does not exist...creating"
    useradd ${webmethods_linuxuser}
    passwd -l ${webmethods_linuxuser}

    mkdir /home/${webmethods_linuxuser}/.ssh
    chmod 700 /home/${webmethods_linuxuser}/.ssh
    touch /home/${webmethods_linuxuser}/.ssh/authorized_keys
    chmod 600 /home/${webmethods_linuxuser}/.ssh/authorized_keys
    echo "${ssh_public_key}" > /home/${webmethods_linuxuser}/.ssh/authorized_keys

    chown -R ${webmethods_linuxuser}:${webmethods_linuxuser} /home/${webmethods_linuxuser}/.ssh
fi

## creating target directory if needed
if [ ! -d ${webmethods_path} ]; then
    echo "creating install directory"
    mkdir ${webmethods_path}
fi

## format and mount the volume for softwareag installation
mkfs -t ext4 /dev/xvdf
mount /dev/xvdf ${webmethods_path}
echo /dev/xvdf ${webmethods_path} ext4 defaults,nofail 0 2 >> /etc/fstab

## applying user/group on the target directory
if [ -d ${webmethods_path} ]; then
    chown -R ${webmethods_linuxuser}:${webmethods_linuxuser} ${webmethods_path}
fi

# Allow the default_linuxuser to sudo without a tty, which is required when we run post
# install scripts on the server.
echo Defaults:${default_linuxuser} \!requiretty >> /etc/sudoers

#write final notification file in tmp
touch /tmp/initial_provisioning_done