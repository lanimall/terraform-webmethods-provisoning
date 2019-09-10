//  Create the internal DNS.
resource "aws_route53_zone" "webmethods-internal" {
  name = "webmethods.local"
  comment = "webmethods Cluster Internal DNS"
  vpc {
    vpc_id = "${aws_vpc.webmethods.id}"
  }
  
  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-webmethods Internal DNS"
    )
  )}"
}

//  Routes for the webmethods components
resource "aws_route53_record" "webmethods_commandcentral-a-record" {
    zone_id = "${aws_route53_zone.webmethods-internal.zone_id}"
    name = "commandcentral.webmethods.local"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.bastion.private_ip}"
    ]
}

resource "aws_route53_record" "webmethods_integration1-a-record" {
    zone_id = "${aws_route53_zone.webmethods-internal.zone_id}"
    name = "integration1.webmethods.local"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.webmethods_integration1.private_ip}"
    ]
}

resource "aws_route53_record" "webmethods_universalmessaging1-a-record" {
    zone_id = "${aws_route53_zone.webmethods-internal.zone_id}"
    name = "universalmessaging1.webmethods.local"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.webmethods_universalmessaging1.private_ip}"
    ]
}

resource "aws_route53_record" "webmethods_terracotta1-a-record" {
    zone_id = "${aws_route53_zone.webmethods-internal.zone_id}"
    name = "terracotta1.webmethods.local"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.webmethods_terracotta1.private_ip}"
    ]
}