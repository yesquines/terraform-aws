// provider.tf variable
variable "region" {
  type        = string
  description = "Set Provide Region"
  default     = "us-east-1"
}

// role.tf variables
variable "s3_role_name" {
  type        = string
  description = "S3 Access role name"
  default     = "s3-access-role"
}

variable "s3_role_file_path" {
  type        = string
  description = "S3 Role file path (e.g /path/role.json)"
  default     = "files/s3_role.json"
}

variable "s3_policy_name" {
  type        = string
  description = "S3 Access Policy name"
  default     = "s3-access-policy"
}

variable "s3_policy_file_path" {
  type        = string
  description = "S3 Policy file path (e.g /path/policy.json)"
  default     = "files/s3_policy.json"
}

// network.tf variables
variable "vpc_name" {
  type        = string
  description = "VPC Name"
  default     = "vpc-web"
}

variable "vpc_network" {
  type        = string
  description = "Set a Network to a VPC (e.g 192.168.0.0/16)"
  default     = "192.168.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS Hostnames (true/false)"
  default     = true
}

variable "igw_name" {
  type        = string
  description = "Internet Gateway Name"
  default     = "igw-web"
}

variable "route_igw_name" {
  type        = string
  description = "Internet Gateway Route Name"
  default     = "route-igw"
}

variable "route_default_cidr" {
  type        = string
  description = "Define the CIDR Block to the Internet Gateway and NAT Gateway as default route"
  default     = "0.0.0.0/0"
}

variable "private_subnet" {
  type        = map(any)
  description = "Define the Private subnet configurations"
  default = {
    private_subnet1 = {
      cidr_block        = "192.168.1.0/24",
      availability_zone = "us-east-1a"
    }
    private_subnet2 = {
      cidr_block        = "192.168.2.0/24",
      availability_zone = "us-east-1b"
    }
  }
}

variable "public_subnet" {
  type        = map(any)
  description = "Define the Public subnet configurations"
  default = {
    public_subnet1 = {
      cidr_block        = "192.168.3.0/24",
      availability_zone = "us-east-1a"
    }
    public_subnet2 = {
      cidr_block        = "192.168.4.0/24",
      availability_zone = "us-east-1b"
    }
  }
}

variable "natgw_name" {
  type        = string
  description = "NAT Gateway Name"
  default     = "nat-gw"
}

variable "route_natgw_name" {
  type        = string
  description = "NAT Gateway Route Name"
  default     = "route-natgw"
}

variable "sg_name" {
  type        = string
  description = "Security Group Name"
  default     = "fw-web"
}

//data.tf variables
variable "image_owners" {
  type        = list(string)
  description = "List with AMI Owners (default - Debian ID)"
  default     = ["136693071363"]
}

variable "ami_most_recent" {
  type        = bool
  description = "AMI Most Recent (true/false)"
  default     = true
}

variable "filter_ami_fieldname" {
  type        = string
  description = "Field name to using on AMI Filter"
  default     = "name"
}

variable "filter_ami_value" {
  type        = list(string)
  description = "Value list to filter AMI"
  default     = ["debian-10-amd64-*"]
}

// ec2.tf variables
variable "instance_profile_name" {
  type        = string
  description = "IAM Instance profile Name"
  default     = "s3_access_profile-ec2"
}

variable "ec2_name" {
  type        = string
  description = "EC2 Name"
  default     = "instance-web"
}

variable "ec2_type" {
  type        = string
  description = "EC2 Type"
  default     = "t2.micro"
}

variable "userdata_file_path" {
  type        = string
  description = "User data file path (e.g /path/script.sh)"
  default     = "files/apache.sh"
}

//loadbalancer.tf variables
variable "loadbalancer_name" {
  type        = string
  description = "Load Balancer Name"
  default     = "lb-web"
}

variable "loadbalancer_type" {
  type        = string
  description = "Load Balancer Type"
  default     = "application"
}

variable "loadbalancer_targetgroup_name" {
  type        = string
  description = "LB Target Group Name"
  default     = "lb-tg-web"
}

variable "loadbalancer_port" {
  type        = number
  description = "Load Balancer port to check instances"
  default     = 80
}

variable "loadbalancer_protocol" {
  type        = string
  description = "Load Balancer protocol to check instances"
  default     = "HTTP"
}

variable "lb_action_type" {
  type        = string
  description = "LB - Default Action type"
  default     = "forward"
}

//autoscaling.tf variables
variable "launch_configuration_name" {
  type        = string
  description = "Launch Configuration Name"
  default     = "lc-web"
}

variable "lc_name_prefix" {
  type        = string
  description = "Define a prefix name in Autoscale instance"
  default     = "instance-web-"
}

variable "autoscaling_group" {
  type        = map(any)
  description = "Autoscaling group configurations"
  default = {
    name              = "ag-web"
    max_size          = 3
    min_size          = 1
    desired_capacity  = 1
    health_check_type = "EC2"
  }
}

variable "autoscaling_policy" {
  type        = map(any)
  description = "Autoscaling policy configurations"
  default = {
    "ag_scale_up" = {
      scaling_adjustment = 1
      adjustment_type    = "ChangeInCapacity"
      cooldown           = 300
    }
    "ag_scale_down" = {
      scaling_adjustment = -1
      adjustment_type    = "ChangeInCapacity"
      cooldown           = 300
    }
  }
}

variable "autoscaling_alarm" {
  type        = map(any)
  description = "Autoscaling alarm configurations"
  default = {
    "ag_metric_up" = {
      comparison_operator = "GreaterThanThreshold"
      metric_name         = "CPUUtilization"
      threshold           = 80
      statistic           = "Average"
      evaluation_periods  = 2
      namespace           = "AWS/EC2"
      period              = 120
      alarm_actions       = "ag_scale_up"
    }
    "ag_metric_down" = {
      comparison_operator = "LessThanThreshold"
      metric_name         = "CPUUtilization"
      threshold           = 60
      statistic           = "Average"
      evaluation_periods  = 2
      namespace           = "AWS/EC2"
      period              = 300
      alarm_actions       = "ag_scale_down"
    }
  }
}

