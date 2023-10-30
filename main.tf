module "iam_roles_and_polices"{
    source = "./modules/iam"
}

module "first_lambda_func" {
    source = "./modules/lambda"
    function_name = "first_lambda_func"
    lambda_arn = "${module.iam_roles_and_polices.lambda_role_arn}"
    depends_on = [ module.iam_roles_and_polices]
}

module "second_lambda_func" {
    source = "./modules/lambda"
    function_name = "second_lambda_func"
    lambda_arn = "${module.iam_roles_and_polices.lambda_role_arn}"
    depends_on = [ module.iam_roles_and_polices]
}

module "third_lambda_func" {
    source = "./modules/lambda"
    function_name = "third_lambda_func"
    lambda_arn = "${module.iam_roles_and_polices.lambda_role_arn}"
    depends_on = [ module.iam_roles_and_polices]
}

module "rest_api" {
    source = "./modules/api_gateway"
    api_name = "test_api"
    api_desc = "sample api to test"
    aws_region = "${var.aws_region}"
    resources = [
        {
            resource = "res1"
            method = "POST",
            function_name = "first_lambda_func"
            lambda_arn = module.first_lambda_func.arn
            invoke_arn = module.first_lambda_func.invoke_arn
        },
        {
            resource = "res1"
            method = "GET"
            function_name = "second_lambda_func"
            lambda_arn = module.second_lambda_func.arn
            invoke_arn = module.second_lambda_func.invoke_arn
        },
        {
            resource = "res2"
            method = "POST"
            function_name = "third_lambda_func"
            lambda_arn = module.third_lambda_func.arn
            invoke_arn = module.third_lambda_func.invoke_arn
        }
    ]

    depends_on = [ 
        module.first_lambda_func,
        module.second_lambda_func,
        module.third_lambda_func 
    ]
}


output "first_lambda_func_arn" {
  value = module.first_lambda_func.arn
}

output "first_lambda_func_invoke_arn" {
  value = module.first_lambda_func.invoke_arn
}

output "api_arns" {
    value = module.rest_api.api_arns
}