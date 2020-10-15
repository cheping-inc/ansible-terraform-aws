#creation of VPC for master
resource "aws_vpc" "vpc_master" {
  provider             = aws.region_master
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "master-vpc-jenkins"
    tools = "terraform"
  }
}

#creation of VPC for workers
resource "aws_vpc" "vpc_worker" {
  provider             = aws.region_worker
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "worker-vpc-jenkins"
    tools = "terraform"
  }
}

#creation IGW for master
resource "aws_internet_gateway" "igw_master" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
}

#creation IGW for worker
resource "aws_internet_gateway" "igw_worker" {
  provider = aws.region_worker
  vpc_id   = aws_vpc.vpc_worker.id
}

#Get available AZ in VPC for master region
data "aws_availability_zones" "az_master" {
  provider = aws.region_master
  state    = "available"
}

#Get available AZ in VPC for worker region
data "aws_availability_zones" "az_worker" {
  provider = aws.region_worker
  state    = "available"
}

#Create Subnet #1 for master
resource "aws_subnet" "subnet_master_1" {
  provider          = aws.region_master
  cidr_block        = "10.1.1.0/24"
  availability_zone = element(data.aws_availability_zones.az_master.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
}

#Create Subnet #2 for master
resource "aws_subnet" "subnet_master_2" {
  provider          = aws.region_master
  cidr_block        = "10.1.2.0/24"
  availability_zone = element(data.aws_availability_zones.az_master.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
}

#Create Subnet for worker
resource "aws_subnet" "subnet_worker" {
  provider          = aws.region_worker
  cidr_block        = "10.2.1.0/24"
  availability_zone = element(data.aws_availability_zones.az_worker.names, 0)
  vpc_id            = aws_vpc.vpc_worker.id
}

#initiate peering connection request from master region
resource "aws_vpc_peering_connection" "peering_master_worker" {
  provider    = aws.region_master
  vpc_id      = aws_vpc.vpc_master.id
  peer_vpc_id = aws_vpc.vpc_worker.id
  peer_region = var.region_worker
}

#Accept VPC peering request in worker region from master region
resource "aws_vpc_peering_connection_accepter" "worker_accept_peering" {
  provider                  = aws.region_worker
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_master_worker.id
  auto_accept               = true
}

#create route table in master region
resource "aws_route_table" "internet_route_master" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_master.id
  }
  route {
    cidr_block                = "10.2.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering_master_worker.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RT"
  }
}

#add route table to VPC master
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region_master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route_master.id
}

#create route table in worker region
resource "aws_route_table" "internet_route_worker" {
  provider = aws.region_worker
  vpc_id   = aws_vpc.vpc_worker.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_worker.id
  }
  route {
    cidr_block                = "10.1.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering_master_worker.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Worker-Region-RT"
  }
}

#add route table to VPC worker
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider       = aws.region_worker
  vpc_id         = aws_vpc.vpc_worker.id
  route_table_id = aws_route_table.internet_route_worker.id
}

