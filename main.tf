provider "aws" {
  region = "${var.aws_region}"
}

locals {
  common_tags = {
    "Project" = "${var.project_name}-${terraform.workspace}",
    "Provisioning" = "terraform",
    "Provisioning_Project" = "terraform-webmethods-provisioning"
  }
}

locals {
  default_name_prefix = "${var.project_name}"
  name_prefix = "${var.resources_name_prefix != "" ? var.resources_name_prefix : local.default_name_prefix}-${terraform.workspace}"
  base_ami = "${var.default_ami != "" ? var.default_ami : data.aws_ami.centos.id}"
  base_ami_user = "${var.default_ami_user != "" ? var.default_ami_user : "centos"}"
}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

    filter {
        name   = "name"
        values = ["CentOS Linux 7 x86_64 HVM EBS *"]
    }

    filter {
        name   = "architecture"
        values = ["x86_64"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }
}