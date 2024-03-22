resource "aws_default_vpc" "default_vpc" {
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-east-1b"
}


resource "aws_api_gateway_rest_api" "apigateway" {
  name        = "timesheet"
  description = "API Gateway para projeto timesheet"
  body        = data.template_file.api_gateway.rendered

  endpoint_configuration {
    types = ["REGIONAL"]
  }

}

data "template_file" "api_gateway" {
  template = file("../../api-gateway-timesheet.yaml")

  vars = {
    aws_region                        = var.AWS_REGION
    url_timesheet_service             = var.url_timesheet_service
    authorizer_credentials      = var.execution_role_ecs
  }

}

#    authorizer_credentials      = aws_iam_role.apigw_execution_role.arn

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.apigateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.apigateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.apigateway.id
  depends_on    = [aws_cloudwatch_log_group.log_group]
  stage_name    = var.stage_prod
  #auto_deploy       = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"

  }
}



#resource "aws_api_gateway_method_settings" "all" {
#  rest_api_id = aws_api_gateway_rest_api.apigateway.id
#  stage_name  = aws_api_gateway_stage.stage.stage_name
#  method_path = "*/*"
##Off
#  settings {
#    logging_level = "OFF"
#  }
#  # Errors and Info Logs
#  #settings {
#  #  logging_level      = "INFO"
#  #  metrics_enabled    = true
#  #  data_trace_enabled = false
#  #}
##Full Request and Response Logs
# # settings {
# #   logging_level      = "INFO"
# #   metrics_enabled    = true
# #   data_trace_enabled = true
# # }
#}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.apigateway.name}/${var.stage_prod}"
  retention_in_days = 1
}

#resource "aws_api_gateway_account" "gateway_account" {
#  cloudwatch_role_arn = var.execution_role_ecs
#}