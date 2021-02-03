output "tfe_bootstrap_bucket" {
  value = aws_s3_bucket.tfe_bootstrap.id
}

output "kms_key_arn" {
  value = aws_kms_key.tfe_key.arn
}

output "aws_secret_arn" {
  value = aws_secretsmanager_secret.ptfe_js.arn
}
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Subnets
output "ec2_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "alb_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "rds_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}
