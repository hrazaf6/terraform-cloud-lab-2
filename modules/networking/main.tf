resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name  = var.vpc_name
    Owner = var.environment
  }
}

resource "aws_internet_gateway" "this" {
  count = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags = {
    Name  = var.vpc_name
    Owner = var.environment
  }
}

resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnet_names) > 0 ? length(var.public_subnet_names) : 0
  vpc_id     = aws_vpc.this[0].id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  tags = {
    Name  = var.vpc_name
    Owner = var.environment
  }
}

resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnet_names) > 0 ? length(var.private_subnet_names) : 0
  vpc_id     = aws_vpc.this[0].id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index+length(var.public_subnet_names))
  tags = {
    Name  = var.vpc_name
    Owner = var.environment
  }
}

resource "aws_eip" "this" {
  count = var.create_vpc && length(var.private_subnet_names) > 0 ? 1 : 0
  vpc = true
  tags = {
    Name  = var.vpc_name
    Owner = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  count = var.create_vpc && length(var.private_subnet_names) > 0 ? 1 : 0
  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name  = var.vpc_name
    Owner = var.environment
  }
}

resource "aws_route_table" "public_rt" {
  count = var.create_vpc && length(var.public_subnet_names) > 0 ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name  = var.vpc_name
    Owner = var.environment
  }
}

resource "aws_route_table" "private_rt" {
  count = var.create_vpc && length(var.private_subnet_names) > 0 ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }

  tags = {
    Name  = var.vpc_name
    Owner = var.environment
  }
}

resource "aws_route_table_association" "public_subnet" {
  count = var.create_vpc && length(var.public_subnet_names) > 0 ? length(var.public_subnet_names) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt[0].id
}

resource "aws_route_table_association" "private_subnet" {
  count = var.create_vpc && length(var.private_subnet_names) > 0 ? length(var.private_subnet_names) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[0].id
}


