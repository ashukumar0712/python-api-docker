output "dns_name" {
  description = "The DNS name of the Flas APP load balancer."
  value       = aws_alb.application_load_balancer.dns_name
}