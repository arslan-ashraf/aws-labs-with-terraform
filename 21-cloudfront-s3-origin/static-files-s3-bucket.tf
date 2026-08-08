resource "aws_s3_bucket" "static_files_s3_bucket" {
  bucket = "static-files-bucket-3l5ka8nb5"
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