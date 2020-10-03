resource "aws_eip" "nat_public_subnet_a" {
  tags = {
    Name = "public_nat_a"
  }
}

resource "aws_nat_gateway" "ngw_subnet_a" {
  allocation_id = aws_eip.nat_public_subnet_a.id
  subnet_id     = aws_subnet.public_subnet_a.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_public_subnet_b" {
  tags = {
    Name = "public_nat_b"
  }
}

resource "aws_nat_gateway" "ngw_subnet_b" {
  allocation_id = aws_eip.nat_public_subnet_b.id
  subnet_id     = aws_subnet.public_subnet_b.id
  depends_on = [aws_internet_gateway.igw]
}
