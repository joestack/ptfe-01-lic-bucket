# variable "bucket_name" {
#     description = "name of the bucket"
#     default     = "joestack-tfe-bootstrap-bucket"
# }

# variable "kms_key_alias" {
#   type        = string
#   description = "Key alias for the AWS KMS Customer managed key"
#   default     = "joestack-kms"
# }

variable "region" {
  
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
    repl_password = "youmustbemadtousethisinproduction"
    enc_password  = "youreallywanttooverridethesevalues"
  }

  type = map
}

locals {
  bucket_name   = "${var.name}-tfe-bootstrap-bucket"
  kms_key_alias = "${var.name}-kms"
}