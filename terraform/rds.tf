# 2. Create a VPC and a Subnet (Required for RDS)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  # Required for RDS if you don't specify availability_zone
  availability_zone = "us-east-1a"
}

# 3. Create a DB Subnet Group (Required for RDS)
resource "aws_db_subnet_group" "main" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.main.id]
}

# 4. Create a Security Group to control access
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow inbound traffic to RDS"
  vpc_id      = aws_vpc.main.id

  # Allow PostgreSQL traffic from your IP (Optional)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Create the Free-Tier RDS Instance
resource "aws_db_instance" "free_tier_postgres" {
  # --- Free Tier Required Settings ---
  instance_class      = "db.t3.micro" # Free tier eligible instance type[reference:0][reference:1]
  allocated_storage   = 20            # Max free tier storage (GB)[reference:2][reference:3]
  storage_type        = "gp2"         # Must be gp2, not gp3[reference:4]
  engine              = "postgres"    # Must be one of: MySQL, MariaDB, PostgreSQL, or SQL Server Express[reference:5]
  engine_version      = "15.4"        # Specify a version
  publicly_accessible = false         # Important for security and cost

  # --- Database Credentials ---
  db_name  = "neo-db"
  username = "postgres"
  password = var.rds_db_password # Use a secure password

  # --- Networking and Access ---
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # --- Backup and Maintenance (Free Tier includes 20GB for backups)[reference:6] ---
  backup_retention_period = 7 # Keep backups for 7 days (0 to disable)
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # --- Additional Free Tier & Safety Settings ---
  skip_final_snapshot = true  # Set to false for production to keep a final snapshot
  deletion_protection = false # Set to true for production to prevent accidental deletion
  multi_az            = false # Must be false for free tier (single-AZ only)[reference:7]
  storage_encrypted   = true  # Enable encryption (Good practice, but check if it affects free tier)

  tags = {
    Name = "Free-Tier-PostgreSQL"
  }
}