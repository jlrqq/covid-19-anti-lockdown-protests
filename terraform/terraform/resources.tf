# Create a public s3 bucket with 2 folders
resource "aws_s3_bucket" "is434-last-sem-best-sem" {
  force_destroy = true
  bucket        = "is434-last-sem-best-sem"
}


#run bash script run.sh for reddit lambda function
resource "null_resource" "run_script_reddit" {
  triggers = {
    src_hash = "${data.archive_file.reddit_zip.output_sha}"
  }
  provisioner "local-exec" {
    command = "bash run.sh"
    environment = {
      function_name = "lambda_function_reddit"
    }
  }
}

#run bash script run.sh for twitter lambda function
resource "null_resource" "run_script_twitter" {
  triggers = {
    src_hash = "${data.archive_file.twitter_zip.output_sha}"
  }
  provisioner "local-exec" {
    command = "bash run.sh"
    environment = {
      function_name = "lambda_function_twitter"
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

resource "aws_api_gateway_rest_api" "api_gateway_trigger_lambda" {
  name        = "api_gateway_trigger_lambda"
  description = "Invoke Lambda function through api call and hope I can enjoy my last sem (LAST SEM BEST SEM)"
}


resource "aws_api_gateway_resource" "twitter_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_trigger_lambda.root_resource_id
  path_part   = "twitter"
}

resource "aws_api_gateway_method" "twitter_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id   = aws_api_gateway_resource.twitter_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_twitter_invoke" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_method.twitter_proxy.resource_id
  http_method = aws_api_gateway_method.twitter_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_twitter.invoke_arn
}

resource "aws_api_gateway_resource" "reddit_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_trigger_lambda.root_resource_id
  path_part   = "reddit"
}


resource "aws_api_gateway_method" "reddit_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id   = aws_api_gateway_resource.reddit_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_reddit_invoke" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_method.reddit_proxy.resource_id
  http_method = aws_api_gateway_method.reddit_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_reddit.invoke_arn
}


resource "aws_api_gateway_deployment" "api_gateway_trigger_lambda_integration" {
  depends_on = [
    aws_api_gateway_integration.lambda_twitter_invoke,
    aws_api_gateway_integration.lambda_reddit_invoke,
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  stage_name  = "test"
}

resource "aws_lambda_permission" "reddit_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_reddit.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.api_gateway_trigger_lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "twitter_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_twitter.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.api_gateway_trigger_lambda.execution_arn}/*/*"
}
