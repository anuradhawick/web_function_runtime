terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # scripts/build-provider.sh supplies the pinned development binary.
      version = "~> 6.71"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  name      = "lambda-webruntime-demo"
  app_dir   = abspath("${path.module}/app")
  build_dir = abspath("${path.module}/.terraform/lambda-build")
  # Ignore generated output, dependencies, and repository metadata.
  source_files = sort([
    for file in fileset(local.app_dir, "**") : file
    if !can(regex("(^|/)(node_modules|\\.next|\\.git)(/|$)", file))
    && !endswith(file, ".tsbuildinfo")
  ])
  source_hash = sha256(jsonencode({
    for file in local.source_files : file => filesha256("${local.app_dir}/${file}")
  }))
}

resource "terraform_data" "build" {
  triggers_replace = [local.source_hash, filesha256("${path.module}/scripts/build-app.sh")]

  provisioner "local-exec" {
    command     = "bash scripts/build-app.sh"
    working_dir = path.module
  }
}

data "archive_file" "app" {
  type        = "zip"
  source_dir  = "${local.build_dir}/package"
  output_path = "${local.build_dir}/app.zip"

  depends_on = [terraform_data.build]
}
