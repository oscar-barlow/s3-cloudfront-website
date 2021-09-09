variable "project_name" {
  type        = string
  description = "the name of this project"
}

variable "env" {
  type        = string
  description = "The environment (staging, prod, etc) in which the resource is to be created"
}

variable "domain" {
  type        = string
  description = "domain name"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate you wish to use to secure your website's domain"
}

variable "index_document" {
  type        = string
  description = "index document to be served by bucket-as-website"
}

variable "error_document" {
  type        = string
  description = "error document to be served by bucket-as-website"
}

variable "price_class" {
  type        = string
  description = "Cloudfront distribution price class"
}
