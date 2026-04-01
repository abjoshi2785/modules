# Terraform / OpenTofu AWS Modules

This repository contains a set of reusable, production-grade Terraform / OpenTofu modules for PROS.

Each module is independently documented and includes usage examples. This root README provides an overview and a dynamically generated index of available modules.

---

## Overview

The modules in this repository are built with the following principles:

* **Consistency** across environments and teams  
* **Fail-fast validation** to catch errors during `validate`  
* **Secure-by-default configurations**  
* **Extensibility without forcing rigid abstractions**  
* **Compatibility with enterprise requirements**  

---

## Available Modules

<!-- BEGIN_MODULE_INDEX -->
* `asg` – Creates:,Launch Template Auto Scaling Group,Production behaviors: IMDSv2 required by default,Encrypted root volume by default Instance refresh enabled by default so AMI/user_data changes roll instances,Preconditions enforce valid size relationships Consistent plain-text user_data input, encoded internally for the launch template
* `ec2_instance` – Creates a single EC2 instance with secure defaults:,IMDSv2 required by default Encrypted root volume by default (gp3, 30GiB),Consistent plain-text user_data input Optional detailed monitoring, EBS optimization, termination protection, and extra EBS volumes,Optional instance profile
* `efs` – Creates an EFS file system and one mount target per subnet.,Also supports optional performance mode and throughput mode controls. Includes cost-control default:,Lifecycle policy transitions data to EFS Infrequent Access (IA) (default: AFTER_30_DAYS)
* `iam_role` – Creates an IAM Role with:,Inline policies (map of JSON policy documents) Optional managed policy attachments,Optional permissions boundary Optional instance profile (default: disabled for safer shared reuse)
* `nlb` – Creates a Network Load Balancer (NLB) with:,Configurable listener and target group protocol One listener,One target group Optional target attachments for `instance` or `ip`,Optional health check overrides Production behaviors:,Target group name includes a random suffix to avoid name collisions on replacement `random_id` uses keepers so name changes when replacement-relevant inputs change,Target group uses `create_before_destroy` Cross-input validations reduce invalid combinations
* `s3` – Creates an S3 bucket with production defaults:,Encryption (SSE-S3 or SSE-KMS) Public access block,Ownership controls (default: BucketOwnerEnforced) Optional bucket policy,Optional server access logging Optional lifecycle rules with transitions, multipart cleanup, and stronger validation
* `security_group` – Creates an AWS Security Group and a set of ingress/egress rules.,Designed for shared use across teams: Uses `name_prefix` + `create_before_destroy` to avoid name-collision failures during replacement.,Rules are maps keyed by stable names, so diffs are reviewable and rule reordering doesn't cause churn. Includes rule-level validations to reduce invalid combinations.
<!-- END_MODULE_INDEX -->

Each module contains its own detailed documentation, including inputs, outputs, and examples.

---

## Key Features

### 1. Organizational Tag Enforcement

All modules require a standard set of tags:

```hcl
tags = {
  env         = "dev"
  owner       = "team-name"
  cost-center = "shared-services"
}
```

This ensures:

* cost allocation  
* ownership tracking  
* environment separation  

---

### 2. Strong Input Validation

Modules include validation to fail early:

* type constraints  
* regex validation  
* JSON validation (IAM policies)  
* cross-field validation  

This prevents invalid configurations from reaching `apply`.

---

### 3. IAM Permissions Boundary Support

IAM roles support optional permissions boundaries:

```hcl
permissions_boundary = "arn:aws:iam::123456789012:policy/example-boundary"
```

This enables compliance with enterprise security controls.

---

### 4. Resource Timeouts

Critical resources include explicit timeout configurations:

* Network Load Balancer  
* EFS  
* Auto Scaling Group  

This improves reliability during slow or retry-heavy AWS operations.

---

### 5. Hardened Storage Configuration

EC2 and ASG modules support additional EBS volumes with validation:

* valid volume types enforced  
* `iops` required for `io1` / `io2`  
* `throughput` only for `gp3`  

---

### 6. NLB Guardrails

The NLB module includes:

* protocol compatibility validation  
* health check validation  
* target type enforcement (instance vs IP)  
* TLS certificate validation  

---

## Example Usage

Example using the EC2 module:

```hcl
module "ec2_instance" {
  source = "git::https://github.com/<org>/<repo>.git//ec2_instance"

  name               = "example-ec2"
  ami_id             = "ami-0123456789abcdef0"
  subnet_id          = "subnet-0123456789abcdef0"
  security_group_ids = ["sg-0123456789abcdef0"]

  tags = {
    env         = "dev"
    owner       = "platform-team"
    cost-center = "shared-services"
  }
}
```

Each module contains a working example under:

```
examples/basic/
```

---

## CI Validation

Modules are validated using:

* `tofu fmt`  
* `tofu init -backend=false`  
* `tofu validate`  
* `tflint`  
* `checkov`  

All modules and examples must pass these checks.

---

## Usage Guidelines

* Do not bypass required tags  
* Use module examples as a starting point  
* Prefer extending modules via inputs instead of forking  
* Validate changes locally before committing  

---

## Limitations

* Modules are designed as a baseline, not a full platform abstraction  
* Some advanced configurations may require extension  
* Not all edge cases are enforced via validation  

---

## Future Improvements

Potential enhancements include:

* module versioning and release automation  
* stricter IAM guardrail enforcement  
* expanded S3 lifecycle capabilities  
* observability integrations  

---

## Contributing

When contributing:

* maintain backward compatibility  
* add validation for new inputs  
* update examples  
* ensure CI passes  

---

## Summary

These modules provide a production-ready foundation for AWS infrastructure provisioning, balancing flexibility with guardrails. They are designed to accelerate delivery while maintaining consistency, reliability, and security.
