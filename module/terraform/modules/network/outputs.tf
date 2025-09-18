output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "public_subnet_map" {
  value = aws_subnet.public
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "private_subnet_map" {
  value = aws_subnet.private
}

output "public_security_group_id" {
  value = aws_security_group.public.id
}

output "private_security_group_id" {
  value = aws_security_group.private.id
}
