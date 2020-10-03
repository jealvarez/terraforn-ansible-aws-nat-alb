resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_subnet_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "rt_private_subnet_a" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_subnet_a.id
  }
}

resource "aws_route_table_association" "rta_web_server_a_to_ngw_a" {
  route_table_id = aws_route_table.rt_private_subnet_a.id
  subnet_id      = aws_subnet.private_subnet_a.id
}

resource "aws_route_table_association" "public_subnet_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "rt_private_subnet_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_subnet_b.id
  }
}

resource "aws_route_table_association" "rta_web_server_b_to_ngw_b" {
  route_table_id = aws_route_table.rt_private_subnet_b.id
  subnet_id      = aws_subnet.private_subnet_b.id
}
