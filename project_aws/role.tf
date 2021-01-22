// Create a role with s3 access 
resource "aws_iam_role" "s3_access_role" {
  name               = "s3-access-role"
  assume_role_policy = file("files/s3_role.json")
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "s3-access-policy"
  policy = file("files/s3_policy.json")
}

resource "aws_iam_role_policy_attachment" "s2_access_attach_policy" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
