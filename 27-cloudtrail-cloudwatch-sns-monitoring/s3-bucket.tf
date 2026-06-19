resource "aws_s3_bucket" "cloudtrail_logs_bucket" {
  bucket        = "cloudtrail_logs_45807934756"
  force_destroy = true
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
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_logs_bucket.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      # values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/secret_accessed_trail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.example.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      # values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/secret_accessed_trail"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_bucket_resource_policy" {
  bucket = aws_s3_bucket.example.id
  policy = data.aws_iam_policy_document.example.json
}