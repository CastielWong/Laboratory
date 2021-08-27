# scale up alarm

resource "aws_autoscaling_policy" "demo-cpu-scaleup-policy" {
  name                   = "demo-cpu-scaleup-policy"
  autoscaling_group_name = aws_autoscaling_group.demo-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "demo-cpu-scaleup-alarm" {
  alarm_name          = "demo-cpu-scaleup-alarm"
  alarm_description   = "demo-cpu-scaleup-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.demo-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.demo-cpu-scaleup-policy.arn]
}

# scale down alarm
resource "aws_autoscaling_policy" "demo-cpu-scaledown-policy" {
  name                   = "demo-cpu-scaledown-policy"
  autoscaling_group_name = aws_autoscaling_group.demo-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "demo-cpu-scaledown-alarm" {
  alarm_name          = "demo-cpu-scaledown-alarm"
  alarm_description   = "demo-cpu-scaledown-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.demo-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.demo-cpu-scaledown-policy.arn]
}
