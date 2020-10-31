resource "aws_autoscaling_group" "bar" {
  name                      = "foobar3-terraform-test"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.foobar.name}"
  vpc_zone_identifier       = ["${aws_subnet.example1.id}", "${aws_subnet.example2.id}"]
role_arn                = "arn:aws:iam::123456789012:role/S3Access"
}

resource "aws_launch_configuration" "as_conf" {
  name = "${prefix}-elasticsearch_data"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.small"
}


resource "aws_iam_role" "elasticsearch_data" {
  name = "${prefix}-elasticsearch_data"
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

resource "aws_iam_group" "elasticsearch_data" {
  name = "${prefix}-elasticsearch_data"
}

resource "aws_iam_policy" "elasticsearch_data" {
  name        = "${prefix}-elasticsearch_data"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "${prefix}-elasticsearch_data"
  roles      = ["${aws_iam_role.elasticsearch_data.name}"]
  groups     = ["${aws_iam_group.elasticsearch_data.name}"]
  policy_arn = "${aws_iam_policy.elasticsearch_data.arn}"
}
