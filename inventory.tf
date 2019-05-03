data "template_file" "inventory" {
  template = "${file("${path.cwd}/helper_scripts/cce-inventory.tpl")}"
  vars {
    webmethods_integration1 = "${aws_route53_record.webmethods_integration1-a-record.name}"
  }
}

resource "local_file" "inventory" {
  content     = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/helper_scripts/cce-inventory.sh"
}