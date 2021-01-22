data "aws_subnet_ids" "lb_subnets" {
  vpc_id     = aws_vpc.vpc_web.id
  depends_on = [aws_subnet.public_subnet1, aws_subnet.public_subnet2]
  tags = {
    Network = "public"
  }
}

resource "aws_lb" "lb_web" {
  name               = "lb-web"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.fw_web.id]
  subnets            = data.aws_subnet_ids.lb_subnets.ids
  internal           = false

}

resource "aws_lb_target_group" "lb_tg" {
  name     = "lb-tg-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_web.id
}

resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.instace_web.id
  port             = 80
}

resource "aws_lb_listener" "lb_backend" {
  load_balancer_arn = aws_lb.lb_web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}
