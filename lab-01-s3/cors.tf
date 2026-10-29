resource "aws_s3_bucket_cors_configuration" "labs" {
  bucket = aws_s3_bucket.labs.id

  dynamic "cors_rule" {

    for_each = var.cors_rules

    content {
      id              = cors_rule.value.id
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = cors_rule.value.allowed_headers
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}
