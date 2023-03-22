# Create a public s3 bucket with 2 folders
resource "aws_s3_bucket" "is434-last-sem-best-sem" {
  force_destroy = true
  bucket = "is434-last-sem-best-sem"
}

#run bash script run.sh
resource "null_resource" "run_script" {
  provisioner "local-exec" {
    command = "bash run.sh"
  }
}

resource "aws_lambda_function" "lambda_function_reddit" {
  filename      = "../code/lambda_function_reddit/lambda_function_reddit.zip"
  function_name = "lambda_function_reddit"
  handler       = "lambda_function_reddit.lambda_handler"
  role          = aws_iam_role.lambda_function_reddit_role.arn
  runtime       = "python3.8"
  timeout       = 900

  environment {
    variables = {
      client_id     = var.client_id
      client_secret = var.client_secret
      password      = var.password
      user_agent    = var.user_agent
      username      = var.username
    }
  }
}
