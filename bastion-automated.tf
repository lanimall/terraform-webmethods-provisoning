resource "aws_key_pair" "webmethods_bastion" {
  key_name   = "${var.webmethods_bastion_key_name}"
  public_key = "${file(var.webmethods_bastion_key_path)}"
}

//Create the bastion userdata script.
data "template_file" "setup-bastion" {
  template = "${file("./helper_scripts/setup-bastion.sh")}"
  vars {
    availability_zone = "${var.azs}"
    cc_password="${var.webmethods_cc_password}"
    webmethods_repo_username="${var.webmethods_repo_username}"
    webmethods_repo_password="${var.webmethods_repo_password}"
    default_linuxuser="${var.default_linuxuser}"
    webmethods_cc_ssh_key_filename="${var.webmethods_cc_ssh_key_filename}"
    webmethods_cc_ssh_key_pwd="${var.webmethods_cc_ssh_key_pwd}"
    webmethods_cc_ssh_user="${var.webmethods_cc_ssh_user}"
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "bastion" {
  ami                  = "${var.default_ami}"
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
      "Name", "webmethods provisoning - Bastion with Command Central"
    )
  )}"

  provisioner "local-exec" {
    command = "ssh-keyscan -t rsa -H ${aws_instance.bastion.public_ip} >> ~/.ssh/known_hosts"
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/id_rsa"
    destination = "~/.ssh/id_rsa"

    connection {
      type        = "ssh"
      user        = "${var.default_linuxuser}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/cce-install-configure.sh"
    destination = "~/cce-install-configure.sh"

    connection {
      type        = "ssh"
      user        = "${var.default_linuxuser}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/inventory-setenv.sh"
    destination = "~/inventory-setenv.sh"

    connection {
      type        = "ssh"
      user        = "${var.default_linuxuser}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "${path.cwd}/helper_scripts/inventory-install.sh"
    destination = "~/inventory-install.sh"

    connection {
      type        = "ssh"
      user        = "${var.default_linuxuser}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "file" {
    source      = "~/sag_licenses.zip"
    destination = "~/sag_licenses.zip"

    connection {
      type        = "ssh"
      user        = "${var.default_linuxuser}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "ssh-keyscan -t rsa -H ${aws_route53_record.webmethods_integration1-a-record.name} >> ~/.ssh/known_hosts",
      "ssh-keyscan -t rsa -H ${aws_instance.webmethods_integration1.private_dns} >> ~/.ssh/known_hosts",
      "ssh-keyscan -t rsa -H ${aws_instance.webmethods_integration1.private_ip} >> ~/.ssh/known_hosts",
      "ssh-keyscan -t rsa -H ${aws_route53_record.webmethods_universalmessaging1-a-record.name} >> ~/.ssh/known_hosts",
      "ssh-keyscan -t rsa -H ${aws_instance.webmethods_universalmessaging1.private_dns} >> ~/.ssh/known_hosts",
      "ssh-keyscan -t rsa -H ${aws_instance.webmethods_universalmessaging1.private_ip} >> ~/.ssh/known_hosts",
      "ssh-keyscan -t rsa -H ${aws_route53_record.webmethods_terracotta1-a-record.name} >> ~/.ssh/known_hosts",
      "ssh-keyscan -t rsa -H ${aws_instance.webmethods_terracotta1.private_dns} >> ~/.ssh/known_hosts",
      "ssh-keyscan -t rsa -H ${aws_instance.webmethods_terracotta1.private_ip} >> ~/.ssh/known_hosts",
      "nohup /bin/bash ~/cce-install-configure.sh > ~/nohup-cce-install-configure.log 2>&1 &",
      "nohup /bin/bash ~/inventory-install.sh > ~/nohup-inventory-install.log 2>&1 &"
    ]

    connection {
      type        = "ssh"
      user        = "${var.default_linuxuser}"
      private_key = "${file("${path.cwd}/helper_scripts/id_rsa_bastion")}"
    }
  }
}