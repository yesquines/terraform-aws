resource "aws_launch_configuration" "lc_web" {
  name            = "lc-web"
  image_id        = data.aws_ami.image_ec2.id
  instance_type   = "t2.micro"
  user_data       = file("files/apache.sh")
  security_groups = [aws_security_group.fw_web.id]
}

resource "aws_autoscaling_group" "ag_web" {
  name                 = "ag-web"
  max_size             = 3
  min_size             = 1
  desired_capacity     = 1
  health_check_type    = "EC2"
  iam_instance_profile = aws_iam_instance_profile.s3_access_profile.id
  launch_configuration = aws_launch_configuration.lc_web.name
  target_group_arns    = [aws_lb_target_group.lb_tg.arn]
  vpc_zone_identifier  = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  depends_on           = [time_sleep.wait_time]
}

resource "aws_autoscaling_policy" "ag_scale_up" {
  name                   = "ag-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ag_web.name
}

resource "aws_cloudwatch_metric_alarm" "ag_metric_up" {
  alarm_name          = "ag-metric-up"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  threshold           = "80"
  statistic           = "Average"
  evaluation_periods  = "2"
  namespace           = "AWS/EC2"
  period              = "60"
  alarm_actions       = [aws_autoscaling_policy.ag_scale_up.arn]
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.ag_web.name }
}

resource "aws_autoscaling_policy" "ag_scale_down" {
  name                   = "ag-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ag_web.name
}

resource "aws_cloudwatch_metric_alarm" "ag_metric_down" {
  alarm_name          = "ag-metric-down"
  comparison_operator = "LessThanThreshold"
  metric_name         = "CPUUtilization"
  threshold           = "60"
  statistic           = "Average"
  evaluation_periods  = "2"
  namespace           = "AWS/EC2"
  period              = "300"
  alarm_actions       = [aws_autoscaling_policy.ag_scale_down.arn]
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.ag_web.name }
}
