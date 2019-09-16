#!/usr/bin/env bash

##before we log everything...
echo "export CC_PASSWORD=\"${cc_password}\"" > /home/${default_linuxuser}/.setenv_cce_secrets.sh
echo "export CC_SAG_REPO_USR=\"${webmethods_repo_username}\"" >> /home/${default_linuxuser}/.setenv_cce_secrets.sh
echo "export CC_SAG_REPO_PWD=\"${webmethods_repo_password}\"" >> /home/${default_linuxuser}/.setenv_cce_secrets.sh
echo "export CC_SSH_KEY_FILENAME=\"${webmethods_cc_ssh_key_filename}\"" >> /home/${default_linuxuser}/.setenv_cce_secrets.sh
echo "export CC_SSH_KEY_PWD=\"${webmethods_cc_ssh_key_pwd}\"" >> /home/${default_linuxuser}/.setenv_cce_secrets.sh
echo "export CC_SSH_USER=\"${webmethods_linuxuser}\"" >> /home/${default_linuxuser}/.setenv_cce_secrets.sh

echo "export CC_PASSWORD=\"\"" > /home/${default_linuxuser}/.delenv_cce_secrets.sh
echo "export CC_SAG_REPO_USR=\"\"" >> /home/${default_linuxuser}/.delenv_cce_secrets.sh
echo "export CC_SAG_REPO_PWD=\"\"" >> /home/${default_linuxuser}/.delenv_cce_secrets.sh
echo "export CC_SSH_KEY_FILENAME=\"\"" >> /home/${default_linuxuser}/.delenv_cce_secrets.sh
echo "export CC_SSH_KEY_PWD=\"\"" >> /home/${default_linuxuser}/.delenv_cce_secrets.sh
echo "export CC_SSH_USER=\"\"" >> /home/${default_linuxuser}/.delenv_cce_secrets.sh

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
yum install -y "@Development Tools" java-1.8.0-openjdk-headless bind-utils

# Install inotify tool to be able to listen to file (useful to know when to start next phases based on file updates)
yum install -y inotify-tools

function check_dns_record(){
    COUNTER=0
    DNS_RECORD=$1
    DNS_MAXTRIES=$2
    DNS_INTERVAL=$3
    while [ "x$(dig +short -t A $DNS_RECORD.)" = "x" ] && [ $COUNTER -lt $DNS_MAXTRIES ]; do
        let COUNTER=COUNTER+1
        echo "Try $COUNTER - trying again in $DNS_INTERVAL sec"
        sleep $DNS_INTERVAL
    done
    dns_record_ip="$(dig +short -t A $DNS_RECORD.)"
}

##check target user
getent passwd ${webmethods_linuxuser} > /dev/null
if [ $? -eq 0 ]; then
    echo "${webmethods_linuxuser} user exists"
else
    echo "${webmethods_linuxuser} user does not exist...creating"
    useradd ${webmethods_linuxuser}
    passwd -l ${webmethods_linuxuser}
fi


##add SSH folder to webmethods_linuxuser home as well as the default_linuxuser
if [ ! -d /home/${default_linuxuser}/.ssh ]; then
    mkdir /home/${default_linuxuser}/.ssh
    chmod 700 /home/${default_linuxuser}/.ssh
    chown ${default_linuxuser}:${default_linuxuser} /home/${default_linuxuser}/.ssh
fi

if [ "x${webmethods_linuxuser}" != "x${default_linuxuser}" ]; then
    if [ ! -d /home/${webmethods_linuxuser}/.ssh ]; then
        mkdir /home/${webmethods_linuxuser}/.ssh
        chmod 700 /home/${webmethods_linuxuser}/.ssh
        chown ${webmethods_linuxuser}:${webmethods_linuxuser} /home/${webmethods_linuxuser}/.ssh
    fi
fi

##add private key to the webmethods_linuxuser home as well as the default_linuxuser
echo "${ssh_private_key}" > /home/${default_linuxuser}/.ssh/id_rsa
chmod 600 /home/${default_linuxuser}/.ssh/id_rsa
chown ${default_linuxuser}:${default_linuxuser} /home/${default_linuxuser}/.ssh/id_rsa
if [ "x${webmethods_linuxuser}" != "x${default_linuxuser}" ]; then
    echo "${ssh_private_key}" > /home/${webmethods_linuxuser}/.ssh/id_rsa
    chmod 600 /home/${webmethods_linuxuser}/.ssh/id_rsa
    chown ${webmethods_linuxuser}:${webmethods_linuxuser} /home/${webmethods_linuxuser}/.ssh/id_rsa
fi

##add known hosts to the webmethods_linuxuser home
touch /home/${default_linuxuser}/.ssh/known_hosts
chown ${default_linuxuser}:${default_linuxuser} /home/${default_linuxuser}/.ssh/known_hosts 
if [ "x${webmethods_linuxuser}" != "x${default_linuxuser}" ]; then
    touch /home/${webmethods_linuxuser}/.ssh/known_hosts
    chown ${webmethods_linuxuser}:${webmethods_linuxuser} /home/${webmethods_linuxuser}/.ssh/known_hosts 
fi

check_dns_record ${ssh_known_host1_dnsname} 10 5
if [ "x$dns_record_ip" != "x" ]; then
    ssh-keyscan -t rsa -H ${ssh_known_host1_dnsname} >> /home/${default_linuxuser}/.ssh/known_hosts
    ssh-keyscan -t rsa -H $dns_record_ip >> /home/${default_linuxuser}/.ssh/known_hosts
    if [ "x${webmethods_linuxuser}" != "x${default_linuxuser}" ]; then
        ssh-keyscan -t rsa -H ${ssh_known_host1_dnsname} >> /home/${webmethods_linuxuser}/.ssh/known_hosts
        ssh-keyscan -t rsa -H $dns_record_ip >> /home/${webmethods_linuxuser}/.ssh/known_hosts
    fi
fi

check_dns_record ${ssh_known_host2_dnsname} 10 5
if [ "x$dns_record_ip" != "x" ]; then
    ssh-keyscan -t rsa -H ${ssh_known_host2_dnsname} >> /home/${default_linuxuser}/.ssh/known_hosts
    ssh-keyscan -t rsa -H $dns_record_ip >> /home/${default_linuxuser}/.ssh/known_hosts
    if [ "x${webmethods_linuxuser}" != "x${default_linuxuser}" ]; then
        ssh-keyscan -t rsa -H ${ssh_known_host2_dnsname} >> /home/${webmethods_linuxuser}/.ssh/known_hosts
        ssh-keyscan -t rsa -H $dns_record_ip >> /home/${webmethods_linuxuser}/.ssh/known_hosts
    fi
fi

check_dns_record ${ssh_known_host3_dnsname} 10 5
if [ "x$dns_record_ip" != "x" ]; then
    ssh-keyscan -t rsa -H ${ssh_known_host3_dnsname} >> /home/${default_linuxuser}/.ssh/known_hosts
    ssh-keyscan -t rsa -H $dns_record_ip >> /home/${default_linuxuser}/.ssh/known_hosts
    if [ "x${webmethods_linuxuser}" != "x${default_linuxuser}" ]; then
        ssh-keyscan -t rsa -H ${ssh_known_host3_dnsname} >> /home/${webmethods_linuxuser}/.ssh/known_hosts
        ssh-keyscan -t rsa -H $dns_record_ip >> /home/${webmethods_linuxuser}/.ssh/known_hosts
    fi
fi

########### webmethod install section

## creating target directory if needed
if [ ! -d ${webmethods_path} ]; then
    echo "creating install directory"
    mkdir -p ${webmethods_path}
fi

## format and mount the volume for softwareag installation
mkfs -t ext4 /dev/xvdf
mount /dev/xvdf ${webmethods_path}
echo /dev/xvdf ${webmethods_path} ext4 defaults,nofail 0 2 >> /etc/fstab

## applying user/group on the target directory
if [ -d ${webmethods_path} ]; then
    chown -R ${webmethods_linuxuser}:${webmethods_linuxuser} ${webmethods_path}
fi

########### CCE code section

## creating target directory for the code
if [ ! -d ${cc_devops_install_dir} ]; then
    echo "Directory [${cc_devops_install_dir}] does not exist - Creating..."
    mkdir -p ${cc_devops_install_dir}
fi

# clone webmethods provisoning project
echo "Getting the webMethods-devops-provisioning project from github and putting in ${cc_devops_install_dir}"
/bin/git clone --recursive -b rel103 https://github.com/lanimall/webMethods-devops-provisioning.git ${cc_devops_install_dir}

## applying user/group on the target directory
echo "Applying user ${webmethods_linuxuser} ownership on the target directory ${cc_devops_install_dir}"
chown -R ${webmethods_linuxuser}:${webmethods_linuxuser} ${cc_devops_install_dir}

########### useful files to copy to the webmethods_linuxuser home 

##move the provisoning "secrets" in the home of the target webmethods_linuxuser user so the provisoning scripts can use it
if [ "x${webmethods_linuxuser}" != "x${default_linuxuser}" ]; then
    echo "Copying the provisoning secrets in the home of the target user ${webmethods_linuxuser}"
    cp -f /home/${default_linuxuser}/.setenv_cce_secrets.sh /home/${webmethods_linuxuser}/.setenv_cce_secrets.sh
fi

##move the product licenses package in the home of the target webmethods_linuxuser user so the provisoning scripts can use it
if [ "x${webmethods_linuxuser}" != "x${default_linuxuser}" ]; then
    LICENSE_FILE="/home/${default_linuxuser}/sag_licenses.zip"
    while [ ! -f $LICENSE_FILE  ]; do echo "File $LICENSE_FILE not found - Sleeping for 10 seconds."; sleep 10; done
    echo "File $LICENSE_FILE found!!!";
    echo "Copying the product licenses package in the home of the target user $webmethods_linuxuser"
    cp -f $LICENSE_FILE /home/${webmethods_linuxuser}/sag_licenses.zip
fi

# Allow the default_linuxuser to sudo without a tty, which is required when we run post
# install scripts on the server.
echo Defaults:${default_linuxuser} \!requiretty >> /etc/sudoers

# Install updates
yum update -y

#write final notification file in tmp
touch /tmp/initial_provisioning_done