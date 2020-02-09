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
