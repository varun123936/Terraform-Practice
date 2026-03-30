resource "aws_launch_template" "frontend" {
  name_prefix            = "${var.name_prefix}-frontend-lt-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.frontend_sg_id]
  key_name               = var.key_name
  update_default_version = true

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.instance_name
    }
  }
}
