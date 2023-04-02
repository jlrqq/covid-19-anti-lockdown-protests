resource "aws_cloudwatch_metric_alarm" "lambda_function_reddit_alarm" {
  alarm_name          = "lambda_function_reddit_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors lambda function reddit"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:lambda_function_reddit_alarm"]
  dimensions = {
    FunctionName = "lambda_function_reddit"
  }
}

//weibo invoke fail
resource "aws_cloudwatch_metric_alarm" "lambda_function_weibo_alarm" {
  alarm_name          = "lambda_function_weibo_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors lambda function weibo"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:lambda_function_weibo_alarm"]
  dimensions = {
    FunctionName = "lambda_function_weibo"
  }
}

//twitter invoke fail
resource "aws_cloudwatch_metric_alarm" "lambda_function_twitter_alarm" {
  alarm_name          = "lambda_function_twitter_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors lambda function twitter"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:lambda_function_twitter_alarm"]
  dimensions = {
    FunctionName = "lambda_function_twitter"
  }
}

//trigger lambda invoke fail
resource "aws_cloudwatch_metric_alarm" "lambda_function_trigger_alarm" {
  alarm_name          = "lambda_function_trigger_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors lambda function trigger"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:lambda_function_trigger_alarm"]
  dimensions = {
    FunctionName = "lambda_function_trigger"
  }
}
