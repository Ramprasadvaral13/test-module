resource "aws_security_group" "test-sg" {
    name = "${var.name_prefix}-asg-sg"
    description = "test-sg"
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
  
}


data "aws_ssm_parameter" "golden_ami" {
    name = "/golden-ami/latest"
  
}

data "aws_iam_instance_profile" "existing" {
    name = var.instance_profile_name
  
}

resource "aws_launch_template" "test_lt" {
    name_prefix = "$(var.name_prefix)-lt"
    image_id = data.aws_ssm_parameter.golden_ami.value
    instance_type = var.instance_type
    vpc_security_group_ids = [ aws_security_group.test-sg.id ]
    key_name = var.key_name

    block_device_mappings {
      device_name = "/dev/xvda"
      ebs {
        volume_size = var.volume_size
        volume_type = "gp3"
        delete_on_termination = true

      }
    }

    iam_instance_profile {
      name = data.aws_iam_instance_profile.existing.name
    }
  
}

resource "aws_autoscaling_group" "test_asg" {
    name = "$(var.name_prefix)-asg"
    min_size = var.min_size
    max_size = var.max_size
    desired_capacity = var.desired_capacity
    vpc_zone_identifier = var.subnet_ids
    health_check_type = "EC2"
    force_delete = true
    wait_for_capacity_timeout = "0"

    launch_template {
      version = "$Latest"
      id = aws_launch_template.test_lt.id
    }

     tag {
      key = "Name"
      value = "${var.name_prefix}-instance"
      propagate_at_launch = true
    }

   tag {
    key                 = "env"
    value               = "dev"
    propagate_at_launch = true
  }
  
}