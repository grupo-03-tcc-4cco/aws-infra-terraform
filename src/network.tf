locals {
  cidr_public  = "192.168.0.0/24"
  cidr_private = "192.168.1.0/24"
}

resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/22"
  instance_tenancy = "default"

  tags = {
    Name      = "Main VPC"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.cidr_public

  tags = {
    Name      = "Public Main Subnet"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.cidr_private

  tags = {
    Name      = "Private Main Subnet"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route = [{
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = aws_internet_gateway.public.id
    carrier_gateway_id         = null
    core_network_arn           = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    instance_id                = null
    ipv6_cidr_block            = null
    local_gateway_id           = null
    nat_gateway_id             = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
  }]

  tags = {
    Name      = "Public Route Table"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route = [{
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = null
    carrier_gateway_id         = null
    core_network_arn           = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    instance_id                = null
    ipv6_cidr_block            = null
    local_gateway_id           = null
    nat_gateway_id             = aws_nat_gateway.nat.id
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
  }]

  tags = {
    Name      = "Private Route Table"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "Main Internet Gateway"
    ManagedBy = "Terraform"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name      = "NAT Gateway"
    ManagedBy = "Terraform"
  }

  depends_on = [
    aws_internet_gateway.public,
    aws_subnet.public
  ]
}

resource "aws_eip" "nat" {
  vpc = true
}