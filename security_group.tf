//  This security group allows intra-node communication on all ports with all
//  protocols.
resource "aws_security_group" "webmethods-default-vpc" {
  name        = "webmethods-default-vpc"
  description = "Default security group that allows all instances in the VPC to talk to each other over any port and protocol."
  vpc_id      = "${aws_vpc.webmethods.id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "webmethods Internal VPC"
    )
  )}"
}

//  This security group allows public egress from the instances for HTTP and
//  HTTPS, which is needed for yum updates, git access etc etc.
resource "aws_security_group" "webmethods-public-egress" {
  name        = "webmethods-public-egress"
  description = "Security group that allows egress to the internet for instances over HTTP and HTTPS."
  vpc_id      = "${aws_vpc.webmethods.id}"

  //  HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "webmethods Public Egress"
    )
  )}"
}

//  Security group which allows SSH access to a host. Used for the bastion.
resource "aws_security_group" "webmethods-ssh" {
  name        = "webmethods-ssh"
  description = "Security group that allows public ingress over SSH."
  vpc_id      = "${aws_vpc.webmethods.id}"

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "webmethods SSH Access"
    )
  )}"
}

###### COMMAND CENTRAL ###### 
resource "aws_security_group" "webmethods-commandcentral" {
  name        = "webmethods-commandcentral"
  description = "Command Central"
  vpc_id      = "${aws_vpc.webmethods.id}"

  ingress {
    from_port   = 8090
    to_port     = 8092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "webmethods Command Central"
    )
  )}"
}

###### INTEGRATION SERVER ###### 
resource "aws_security_group" "webmethods-integrationserver" {
  name        = "webmethods-integrationserver"
  description = "Integration Server"
  vpc_id      = "${aws_vpc.webmethods.id}"

  ingress {
    from_port   = 9510
    to_port     = 9540
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8075
    to_port     = 8075
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5443
    to_port     = 5443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5555
    to_port     = 5555
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "webmethods Integration Server"
    )
  )}"
}

###### TERRACOTTA ###### 
resource "aws_security_group" "webmethods-terracotta" {
  name        = "webmethods-terracotta"
  description = "Terracotta"
  vpc_id      = "${aws_vpc.webmethods.id}"

  ingress {
    from_port   = 9540
    to_port     = 9540
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9610
    to_port     = 9610
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9410
    to_port     = 9410
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9510
    to_port     = 9510
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9443
    to_port     = 9443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9530
    to_port     = 9530
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9889
    to_port     = 9889
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9430
    to_port     = 9430
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9480
    to_port     = 9480
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9520
    to_port     = 9520
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "webmethods Terracotta"
    )
  )}"
}

###### UNIVERSAL MESSAGING ###### 
resource "aws_security_group" "webmethods-universalmessaging" {
  name        = "webmethods-universalmessaging"
  description = "Universal Messaging"
  vpc_id      = "${aws_vpc.webmethods.id}"

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9001
    to_port     = 9004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "webmethods Universal Messaging"
    )
  )}"
}