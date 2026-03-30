resource "aws_autoscaling_group" "frontend" {
  name_prefix         = "${var.name_prefix}-frontend-asg-"
  desired_capacity    = var.frontend_desired_capacity
  max_size            = var.frontend_max_size
  min_size            = var.frontend_min_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.frontend_target_group_arn]
  health_check_type   = "ELB"

  launch_template {
    id      = var.frontend_launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-frontend-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "frontend_scale_out" {
  name                   = "${var.name_prefix}-frontend-scale-out"
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.scale_out_target_value
  }
}
