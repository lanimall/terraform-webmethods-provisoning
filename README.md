# terraform-webmethods-provisoning

Demo project that leverages terraform and softwareAG Command Central for creating a complete webmethods infrastructure

This project works closely with project [webMethods-devops-provisioning]https://github.com/lanimall/webMethods-devops-provisioning.git which takes care of the actual provisoning of the webMethods products.

The terraform portion will automatically create the infrastructure on AWS, as well as bootstrap the actual webMethods product provisoning outlined in [webMethods-devops-provisioning]https://github.com/lanimall/webMethods-devops-provisioning.git

## Prerequisites

You need:

1. [Terraform](https://www.terraform.io/intro/getting-started/install.html) - `brew update && brew install terraform`
2. An AWS account, configured with the cli locally

## Get the code and initial setup

Run the following commands to get the terraform code, generate the ssh keys we'll need, and fix the permissions on the keys

```
git clone https://github.com/lanimall/terraform-webmethods-provisoning.git
cd ./terraform-webmethods-provisoning
ssh-keygen -b 2048 -t rsa -f ./helper_scripts/id_rsa_bastion -q -N ""
ssh-keygen -b 2048 -t rsa -f ./helper_scripts/id_rsa -q -N ""
chmod 600 ./helper_scripts/id_rsa*
```

Then, add the ssh key to the local agent for easy remote connecting:
```
ssh-add ./helper_scripts/id_rsa_bastion
```

## Complete Automated Provisoning

This is for the fully automated provisoning from A to Z without having to touch the keyboard during...

TBD

## Manual Steps-By-Steps 

This is for the semi-manual steps-by-steps...mostly for deeper understanding of the various pieces involved.

### Creating the Infrastructure

Create the infrastructure first (use  "-auto-approve" if you want to do it all in one shot)

```bash
terraform init && terraform apply
```

After a little while, all AWS infrastructure should have been created...you should see:

```
...
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
```

Couple of output variables that you can reference later using notation  'terraform output <output>':
 - bastion-private_dns
 - bastion-private_ip
 - bastion-public_ip
 - webmethods_commandcentral-private_dns
 - webmethods_commandcentral-private_ip
 - webmethods_commandcentral-private_route53_dns
 - webmethods_commandcentral-public_ip
 - webmethods_integration1-private_dns
 - webmethods_integration1-private_ip
 - webmethods_integration1-private_route53_dns
 - webmethods_integration1-public_ip

### Setup Connectivity to the infrastructure

Let's add the inter-node SSH key to the bastion and the various hosts to the known-host on the bastion:

```
ssh-keyscan -t rsa -H $(terraform output bastion-public_ip) >> ~/.ssh/known_hosts && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_integration1-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_integration1-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_integration1-private_ip) >> ~/.ssh/known_hosts" && \
scp ./helper_scripts/id_rsa ec2-user@$(terraform output bastion-public_ip):~/.ssh/ && \
echo DONE!
```

That's it! The infrastructure is ready.
There are some post-provisoning scripts that are running after the AWS nodes are up...so leave about five minutes for everything to start up fully.
To be sure, you can check the provisoning logs on each node...eg. on the bastion:
```
ssh -A ec2-user@$(terraform output bastion-public_ip) "tail -f /var/log/user-data.log"
```

You should also be able to SSH login to the bastion at this point:
```
ssh -A ec2-user@$(terraform output bastion-public_ip)
```

### Run webMethods Command Central Provisoning

Run the install script:
```
cat ./helper_scripts/install-cce.sh | ssh -A ec2-user@$(terraform output bastion-public_ip)
```

OR alternatively, you could copy the script to the bastion server and then run it there (eg. if you want to run it all in the background using nohup for example) 
```
scp ./helper_scripts/install-cce.sh ec2-user@$(terraform output bastion-public_ip):~/
ssh ec2-user@$(terraform output bastion-public_ip)
nohup /bin/bash install-cce.sh > nohup-install-cce.log &
```

NOTE: Be patient...this will take 10s of minutes: ansible at work!!!

At the end, command central should be running and accessible:
```
open https://$(terraform output bastion-public_ip):8091/cce/web/
```

### Run webMethods Products Provisoning

```
nohup /bin/bash install-inventory.sh > nohup-inventory.log &
```

