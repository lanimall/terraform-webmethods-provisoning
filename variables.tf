variable "project_name" {
  description = "Project Name"
  default = "SoftwareAG webmethods Cloud Provisoning"
}

variable "resources_name_prefix" {
  description = "Prefix for all resource names"
  default = "SAG_wM_Terraform_Demo"
}

variable "execute_cce_install" {
  description = "If set to true, execute CCE installation on the bastion"
}

variable "execute_cce_config" {
  description = "If set to true, execute CCE configuration on the bastion"
}

variable "execute_cce_products_install" {
  description = "If set to true, execute CCE's remote provisoning of wM products onto the varisou servers"
}

variable "webmethods_bastion_key_name" {
  description = "My secure bastion ssh key name"
  default = "webmethodS_BASTION"
}

variable "webmethods_bastion_key_path_public" {
  description = "My secure bastion ssh public key"
  default = "./helper_scripts/id_rsa_bastion.pub"
}

variable "webmethods_bastion_key_path_private" {
  description = "My secure bastion ssh private key"
  default = "./helper_scripts/id_rsa_bastion"
}

variable "webmethods_nodes_key_name" {
  description = "My node to node ssh key name"
   default = "webmethodS_NODE"
}

variable "webmethods_nodes_key_path_public" {
  description = "My node to node ssh public key"
   default = "./helper_scripts/id_rsa.pub"
}

variable "webmethods_nodes_key_path_private" {
  description = "My node to node ssh private key"
   default = "./helper_scripts/id_rsa"
}

variable "amisize" {
  description = "The default instance sizes"
  default = "t2.large"
}

//22 --> 1024 addresses (mask: 255.255.252.0)
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default = "20.20.0.0/22"
}

//possible 4 subnets of 254 addresses... 20.20.0.0/24, 20.20.1.0/24, 20.20.2.0/24, 20.20.3.0/24
variable "subnet_cidr" {
  description = "The CIDR block for the public subnet"
  default = "20.20.0.0/24"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "azs" {
  default     = "us-east-1a"
}

variable "default_ami" {
  default = ""
}

variable "default_ami_user" {
  description = "The linux user to connect with for the ami"
  default     = ""
}

variable "webmethods_base_path" {
  description = "the base install path for webmethods"
  default     = "/opt/softwareag"
}

variable "webmethods_provisioning_base_path" {
  description = "the base install path for the webmethods provisioning project"
  default     = "/opt/webMethods-devops-provisioning"
}

variable "webmethods_linux_user" {
  description = "the user for webmethods process and the user that command central will use to connect to the remote servers"
  default     = "saguser"
}

###### COMMAND CENTRAL ADMINISTRATOR CREDENTIAL ######
variable "webmethods_cc_password" {
  description = "the default password for command central"
}

###### EMPOWER CREDENTIALS ######
variable "webmethods_repo_username" {
  description = "the username to use for the webMethods remote product repo"
}

variable "webmethods_repo_password" {
  description = "the password for webmethods_repo_username"
}

variable "webmethods_cc_ssh_key_filename" {
  description = "the ssh key filename that will be used by command central to connect to the remote servers - should be in standard <user.home>/.ssh/ folder location"
  default = "id_rsa"
}

variable "webmethods_cc_ssh_key_pwd" {
  description = "the password for the ssh key defined by webmethods_cc_ssh_key_path"
  default = ""
}

variable "webmethods_license_zip_path" {
  description = "the license zip file that contains all the webmethods licenses that you wish to install"
}

variable "webmethods_integration_license_key_alias" {
  description = "the license key alias for webmethods integration server"
}

variable "webmethods_universalmessaging_license_key_alias" {
  description = "the license key alias for webmethods universal messaging"
}

variable "webmethods_terracotta_license_key_alias" {
  description = "the license key alias for webmethods terracotta"
}