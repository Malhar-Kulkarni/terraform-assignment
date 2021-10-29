provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region
}

data "aws_route53_zone" "zone" {
  name = "${var.route53_hosted_zone_name}"
}
