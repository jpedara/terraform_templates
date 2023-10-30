variable "aws_region" {}
variable "api_name" {}
variable "api_desc" {}
variable "resources" {
    type = list(object({
      resource = string
      method = string
      function_name = string
      lambda_arn = string
      invoke_arn = string
    }))
    default = []
}