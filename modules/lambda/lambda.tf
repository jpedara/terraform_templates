data "archive_file" "zip_the_python_code" {
    type        = "zip"
    source_dir  = "${path.module}/lambda_code/${var.function_name}/"
    output_path = "${path.module}/lambda_zip/${var.function_name}.zip"
}

resource "aws_lambda_function" "lambda_func" {
    filename                       = "${path.module}/lambda_zip/${var.function_name}.zip"
    function_name                  = "${var.function_name}"
    role                           = "${var.lambda_arn}"
    handler                        = "index.lambda_handler"
    runtime                        = "python3.9"
    source_code_hash               = data.archive_file.zip_the_python_code.output_base64sha256
}

output "arn" {
    value = aws_lambda_function.lambda_func.arn
}

output "invoke_arn" {
    value = aws_lambda_function.lambda_func.invoke_arn
}