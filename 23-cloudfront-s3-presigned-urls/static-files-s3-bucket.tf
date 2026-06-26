resource "aws_s3_bucket" "static_files_s3_bucket" {
  bucket = "static-files-bucket-3l5ka8nb5"
}

data "aws_iam_policy_document" "cloudfront_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_files_s3_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.static_files_s3_bucket.id
  policy = data.aws_iam_policy_document.cloudfront_s3_policy.json
}

resource "aws_s3_object" "index_html_page" {
  bucket       = aws_s3_bucket.static_files_s3_bucket.id
  key          = "index.html"
  source       = "${path.module}/static-files/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/static-files/index.html")
}

resource "aws_s3_object" "error_html_page" {
  bucket       = aws_s3_bucket.static_files_s3_bucket.id
  key          = "error.html"
  source       = "${path.module}/static-files/error.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/static-files/error.html")
}