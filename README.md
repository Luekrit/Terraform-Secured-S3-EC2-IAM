# 🚀 Terraform Project: Secure S3 Bucket + EC2 + IAM

This project demonstrates how to use Terraform to provision AWS resources, starting from an S3 bucket and extending to IAM and EC2. It follows best practices for security, automation, and Infrastructure as Code (IaC).

---
## Table of contents 


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
