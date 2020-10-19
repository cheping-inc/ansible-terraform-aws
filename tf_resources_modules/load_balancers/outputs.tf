#add LB DNS name to outputs
output "LB-DNS-NAME" {
  value = aws_lb.application_lb.dns_name
}