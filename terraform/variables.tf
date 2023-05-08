variable "ecr_repo_url" {
  type        = string
  description = "ECR Repo URI : "
}

variable "region" {
  type        = string
  description = "aws region. One of: https://aws.amazon.com/about-aws/global-infrastructure/regions_az/"
  default     = "eu-west-2"
}