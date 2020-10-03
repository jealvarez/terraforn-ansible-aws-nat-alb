resource "aws_key_pair" "testing" {
  key_name   = "testing"
  public_key = file("${var.ssh_private_key_path}.pub")
}

resource "aws_security_group" "web_server" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

resource "aws_instance" "web_server_a" {
  ami                    = "ami-088c153f74339f34c"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_a.id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = aws_key_pair.testing.id
  tags = {
    Name = "web_server_a"
  }
}

resource "aws_instance" "web_server_b" {
  ami                    = "ami-088c153f74339f34c"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_b.id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = aws_key_pair.testing.id
  tags = {
    Name = "web_server_b"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-088c153f74339f34c"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.testing.id

  depends_on = [aws_route_table_association.rta_web_server_a_to_ngw_a, aws_route_table_association.rta_web_server_b_to_ngw_b]

  tags = {
    Name = "bastion"
  }

  provisioner "file" {
    source      = var.ssh_private_key_path
    destination = "/home/ec2-user/id_rsa"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("${var.ssh_private_key_path}")
    }
  }

  provisioner "file" {
    source      = "configuration/playbook.yml"
    destination = "/home/ec2-user/playbook.yml"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("${var.ssh_private_key_path}")
    }
  }

  provisioner "file" {
    source      = "configuration/index.html"
    destination = "/home/ec2-user/index.html"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("${var.ssh_private_key_path}")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 600 /home/ec2-user/id_rsa",
      "sudo yum install -y python36 python3-pip",
      "sudo pip install ansible",
      "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key /home/ec2-user/id_rsa -i '${aws_instance.web_server_a.private_ip},${aws_instance.web_server_b.private_ip},' /home/ec2-user/playbook.yml --extra-vars 'efs_id=${aws_efs_file_system.private_efs.id}'"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("${var.ssh_private_key_path}")
    }
  }
}
