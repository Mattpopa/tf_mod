data "aws_availability_zones" "all" {}

data "terraform_remote_state" "dbs" {
  backend = "s3"
  environment = "${terraform.env}"
  config {
    bucket  = "wip-tf-state-080817"
    key     = "dbs"
    region  = "eu-central-1"
    encrypt = true
    profile = "cyclones-dev"
  }
}

data "template_file" "user_data" {
    template = "${file("${path.module}/user_data.sh")}"

        vars {
            server_port = "${var.server_port}"
            db_address = "${data.terraform_remote_state.dbs.address}"
            db_port = "${data.terraform_remote_state.dbs.port}"
        }
}

resource "aws_launch_configuration" "wip-020817" {
    image_id = "ami-1e339e71"
    instance_type = "${var.instance_type}"
    key_name = "mpopa"
    security_groups = ["${aws_security_group.instance.id}", "${aws_security_group.instance2.id}"]

    #user_data = "${file("user_data.sh")}"
    user_data = "${data.template_file.user_data.rendered}"

   lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-wip-020817"
    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "instance2" {
    name = "${var.cluster_name}-wip-170817"
    ingress {
        from_port = "${var.server_port2}"
        to_port = "${var.server_port2}"
        protocol = "tcp"
        cidr_blocks = ["78.96.101.50/32", "109.166.0.0/16"]
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "wip-020817" {
    launch_configuration = "${aws_launch_configuration.wip-020817.id}"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    load_balancers = ["${aws_elb.wip-elb.name}"]
    health_check_type = "ELB"
    min_size = "${var.min_size}" 
    max_size = "${var.max_size}"
    tag {
        key = "Name"
        value = "${var.cluster_name}-wip-asg-060817"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_schedule" "scale_out" {
    count = "${var.enable_autoscaling}"
    scheduled_action_name = "scale-out-during-business-hours"
    min_size = "${var.min_size}" 
    max_size = "${var.max_size}"
    desired_capacity      = "${var.desired}"
    recurrence            = "0 9 * * *"
    autoscaling_group_name = "${module.webcluster.asg_name}"
}

resource "aws_autoscaling_schedule" "scale_in" {
    count = "${var.enable_autoscaling}"
    scheduled_action_name = "scale-in-at-night"
    min_size = "${var.min_size}" 
    max_size = "${var.max_size}"
    desired_capacity      = "${var.desired}"
    recurrence            = "0 17 * * *"
    autoscaling_group_name = "${module.webcluster.asg_name}"
}

resource "aws_elb" "wip-elb" {
    name = "${var.cluster_name}-wip-020817"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups = ["${aws_security_group.elb.id}"]    
    listener {
        lb_port = 80
        lb_protocol = "http"
        instance_port = "${var.server_port}"
        instance_protocol = "http"
    }
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        interval = 30
        target = "HTTP:${var.server_port}/"
    }
}

resource "aws_security_group" "elb" {
    name = "${var.cluster_name}-elb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = "${aws_security_group.elb.id}"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_outbound" {
    type = "egress"
    security_group_id = "${aws_security_group.elb.id}"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}


