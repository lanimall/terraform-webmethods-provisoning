#!/usr/bin/env bash

##before we log everything...
echo "export CC_PASSWORD=\"${cc_password}\"" > /home/${default_linuxuser}/setenv_cce_init_secrets.sh
echo "export CC_SAG_REPO_USR=\"${webmethods_repo_username}\"" >> /home/${default_linuxuser}/setenv_cce_init_secrets.sh
echo "export CC_SAG_REPO_PWD=\"${webmethods_repo_password}\"" >> /home/${default_linuxuser}/setenv_cce_init_secrets.sh
echo "export CC_SSH_KEY_FILENAME=\"${webmethods_cc_ssh_key_filename}\"" >> /home/${default_linuxuser}/setenv_cce_init_secrets.sh
echo "export CC_SSH_KEY_PWD=\"${webmethods_cc_ssh_key_pwd}\"" >> /home/${default_linuxuser}/setenv_cce_init_secrets.sh
echo "export CC_SSH_USER=\"${webmethods_cc_ssh_user}\"" >> /home/${default_linuxuser}/setenv_cce_init_secrets.sh

echo "export CC_PASSWORD=\"\"" > /home/${default_linuxuser}/setenv_cce_remove_secrets.sh
echo "export CC_SAG_REPO_USR=\"\"" >> /home/${default_linuxuser}/setenv_cce_remove_secrets.sh
echo "export CC_SAG_REPO_PWD=\"\"" >> /home/${default_linuxuser}/setenv_cce_remove_secrets.sh
echo "export CC_SSH_KEY_FILENAME=\"\"" >> /home/${default_linuxuser}/setenv_cce_remove_secrets.sh
echo "export CC_SSH_KEY_PWD=\"\"" >> /home/${default_linuxuser}/setenv_cce_remove_secrets.sh
echo "export CC_SSH_USER=\"\"" >> /home/${default_linuxuser}/setenv_cce_remove_secrets.sh

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

# Install updates
yum update -y

## format and mount the volume for softwareag installation
mkfs -t ext4 /dev/xvdf
mkdir /opt/softwareag
mount /dev/xvdf /opt/softwareag
echo /dev/xvdf  /opt/softwareag ext4 defaults,nofail 0 2 >> /etc/fstab
chown -R ec2-user:ec2-user /opt/softwareag

# Allow the ec2-user to sudo without a tty, which is required when we run post
# install scripts on the server.
echo Defaults:ec2-user \!requiretty >> /etc/sudoers

#write final notification file in tmp
touch /tmp/intial_provisoning_done