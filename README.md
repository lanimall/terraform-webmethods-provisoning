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

## webMethods Licensing - Preparing the license package

Before running the provisoning, you'll need to ZIP package all the product licenses you have (or plan on using for this demo) so it can be shipped to the TO-BE provisionned Command Central server.

The Terraform variable "webmethods_license_zip_path" will prompt you for the local path to that license ZIP package.
When the Terraform provisoning runs, it will copy the license package to the bastion server 
(FYI: Zip file package will be renamed to "sag_licenses.zip" on the server)

## Complete Automated Provisoning

This is for the fully automated provisoning from A to Z without having to touch the keyboard during...

Simply run the following:

```bash
terraform init && terraform apply
```

This will do the following automatically:
 - Ask you about different item related to the installation
 - Install all the servers and related artifacts (VPC, security groups, dns, gateways, etc...) on AWS,
 - Update the OS to latest patches / versiions and other misc initial tasks,
 - Install webMethods Command Central on a special "Bastion" server,
 - Configure webMethods Command Central (register licenses, repositories, and specific credentials),
 - Install multiple products per desired outcome

**Note**:
In the first step "Ask you about different item related to the installation", it is possible to have all the questions "answered" automatically by setting up the right environment variables in your shell...
Check [Terraform Docs about Environment Variables](https://www.terraform.io/docs/commands/environment-variables.html#tf_var_name) for more info.

IF you chose to do this, here are the variables you'd need to set for a complete question-less start:
```
export TF_VAR_webmethods_cc_password= <password you want to set for command central ui and all spm communications>
export TF_VAR_webmethods_repo_username= <username to access the empower repo>
export TF_VAR_webmethods_repo_password= <password for empower user>
export TF_VAR_webmethods_license_zip_path= <full path to a softwareag license zip file package>
export TF_VAR_webmethods_integration_license_key_alias= <license key alias for integration server>
export TF_VAR_webmethods_universalmessaging_license_key_alias= <license key alias for universal messaging>
export TF_VAR_webmethods_terracotta_license_key_alias= <license key alias for terracotta>
```

**Important**: When the Terraform command ends, that means all the infrastructure has been created, and webMethods Command Central has been installed and configured. 
BUT know that the actual webMethods product provisoning is still under way...
Only after some extra time (10s of minutes depending on your infrastructure, network, etc...), all will be installed and running as planned.

In the meantime, as soon as Terraform scripts end, you should be able to open wM Command Central:
```
open https://$(terraform output bastion-public_ip):8091/cce/web/
```

After logging in to the Command Central Web UI, you should see provisoning jobs still running, as explained above.
OR if all done, you should see the various product instances (IS, UM, Terracotta) installed and running.

*After the full installation is complete*, there are couple of setup items to run as root.
Let's manually run the post install script on all the newly provisonned servers:

```
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) ssh integration1.webmethods.local
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) ssh terracotta1.webmethods.local
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) ssh universalmessaging1.webmethods.local
```

And that's it!

Integration Server Admin UI is at:
```
open http://$(terraform output webmethods_integration1-public_ip):5555
```

**Extra info**:

To administer the newly created servers, you can SSH to the bastion like so:
```
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip)
```

From there, you can SSH to any of the servers via their internal DNS name:
```
ssh integration1.webmethods.local
ssh terracotta1.webmethods.local
ssh universalmessaging1.webmethods.local
```

## Semi-Manual Provisoning Steps-By-Steps

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
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_integration1-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_integration1-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_integration1-private_ip) >> ~/.ssh/known_hosts" && \
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_universalmessaging1-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_universalmessaging1-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_universalmessaging1-private_ip) >> ~/.ssh/known_hosts" && \
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_terracotta1-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_terracotta1-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output webmethods_terracotta1-private_ip) >> ~/.ssh/known_hosts" && \
scp ./helper_scripts/id_rsa $(terraform output amiuser)@$(terraform output bastion-public_ip):~/.ssh/ && \
echo DONE!
```

That's it! The infrastructure is ready.
There are some post-provisoning scripts that are running after the AWS nodes are up...so leave about five minutes for everything to start up fully.
To be sure, you can check the provisoning logs on each node...eg. on the bastion:
```
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "tail -f /var/log/user-data.log"
```

You should also be able to SSH login to the bastion at this point:
```
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip)
```

### Run webMethods Command Central Provisioning

If all went well, The terraform scripts should have copied the necessary files to the bastion server...and 
you should see the following files in the HOME of the "amiuser" by running:

```
ssh $(terraform output amiuser)@$(terraform output bastion-public_ip) "ls -al"
```
 - bootstrap-complete.sh
 - cce-install-configure.sh
 - delenv_cce_secrets.sh
 - inventory-install.sh
 - inventory-setenv.sh
 - sag_licenses.zip
 - setenv_cce_devops.sh
 - setenv_cce_secrets.sh


Now, since all the relevant files are there, we can run the Command Central install scripts (since the script will run for a little while, I like to use nohup just in case I lose the connectivity to the server...)

```
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "nohup /bin/bash cce-install-configure.sh > nohup-cce-install-configure.log 2>&1 &"
```

NOTE: Be patient...this will take some time...

To check how the script is doing:
```
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "tail -f ~/nohup-cce-install-configure.log"
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

### Run webMethods Products Provisioning

From there, we can now run the inventory provisoning:

```
ssh $(terraform output amiuser)@$(terraform output bastion-public_ip) "nohup /bin/bash ~/cce-inventory-install.sh > nohup-cce-inventory-install.log 2>&1 &"
```

NOTE: Be patient...this will take some time...Command Central at work installing multiple servers

To check how the script is doing:
```
ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) "tail -f ~/nohup-inventory-install.log"
```

### Post Install

After the installation, there are couple of setup items to run as root... Let's run the post install script on all the newly provisonned servers:

```
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) ssh integration1.webmethods.local
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) ssh terracotta1.webmethods.local
cat ./helper_scripts/postinstall-webmethods-node.sh | ssh -A $(terraform output amiuser)@$(terraform output bastion-public_ip) ssh universalmessaging1.webmethods.local
```