resource "aws_iam_role" "demo-ec2-s3-role" {
  name               = "demo-ec2-s3-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "s3-mybucket-role-instanceprofile" {
  name = "demo-s3-bucket-role"
  role = aws_iam_role.demo-ec2-s3-role.name
}

resource "aws_iam_role_policy" "demo-ec2-s3-policy" {
  name = "demo-ec2-s3-policy"
  role = aws_iam_role.demo-ec2-s3-role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:*"
            ],
            "Resource": [
              "arn:aws:s3:::${var.BUCKET_NAME}",
              "arn:aws:s3:::${var.BUCKET_NAME}/*"
            ]
        }
    ]
}
EOF

}
