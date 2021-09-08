# s3-cloudfront-static-website
[Terraform module](https://www.terraform.io/docs/language/modules/develop/index.html) for deploying a static website to an s3 bucket.

This module will create the following resources:

* A S3 bucket configured as a website;
* An Origin Access Identity with exclusive allowed to access to the bucket, as enforced by a bucket policy;
* A cloudfront distribution to acting as a CDN for the website;
* An IAM user, with IAM policy attached, permitting the user to update the contents of the S3 bucket, and invalidate cloudfront distributions;

It is expected that you have a **validated certificate** in [AWS ACM](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html), which corresponds to the domain at which you want to serve the website, and that you provide the ARN of this certificate to this module as a variable.

## Contributing
You will need:

### Prerequisites
* [Terraform](https://www.terraform.io/)
* [Pre-commit](https://pre-commit.com/)
* A decent text editor or IDE

### Getting started
Please install pre-commit hooks first:

```
pre-commit install
```

Hashicorp [recommend](https://www.terraform.io/docs/language/modules/develop/structure.html) that simple modules be structured with all resources in a single `main.tf` file. Please respect this structure in contributing to this project.

## Usage
As standard for a Terraform module.

## Deployment
`git push`
