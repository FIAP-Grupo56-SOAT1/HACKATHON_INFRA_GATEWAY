variable "AWS_REGION" {
  default = "us-east-1"
}

variable "url_timesheet_service" {
  type    = string
  default = "http://load-balancer-timesheet-595005313.us-east-1.elb.amazonaws.com"
}

variable "stage_prod" {
  default = "prod"
  type    = string
}

######### OBS: a execution role acima foi trocada por LabRole devido a restricoes de permissao na conta da AWS Academy ########
variable "execution_role_ecs" {
  type    = string
  default = "arn:aws:iam::730335661438:role/LabRole" #aws_iam_role.ecsTaskExecutionRole.arn
}