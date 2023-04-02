# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "last-sem-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

resource "aws_security_group" "aws_sg" {
  name = "security group from terraform"

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "80 from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "7474 from the internet"
    from_port   = 7474
    to_port     = 7474
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "7473 from the internet"
    from_port   = 7473
    to_port     = 7473
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "7687 from the internet"
    from_port   = 7687
    to_port     = 7687
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "is434-ec2-neo4j-instance" {

  ami                         = "ami-007855ac798b5175e"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.aws_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.key_name
  tags = {
    Name = "IS434 Neo4J EC2"
  }
}

# create another ec2 with empty ubuntu image
resource "aws_instance" "analysis-compute-service" {
  ami                         = "ami-007855ac798b5175e"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.aws_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.key_name
  tags = {
    Name = "IS434 Neo4J EC2"
  }
}


