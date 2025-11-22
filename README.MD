# Terraform Modules Collection 

A curated collection of production-ready, reusable Terraform modules for AWS infrastructure automation. Built with best practices, comprehensive documentation, and real-world use cases in mind.

[![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

## 📚 Overview

This repository contains enterprise-grade Terraform modules that I've developed to simplify and standardize infrastructure deployments. Each module is designed with:

- **Security best practices** - Following AWS Well-Architected Framework
- **Cost optimization** - Configurable options for different environments
- **Scalability** - Built to grow with your infrastructure needs
- **Comprehensive documentation** - Clear examples and usage guides
- **Production tested** - Battle-tested in real-world scenarios

## Available Modules

### Networking

#### [AWS VPC Module](./vpc)
Complete VPC setup with public/private subnets, NAT gateways, and Internet gateway.

**Features:**
- ✨ Automatic CIDR block calculation
- 🌍 Multi-AZ subnet distribution
- 🔐 Configurable NAT gateway deployment (HA or cost-optimized)
- 📊 Optional VPC Flow Logs
- 🏷️ Comprehensive tagging support

**Use Cases:**
- Kubernetes/EKS clusters
- Multi-tier applications
- Microservices architecture
- Development/staging environments

---

### Compute
*Coming Soon*
- EC2 Auto Scaling Groups
- ECS/Fargate Clusters
- Lambda Functions

### Storage
*Coming Soon*
- S3 Buckets with versioning and encryption
- EFS File Systems
- RDS Database Clusters

### Security
*Coming Soon*
- Security Groups
- IAM Roles and Policies
- Secrets Manager

### Observability
*Coming Soon*
- CloudWatch Dashboards
- Log Aggregation
- Monitoring and Alerting

## 🎯 Design Philosophy

### 1. **Modularity First**
Each module is self-contained and focuses on a single responsibility. Mix and match modules to build complex infrastructure.

### 2. **Configuration Over Code**
Modules are highly configurable through variables, reducing the need to fork or modify code.

### 3. **Sensible Defaults**
Production-ready defaults that can be overridden when needed. Get started quickly, customize when necessary.

### 4. **Documentation as Code**
Every module includes:
- Detailed README with examples
- Input/output documentation
- Architecture diagrams

### 5. **Real-World Tested**
These aren't theoretical modules. They're built from actual production needs and refined through use.

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- Basic understanding of AWS services
- An AWS account

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/YOUR_USERNAME/terraform-modules.git
cd terraform-modules
```

2. **Choose a module:**
```bash
cd resources/vpc-eg
```

3. **Customize for your needs:**
```bash
# Edit terraform.tfvars with your values
```

5. **Deploy:**
```bash
terraform init
terraform plan
terraform apply
```

### Using Modules in Your Project

Reference modules directly from this repository:

```hcl
module "vpc" {
  source = "git::https://github.com/YOUR_USERNAME/terraform-modules.git//terraform-vpc-module?ref=v1.0.0"

  name_prefix          = "my-project"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_count  = 3
  private_subnet_count = 3
}
```

Or use local modules:

```hcl
module "vpc" {
  source = "../terraform-modules/terraform-vpc-module"
  
  # ... configuration
}
```

## 📖 Module Standards

All modules in this repository follow these standards:

### File Structure
```
module-name/
├── main.tf              # Main resource definitions
├── variables.tf         # Input variables with validation
├── outputs.tf           # Output values
├── versions.tf          # Terraform and provider versions
├── README.md            # Documentation
├── examples/            # Usage examples
│   └── complete/
│       └── main.tf
└── tests/               # Automated tests (where applicable)
```

### Variable Naming Conventions
- Use descriptive names: `enable_nat_gateway` not `enable_nat`
- Boolean variables start with `enable_` or `create_`
- Count variables end with `_count`
- ARNs end with `_arn`
- IDs end with `_id`

### Required Documentation
- Module purpose and use cases
- Input variable descriptions with types and defaults
- Output descriptions
- Complete usage examples
- Architecture diagrams (where helpful)

### Tagging Strategy
All modules support a `tags` variable for consistent resource tagging:

```hcl
tags = {
  Environment  = "production"
  Project      = "my-app"
  ManagedBy    = "terraform"
  Owner        = "platform-team"
  CostCenter   = "engineering"
}
```

### Testing Locally

```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# Plan (dry-run)
terraform plan

# Apply
terraform apply 
```

### Contribution Guidelines

While this is a personal repository, I welcome suggestions and improvements:

1. **Open an issue** to discuss proposed changes
2. **Fork the repository** and create a feature branch
3. **Follow existing code style** and conventions
4. **Add/update documentation** for any changes
5. **Submit a pull request** with a clear description


## Learning Resources

If you're new to Terraform or want to learn more:

- [Official Terraform Documentation](https://www.terraform.io/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)

## Roadmap

### Short Term
- [ ] EC2 Auto Scaling Group module
- [ ] RDS database cluster module
- [ ] S3 bucket module with encryption

### Medium Term
- [ ] EKS cluster module
- [ ] ECS/Fargate module
- [ ] Lambda function module

### Long Term
- [ ] Multi-region deployment patterns
- [ ] Disaster recovery modules
- [ ] Service mesh integration
- [ ] GitOps integration examples

## 💡 Why I Built This

As a DevOps/Cloud Engineer, I found myself repeatedly creating similar infrastructure components across different projects. This repository serves multiple purposes:

1. **Personal Knowledge Base**: Codified best practices and patterns I've learned
2. **Rapid Deployment**: Quickly spin up proven infrastructure for new projects
3. **Portfolio**: Demonstrate my Terraform and AWS expertise
4. **Community Contribution**: Share knowledge with others on similar journeys

## Blog Posts & Articles

I write about my experiences with DevOps and infrastructure as code:

https://syedamasarath.substack.com/p/how-to-make-aws-eks-auto-production

https://syedamasarath.substack.com/p/git-branching-strategies-for-devops

## Connect With Me

- **GitHub**: https://github.com/SyedaMasarath
- **LinkedIn**: https://www.linkedin.com/in/syeda-masarath-zaidi/
- **Blog**: https://syedamasarath.substack.com/


## ⭐ Show Your Support

If you find these modules helpful, please consider:
- Giving this repository a star ⭐
- Sharing it with others
---

**Built with ❤️ and ☕ by Masarath**

