resource "aws_key_pair" "webmethods_nodes" {
  key_name   = "${var.webmethods_nodes_key_name}"
  public_key = "${file(var.webmethods_nodes_key_path)}"
}

//  Create the standard webmethods node userdata script.
data "template_file" "setup-webmethods-node" {
  template = "${file("./helper_scripts/setup-webmethods-node.sh")}"
  vars {
    availability_zone = "${var.azs}"
  }
}

//  Launch configuration for an integration node
resource "aws_instance" "webmethods_integration1" {
  ami                  = "${var.default_ami}"
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
      "Name", "webmethods provisoning - integration server 1"
    )
  )}"
}

//  Launch configuration for an integration node
resource "aws_instance" "webmethods_universalmessaging1" {
  ami                  = "${var.default_ami}"
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
      "Name", "webmethods provisoning - webmethods universal messaging server 1"
    )
  )}"
}

//  Launch configuration for an integration node
resource "aws_instance" "webmethods_terracotta1" {
  ami                  = "${var.default_ami}"
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
      "Name", "webmethods provisoning - terracotta caching server 1"
    )
  )}"
}