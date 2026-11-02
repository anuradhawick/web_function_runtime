terraform {
  backend "s3" {
    bucket       = "terraform-states-anuradhawick"
    key          = "lambda-webruntime-demo"
    region       = "ap-southeast-1"
    use_lockfile = true
  }
}
