locals {
  origin_id = "${var.project_name}-${var.env}-cf-distribution"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.project_name}-${var.env}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  acl = "private"

  website {
    index_document = var.index_document
    error_document = var.error_document

    routing_rules = var.routing_rules
  }

  tags = {
    Name = "${var.project_name}-${var.env}"
  }
}

data "aws_iam_policy_document" "website_bucket_policy_document" {
  statement {

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      ]
    }

    sid = "publicReadAccess"

    actions = [
      "s3:GetObject",
      "s3:ListObject",
      "s3:ListObjectsV2"
    ]

    resources = [
      "${aws_s3_bucket.website_bucket.arn}/*",
      aws_s3_bucket.website_bucket.arn
    ]
  }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.website_bucket_policy_document.json
}


resource "aws_cloudfront_origin_access_identity" "website_origin_access_identity" {
  comment = "access identity for ${var.project_name} website"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access identity for ${var.project_name}"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = local.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  default_root_object = "index.html"

  aliases = [var.domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id
    smooth_streaming = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = var.price_class

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = local.origin_id
  }
}

data "aws_iam_policy_document" "website_deploy_policy_document" {
  statement {
    sid = "s3"

    actions = [
      "s3:DeleteObject",
      "s3:ListObject",
      "s3:ListObjectsV2",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.website_bucket.arn}/*",
      aws_s3_bucket.website_bucket.arn
    ]
  }

  statement {
    sid = "cloudfront"

    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:GetStreamingDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudfront:ListCloudFrontOriginAccessIdentities",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation"
    ]

    resources = [
      aws_cloudfront_distribution.distribution.arn
    ]
  }
}

resource "aws_iam_policy" "website_deploy_policy" {
  name   = "${var.project_name}-${var.env}-deploy-policy"
  policy = data.aws_iam_policy_document.website_deploy_policy_document.json
}

resource "aws_iam_user" "website_deploy_user" {
  name = "${var.project_name}-${var.env}-deploy-user"

  tags = {
    Name = "${var.project_name}-${var.env}-deploy-user"
  }
}

resource "aws_iam_user_policy_attachment" "website_deploy_user_attach_deploy_policy" {
  user       = aws_iam_user.website_deploy_user.name
  policy_arn = aws_iam_policy.website_deploy_policy.arn
}