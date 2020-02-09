# AWS Lambda function Layers

Simple demo-case where code will be deployed into a function, and all required dependencies decoupled into a layer

## Prerequisites

- docker
- docker-machine
- terraform

## Steps

Check `provider.tf` for the AWS profile and destined region

### Create

1. Build Python dependencies with `./build.sh`
1. Deploy AWS Lambda function with `./terraform.sh -a`

### Clean up

1. `./terraform.sh -d -a`

## Seamless layer update

The one suggested to maintain layers outside the Terraform state, storing layers data on S3 bucket

```bash
# upload new layer to s3
aws s3 cp {{ lambda_layer_file }} s3://{{ lambda_s3_bucket }}/{{ lambda_s3_key }}

# promote new layer to service
aws lambda publish-layer-version \
    --layer-name 'dep' \
    --content S3Bucket={{ lambda_s3_bucket }},S3Key={{ lambda_s3_key }} \
    --compatible-runtimes python3.6
```

Then access it like

```
# find latest layer
data "aws_lambda_layer_version" "layer" {
  layer_name         = "dep"
  compatible_runtime = "python3.6"
}

# use it
resource "aws_lambda_function" "lambda" {
  # ... other configuration ...
  layers = ["${data.aws_lambda_layer_version.layer.layer_arn}"]
}

# destroy
resource "null_resource" "drop_layer" {
  provisioner "local-exec" {
    when    = "destroy"
    command = "aws lambda delete-layer-version --layer-name dep --version-number ${data.aws_lambda_layer_version.layer.version}"
  }

  depends_on = ["aws_lambda_function.lambda"]
}
```

## Additional reading

https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html
