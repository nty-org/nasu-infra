# ------------------------------------------------------------#
#  variables
# ------------------------------------------------------------#

variable "PJPrefix" {
  type = string
}

variable "EnvPrefix" {
  type = string
}
/*
variable "ecs_night_stop_cluster" {
  type = string
}

variable "ecs_night_stop_services_0000-0600" {
  type = list(string)
}

variable "ecs_night_stop_services_0000-0530" {
  type = list(string)
}
*/
variable "ec2_night_stop_instance_0000-0600" {
  type = map(string)
}

# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  eventbrige scheduler
## ------------------------------------------------------------#

resource "aws_iam_role" "eventbridge_scheduler" {
  assume_role_policy   = data.aws_iam_policy_document.eventbridge_scheduler_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${var.PJPrefix}-${var.EnvPrefix}-eventbridge-scheduler-role"
  path                 = "/service-role/"
}

data "aws_iam_policy_document" "eventbridge_scheduler_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "eventbridge_scheduler" {
  name   = "${var.PJPrefix}-${var.EnvPrefix}-eventbridge-scheduler-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.eventbridge_scheduler.json
}

data "aws_iam_policy_document" "eventbridge_scheduler" {

  statement {
    effect = "Allow"
    actions = [
      "ecs:UpdateService"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "rds:StartDBCluster",
      "rds:StopDBCluster"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler" {
  role       = aws_iam_role.eventbridge_scheduler.name
  policy_arn = aws_iam_policy.eventbridge_scheduler.arn
}

# ------------------------------------------------------------#
#  eventbrige scheduler
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ec2 night stop 0:00~6:00
## ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ec2_start_0000-0600" {
  for_each = var.ec2_night_stop_instance_0000-0600

  name       = "${var.PJPrefix}-${var.EnvPrefix}-ec2-${each.key}-start"

  flexible_time_window {
    mode = "OFF"
  }
  
  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 6 * * ? *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      InstanceIds = [each.value]
    })
  }
}

resource "aws_scheduler_schedule" "ec2_stop_0000-0600" {
  for_each = var.ec2_night_stop_instance_0000-0600

  name       = "${var.PJPrefix}-${var.EnvPrefix}-ec2-${each.key}-stop"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 0 * * ? *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      InstanceIds = [each.value]
    })
  }
}

## ------------------------------------------------------------#
##  rds night stop
## ------------------------------------------------------------#
/*
resource "aws_scheduler_schedule" "rds_start" {
  name       = "${var.PJPrefix}-${var.EnvPrefix}-rds-start"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(12 21 ? * MON-FRI *)"
  state = "DISABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      DbClusterIdentifier = "${aws_rds_cluster.this.id}"
    })
  }
}

resource "aws_scheduler_schedule" "rds_stop" {
  name       = "${var.PJPrefix}-${var.EnvPrefix}-rds-stop"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(50 16 ? * MON-FRI *)"
  #state = "DISABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      DbClusterIdentifier = "${aws_rds_cluster.this.id}"
    })
  }
}
*/

## ------------------------------------------------------------#
##  ecs night
## ------------------------------------------------------------#
/*
resource "aws_scheduler_schedule" "ecs_start" {
  name       = "${var.PJPrefix}-${var.EnvPrefix}-ecs-start"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }


  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(30 13 ? * MON-FRI *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      Service      = "${aws_ecs_service.sync.name}",
      Cluster      = "${aws_ecs_cluster.this.id}",
      DesiredCount = 1
    })
  }
}

## ------------------------------------------------------------#
##  ecs auto stop
## ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ecs_stop" {
  name       = "${var.PJPrefix}-${var.EnvPrefix}-ecs-stop"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 14 ? * MON-FRI *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      Service      = "${aws_ecs_service.sync.name}",
      Cluster      = "${aws_ecs_cluster.this.id}",
      DesiredCount = 0
    })
  }
}

# ------------------------------------------------------------#
#  ECS night stop
# ------------------------------------------------------------#
# ------------------------------------------------------------#
#  0:00~6:00
# ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ecs_start_0000-0600" {
  for_each = toset(var.ecs_night_stop_services_0000-0600)

  name       = "ecs-start-${each.value}"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 6 * * ? *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"
    
    retry_policy {
      maximum_retry_attempts = 3
    }

    input = jsonencode({
      Service      = "${each.value}",
      Cluster      = "${var.ecs_night_stop_cluster}",
      DesiredCount = 1
    })
  }
}

resource "aws_scheduler_schedule" "ecs_stop_0000-0600" {
  for_each = toset(var.ecs_night_stop_services_0000-0600)

  name       = "ecs-stop-${each.value}"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 0 * * ? *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"
    
    retry_policy {
      maximum_retry_attempts = 3
    }

    input = jsonencode({
      Service      = "${each.value}",
      Cluster      = "${var.ecs_night_stop_cluster}",
      DesiredCount = 0
    })
  }
}

# ------------------------------------------------------------#
#  0:00~5:30
# ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ecs_start_0000-0530" {
  for_each = toset(var.ecs_night_stop_services_0000-0530)

  name       = "ecs-start-${each.value}"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(30 5 * * ? *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"
    
    retry_policy {
      maximum_retry_attempts = 3
    }

    input = jsonencode({
      Service      = "${each.value}",
      Cluster      = "${var.ecs_night_stop_cluster}",
      DesiredCount = 1
    })
  }
}

resource "aws_scheduler_schedule" "ecs_stop_0000-0530" {
  for_each = toset(var.ecs_night_stop_services_0000-0530)

  name       = "ecs-stop-${each.value}"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 0 * * ? *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"
    
    retry_policy {
      maximum_retry_attempts = 3
    }

    input = jsonencode({
      Service      = "${each.value}",
      Cluster      = "${var.ecs_night_stop_cluster}",
      DesiredCount = 0
    })
  }
}

# ------------------------------------------------------------#
#  EC2 night stop
# ------------------------------------------------------------#
# ------------------------------------------------------------#
#  0:00~6:00
# ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ec2_start_0000-0600" {
  for_each = var.ec2_night_stop_instance_0000-0600

  name       = "ec2-start-${each.key}"

  flexible_time_window {
    mode = "OFF"
  }
  
  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 6 * * ? *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      InstanceIds = [each.value]
    })
  }
}

resource "aws_scheduler_schedule" "ec2_stop_0000-0600" {
  for_each = var.ec2_night_stop_instance_0000-0600

  name       = "ec2-stop-${each.key}"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 0 * * ? *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      InstanceIds = [each.value]
    })
  }
}
*/