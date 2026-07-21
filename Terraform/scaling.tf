resource "aws_autoscaling_policy" "backend_cpu_policy" {

  name = "backend-cpu-scaling"

  autoscaling_group_name = aws_autoscaling_group.backend.name

  policy_type = "TargetTrackingScaling"


  target_tracking_configuration {

    predefined_metric_specification {

      predefined_metric_type = "ASGAverageCPUUtilization"

    }


    target_value = 70

  }

}