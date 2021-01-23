//Launch an ec2 instance with a role inside the private subnet of VPC, and install apache through bootstrapping.
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.s3_access_role.name
}

resource "time_sleep" "wait_time" {
  depends_on      = [aws_route_table_association.association_natgw]
  create_duration = "30s"
}

resource "aws_instance" "instace_web" {
  ami                    = data.aws_ami.image_ec2.id
  instance_type          = var.ec2_type
  subnet_id              = aws_subnet.private_subnet["private_subnet1"].id
  iam_instance_profile   = aws_iam_instance_profile.s3_access_profile.id
  user_data              = file(var.userdata_file_path)
  vpc_security_group_ids = [aws_security_group.fw_web.id]
  depends_on             = [time_sleep.wait_time]
  tags                   = { Name = var.ec2_name }
}

