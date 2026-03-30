# Terraform / OpenTofu AWS Modules

This repository contains a set of reusable, production-grade Terraform / OpenTofu modules for PROS.

These modules provide a consistent, validated, and secure foundation for provisioning infrastructure across environments. They are designed to reduce duplication, enforce organizational standards, and accelerate delivery.

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

* `s3` – S3 bucket with lifecycle configuration and security defaults
* `iam_role` – IAM role with optional permissions boundary support
* `security_group` – Security group with structured ingress/egress rules
* `ec2_instance` – EC2 instance with configurable networking and storage
* `efs` – EFS file system with mount targets
* `asg` – Auto Scaling Group with launch template support
* `nlb` – Network Load Balancer with listener and target group configuration

Each module includes:

* `main.tf`
* `variables.tf`
* `outputs.tf`
* `examples/basic`

---

## Repository Structure

```id="struct1"
modules/
  s3/
  iam_role/
  security_group/
  ec2_instance/
  efs/
  asg/
  nlb/
```

---

## Key Features

### 1. Organizational Tag Enforcement

All modules require a standard set of tags:

```id="tags1"
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

```id="iam1"
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

```id="ex1"
module "ec2_instance" {
  source = "git::https://github.com/<org>/<repo>.git//modules/ec2_instance"

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
