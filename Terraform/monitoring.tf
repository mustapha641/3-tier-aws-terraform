resource "aws_cloudwatch_log_group" "backend_logs" {

  name = "/aws/ec2/backend"

  retention_in_days = 7

}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {

  alarm_name = "backend-high-cpu"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = 300

  statistic = "Average"

  threshold = 80


  alarm_description = "Triggers when EC2 CPU exceeds 80%"


  dimensions= {

    AutoScalingGroupName = aws_autoscaling_group.backend.name

  }

}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {


  alarm_name = "rds-high-cpu"


  comparison_operator = "GreaterThanThreshold"


  evaluation_periods = 2


  metric_name = "CPUUtilization"


  namespace = "AWS/RDS"


  period = 300


  statistic = "Average"


  threshold = 80


  dimensions= {

    DBInstanceIdentifier = aws_db_instance.postgres.id

  }


}