provider "aws" {
  region = "${var.aws_region}"
}

locals {
  common_tags = "${map(
    "Project", "SoftwareAG webmethods Cloud Provisoning"
  )}"
}