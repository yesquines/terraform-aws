//Create a load balancer in public subnet and Add the ec2 instance, under the load balancer
resource "aws_lb" "lb_web" {
  name               = var.loadbalancer_name
  load_balancer_type = var.loadbalancer_type
  security_groups    = [aws_security_group.fw_web.id]
  subnets            = data.aws_subnet_ids.lb_subnets.ids
  internal           = false
}

resource "aws_lb_target_group" "lb_tg" {
  name     = var.loadbalancer_targetgroup_name
  port     = var.loadbalancer_port
  protocol = var.loadbalancer_protocol
  vpc_id   = aws_vpc.vpc_web.id
}

resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.instace_web.id
  port             = var.loadbalancer_port
}

resource "aws_lb_listener" "lb_backend" {
  load_balancer_arn = aws_lb.lb_web.arn
  port              = var.loadbalancer_port
  protocol          = var.loadbalancer_protocol

  default_action {
    type             = var.lb_action_type
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

