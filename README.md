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

Simply run the following:

```bash
terraform init && terraform apply
```

This will do the following automatically:
 - Install all the servers and related artifacts (VPC, security groups, dns, gateways, etc...) on AWS,
 - Update the OS to latest patches / versiions and other misc initial tasks,
 - Install webMethods Command Central on a special "Bastion" server,
 - Configure webMethods Command Central (register licenses, repositories, and specific credentials),
 - Install multiple products per desired outcome

**Important**: When the Terraform command ends, that means all the infrastructure has been created, and webMethods Command Central has been installed and configured. 
BUT know that the actual webMethods product provisoning is still under way...
Only after some extra time (10s of minutes depending on your infrastructure, network, etc...), all will be installed and running as planned.

In the meantime, as soon as Terraform scripts end, you should be able to open wM Command Central:
```
open https://$(terraform output bastion-public_ip):8091/cce/web/
```

After logging in to the Command Central Web UI, you should see provisoning jobs still running, as explained above.
OR if all done, you should see the various product instances (IS, UM, Terracotta) installed and running.

After the installation is complete, there are couple of setup items to run as root... 
Let's manually run the post install script on all the newly provisonned servers:

```
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh integration1.webmethods.local
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh terracotta1.webmethods.local
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh universalmessaging1.webmethods.local
```

and that's it!

**Extra info**:

To administer the newly created servers, you can SSH to the bastion like so:
```
ssh -A ec2-user@$(terraform output bastion-public_ip)
```

From there, you can SSH to any of the servers via their internal DNS name:
```
ssh integration1.webmethods.local
ssh terracotta1.webmethods.local
ssh universalmessaging1.webmethods.local
```

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
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_universalmessaging1-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_universalmessaging1-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_universalmessaging1-private_ip) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_terracotta1-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_terracotta1-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_terracotta1-private_ip) >> ~/.ssh/known_hosts" && \
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

Before running the provisoning, let's add all the product licenses you have (or plan on using for this demo) to the server (Ideally, that would get downloaded automatically by the scripts)

Note: The webMethods provisoning script for command central (the ones in [webMethods-devops-provisioning]https://github.com/lanimall/webMethods-devops-provisioning.git expects a zip file named "sag_licenses.zip" in the user home... So let's follow this standard (you could change this if absolutely needed)
```
scp ~/sag_licenses.zip ec2-user@$(terraform output bastion-public_ip):~/sag_licenses.zip
```

Once the license file is in position, we can run the Command Central install script by copying it to the bastion server and then running it from there (since the script will run for a little while, I like to use nohup just in case I lose the connectivity to the server...)
```
scp ./helper_scripts/cce-install-configure.sh ec2-user@$(terraform output bastion-public_ip):~/
ssh ec2-user@$(terraform output bastion-public_ip) "nohup /bin/bash cce-install-configure.sh > nohup-cce-install-configure.log 2>&1 &"
```

NOTE: Be patient...this will take some time...

To check how the script is doing:
```
ssh -A ec2-user@$(terraform output bastion-public_ip) "tail -f ~/nohup-cce-install-configure.log"
```

At the end, you should see the following in the logs:
```
...
BUILD SUCCESSFUL
Total time: 14 seconds
```

And command central should be running and accessible:
```
open https://$(terraform output bastion-public_ip):8091/cce/web/
```

You should now be able to login to the UI using the Administrator user and the Password you chose at the beginning of the terraform apply step.

Once in, you should now have the following configurations applied and working:
- Registered product repository
- Registered fix repository
- Registered licenses
- Registered passwords

### Run webMethods Products Provisoning

From there, we can now run the inventory provisoning. The following first copy the two inventory scripts to the server...and then run it.

```
scp ./helper_scripts/inventory-setenv.sh ec2-user@$(terraform output bastion-public_ip):~/
scp ./helper_scripts/inventory-install.sh ec2-user@$(terraform output bastion-public_ip):~/
ssh ec2-user@$(terraform output bastion-public_ip) "nohup /bin/bash inventory-install.sh > nohup-inventory-install.log 2>&1 &"
```

ssh ec2-user@$(terraform output bastion-public_ip) "/bin/bash ~/inventory-install.sh"


NOTE: Be patient...this will take some time...Command Central at work installing multiple servers

To check how the script is doing:
```
ssh -A ec2-user@$(terraform output bastion-public_ip) "tail -f ~/nohup-inventory-install.log"
```

### Post Install

After the installation, there are couple of setup items to run as root... Let's run the post install script on all the newly provisonned servers:

```
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh integration1.webmethods.local
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh terracotta1.webmethods.local
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh universalmessaging1.webmethods.local
```