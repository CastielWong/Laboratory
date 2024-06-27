# policy
resource "aws_iam_policy" "demo-policy" {
  name        = "DemoAdminAccess"
  path        = "/"
  description = "Demo policy for administration"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

# group
resource "aws_iam_group" "demo-admin" {
  name = "demo-admin"
}

resource "aws_iam_policy_attachment" "demo-admin-attach" {
  name       = "demo-admin-attach"
  groups     = [aws_iam_group.demo-admin.name]
  policy_arn = aws_iam_policy.demo-policy.arn
}

# user
resource "aws_iam_user" "demo-admin1" {
  name = "demo-admin-1"
}

resource "aws_iam_user" "demo-admin2" {
  name = "demo-admin-2"
}

resource "aws_iam_group_membership" "demo-admin-users" {
  name = "demo-admin-users"
  users = [
    aws_iam_user.demo-admin1.name,
    aws_iam_user.demo-admin2.name,
  ]
  group = aws_iam_group.demo-admin.name
}

output "warning" {
  value = <<EOF
  WARNING: Make sure policy applied here is not used by any other user/group/role.
  Otherwise, `terraform destroy` would also revoke such policy for that user/group/role.
  Be careful when unlinking/deleting the created resources.
  EOF
}
