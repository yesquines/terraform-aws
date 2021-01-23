//Show the loadbalancer DNS
output "loadbalancer_dns" {
  value = aws_lb.lb_web.dns_name
}
