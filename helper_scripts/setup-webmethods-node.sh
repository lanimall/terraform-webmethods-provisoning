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