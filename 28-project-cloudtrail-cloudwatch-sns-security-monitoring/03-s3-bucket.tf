resource "aws_s3_bucket" "cloudtrail_logs_bucket" {
  bucket        = "cloudtrail-logs-3df48b"
  force_destroy = true
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition = data.aws_partition.current.partition
  region = data.aws_region.current.region
  cloudtrail_base_arn = "arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail"
}

data "aws_iam_policy_document" "s3_resource_policy_document" {

  statement {
    sid    = "Allow CloudTrail to verify bucket's ACL"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    # grants CloudTrail permission to verify the bucket's Access Control List
    # or (ACL), it allows CloudTrail to check these permissions so it can 
    # deliver logs into the designated bucket
    actions = ["s3:GetBucketAcl"]

    resources = [aws_s3_bucket.cloudtrail_logs_bucket.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["${local.cloudtrail_base_arn}/secret_accessed_trail"]
      # values = [aws_cloudtrail.secret_accessed_trail.arn]
    }
  }

  statement {
    sid    = "Allow CloudTrail to write to S3 bucket"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources  = ["${aws_s3_bucket.cloudtrail_logs_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["${local.cloudtrail_base_arn}/secret_accessed_trail"]
      # values = [aws_cloudtrail.secret_accessed_trail.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_bucket_resource_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs_bucket.id
  policy = data.aws_iam_policy_document.s3_resource_policy_document.json
}