variable "project_name" {
  type        = string
  description = "the name of this project"
  default     = "allgaeuer-hof-website"
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
