variable "server_port" {
    description = "HTTP"
    default = 9090
}
variable "server_port2" {
    description = "SSH"
    default = 22
}

variable "cluster_name" {
  description = "webcluster resources name"
}

variable "instance_type" {
  description = "type of EC2 Instances"
}

variable "min_size" {
  description = "min number of EC2 Instances in the ASG"
}

variable "max_size" {
  description = "max number of EC2 Instances in the ASG"
}

variable "desired" {
  description = "desired EC2 Instances in ASG"
}

variable "enable_autoscaling" {
  description = "autoscaling true/false"
}

variable "app_data_v2" {
  description = "if true, then enable the new app_data vers."
}
