resource "aws_key_pair" "webmethods_bastion" {
  key_name   = "${var.webmethods_bastion_key_name}"
  public_key = "${file(var.webmethods_bastion_key_path_public)}"
}

resource "random_id" "bastionserver" {
  keepers = {
    # Generate a new id each time we recreate
    execute_cce_install = "${var.execute_cce_install}"
    execute_cce_config = "${var.execute_cce_config}"
    execute_cce_products_install = "${var.execute_cce_products_install}"
  }
  byte_length = 8
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
    ssh_known_host1_dnsname = "${aws_route53_record.webmethods_integration1-a-record.name}"
    ssh_known_host2_dnsname = "${aws_route53_record.webmethods_universalmessaging1-a-record.name}"
    ssh_known_host3_dnsname = "${aws_route53_record.webmethods_terracotta1-a-record.name}"
    ssh_known_host1_ip = "${aws_instance.webmethods_integration1.private_ip}"
    ssh_known_host2_ip = "${aws_instance.webmethods_universalmessaging1.private_ip}"
    ssh_known_host3_ip = "${aws_instance.webmethods_terracotta1.private_ip}"
  }
}

data "template_file" "inventory" {
  template = "${file("${path.cwd}/helper_scripts/inventory.tpl")}"
  vars {
    webmethods_integration1 = "${aws_route53_record.webmethods_integration1-a-record.name}"
    webmethods_integration_license_key_alias= "${var.webmethods_integration_license_key_alias}"

    webmethods_universalmessaging1 = "${aws_route53_record.webmethods_universalmessaging1-a-record.name}"
    webmethods_universalmessaging_license_key_alias = "${var.webmethods_universalmessaging_license_key_alias}"

    webmethods_terracotta1 = "${aws_route53_record.webmethods_terracotta1-a-record.name}"
    webmethods_terracotta_license_key_alias = "${var.webmethods_terracotta_license_key_alias}"
  }
}

resource "local_file" "inventory" {
  content     = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/helper_scripts/tfexpanded_inventory-setenv.sh"
}

data "template_file" "bootstrap" {
  template = "${file("${path.cwd}/helper_scripts/bootstrap.sh")}"
  vars {
    execute_cce_install = "${random_id.bastionserver.keepers.execute_cce_install}"
    execute_cce_config = "${random_id.bastionserver.keepers.execute_cce_config}"
    execute_cce_products_install = "${random_id.bastionserver.keepers.execute_cce_products_install}"
    unique_id = "${random_id.bastionserver.hex}"
  }
}

resource "local_file" "bootstrap" {
  content     = "${data.template_file.bootstrap.rendered}"
  filename = "${path.cwd}/helper_scripts/tfexpanded_bootstrap.sh"
}

//  Launch configuration for the bastion
resource "aws_instance" "bastion" {
  ami                  = "${local.base_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-bastion.rendered}"
  key_name            = "${aws_key_pair.webmethods_bastion.id}"
  associate_public_ip_address = "true"

  depends_on = [
    "data.template_file.inventory",
    "local_file.inventory",
    "data.template_file.bootstrap",
    "local_file.bootstrap",
    "random_id.bastionserver"
  ]

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
    source      = "${path.cwd}/helper_scripts/cce-install-configure.sh"
    destination = "~/cce-install-configure.sh"

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
    source      = "${path.cwd}/helper_scripts/common.sh"
    destination = "~/common.sh"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/tfexpanded_inventory-setenv.sh"
    destination = "~/inventory-setenv.sh"

    connection {
      type        = "ssh"
      user        = "${local.base_ami_user}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/tfexpanded_bootstrap.sh"
    destination = "~/bootstrap.sh"

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

  ////// executing remote commands to ensure all the servers are registered in the bastion known_hosts file
  //NOTE: not using this because it does not execute for some reasons...
  //provisioner "remote-exec" {
  //  inline = [
  //    "/bin/bash ~/bootstrap.sh"
  //  ]
  //
  //  connection {
  //    type        = "ssh"
  //    user        = "${local.base_ami_user}"
  //    private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
  //  }
  //}

  ////// executing full provisoning in 1 script
  provisioner "local-exec" {
    command = "ssh -o 'StrictHostKeyChecking no' -i ${path.cwd}/helper_scripts/id_rsa_bastion ${local.base_ami_user}@${self.public_ip} '/bin/bash ~/bootstrap.sh'"
  }
}