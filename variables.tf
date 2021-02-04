# variable "bucket_name" {
#     description = "name of the bucket"
#     default     = "joestack-tfe-bootstrap-bucket"
# }

# variable "kms_key_alias" {
#   type        = string
#   description = "Key alias for the AWS KMS Customer managed key"
#   default     = "joestack-kms"
# }

variable "aws_region" {
  default = "eu-west-1"
}

variable "key_name" {
  default = "joestack"
}

variable "name" {
  type        = string
  description = "unique name of the installation"
  default     = "joestack"
}

variable "tfe_licence_rli" {
  type        = string
  description = "content of the TFE licence.rli file"
}

variable "ptfe_secrets" {
  default = {
    repl_password = "you_must_be_mad_to_use_this_in_production"
    enc_password  = "you_really_want_to_override_these_values"
  }

  type = map
}

locals {
  bucket_name   = "${var.name}-tfe-bootstrap-bucket"
  kms_key_alias = "${var.name}-kms"
}