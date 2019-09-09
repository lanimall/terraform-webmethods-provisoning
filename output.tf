output "ami" {
  value = "${local.base_ami}"
}

output "amiuser" {
  value = "${local.base_ami_user}"
}

//  Output some useful variables for quick SSH access etc.
output "bastion-public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
output "bastion-private_dns" {
  value = "${aws_instance.bastion.private_dns}"
}
output "bastion-private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}

## integration server
output "webmethods_integration1-public_ip" {
  value = "${aws_instance.webmethods_integration1.public_ip}"
}
output "webmethods_integration1-private_dns" {
  value = "${aws_instance.webmethods_integration1.private_dns}"
}
output "webmethods_integration1-private_route53_dns" {
  value = "${aws_route53_record.webmethods_integration1-a-record.name}"
}
output "webmethods_integration1-private_ip" {
  value = "${aws_instance.webmethods_integration1.private_ip}"
}

## universal messaging
output "webmethods_universalmessaging1-public_ip" {
  value = "${aws_instance.webmethods_universalmessaging1.public_ip}"
}
output "webmethods_universalmessaging1-private_dns" {
  value = "${aws_instance.webmethods_universalmessaging1.private_dns}"
}
output "webmethods_universalmessaging1-private_route53_dns" {
  value = "${aws_route53_record.webmethods_universalmessaging1-a-record.name}"
}
output "webmethods_universalmessaging1-private_ip" {
  value = "${aws_instance.webmethods_universalmessaging1.private_ip}"
}

## terracotta
output "webmethods_terracotta1-public_ip" {
  value = "${aws_instance.webmethods_terracotta1.public_ip}"
}
output "webmethods_terracotta1-private_dns" {
  value = "${aws_instance.webmethods_terracotta1.private_dns}"
}
output "webmethods_terracotta1-private_route53_dns" {
  value = "${aws_route53_record.webmethods_terracotta1-a-record.name}"
}
output "webmethods_terracotta1-private_ip" {
  value = "${aws_instance.webmethods_terracotta1.private_ip}"
}