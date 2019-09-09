#!/usr/bin/env bash

##before we log everything...
echo "export CC_PASSWORD=\"${cc_password}\"" > /home/${default_linuxuser}/setenv_cce_secrets.sh
echo "export CC_SAG_REPO_USR=\"${webmethods_repo_username}\"" >> /home/${default_linuxuser}/setenv_cce_secrets.sh
echo "export CC_SAG_REPO_PWD=\"${webmethods_repo_password}\"" >> /home/${default_linuxuser}/setenv_cce_secrets.sh
echo "export CC_SSH_KEY_FILENAME=\"${webmethods_cc_ssh_key_filename}\"" >> /home/${default_linuxuser}/setenv_cce_secrets.sh
echo "export CC_SSH_KEY_PWD=\"${webmethods_cc_ssh_key_pwd}\"" >> /home/${default_linuxuser}/setenv_cce_secrets.sh
echo "export CC_SSH_USER=\"${webmethods_linuxuser}\"" >> /home/${default_linuxuser}/setenv_cce_secrets.sh

echo "export CC_PASSWORD=\"\"" > /home/${default_linuxuser}/delenv_cce_secrets.sh
echo "export CC_SAG_REPO_USR=\"\"" >> /home/${default_linuxuser}/delenv_cce_secrets.sh
echo "export CC_SAG_REPO_PWD=\"\"" >> /home/${default_linuxuser}/delenv_cce_secrets.sh
echo "export CC_SSH_KEY_FILENAME=\"\"" >> /home/${default_linuxuser}/delenv_cce_secrets.sh
echo "export CC_SSH_KEY_PWD=\"\"" >> /home/${default_linuxuser}/delenv_cce_secrets.sh
echo "export CC_SSH_USER=\"\"" >> /home/${default_linuxuser}/delenv_cce_secrets.sh

echo "export CCE_DEVOPS_INSTALL_DIR=\"${cc_devops_install_dir}\"" >> /home/${default_linuxuser}/setenv_cce_devops.sh
echo "export CCE_DEVOPS_INSTALL_USER=\"${cc_devops_install_user}\"" >> /home/${default_linuxuser}/setenv_cce_devops.sh

# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

mkdir -p /etc/aws/
cat > /etc/aws/aws.conf <<- EOF
[Global]
Zone = ${availability_zone}
EOF

# Create initial logs config.
cat > ./awslogs.conf << EOF
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/messages]
log_stream_name = webmethods-bastion-{instance_id}
log_group_name = /var/log/messages
file = /var/log/messages
datetime_format = %b %d %H:%M:%S
buffer_duration = 5000
initial_position = start_of_file

[/var/log/user-data.log]
log_stream_name = webmethods-bastion-{instance_id}
log_group_name = /var/log/user-data.log
file = /var/log/user-data.log
EOF

# Install epel
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install dev tools.
yum install -y "@Development Tools" java-1.8.0-openjdk-headless

# Install inotify tool to be able to listen to file (useful to know when to start next phases based on file updates)
yum install -y inotify-tools

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