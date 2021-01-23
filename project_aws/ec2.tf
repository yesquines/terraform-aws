resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access_profile-ec2"
  role = aws_iam_role.s3_access_role.name
}

data "aws_ami" "image_ec2" {
  owners      = ["136693071363"] #Debian ID - https://wiki.debian.org/Cloud/AmazonEC2Image/Marketplace
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-10-amd64-*"]
  }
}

resource "time_sleep" "wait_time" {
  depends_on      = [aws_route_table_association.association_natgw1, aws_route_table_association.association_natgw2]
  create_duration = "30s"
}

resource "aws_instance" "instace_web" {
  ami                    = data.aws_ami.image_ec2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet1.id
  iam_instance_profile   = aws_iam_instance_profile.s3_access_profile.id
  user_data              = file("files/apache.sh")
  vpc_security_group_ids = [aws_security_group.fw_web.id]
  depends_on             = [time_sleep.wait_time]
  tags                   = { Name = "instance-web" }
}

