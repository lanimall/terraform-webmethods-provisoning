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
  filename = "${path.cwd}/helper_scripts/inventory-setenv.sh"
}