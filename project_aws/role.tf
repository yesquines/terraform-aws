// Create a role with s3 access 
resource "aws_iam_role" "s3_access_role" {
  name               = var.s3_role_name
  assume_role_policy = file(var.s3_role_file_path)
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = var.s3_policy_name
  policy = file(var.s3_policy_file_path)
}

resource "aws_iam_role_policy_attachment" "s2_access_attach_policy" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

