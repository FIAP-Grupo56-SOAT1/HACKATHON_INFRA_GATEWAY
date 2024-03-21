terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }

  backend "s3" {
    bucket = "bucket-fiap56-to-remote-state"
    key    = "aws-apigateway-timesheet-fiap56/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


# Criando um modulo que utiliza os dados do infra para criação do ambiente
module "prod" {
  source                = "../../"
  url_timesheet_service    = jsondecode(data.aws_secretsmanager_secret_version.credentials_producao.secret_string)["url_timesheet_service"]
}


#obteando dados do secret manager
data "aws_secretsmanager_secret" "secrets_timesheet" {
  name = "prod/soat1grupo56/Timesheet"
}

data "aws_secretsmanager_secret_version" "credentials_timesheet" {
  secret_id = data.aws_secretsmanager_secret.secrets_timesheet.id
}
