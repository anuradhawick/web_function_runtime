resource "aws_s3_bucket" "deployment" {
  bucket_prefix = "${local.name}-"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "deployment" {
  bucket = aws_s3_bucket.deployment.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "lambda_code" {
  bucket = aws_s3_bucket.deployment.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowLambdaWebFunctionCodeAccess"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = ["s3:GetObject", "s3:GetObjectVersion"]
      Resource  = "${aws_s3_bucket.deployment.arn}/app.zip"
      Condition = {
        ArnLike = {
          "aws:SourceArn" = "${aws_lambdaweb_function.app.arn}/revision/*"
        }
      }
    }]
  })
}

resource "aws_s3_object" "app" {
  bucket       = aws_s3_bucket.deployment.id
  key          = "app.zip"
  source       = data.archive_file.app.output_path
  source_hash  = data.archive_file.app.output_base64sha256
  content_type = "application/zip"

  # Keep previous object versions available for existing revisions.
  depends_on = [aws_s3_bucket_versioning.deployment]
}

resource "aws_iam_role" "app" {
  name_prefix = "lambda-web-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_lambdaweb_function" "app" {
  function_name = local.name
}

resource "aws_lambdaweb_function_revision" "app" {
  function_name = aws_lambdaweb_function.app.function_name

  build_config {
    runtime_config {
      runtime = "nodejs24.x"
    }
    code_config {
      s3_object {
        bucket     = aws_s3_object.app.bucket
        key        = aws_s3_object.app.key
        version_id = aws_s3_object.app.version_id
      }
    }
  }

  service_config {
    execution_role_arn = aws_iam_role.app.arn
    environment_variables = {
      NODE_ENV                     = "production"
      NEXT_TELEMETRY_DISABLED      = "1"
      AWS_LAMBDA_NODEJS_ENTRYPOINT = "lambda-entrypoint.cjs"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_s3_bucket_policy.lambda_code]
}

resource "aws_lambdaweb_function_endpoint" "app" {
  function_name        = aws_lambdaweb_function.app.function_name
  endpoint_name        = "prod"
  endpoint_type        = "HomeRegion"
  auth_type            = "ApplicationManaged"
  auto_deployment_mode = "Disabled"

  revision_weight {
    revision_id = aws_lambdaweb_function_revision.app.revision_id
    weight      = 100
  }
}

output "app_url" {
  value = "https://${aws_lambdaweb_function_endpoint.app.domain_name}"
}
