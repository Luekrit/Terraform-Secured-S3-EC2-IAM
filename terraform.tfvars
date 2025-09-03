project_name         = "lk-s3-ec2-iam-demo"
aws_region           = "ap-southeast-2"
bucket_force_destroy = true # lab only; set false for prod
ec2_enable           = true # set to false to skip EC2/IAM
allowed_ssh_cidr     = "202.144.174.31/32"