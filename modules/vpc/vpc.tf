resource "aws_vpc" "test-vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
  
}

resource "aws_internet_gateway" "test_igw" {
    vpc_id = aws_vpc.test-vpc.id
  
}

resource "aws_subnet" "test_subnet" {
    vpc_id = aws_vpc.test-vpc.id
    for_each = var.subnet
    cidr_block = each.value.cidr
    availability_zone = each.value.az
    map_public_ip_on_launch = each.value.public
  
}

resource "aws_eip" "test_eip" {
    domain = "vpc"
  
}

resource "aws_nat_gateway" "test_nat" {
    allocation_id = aws_eip.test_eip.id
    subnet_id = aws_subnet.test-subnet[
        keys({
            for k,s in var.subnet : k=>s if s.public == true
        })[0]
        ].id
  
}

resource "aws_route_table" "test_public_rtb" {
    vpc_id = aws_vpc.test-vpc.id
    route {
        cidr_block = var.route_cidr
        gateway_id = aws_internet_gateway.test_igw.id
    }
  
}

resource "aws_route_table_association" "test_public_rtba" {
   for_each = {
    for k,s in var.subnet : k=>s if s.public == true
   }

   route_table_id = aws_route_table.test-public-rtb.id
   subnet_id = aws_subnet.test-subnet[each.key].id
  
}

resource "aws_route_table" "test_private_rtb" {
    vpc_id = aws_vpc.test-vpc.id
    route {
        cidr_block = var.route_cidr
        gateway_id = aws_nat_gateway.test_nat.id
    }
  
}

resource "aws_route_table_association" "test_private_rtba" {
    for_each = {
      for k,s in var.subnet : k=>s if s.public == false 
    }
    route_table_id = aws_route_table.test_private_rtb.id
    subnet_id = aws_subnet.test-subnet[each.key].id
  

}