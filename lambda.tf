data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.root}/lambda/code/main.py"
  output_path = "${path.root}/lambda/pkg/lambda_function.zip"
}

data "archive_file" "dep" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/dep"
  output_path = "${path.root}/lambda/pkg/dep_layer.zip"
}

resource "aws_lambda_function" "lambda" {
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "lambda-layers-test"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "main.lambda_handler"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  runtime          = "python3.6"
  timeout          = 15
  memory_size      = 128
  layers           = ["${aws_lambda_layer_version.layer.arn}"]
}

resource "aws_lambda_layer_version" "layer" {
  filename            = "${data.archive_file.dep.output_path}"
  layer_name          = "dep"
  source_code_hash    = "${data.archive_file.dep.output_base64sha256}"
  compatible_runtimes = ["python3.6"]
}
