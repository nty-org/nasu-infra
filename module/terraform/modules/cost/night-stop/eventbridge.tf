# ------------------------------------------------------------#
#  eventbrige scheduler
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ec2 night stop
## ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ec2_start" {
  for_each = var.ec2_night_stop_instances

  name       = "${var.pj_prefix}-${var.env_prefix}-ec2-${each.key}-start"
  schedule_expression          = "cron(${each.value.start_time} * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    retry_policy {
      maximum_retry_attempts = 3
    }

    input = jsonencode({
      InstanceIds = [data.aws_instance.ec2_instance[each.key].id]
    })
  }
}

resource "aws_scheduler_schedule" "ec2_stop" {
  for_each = var.ec2_night_stop_instances

  name       = "${var.pj_prefix}-${var.env_prefix}-ec2-${each.key}-stop"
  schedule_expression          = "cron(${each.value.stop_time} * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    retry_policy {
      maximum_retry_attempts = 3
    }

    input = jsonencode({
      InstanceIds = [data.aws_instance.ec2_instance[each.key].id]
    })
  }
}

## ------------------------------------------------------------#
##  ecs night stop
## ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ecs_start" {
  for_each = var.ecs_night_stop_services

  name       = "${var.pj_prefix}-${var.env_prefix}-ecs-${each.key}-start"
  schedule_expression          = "cron(${each.value.start_time} * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"
    
    retry_policy {
      maximum_retry_attempts = 3
    }

    input = jsonencode({
      Service      = "${each.value.service_name}",
      Cluster      = "${var.ecs_night_stop_cluster}",
      DesiredCount = each.value.start_desire_count
    })
  }
}

resource "aws_scheduler_schedule" "ecs_stop" {
  for_each = var.ecs_night_stop_services

  name       = "${var.pj_prefix}-${var.env_prefix}-ecs-${each.key}-stop"
  schedule_expression          = "cron(${each.value.stop_time} * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"
    
    retry_policy {
      maximum_retry_attempts = 3
    }

    input = jsonencode({
      Service      = "${each.value.service_name}",
      Cluster      = "${var.ecs_night_stop_cluster}",
      DesiredCount = each.value.stop_desire_count
    })
  }
}

/*
## ------------------------------------------------------------#
##  rds night stop
## ------------------------------------------------------------#

resource "aws_scheduler_schedule" "rds_start" {
  name       = "${var.PJPrefix}-${var.EnvPrefix}-rds-start"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 06 ? * MON-FRI *)"
  state = "DISABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      DbClusterIdentifier = "${var.rds_night_stop_cluster}"
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
  schedule_expression          = "cron(00 00 ? * MON-FRI *)"
  #state = "DISABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      DbClusterIdentifier = "${var.rds_night_stop_cluster}"
    })
  }
}
*/