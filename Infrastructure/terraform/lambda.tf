#run bash script run.sh for reddit lambda function
resource "null_resource" "run_script_reddit" {
  provisioner "local-exec" {
    command = "bash run.sh"
    environment = {
      function_name = "lambda_function_reddit"
    }
  }
}

#run bash script run.sh for twitter lambda function
resource "null_resource" "run_script_twitter" {
  provisioner "local-exec" {
    command = "bash run.sh"
    environment = {
      function_name = "lambda_function_twitter"
    }
  }
}

#run bash script run.sh for twitter lambda function
resource "null_resource" "run_script_weibo" {
  provisioner "local-exec" {
    command = "bash run.sh"
    environment = {
      function_name = "lambda_function_weibo"
    }
  }
}

resource "null_resource" "run_script_trigger" {
  provisioner "local-exec" {
    command = "bash run.sh"
    environment = {
      function_name = "lambda_trigger"
    }
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

resource "aws_lambda_function" "lambda_function_twitter" {
  filename      = "../code/lambda_function_twitter/lambda_function_twitter.zip"
  function_name = "lambda_function_twitter"
  handler       = "lambda_function_twitter.lambda_handler"
  role          = aws_iam_role.lambda_function_twitter_role.arn
  runtime       = "python3.8"
  timeout       = 900

  environment {
    variables = {
      bearer_token = var.bearer_token
    }
  }
}

resource "aws_lambda_function" "lambda_function_weibo" {
  filename      = "../code/lambda_function_weibo/lambda_function_weibo.zip"
  function_name = "lambda_function_weibo"
  handler       = "lambda_function_weibo.lambda_handler"
  role          = aws_iam_role.lambda_function_weibo_role.arn
  runtime       = "python3.8"
  timeout       = 900
}

resource "aws_lambda_function" "lambda_trigger" {
  filename      = "../code/lambda_trigger/lambda_trigger.zip"
  function_name = "lambda_trigger"
  handler       = "lambda_trigger.lambda_handler"
  role          = aws_iam_role.lambda_trigger_role.arn
  runtime       = "python3.8"
  timeout       = 900
}


