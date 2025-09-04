# 🚀 Terraform Project: Secure S3 Bucket + EC2 + IAM

This project demonstrates how to use Terraform to provision AWS resources, starting from an S3 bucket and extending to IAM and EC2. It follows best practices for security, automation, and Infrastructure as Code (IaC).

---
## 📖 Table of contents 
1. [Project Overview](#Project-Overview)
2. [Architecture](#Architecture)
3. [Step 1: Install Terraform](#Step-1-Install-Terraform)
4. [Step 2: Set Up Terraform Project](#Step-2-Set-Up-Terraform-Project)
5. [Step 3: Define main.tf](#Step-3-Define-main.tf)
6. [Step 4: run Terraform Configuration](#Step-4-run-Terraform-Configuration)
7. [Step 5: Set up AWS Credentials](#Step-5-Set-Up-AWS-Credentials)
8. [Step 6: Launch an S3 Bucket with Terraform](#Step-6-Launch-an-S3-Bucket-with-Terraform)
9. [Secret Mission: Upload an Object](#Secret-Mission-Upload-an-Object)
10. [Stretch Goal: EC2 + IAM integration](#Stretch-Goal-Add-EC2+IAM-Role-to-Access-S3)
11. [Step 8: Verify EC2 + IAM](#Step-8-Verify-EC2+IAM-integration)
12. [Reflection](#Reflection)
13. [Conclusion & Talking Point](#Conclusion&TalkingPoints)
14. [Key Learnings & Skills Demonstrated](#Key-Learnings&Skills-Demonstrated)

---

## Project Overview
- Provisioned a secure S3 bucket with:
  - Versioning enabled
  - Server-side encryption (AES256)
  - Lifecycle rule to expire non-current versions
  - Blocked public access
- Uploaded and validated an object (image.png).
- Extended the project by:
  - Creating an IAM role with S3 read-only access.
  - Launching an EC2 instance that assumed the role.
  - Verified least-privilege access (read ✅, write ❌).
---

## Architecture

---

## Step 1: Install Terraform
### What are we doing?
We are installing **Terraform** to define and provision infrastructure as code.

### Windows Installation (using Chocolatey)
Run the following command in your terminal (as Administrator):

```bash
choco install terraform
```

### Verify Installation
Run the following command to confirm Terraform is installed and check the version:

```bash
terraform -version
```
### If successful, you should see output similar to:

```nginx
Terraform v1.xx.x
```
Screenshoot

---

## Step 2: Set Up Terraform Project

### What are we doing?
We are creating a project folder and the main configuration file (`main.tf`) where we will define our infrastructure as code.

### Commands (Windows PowerShell)
Run the following commands in your terminal:

```powershell
# Create a new project folder
mkdir terraform

# Navigate into the project folder
cd terraform

# Create the main configuration file
New-Item main.tf
```
### Result

After running these commands:

- A new folder named **terraform** is created.  
- Inside it, an empty **main.tf** file is created.  
- This file will store all Terraform configurations for your project.  
- 📂 For easy access, move the **terraform** folder to your **Desktop**.  
Final structure will look like this: Desktop/terraform/ main.tf
---

## Step 3: Define main.tf

### What are we doing in this step?
We’re writing the first lines of Terraform code inside **main.tf**. This file tells Terraform exactly what infrastructure to create — in this case, a simple **S3 bucket**.

### In this step, we will:
- Add Terraform code to `main.tf`.
- Define an **AWS provider** so Terraform knows which cloud and region to use.
- Define an **S3 bucket resource** that Terraform will create.

### Why are we doing this?
Terraform doesn’t build anything until you describe it in code.  
By adding a **provider (AWS)** and a **resource (S3 bucket)**, we’re giving Terraform the “recipe” for what to build.

### 🛠️ Code to add into `main.tf`
```hcl
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
```
### ✅ Result

After saving this file, your Terraform project officially has something to build:  
an **S3 bucket** in AWS.

### Folder Structure: 
```css
Desktop/
└── terraform/
    └── main.tf
```
## Add S3 Best Practices

Now that we have a basic S3 bucket, let’s enhance it with **security, resilience, and cost optimization** features.

---

### 1️⃣ Enable Bucket Versioning
This keeps multiple versions of an object in the same bucket. It’s a best practice for data protection and rollback.

```hcl
resource "aws_s3_bucket_versioning" "demo_versioning" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}
```
<h4>💡 Why it’s good: Protects against accidental deletions or overwrites. </h4>

### 2️⃣ Enable Server-Side Encryption

This ensures all objects stored in the bucket are automatically encrypted at rest.

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "demo_encryption" {
  bucket = aws_s3_bucket.demo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```
<h4> 💡 Why it’s good: Meets compliance standards (ISO 27001, NIST, Essential 8). </h4>

### 3️⃣ Add a Lifecycle Policy

This allows you to automatically manage objects (e.g., move to cheaper storage or expire old versions).

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "demo_lifecycle" {
  bucket = aws_s3_bucket.demo.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
```
<h4> 💡 Why it’s good: Saves costs and keeps storage clean. </h4>

---

## Step 4: run Terraform Configuration

### What are we doing in this step?
Now that **main.tf** is defined, we’re going to run Terraform for the first time.  
This will prepare our project and then show us what changes Terraform is about to make in AWS.

### In this step, we will:
- Initialize Terraform with `terraform init` to download the AWS provider and set up the working directory.
- Plan infrastructure changes with `terraform plan` to preview what resources will be created before applying them.

### Why are we doing this?
Terraform needs to be **initialized once per project** to install required providers and create a **state file**.  
Running a **plan** before applying changes ensures we can safely review what Terraform is about to build in AWS, avoiding mistakes and surprises.

### 🛠️ Commands

**Initialize Terraform**
```bash
terraform init
```
- Downloads the **AWS provider plugin**  
- Creates a hidden **.terraform/** folder  
- Prepares your project for execution  


**Preview the plan**
```bash
terraform plan
```
- Shows what Terraform would create  
- You should see your **S3 bucket**, **public access block**, **versioning**, **encryption**, and **lifecycle rules** in the output  

---

## Step 5: Set Up AWS Credentials

### What are we doing in this step?
We’re giving Terraform the ability to talk to AWS securely.  
To do that, we’ll install the AWS CLI, generate access keys, and configure them locally.

### In this step, we will:
- Install the **AWS CLI** on the machine.  
- Generate an **Access Key ID** and **Secret Access Key** for an IAM user with S3 permissions.  
- Configure the **AWS CLI** with these credentials so Terraform can authenticate with AWS.  

### Why are we doing this?
Terraform needs valid **AWS credentials** to create resources.  
Without them, it can parse and plan but cannot actually apply changes.  
Setting up the AWS CLI also allows us to **test and verify AWS resources** directly from the terminal.

---

### 🛠️ Instructions

**Install AWS CLI**

**Windows (PowerShell):**
```powershell
# Download and install
Invoke-Webrequest -Url "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "AWSCLIV2.msi"
Start-Process msiexec.exe -ArgumentList "/i AWSCLIV2.msi" -Wait

# Verify installation
aws --version
```
Screenshoot 1 and 2

### Generate AWS Access Keys

1. Go to the **AWS Console** → **IAM** → **Users** → select your IAM user → **Security credentials** tab.  
2. Under **Access keys**, click **Create access key**.  
3. Copy the **Access Key ID** and **Secret Access Key** (download CSV if offered).  

⚠️ **Tip:** Don’t use your root account — create an **IAM user** with admin or least privilege access.

---

### Configure the AWS CLI

Run this command in your terminal:

```bash
aws configure
```
Enter the following when prompted:

- **AWS Access Key ID**  
- **AWS Secret Access Key**  
- **Default region** (e.g., `ap-southeast-2` for Sydney)  
- **Default output format** (press Enter for none, or type `json`)  

### Verify it Works 
```bash
aws s3 ls
```
You should see a list of your buckets (or none if you haven't created any yet).

✅ At this point, both Terraform and the AWS CLI are configured to use your credentials to manage resources.

---

## Step 6: Launch an S3 Bucket with Terraform

### What are we doing in this step?
We’re taking all the work we’ve done — installing Terraform, writing our configuration, and planning the changes — and now actually creating the bucket in AWS.  
This is where Terraform goes from “dry run” to **real infrastructure**.

### In this step, we will:
- Run `terraform apply` to deploy the configuration.  
- Confirm that the S3 bucket has been launched successfully.  

### Why are we doing this?
Terraform only previews changes during `plan`.  
The `apply` command **executes those changes**, creating the customized S3 bucket in AWS with **versioning, encryption, and lifecycle rules**.  
Verifying the bucket ensures everything was built as expected.

---

### 🛠️ Commands

**Apply Configuration**
```bash
terraform apply
```
- Builds the resources defined in main.tf.
- Prompts for confirmation before applying changes.
- Creates your S3 bucket (with versioning, encryption, and lifecycle rules) in AWS.

## Verify Your Customizations (CLI Checks)

After applying your configuration, verify that the S3 bucket was created with all customizations.  
Replace `<bucket>` with your actual bucket name (e.g., `unique-bucket-luekrit-23598119871`).

### 🛠️ Commands

```bash
# Bucket exists
aws s3 ls s3://unique-bucket-luekrit-23598119871

# Versioning enabled
aws s3api get-bucket-versioning --bucket unique-bucket-luekrit-23598119871

# Encryption defaulted to AES256
aws s3api get-bucket-encryption --bucket unique-bucket-luekrit-23598119871

# Lifecycle rule present
aws s3api get-bucket-lifecycle-configuration --bucket unique-bucket-luekrit-23598119871

# Public access block enforced
aws s3api get-public-access-block --bucket unique-bucket-luekrit-23598119871
```

### ✅ Expected Results
- **Versioning:** `Status: Enabled`  
- **Encryption:** `SSEAlgorithm: AES256`  
- **Lifecycle:** `expire-old-versions` rule visible  
- **Public Access Block:** all flags set to `true`  

### Optional 
Add `outputs.tf` So Terraform prints handy Values.
```hcl
output "bucket_name" { value = aws_s3_bucket.my_bucket.bucket }
output "bucket_arn"  { value = aws_s3_bucket.my_bucket.arn }
```
Run `Terraform apply` again (no change to infrastructure, just output). 

---

### ⚠️ Common Hiccups (Quick Fixes)
- **BucketAlreadyExists:** S3 bucket names are **global**. If it clashes, change the name and re-run `terraform plan` + `terraform apply`.  
- **AccessDenied:** Ensure your AWS CLI credentials have correct **S3 permissions**.  
- **Region mismatch:** Provider is set to `ap-southeast-2`(your own region). Make sure your CLI default region (or explicit commands) match.  

---

## 🕵️ Secret Mission: Upload an Object

### What are we doing in this mission?
We are extending our Terraform project to **upload an image file** into the S3 bucket we created.  
This demonstrates how Terraform can manage not only infrastructure but also the **objects stored inside it**.

### In this mission, we will:
- Update the Terraform configuration to include an **S3 object resource** for `image.png`.  
- Re-run `terraform apply` to upload the image into the bucket.  
- Verify that the image was successfully uploaded.  

### Why are we doing this?
Terraform can manage both **infrastructure** and the **data** within it.  
By uploading `image.png`, we prove that our S3 bucket is functional and that Terraform can handle **data deployments** as part of automation.

---

### 🛠️ Terraform Code (add to `main.tf`)
```hcl
# Upload an image file to the bucket
resource "aws_s3_object" "my_image" {
  bucket = aws_s3_bucket.demo.id
  key    = "image.png"                     # Object name in S3
  source = "${path.module}/image.png"      # Local file path
  etag   = filemd5("${path.module}/image.png")
}
```
### 🚀 Steps

1. Place `image.png` inside your Terraform project folder:

### Folder Structure: 
```css
Desktop/
└── terraform/
    └── main.tf
    └── image.png
```
2. Apply the configuration
```bash
terraform apply
```
Type `yes` when prompted

3. Verify the upload
```bash
aws s3 ls s3://unique-bucket-luekrit-23598119871/
```
You should see `image.png` listed in the bucket

---

## 🎯 Stretch Goal: Add EC2 + IAM Role to Access S3

### What are we doing in this stretch goal?
We are extending the project beyond just an S3 bucket by provisioning an EC2 instance that uses an IAM role with least-privilege permissions. This demonstrates how applications can securely access AWS resources without hardcoding credentials:
- Create an IAM role with an inline policy granting read-only access to my S3 bucket.  
- Attach the IAM role to an instance profile. 
- Create a security group allowing SSH only from my public IP.
- Provision an EC2 instance that uses the IAM role and lists my S3 bucket on startup.

### Why are we doing this?
This stretch goal simulates a real-world application flow where an EC2 instance (representing a web app or service) needs to interact with an S3 bucket. By applying the principle of least privilege, the instance can only read objects but cannot write, proving secure IAM design.

### 🛠️ Code Additions

We will create `variable.tf`, `outputs.tf`,and `terraform.tfvars` for best practice in real projects to fix errors. Check the attached files

### Folder Structure: 
```css
Desktop/
└── terraform/
    └── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── outputs.tf
    └── image.png
```

### 🚀 Steps

1. Generate a key pair (id_rsa, id_rsa.pub) in your project folder. 
   ```bash
   ssh-keygen -t rsa -b 4096 -C "ec2" -f id_rsa
It will prompt you: 
```yaml
      Enter passphrase (empty for no passphrase):
      Enter same passphrase again:
```
👉 Just Press `Enter`twice to leave it empty.
You should see messages like: 
```vbnet
Your identification has been saved in id_rsa
Your public key has been saved in id_rsa.pub
```
And inside your `terraform` folder: 
- `id_rsa` → private key (use this when you SSH)
- `id_rsa.pub` → public key (Terraform will upload this to AWS as `aws_key_pair`)

### 🛠️ Insert this block before EC2 instance block (add to `main.tf`)
```hcl
# Upload your public key to AWS
resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-kp"
  public_key = file("${path.module}/id_rsa.pub")
}
```

### 🛠️ Updated EC2 instance block (add to `main.tf`)
```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.this.key_name    # <--- added
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

```

2. Run  
   ```powershell
   terraform fmt
   terraform plan
   terraform apply
   terraform output ec2_public_ip
3. SSH into your instance:
   ```powershell
   ssh -i id_rsa ec2-user@<EC2_PUBLIC_IP>

4. Inside the EC2, check:
   ```bash
   cat /var/log/s3-access.log
You should see your bucket listing (with image.png)

---

## Step 8: Verify EC2 + IAM integration

### What are we doing in this step?
We are verifying that our **EC2 instance** can successfully use its **IAM role** to access the S3 bucket.  
This proves that the IAM role is working as intended and that the EC2 instance can interact with S3 **without hardcoded credentials**.

### In this step, we will:
- Confirm the instance identity via STS.  
- List and download an object from S3.  
- Attempt a write and expect it to fail.  

### Why are we doing this?
This demonstrates the **principle of least privilege IAM** in action.  
The EC2 instance has only the permissions needed (list and get objects from the S3 bucket), which is a **security best practice**.  
Verifying access ensures that the infrastructure and IAM role are configured correctly, showing real-world integration between **compute (EC2)** and **storage (S3)**.

---
### 🛠️ Commands

** SSH into the EC2 instance**
```bash
ssh -i id_rsa ec2-user@<EC2_PUBLIC_IP>
```
** 1. Confirm the instance is using your IAM role** 
```bash
aws sts get-caller-identity
```
** 2. See what user_data logged (it listed your bucket at boot)**
```bash
sudo tail -n 100 /var/log/s3-access.log
```
** 3. Manually list your bucket and see the object(s)**
```bash
aws s3 ls s3://your bucket/
```
You should see your `image.png` in step 3, and step 1 should show an ARN ending with role name like `...:role/lk-s3-ec2-iam-demo-ec2-role`. 

### 🧪 Optional Quick Tests

Run these commands from inside your EC2 instance to validate permissions:

**Read a specific object (prove GetObject works)**
```bash
aws s3 cp s3://unique-bucket-luekrit-23598119871/image.png /tmp/image.png
ls -lh /tmp/image.png
```
✅ You should see `image.png` downloaded locally.

**Write should FAIL (we only granted read) — proving least privilege**
```bash
echo test > /tmp/test.txt
aws s3 cp /tmp/test.txt s3://unique-bucket-luekrit-23598119871/
```
❌ This should fail, confirming that the IAM role only has read-only access to the bucket.

**When you're done**
```bash
exit   # leave SSH session
```
Back on PC, you can keep the environment running or clean up later with: 
```powershell
terraform destroy

```

It should contain the same bucket listing output.
### ✅ Result
- EC2 could list + read objects.
- EC2 could not write (least privilege enforced).

---

## Reflection
I chose to do this project today because I wanted hands-on practice with Terraform and AWS services.
Something that would make learning with NextWork even better is having more optional stretch goals like IAM + EC2 integration.
I also extended my initial goal to include EC2 and IAM, which demonstrated how Terraform can securely orchestrate multiple AWS services.

---

## Conclusion & Talking Points 
This project demonstrates the full lifecycle of managing AWS infrastructure with Terraform. Starting from scratch, I:
1. Provisioned a secure S3 bucket with versioning, encryption, lifecycle rules, and blocked public access.
2. Uploaded and validated objects (`image.png`) to confirm the bucket was functional.
3. Extended the project with IAM + EC2 by:
    - Creating a least-privilege IAM role with S3 read-only access.
    - Launching an EC2 instance attached to that role.
    - Verifying that the instance could list and download objects, while being blocked from writing (proving least privilege).

---
## ✅ Key Learnings & Skills Demonstrated 
- Infrastructure as Code (IaC): Built AWS resources declaratively with Terraform.
- Security Best Practices:
  - Blocked public bucket access.
  - Enforced encryption and lifecycle management.
  - Applied IAM least privilege (read-only role for EC2).
- Automation: Used `terraform init → plan → apply → destroy` to manage the entire lifecycle.
- Cloud-Native Integration: Proved real-world flow: application (EC2) → IAM role → S3 bucket.
- Verification & Testing: Validated uploads, downloads, and enforced access restrictions via AWS CLI.
