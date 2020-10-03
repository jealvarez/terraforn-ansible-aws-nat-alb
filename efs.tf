resource "aws_efs_file_system" "private_efs" {
  creation_token = "private_efs"

  tags = {
    Name = "private_efs"
  }
}

resource "aws_security_group" "allow_efs_traffic" {
  name   = "allow_efs_traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_efs_mount_target" "efs_mount_target_private_subnet_a" {
  file_system_id  = aws_efs_file_system.private_efs.id
  subnet_id       = aws_subnet.private_subnet_a.id
  security_groups = ["${aws_security_group.allow_efs_traffic.id}"]
}

resource "aws_efs_mount_target" "efs_mount_target_private_subnet_b" {
  file_system_id  = aws_efs_file_system.private_efs.id
  subnet_id       = aws_subnet.private_subnet_b.id
  security_groups = ["${aws_security_group.allow_efs_traffic.id}"]
}
