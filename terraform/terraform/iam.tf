
#aws allow lambda to access boto3 with aws translate
resource "aws_iam_role" "lambda_boto3_role" {
  name               = "lambda_boto3_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}





#aws attach full access to s3 to user group call is434-group
resource "aws_iam_group_policy_attachment" "is434-group" {
  group      = "is434-group"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role" "lambda_function_reddit_role" {
  name               = "lambda_function_reddit_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "lambda_function_twitter_role" {
  name               = "lambda_function_twitter_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "lambda_function_weibo_role" {
  name               = "lambda_function_weibo_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "lambda_trigger_role" {
  name               = "lambda_trigger_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "lambda_function_custom_policy"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "translate:TranslateText"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role_lambda_function_reddit_role" {
  role       = aws_iam_role.lambda_function_reddit_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role_lambda_function_twitter_role" {
  role       = aws_iam_role.lambda_function_twitter_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role_lambda_function_weibo_role" {
  role       = aws_iam_role.lambda_function_weibo_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role_lambda_function_trigger_role" {
  role       = aws_iam_role.lambda_trigger_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}



