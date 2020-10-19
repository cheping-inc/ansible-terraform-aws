terraform {
  required_version = ">0.12.0"

  backend "s3" {
    bucket = "terraform-statebucket-0604"
    key    = "tfstate"
    region = "us-east-1"
  }
}
