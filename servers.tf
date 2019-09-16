resource "aws_key_pair" "webmethods_nodes" {
  key_name   = "${var.webmethods_nodes_key_name}"
  public_key = "${file(var.webmethods_nodes_key_path_public)}"
}

//  Create the standard webmethods node userdata script.
data "template_file" "setup-webmethods-node" {
  template = "${file("./helper_scripts/setup-webmethods-node.sh")}"
  vars {
    availability_zone = "${var.azs}"
    default_linuxuser = "${local.base_ami_user}"
    webmethods_linuxuser = "${var.webmethods_linux_user}"
    webmethods_path = "${var.webmethods_base_path}"
    ssh_public_key = "${file(var.webmethods_nodes_key_path_public)}"
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "webmethods_commandcentral" {
  ami                  = "${local.base_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-webmethods-node.rendered}"
  key_name            = "${aws_key_pair.webmethods_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.webmethods-default-vpc.id}",
    "${aws_security_group.webmethods-public-egress.id}",
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
      "Name", "${local.name_prefix}-webmethods Command Central"
    )
  )}"
}

//  Launch configuration for an integration node
resource "aws_instance" "webmethods_universalmessaging1" {
  ami                  = "${local.base_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-webmethods-node.rendered}"
  key_name            = "${aws_key_pair.webmethods_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.webmethods-default-vpc.id}",
    "${aws_security_group.webmethods-public-egress.id}",
    "${aws_security_group.webmethods-universalmessaging.id}"
  ]

  # Storage for webmethods software
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "gp2"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-webmethods universal messaging server 1"
    )
  )}"
}

//  Launch configuration for an integration node
resource "aws_instance" "webmethods_terracotta1" {
  ami                  = "${local.base_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-webmethods-node.rendered}"
  key_name            = "${aws_key_pair.webmethods_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.webmethods-default-vpc.id}",
    "${aws_security_group.webmethods-public-egress.id}",
    "${aws_security_group.webmethods-terracotta.id}"
  ]

  # Storage for webmethods software
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "gp2"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-terracotta caching server 1"
    )
  )}"
}

//  Launch configuration for an integration node
resource "aws_instance" "webmethods_integration1" {
  ami                  = "${local.base_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-webmethods-node.rendered}"
  key_name            = "${aws_key_pair.webmethods_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.webmethods-default-vpc.id}",
    "${aws_security_group.webmethods-public-egress.id}",
    "${aws_security_group.webmethods-integrationserver.id}"
  ]

  # Storage for webmethods software
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "gp2"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-integration server 1"
    )
  )}"
}

//  Launch configuration for an integration node
resource "aws_instance" "webmethods_integration2" {
  ami                  = "${local.base_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-webmethods-node.rendered}"
  key_name            = "${aws_key_pair.webmethods_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.webmethods-default-vpc.id}",
    "${aws_security_group.webmethods-public-egress.id}",
    "${aws_security_group.webmethods-integrationserver.id}"
  ]

  # Storage for webmethods software
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "gp2"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-integration server 2"
    )
  )}"
}

//  Launch configuration for an integration node
resource "aws_instance" "webmethods_integration3" {
  ami                  = "${local.base_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-webmethods-node.rendered}"
  key_name            = "${aws_key_pair.webmethods_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.webmethods-default-vpc.id}",
    "${aws_security_group.webmethods-public-egress.id}",
    "${aws_security_group.webmethods-integrationserver.id}"
  ]

  # Storage for webmethods software
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "gp2"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-integration server 3"
    )
  )}"
}