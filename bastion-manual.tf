resource "aws_key_pair" "webmethods_bastion" {
  key_name   = "${var.webmethods_bastion_key_name}"
  public_key = "${file(var.webmethods_bastion_key_path_public)}"
}

//Create the bastion userdata script.
data "template_file" "setup-bastion" {
  template = "${file("./helper_scripts/setup-bastion.sh")}"
  vars {
    availability_zone = "${var.azs}"
    default_linuxuser = "${local.base_ami_user}"
    webmethods_linuxuser = "${var.webmethods_linux_user}"
    webmethods_path = "${var.webmethods_base_path}"
    cc_password="${var.webmethods_cc_password}"
    webmethods_repo_username="${var.webmethods_repo_username}"
    webmethods_repo_password="${var.webmethods_repo_password}"
    webmethods_cc_ssh_key_filename="${var.webmethods_cc_ssh_key_filename}"
    webmethods_cc_ssh_key_pwd="${var.webmethods_cc_ssh_key_pwd}"
    cc_devops_install_dir = "${var.webmethods_provisioning_base_path}"
    cc_devops_install_user = "${var.webmethods_linux_user}"
    ssh_private_key = "${file(var.webmethods_nodes_key_path_private)}"
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "bastion" {
  ami                  = "${local.base_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-bastion.rendered}"
  key_name            = "${aws_key_pair.webmethods_bastion.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.webmethods-default-vpc.id}",
    "${aws_security_group.webmethods-public-egress.id}",
    "${aws_security_group.webmethods-ssh.id}",
    "${aws_security_group.webmethods-commandcentral.id}"
  ]

  # Storage for webmethods software
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 50
    volume_type = "gp2"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-Bastion with Command Central"
    )
  )}"

  ////// copying all the files we need on the bastion server
  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/id_rsa"
    destination = "~/.ssh/id_rsa"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/cce-install-configure.sh"
    destination = "~/cce-install-configure.sh"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/inventory-setenv.sh"
    destination = "~/inventory-setenv.sh"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/cce-inventory-install.sh"
    destination = "~/cce-inventory-install.sh"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/inventory-install.sh"
    destination = "~/inventory-install.sh"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/bootstrap-complete.sh"
    destination = "~/bootstrap-complete.sh"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${var.webmethods_license_zip_path}"
    destination = "~/sag_licenses.zip"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }
}