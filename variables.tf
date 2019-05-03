variable "webmethods_bastion_key_name" {
  description = "My secure bastion ssh key name"
  default = "webmethodS_BASTION"
}

variable "webmethods_bastion_key_path" {
  description = "My secure bastion ssh key"
  default = "./helper_scripts/id_rsa_bastion.pub"
}

variable "webmethods_nodes_key_name" {
  description = "My node to node ssh key name"
   default = "webmethodS_NODE"
}

variable "webmethods_nodes_key_path" {
  description = "My node to node ssh key"
   default = "./helper_scripts/id_rsa.pub"
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
  default = "ami-034b65115d858cd6d"
}

###### USERNAME FOR LINUX AMIS ######
variable "default_linuxuser" {
  default = "ec2-user"
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

variable "webmethods_cc_ssh_user" {
  description = "the user that command central will use to connectto the remote servers"
  default = "ec2-user"
}