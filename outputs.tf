output "bucket_name" {
  value       = aws_s3_bucket.my_bucket.bucket
  description = "The S3 bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.my_bucket.arn
  description = "The S3 bucket ARN"
}

output "ec2_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the EC2 instance"
}
output "bucket_s3_uri" {
  value       = "s3://${aws_s3_bucket.my_bucket.bucket}"
  description = "S3 URI for the bucket"
}
