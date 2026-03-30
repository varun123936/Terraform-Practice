resource "aws_autoscaling_group" "backend" {
  name_prefix         = "${var.name_prefix}-backend-asg-"
  desired_capacity    = var.backend_desired_capacity
  max_size            = var.backend_max_size
  min_size            = var.backend_min_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.backend_target_group_arn]
  health_check_type   = "ELB"

  launch_template {
    id      = var.backend_launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-backend-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "backend_scale_out" {
  name                   = "${var.name_prefix}-backend-scale-out"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.scale_out_target_value
  }
}
