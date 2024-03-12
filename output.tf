output "aws_s3_bucket_url" {
  description = "value of the website_domain attribute of the aws_s3_bucket.my_bucket resource"
  value       = "http://${var.bucket_name}.s3-website-${var.region}.amazonaws.com/"
                #http://imad-terraform-bucket.s3-website-us-east-1.amazonaws.com/
}
