resource "aws_api_gateway_rest_api" "terraform_rest_api" {
  name        = "${var.api_name}"
  description = "${var.api_desc}"
}

resource "aws_api_gateway_resource" "resource" {
  for_each =  {for val in distinct([for item in var.resources: item.resource]): val => val}
  parent_id   = aws_api_gateway_rest_api.terraform_rest_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.terraform_rest_api.id
  path_part   = each.value
}

resource "aws_api_gateway_method" "test" {
  for_each = { for idx, resource in var.resources : "${resource.resource}_${resource.method}" => resource }
  rest_api_id   = aws_api_gateway_rest_api.terraform_rest_api.id
  resource_id   = aws_api_gateway_resource.resource["${each.value.resource}"].id
  http_method   = each.value.method
  authorization = "NONE"
}



resource "aws_api_gateway_integration" "lambda_integration_handler" {
  for_each = { for idx, resource in var.resources : "${resource.resource}_${resource.method}" => resource }
  rest_api_id = aws_api_gateway_rest_api.terraform_rest_api.id
  resource_id = aws_api_gateway_method.test["${each.value.resource}_${each.value.method}"].resource_id
  http_method = aws_api_gateway_method.test["${each.value.resource}_${each.value.method}"].http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = each.value.invoke_arn
}
 
resource "aws_lambda_permission" "lambda_permission" {
  for_each = {for val in distinct([for item in var.resources: item.function_name]): val => val}
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"

  #your lambda function ARN
  function_name = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${each.value}"  
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.terraform_rest_api.execution_arn}/*"
}

resource "aws_api_gateway_method_response" "response_200" {
  for_each = { for idx, resource in var.resources : "${resource.resource}_${resource.method}" => resource }
  rest_api_id = aws_api_gateway_rest_api.terraform_rest_api.id
  resource_id = aws_api_gateway_resource.resource["${each.value.resource}"].id
  http_method = aws_api_gateway_method.test["${each.value.resource}_${each.value.method}"].http_method
  status_code = "200"
 
 response_models = { "application/json" = "Empty"}
}

resource "aws_api_gateway_integration_response" "IntegrationResponse" {
  depends_on = [
     aws_api_gateway_integration.lambda_integration_handler
  ]
  for_each = { for idx, resource in var.resources : "${resource.resource}_${resource.method}" => resource }
  rest_api_id = aws_api_gateway_rest_api.terraform_rest_api.id
  resource_id = aws_api_gateway_resource.resource["${each.value.resource}"].id
  http_method = aws_api_gateway_method.test["${each.value.resource}_${each.value.method}"].http_method
  status_code = aws_api_gateway_method_response.response_200["${each.value.resource}_${each.value.method}"].status_code
  # Transforms the backend JSON response to json. The space is "A must have"
  response_templates = {
    "application/json" = <<EOF
 
    EOF
 }
}


resource "aws_api_gateway_deployment" "terraform_rest_api_deployment" {
   depends_on = [
      aws_api_gateway_integration.lambda_integration_handler,
      aws_api_gateway_integration_response.IntegrationResponse
   ]
   rest_api_id = aws_api_gateway_rest_api.terraform_rest_api.id
   stage_name  = "v1"
   triggers = {
        redeployment = sha1(jsonencode([
          aws_api_gateway_resource.resource,
          aws_api_gateway_method.test,
          aws_api_gateway_integration.lambda_integration_handler,
        ]))
    }
    lifecycle {
        create_before_destroy = true
    }
}

output api_arns {
  value = [for val in distinct([for item in var.resources: item.resource]) : "${aws_api_gateway_deployment.terraform_rest_api_deployment.invoke_url}/${val}"]
}