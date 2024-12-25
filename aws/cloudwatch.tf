# ------------------------------------------------------------#
#  dashboard
# ------------------------------------------------------------#
/*
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${local.PJPrefix}-${local.EnvPrefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ServiceName",
              "${local.PJPrefix}-${local.EnvPrefix}-flask-service",
              "ClusterName",
              "${local.PJPrefix}-${local.EnvPrefix}-cluster",
            ],
            [
              "...",
              "${local.PJPrefix}-${local.EnvPrefix}-flask2-service",
              ".",
              ".",
            ],
          ]
          title   = "ECS CPUUtilization"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ServiceName",
              "${local.PJPrefix}-${local.EnvPrefix}-flask-service",
              "ClusterName",
              "${local.PJPrefix}-${local.EnvPrefix}-cluster",
            ],
            [
              "...",
              "${local.PJPrefix}-${local.EnvPrefix}-flask2-service",
              ".",
              ".",
            ],
          ]
          title   = "ECS MemoryUtilization"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "ECS/ContainerInsights",
              "RunningTaskCount",
              "ServiceName",
              "${local.PJPrefix}-${local.EnvPrefix}-flask-service",
              "ClusterName",
              "${local.PJPrefix}-${local.EnvPrefix}-cluster",
            ],
            [
              "...",
              "${local.PJPrefix}-${local.EnvPrefix}-flask2-service",
              ".",
              ".",
            ],
          ]
          title   = "ECS RunningTaskCount"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              "${local.PJPrefix}-${local.EnvPrefix}",
            ],
          ]
          title   = "RDS CPUUtilization"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/RDS",
              "FreeableMemory",
              "DBInstanceIdentifier",
              "${local.PJPrefix}-${local.EnvPrefix}",
            ],
          ]
          title   = "RDS FreeableMemory"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ElastiCache",
              "CPUUtilization",
              "CacheClusterId",
              "${local.PJPrefix}-${local.EnvPrefix}-redis-001",
            ],
          ]
          title   = "redis CPUUtilization"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ElastiCache",
              "DatabaseMemoryUsagePercentage",
              "CacheClusterId",
              "${local.PJPrefix}-${local.EnvPrefix}-redis-001",
            ],
          ]
          title   = "redis DatabaseMemoryUsagePercentage"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ElastiCache",
              "Evictions",
              "CacheClusterId",
              "${local.PJPrefix}-${local.EnvPrefix}-redis-001",
            ],
          ]
          title   = "redis Evictions"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ElastiCache",
              "CurrConnections",
              "CacheClusterId",
              "${local.PJPrefix}-${local.EnvPrefix}-redis-001",
            ],
          ]
          title   = "redis CurrConnections"
          region  = "ap-northeast-1"
          stacked = false
          view    = "timeSeries"
        }
      },

    ]
  })
}
*/
# ------------------------------------------------------------#
#  ECS
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  flask
# ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "ecs_flask_cpu" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-service-cpu"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 70
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "ClusterName" = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
    "ServiceName" = "${local.PJPrefix}-${local.EnvPrefix}-flask-service"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "ecs_flask_memory" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-service-memory"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 70
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "ClusterName" = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
    "ServiceName" = "${local.PJPrefix}-${local.EnvPrefix}-flask-service"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "ecs_flask_task_count" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-service-task-count"
  alarm_description   = ""
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  statistic           = "Average"
  threshold           = 0
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "ClusterName" = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
    "ServiceName" = "${local.PJPrefix}-${local.EnvPrefix}-flask-service"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}
*/

# ------------------------------------------------------------#
#  RDS
# ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "rds_writer_cpu_70" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-rds-writer-cpu-70"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 70
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "DBInstanceIdentifier" = "${local.PJPrefix}-${local.EnvPrefix}"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "rds_writer_cpu_90" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-rds-writer-cpu-90"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 90
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "DBInstanceIdentifier" = "${local.PJPrefix}-${local.EnvPrefix}"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "rds_writer_memory_70" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-rds-writer-memory-70"
  alarm_description   = ""
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 30
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "DBInstanceIdentifier" = "${local.PJPrefix}-${local.EnvPrefix}"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "rds_writer_memory_90" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-rds-writer-cpu-90"
  alarm_description   = ""
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 10
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "DBInstanceIdentifier" = "${local.PJPrefix}-${local.EnvPrefix}"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}
*/

# ------------------------------------------------------------#
#  REDIS
# ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-cpu"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 75
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-memory"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 75
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "redis_evictions" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-evictions"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 0
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "redis_curr_connections" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-curr-connections"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 500
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  dimensions          = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}
*/
# ------------------------------------------------------------#
#  OPEN SEARCH
# ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "opensearch_cpu" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-opensearch-cpu"
  alarm_description   = ""
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  threshold           = 80
  period              = 900

  datapoints_to_alarm = 3
  evaluation_periods  = 3

  dimensions          = {
    "DomainName" = "${local.PJPrefix}-${local.EnvPrefix}"
    "ClientId"   = local.account_id
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    #Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "opensearch_memory" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-opensearch-memory"
  alarm_description   = ""
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "JVMMemoryPressure"
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  threshold           = 95
  period              = 60

  datapoints_to_alarm = 3
  evaluation_periods  = 3

  dimensions          = {
    "DomainName" = "${local.PJPrefix}-${local.EnvPrefix}"
    "ClientId"   = local.account_id
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "opensearch_cluster_status_red" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-opensearch-cluster-status-red"
  alarm_description   = ""
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  threshold           = 1
  period              = 60

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  dimensions          = {
    "DomainName" = "${local.PJPrefix}-${local.EnvPrefix}"
    "ClientId"   = local.account_id
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}
*/
# ------------------------------------------------------------#
#  ALB
# ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "alb_flask_elb_5xx_count" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-alb-api-elb-5xx-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  datapoints_to_alarm = 1
  dimensions = {
    "LoadBalancer" = aws_lb.flask.arn_suffix
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "alb_flask_target_5xx_count" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-alb-api-target-5xx-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  datapoints_to_alarm = 10
  dimensions = {
    "LoadBalancer" = aws_lb.flask.arn_suffix
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}
*/
/*
# source code zip
data "local_file" "canary_source" {
  filename = "${path.module}/canary_script/source/nodejs/node_modules/pageLoadBlueprint.js"
}

locals {
  source_hash = sha256(data.local_file.canary_source.content)
}

data "archive_file" "canary_zip" {
  type        = "zip"
  source_dir  = "${path.module}/canary_script/source"
  output_path = "${path.module}/canary_script/synthetics_${local.source_hash}.zip"
}

# canary
resource "aws_synthetics_canary" "api" {
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-api-canary"
  start_canary         = var.start_canary
  artifact_s3_location = "s3://${aws_s3_bucket.synthetics.bucket}/logs/"
  execution_role_arn   = aws_iam_role.synthetics.arn
  handler              = "pageLoadBlueprint.handler"
  zip_file             = data.archive_file.canary_zip.output_path
  runtime_version      = "syn-nodejs-puppeteer-9.0"
  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
  }

  lifecycle {
    create_before_destroy = true
  }
}
*/
# ------------------------------------------------------------#
#  metric filter
# ------------------------------------------------------------#
/*
resource "aws_cloudwatch_log_metric_filter" "ecs_flask_error" {

  name           = "${local.PJPrefix}-${local.EnvPrefix}-flask-error" 
  pattern        = "%hello%"
  log_group_name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-flask"

  metric_transformation {
    name      = "${local.PJPrefix}-${local.EnvPrefix}-flask-error"
    namespace = "ECS/Error"
    value     = 1
  }

}

resource "aws_cloudwatch_metric_alarm" "ecs_flask_error" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-flask-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "${local.PJPrefix}-${local.EnvPrefix}-flask-error"
  namespace           = "ECS/Error"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  datapoints_to_alarm = 1
  dimensions = {
    
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}
*/

# ------------------------------------------------------------#
#  cloudtrail
# ------------------------------------------------------------#
resource "aws_cloudwatch_log_metric_filter" "s3_not_app_role_download" {

  name           = "${local.PJPrefix}-${local.EnvPrefix}-s3-not-app-role-download" 
  pattern        = "{ ($.userIdentity.sessionContext.sessionIssuer.userName!=nasu-prod-ec2-role)&&($.eventName = GetObject) }"
  log_group_name = "/cloudtrail/s3"

  metric_transformation {
    name      = "${local.PJPrefix}-${local.EnvPrefix}-s3-not-app-role-download"
    namespace = "CloudTrail/"
    value     = 1
  }

}

resource "aws_cloudwatch_metric_alarm" "s3_not_app_role_download" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-s3-not-app-role-download"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "${local.PJPrefix}-${local.EnvPrefix}-s3-not-app-role-download"
  namespace           = "CloudTrail/"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  datapoints_to_alarm = 1
  dimensions = {
    
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}

resource "aws_cloudwatch_log_metric_filter" "s3_iam_user_download" {

  name           = "${local.PJPrefix}-${local.EnvPrefix}-s3-iam-user-download" 
  pattern        = "{ ($.userIdentity.type=IAMUser)&&($.userIdentity.userName!=Administrator)&&($.eventName = GetObject) }"
  log_group_name = "/cloudtrail/s3"

  metric_transformation {
    name      = "${local.PJPrefix}-${local.EnvPrefix}-s3-iam-user-download"
    namespace = "CloudTrail/"
    value     = 1
  }

}

resource "aws_cloudwatch_metric_alarm" "s3_iam_user_download" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-s3-iam-user-download"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "${local.PJPrefix}-${local.EnvPrefix}-s3-iam-user-download"
  namespace           = "CloudTrail/"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  datapoints_to_alarm = 1
  dimensions = {
    
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}