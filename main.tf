provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "unique-bucket-luekrit-23598119871" # Make sure this bucket name is globally unique by typing a long random number
}

resource "aws_s3_bucket_public_access_block" "my_bucket_public_access_block" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_encryption" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    # NEW: required in provider v5+ (applies rule to all objects)
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
resource "aws_s3_object" "image" {
  bucket = aws_s3_bucket.my_bucket.id # Reference the bucket ID
  key    = "image.png"                # Path in the bucket
  source = "image.png"                # Local file path
  etag   = filemd5("${path.module}/image.png")
}

#############################
# IAM Role for EC2
#############################
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Policy to allow read-only access to the bucket
resource "aws_iam_policy" "s3_read_policy" {
  name = "${var.project_name}-s3-read"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.my_bucket.arn]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = ["${aws_s3_bucket.my_bucket.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}
resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-kp"
  public_key = file("${path.module}/id_rsa.pub")
}
#############################
# EC2 Instance
#############################
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "${var.project_name}-ssh"
  description = "Allow SSH access"
  vpc_id      = null # uses default VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr] # replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.this.key_name # <--- added here
  iam_instance_profile   = aws_iam_instance_profile.this.name
  vpc_security_group_ids = [aws_security_group.ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf -y update
              dnf -y install awscli
              aws s3 ls s3://${aws_s3_bucket.my_bucket.id}/ > /var/log/s3-access.log 2>&1
              EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}


