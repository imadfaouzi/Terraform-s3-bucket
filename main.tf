## Create a S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "Production"
  }

}

# aws_s3_bucket_ownership_controls serve to specify the Object Ownership setting for the S3 bucket.
resource "aws_s3_bucket_ownership_controls" "ownership_control_S3" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred" # 
  }
}

# this activates the public access block settings for the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# this will allow anyone to read the objects in the bucket  
resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership_control_S3,
    aws_s3_bucket_public_access_block.public_access_block
  ]
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read"
}


# this will allow anyone to read the objects in the bucket 
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}


# Enable web static 
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }

}

# # static website hosting
# module "template_file" {
#   source   = "hashicorp/dir/template"
#   base_dir = "${path.module}/web-files"
# }



# resource "aws_s3_object" "bucket_files" {
#    for_each = module.template_file.files

#    bucket = aws_s3_bucket.my_bucket.id

#    key = each.key
#    content_type = each.value.content_type
#    content = each.value.content

#    etag = each.value.digests.md5
# }

##""""""       WORKS BUT DEPRECATED

# upload files to the bucket
# resource "aws_s3_bucket_object" "bucket_files" {
#   for_each = fileset("${path.module}/web-files", "**/*")
  
#   bucket = aws_s3_bucket.my_bucket.bucket
#   key = each.value
#   source = "${path.module}/web-files/${each.value}"
#   content_type = "text/html"
# }

# resource "aws_s3_object" "bucket_files" {
#   bucket = aws_s3_bucket.my_bucket.id

#   for_each = module.template_file.files
#   key = each.key
#   content_type = each.value.content_type

#   source = each.value.source
#   content = each.value.content

#   etag = each.value.digests.md5

# }
