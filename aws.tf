provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region
}

data "aws_route53_zone" "zone" {
  name = "${var.route53_hosted_zone_name}"
}

data "template_file" "provision" {
  template = "${file("${path.module}/provision.sh")}"

  vars {
    database_endpoint = "${aws_db_instance.default.endpoint}"
    database_name     = "${var.database_name}"
    database_user     = "${var.database_user}"
    region            = "${var.region}"
    s3_bucket_name    = "${var.s3_bucket_name}"
  }
}
