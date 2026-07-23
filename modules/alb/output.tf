output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "read_target_group_arn" {
  value = aws_lb_target_group.read.arn
}

output "write_target_group_arn" {
  value = aws_lb_target_group.write.arn
}
