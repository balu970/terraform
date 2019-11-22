provider "aws" {
  version = "~> 2.36"
  profile = "${var.prof_name}"
  region  = "${var.region_name}"
}