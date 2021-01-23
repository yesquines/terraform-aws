// Get useful informations 
data "aws_ami" "image_ec2" {
  owners      = var.image_owners
  most_recent = var.ami_most_recent
  filter {
    name   = var.filter_ami_fieldname
    values = var.filter_ami_value
  }
}

data "aws_subnet_ids" "lb_subnets" {
  vpc_id     = aws_vpc.vpc_web.id
  depends_on = [aws_subnet.public_subnet]
  tags = {
    Network = "public"
  }
}
