output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = [
    for key, subnet in aws_subnet.this : subnet.id
    if var.subnets[key].public
  ]
}

output "private_app_subnet_ids" {
  value = [
    for key, subnet in aws_subnet.this : subnet.id
    if !var.subnets[key].public && can(regex("private-app", key))
  ]
}

output "private_db_subnet_ids" {
  value = [
    for key, subnet in aws_subnet.this : subnet.id
    if !var.subnets[key].public && can(regex("private-db", key))
  ]
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value       = aws_route_table.private.id
}