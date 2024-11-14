terraform {
  backend "s3" {
    bucket         = "vegatestbucket122"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "lock_file"
    encrypt        = true
  }
}