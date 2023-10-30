resource "aws_iam_role" "lambda_assume_role" {
    name = "lambda_assume_role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
       	        "Sid": "lambdaAssumeRole"
       	        "Action": "sts:AssumeRole",
       	        "Principal": {
             	    "Service": "lambda.amazonaws.com"
       	        },
       	        "Effect": "Allow",
            }
        ]
    })
}

resource "aws_iam_policy" "lambda_execution_policy" {
    name         = "lambda_execution_policy"
    path         = "/"
    description  = "AWS IAM Policy for managing aws lambda role"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            }
        ]
    })
}


resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  role        = aws_iam_role.lambda_assume_role.name
  policy_arn  = aws_iam_policy.lambda_execution_policy.arn
}

output "lambda_role_arn"{
    value = aws_iam_role.lambda_assume_role.arn
}


