data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


data "template_file" "tfe_s3_bootstrap_bucket_policy" {
  template = file("${path.module}/templates/tfe-s3-bootstrap-bucket-policy.json")

  vars = {
    tfe_s3_bootstrap_bucket_arn  = aws_s3_bucket.tfe_bootstrap.arn
    aws_account_id               = data.aws_caller_identity.current.account_id
    current_iam_user_arn         = data.aws_caller_identity.current.arn
  }
}

resource "aws_kms_key" "tfe_key" {
  description             = "AWS KMS Customer-managed key to encrypt TFE and other resources"
  key_usage               = "ENCRYPT_DECRYPT"
  #policy                  = data.template_file.kms_key_policy.rendered
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = false

  tags = {
    Name = "TFE-BASE-KMS-CMK"
  }
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.tfe_key.id
}

resource "aws_s3_bucket" "tfe_bootstrap" {
  bucket = var.bucket_name
  region = data.aws_region.current.name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.tfe_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


resource "aws_s3_bucket_public_access_block" "tfe_bootstrap_block_public" {
  bucket = aws_s3_bucket.tfe_bootstrap.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

  depends_on = [aws_s3_bucket.tfe_bootstrap]
}


resource "aws_s3_bucket_policy" "tfe_s3_bootstrap_bucket_policy" {
  bucket = aws_s3_bucket.tfe_bootstrap.id
  policy = data.template_file.tfe_s3_bootstrap_bucket_policy.rendered

  depends_on = [aws_s3_bucket_public_access_block.tfe_bootstrap_block_public]
}


resource "local_file" "tfe_licence_rli" {
  
  content  = var.tfe_licence_rli
  filename = "${path.root}/tfe-license.rli"
}




resource "null_resource" "copy_license" {
 
  depends_on = [aws_s3_bucket.tfe_bootstrap]

  #triggers = {
  #  always_run = timestamp()
  #}

  provisioner "local-exec" {
    command = "aws s3 cp ${path.root}/tfe-license.rli s3://${var.bucket_name}/tfe-license.rli "
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.25.0"
  # insert the 8 required variables here


  name = "joestack-ptfev4"
  cidr = "10.0.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = var.name
  }

}

resource "aws_secretsmanager_secret" "ptfe_secrets" {
  name = "ptfe-sec-${var.name}-1"
  recovery_window_in_days = 0
}


resource "aws_secretsmanager_secret_version" "ptfe" {
  secret_id     = aws_secretsmanager_secret.ptfe_secrets.id
  secret_string = jsonencode(var.ptfe_secrets)
}
