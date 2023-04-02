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

resource "aws_api_gateway_method_response" "response_200_twitter" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_resource.twitter_proxy.id
  http_method = aws_api_gateway_method.twitter_proxy.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "twitter_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_resource.twitter_proxy.id
  http_method = aws_api_gateway_method.twitter_proxy.http_method
  status_code = aws_api_gateway_method_response.response_200_twitter.status_code
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

resource "aws_api_gateway_method_response" "response_200_reddit" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_resource.reddit_proxy.id
  http_method = aws_api_gateway_method.reddit_proxy.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "reddit_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_resource.reddit_proxy.id
  http_method = aws_api_gateway_method.reddit_proxy.http_method
  status_code = aws_api_gateway_method_response.response_200_reddit.status_code
}

resource "aws_api_gateway_resource" "weibo_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_trigger_lambda.root_resource_id
  path_part   = "weibo"
}


resource "aws_api_gateway_method" "weibo_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id   = aws_api_gateway_resource.weibo_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_weibo_invoke" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_method.weibo_proxy.resource_id
  http_method = aws_api_gateway_method.weibo_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_weibo.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200_weibo" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_resource.weibo_proxy.id
  http_method = aws_api_gateway_method.weibo_proxy.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "weibo_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_trigger_lambda.id
  resource_id = aws_api_gateway_resource.weibo_proxy.id
  http_method = aws_api_gateway_method.weibo_proxy.http_method
  status_code = aws_api_gateway_method_response.response_200_weibo.status_code
}


resource "aws_api_gateway_deployment" "api_gateway_trigger_lambda_integration" {
  depends_on = [
    aws_api_gateway_integration.lambda_twitter_invoke,
    aws_api_gateway_integration.lambda_reddit_invoke,
    aws_api_gateway_integration.lambda_weibo_invoke
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

resource "aws_lambda_permission" "weibo_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_weibo.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.api_gateway_trigger_lambda.execution_arn}/*/*"
}


output "base_url" {
  value = aws_api_gateway_deployment.api_gateway_trigger_lambda_integration.invoke_url
}