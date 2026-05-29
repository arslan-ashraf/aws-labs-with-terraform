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

  # policy = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [
  #     {
  #       Action   = "s3:GetObject"
  #       Effect   = "Allow"
  #       Resource = "${aws_s3_bucket.static_files_s3_bucket.arn}/*"
  #       Principal = {
  #         Service = "cloudfront.amazonaws.com"
  #       }
  #       Condition = {
  #         StringEquals = {
  #           "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
  #         }
  #       }
  #     }
  #   ]
  # })
}

resource "aws_s3_bucket_website_configuration" "static_website_config" {
  bucket = aws_s3_bucket.static_files_s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_object" "index_html_page" {
  bucket       = aws_s3_bucket.static_files_s3_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("static-files/index.html")
}

resource "aws_s3_object" "error_html_page" {
  bucket       = aws_s3_bucket.static_files_s3_bucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
  etag         = filemd5("static-files/error.html")
}