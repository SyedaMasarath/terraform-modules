#--------------------------------------------------------------
# VPC Outputs
#--------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

#--------------------------------------------------------------
# Internet Gateway Outputs
#--------------------------------------------------------------
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = var.create_igw ? aws_internet_gateway.main[0].id : null
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = var.create_igw ? aws_internet_gateway.main[0].arn : null
}

#--------------------------------------------------------------
# Public Subnet Outputs
#--------------------------------------------------------------
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_availability_zones" {
  description = "List of availability zones of public subnets"
  value       = aws_subnet.public[*].availability_zone
}

#--------------------------------------------------------------
# Private Subnet Outputs
#--------------------------------------------------------------
output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_availability_zones" {
  description = "List of availability zones of private subnets"
  value       = aws_subnet.private[*].availability_zone
}

#--------------------------------------------------------------
# NAT Gateway Outputs
#--------------------------------------------------------------
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs created for NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "nat_gateway_allocation_ids" {
  description = "List of Elastic IP allocation IDs for NAT Gateways"
  value       = aws_eip.nat[*].id
}

#--------------------------------------------------------------
# Route Table Outputs
#--------------------------------------------------------------
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

#--------------------------------------------------------------
# Availability Zones
#--------------------------------------------------------------
output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}
