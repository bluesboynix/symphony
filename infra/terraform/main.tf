# Configure AWS provider
provider "aws" {
  region = "ap-south-1"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "devops-vpc"
  }
}

# Create subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "devops-subnet"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "devops-igw"
  }
}

# Create route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "devops-rt"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# Create security group
resource "aws_security_group" "sg" {
  name        = "devops-sg"
  description = "Allow SSH, HTTP, HTTPS and custom port"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}

# Create EC2 instance
resource "aws_instance" "app_server" {
  ami           = "ami-0b5317ee10bd261f7" # Debian 13 in ap-south-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  
  tags = {
    Name = "terraform-ec2"
  }
}

# Create S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "devops-project-bucket-12345" # Change to unique name
  tags = {
    Name = "devops-bucket"
  }
}

resource "aws_db_instance" "database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  #engine_version       = "8.0.35"       # ✅ Supported in ap-south-1
  instance_class       = "db.t3.micro"  # ✅ Free tier eligible
  db_name              = "devopsdb"
  username             = "admin"
  password             = "password123"  # Change in production
  skip_final_snapshot  = true
  publicly_accessible  = true

  tags = {
    Name = "devops-rds"
  }
}


output "instance_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.database.endpoint
}
