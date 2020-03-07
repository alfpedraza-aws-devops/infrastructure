# ----------------------------------------------------------------------------#
# Required Parameters                                                         #
# ----------------------------------------------------------------------------#

variable "account_id" {
  description = "The AWS account id running this example project"
  type = string
}

variable "region_name" {
  description = "The name of the region where the resources will be created"
  type = string
}

variable "project_name" {
  description = "The name of this aws-devops example project"
  type = string
}

variable "jenkins_admin_password" {
  description = "The password for the Jenkins admin user"
  type = string
}

variable "aws_access_key_id" {
  description = "An AWS access key associated with an IAM user or role"
  type = string
}

variable "aws_secret_access_key" {
  description = "The secret key associated with the access key"
  type = string
}

# ----------------------------------------------------------------------------#
# Optional Parameters                                                         #
# ----------------------------------------------------------------------------#

variable "server_instance_type" {
  description = "The instance type for the Jenkins server"
  type = string
  default = "t2.micro"
}

locals {
    vpc_availability_zone = join("", [var.region_name, "a"])
    common_tags = {
        ApplicationId = var.project_name
    }
}