# TODO setup users for DB access
# TODO save password in Secrect Manager & rotate
# TODO bug fix ssh_identity_file path issue



module "postgres" {
  source = "git@github.com:willfarrell/terraform-db-modules//rds?ref=v0.0.1"
  name   = local.workspace["name"]
  vpc_id = module.vpc.id

  private_subnet_ids = module.vpc.private_subnet_ids

  type              = local.workspace["postgres_type"]
  instance_type     = local.workspace["postgres_instance_type"]
  node_count        = local.workspace["postgres_node_count"]
  replica_count     = local.workspace["postgres_replica_count"]
  multi_az          = local.workspace["multi_az"]
  apply_immediately = local.workspace["apply_immediately"]

  db_name  = local.workspace["postgres_db_name"]
  username = "root"
  password = "password"

  engine                  = local.workspace["postgres_engine"]
  engine_version          = local.workspace["postgres_engine_version"]
  engine_mode             = local.workspace["postgres_engine_mode"]
  allocated_storage       = local.workspace["postgres_allocated_storage"]
  backup_retention_period = local.workspace["postgres_backup_retention_period"]

  bastion_ip = module.bastion.public_ip

  # bootstrap
  #ssh_username      = "iam.username"
  #ssh_identity_file = "~/.ssh/id_rsa"
  #bootstrap_folder        = "${local.workspace["postgres_bootstrap_folder"]}"

  security_group_ids = [
    #module.bastion.security_group_id,
    #module.ecs.security_group_id,
  ]
}

# SSM
resource "aws_ssm_parameter" "postgres_endpoint" {
  name        = "/database/postgres/endpoint"
  description = "Endpoint to connect to the database"
  type        = "String"
  value       = module.postgres.endpoint
}

resource "aws_ssm_parameter" "postgres_endpoints" {
  name        = "/database/postgres/endpoints"
  description = "Endpoints to connect to read the database"
  type        = "StringList"
  value       = join(",", module.postgres.replica_endpoints)
}

resource "aws_ssm_parameter" "postgres_port" {
  name        = "/database/postgres/port"
  description = "Port to connect to the database"
  type        = "String"
  value       = module.postgres.port
}

resource "aws_ssm_parameter" "postgres_username" {
  name        = "/database/postgres/username"
  description = "Username to connect to the database"
  type        = "SecureString"
  value       = module.postgres.username
}

resource "aws_ssm_parameter" "postgres_password" {
  name        = "/database/postgres/password"
  description = "Username to connect to the database"
  type        = "SecureString"
  value       = module.postgres.password
}

resource "aws_ssm_parameter" "postgres_database" {
  name        = "/database/postgres/database"
  description = "Database to connect to"
  type        = "String"
  value       = module.postgres.database
}

# Output
output "postgres_endpoint" {
  value = module.postgres.endpoint
}

output "postgres_replica_endpoints" {
  value = module.postgres.replica_endpoints
}

output "postgres_billing_suggestion" {
  value = module.postgres.billing_suggestion
}


