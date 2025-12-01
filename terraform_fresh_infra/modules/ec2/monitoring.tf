resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.project_name}-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when EC2 CPU exceeds 80%"
  alarm_actions       = []

  dimensions = {
    InstanceId = aws_instance.app.id
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  alarm_name          = "${var.project_name}-ec2-status-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alert when EC2 instance status check fails"
  alarm_actions       = []

  dimensions = {
    InstanceId = aws_instance.app.id
  }
}

resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/aws/ec2/${var.project_name}-instance"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-logs"
  }
}
