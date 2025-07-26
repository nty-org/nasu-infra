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
## ------------------------------------------------------------#
##  ecs
## ------------------------------------------------------------#

## ------------------------------------------------------------#
##  api
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "ecs_api_cpu" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-ecs-api-service-cpu"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 70
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  dimensions = {
    "ClusterName" = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
    "ServiceName" = "${local.PJPrefix}-${local.EnvPrefix}-api-service"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "ecs_api_memory" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-ecs-api-service-memory"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 70
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  dimensions = {
    "ClusterName" = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
    "ServiceName" = "${local.PJPrefix}-${local.EnvPrefix}-api-service"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "ecs_api_task_count" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-ecs-api-service-task-count"
  alarm_description   = ""
  comparison_operator = "LessThanThreshold"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  statistic           = "Average"
  threshold           = 4
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  dimensions = {
    "ClusterName" = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
    "ServiceName" = "${local.PJPrefix}-${local.EnvPrefix}-api-service"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_log_metric_filter" "ecs_api_gunicorn_error" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-ecs-api-gunicorn-error"

  log_group_name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-api"
  pattern        = "%Using worker: gthread%"

  metric_transformation {
    name      = "${local.PJPrefix}-${local.EnvPrefix}-ecs-api-gunicorn-error"
    namespace = "ECS/Error"
    value     = 1
  }

}

resource "aws_cloudwatch_metric_alarm" "ecs_api_gunicorn_error" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-ecs-api-gunicorn-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "${local.PJPrefix}-${local.EnvPrefix}-ecs-api-gunicorn-error"
  namespace           = "ECS/Error"
  statistic           = "Sum"
  threshold           = 1
  period              = 60

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "notBreaching"

  dimensions = {

  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}
*/
## ------------------------------------------------------------#
##  rds
## ------------------------------------------------------------#
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

  treat_missing_data = "breaching"

  dimensions = {
    "DBInstanceIdentifier" = "${local.PJPrefix}-${local.EnvPrefix}-v2"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
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

  treat_missing_data = "breaching"

  dimensions = {
    "DBInstanceIdentifier" = "${local.PJPrefix}-${local.EnvPrefix}-v2"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "rds_writer_memory_90" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-rds-writer-memory-90"
  alarm_description   = ""
  comparison_operator = "LessThanThreshold"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 3435973836 #メモリ上限から計算32GB*0.1=3.2GB=3435973836B
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  dimensions = {
    "DBInstanceIdentifier" = "${local.PJPrefix}-${local.EnvPrefix}-v2"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}
*/
## ------------------------------------------------------------#
##  redis
## ------------------------------------------------------------#
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

  treat_missing_data = "breaching"

  dimensions = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-memory"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 30
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  dimensions = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
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

  treat_missing_data = "breaching"

  dimensions = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "redis_curr_connections" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-curr-connections"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 1200
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  dimensions = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "redis_freeable_memory" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-freeable-memory"
  alarm_description   = ""
  comparison_operator = "LessThanThreshold"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 100
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  dimensions = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "redis_dbo_average_ttl" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-dbo-average-ttl"
  alarm_description   = ""
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "DB0AverageTTL"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 620000000
  period              = 60

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  dimensions = {
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "redis_swap_usage" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-redis-swap-usage"
  alarm_description   = ""
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  datapoints_to_alarm = 5
  evaluation_periods  = 5

  treat_missing_data = "breaching"

  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  metric_query {
    id = "freeableMemory"
    metric {
      namespace   = "AWS/ElastiCache"
      metric_name = "FreeableMemory"
      period      = 60
      stat        = "Average"

      dimensions = {
        "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
      }
    }
  }

  metric_query {
    id = "swapUsage"
    metric {
      namespace   = "AWS/ElastiCache"
      metric_name = "SwapUsage"
      period      = 60
      stat        = "Average"

      dimensions = {
        "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
      }
    }
  }

  metric_query {
    id          = "swapUsageComparisonToFreeableMemory"
    return_data = true
    expression  = "swapUsage>freeableMemory"
    label       = "SwapUsageComparisonToFreeableMemory"
  }


  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}
*/
## ------------------------------------------------------------#
##  openserch
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "opensearch_cpu" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-opensearch-cpu"
  alarm_description   = ""
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  threshold           = 90
  period              = 900

  datapoints_to_alarm = 3
  evaluation_periods  = 3

  treat_missing_data = "breaching"

  dimensions = {
    "DomainName" = "${local.PJPrefix}-${local.EnvPrefix}2"
    "ClientId"   = local.account_id
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
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

  treat_missing_data = "breaching"

  dimensions = {
    "DomainName" = "${local.PJPrefix}-${local.EnvPrefix}2"
    "ClientId"   = local.account_id
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
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

  treat_missing_data = "breaching"

  dimensions = {
    "DomainName" = "${local.PJPrefix}-${local.EnvPrefix}2"
    "ClientId"   = local.account_id
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}
*/
## ------------------------------------------------------------#
##  ALB
## ------------------------------------------------------------#

### ------------------------------------------------------------#
### api
### ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "alb_api_elb_5xx_count" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-alb-api-elb-5xx-count"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Sum"
  threshold           = 5
  period              = 600

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "notBreaching"

  dimensions = {
    "LoadBalancer" = aws_lb.api.arn_suffix
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_cloudwatch_metric_alarm" "alb_api_target_5xx_count" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-alb-api-target-5xx-count"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Sum"
  threshold           = 5
  period              = 600

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "notBreaching"

  dimensions = {
    "LoadBalancer" = aws_lb.api.arn_suffix
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}
*/
## ------------------------------------------------------------#
##  synthetics
## ------------------------------------------------------------#

### ------------------------------------------------------------#
###  api
### ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "synthetics_api_success" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-api-success"
  comparison_operator = "LessThanThreshold"
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  threshold           = 100
  period              = 600

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "breaching"

  dimensions = {
    CanaryName = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

}

resource "aws_cloudwatch_metric_alarm" "synthetics_api_duration" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-api-duration"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "Duration"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  threshold           = 10000
  period              = 600

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "breaching"

  dimensions = {
    CanaryName = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

}
*/
### ------------------------------------------------------------#
###  sync
### ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "synthetics_sync_success" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-sync-success"
  comparison_operator = "LessThanThreshold"
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  threshold           = 100
  period              = 600

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "breaching"

  dimensions = {
    CanaryName = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

}

resource "aws_cloudwatch_metric_alarm" "synthetics_sync_duration" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-sync-duration"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "Duration"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  threshold           = 10000
  period              = 600

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "breaching"

  dimensions = {
    CanaryName = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

}
*/
## -----------------------------------------------------------#
##  cloudtrail
## -----------------------------------------------------------#

### ------------------------------------------------------------#
###  s3 
### ------------------------------------------------------------#
/*
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
*/
/*
resource "aws_cloudwatch_log_metric_filter" "s3_iam_user_download" {

  name           = "${local.PJPrefix}-${local.EnvPrefix}-s3-iam-user-download" 
  #pattern        = "{ (($.userIdentity.type=IAMUser)&&($.userIdentity.userName!=Administrator))||(($.userIdentity.type=IAMUser)&&($.userIdentity.userName=Administrator)&&($.sourceIPAddress!=${aws_eip.nat.public_ip})&&(($.additionalEventData.AuthenticationMethod!=QueryString)||($.requestParameters.X-Amz-Expires IS NULL)))||($.userIdentity.type!=IAMUser) }"
  pattern        = <<-EOT
  {
  (
  (($.userIdentity.type=IAMUser)&&($.userIdentity.userName!=Administrator))||
  (($.userIdentity.type=IAMUser)&&($.userIdentity.userName=Administrator)&&(($.additionalEventData.AuthenticationMethod!=QueryString)||($.requestParameters.X-Amz-Expires IS NULL)))||
  ($.userIdentity.type!=IAMUser)
  )&&
  ($.errorCode!=AccessDenied)
  }
  EOT
  log_group_name = "/cloudtrail/s3"

  metric_transformation {
    name      = "${local.PJPrefix}-${local.EnvPrefix}-s3-iam-user-download"
    namespace = "CloudTrail/"
    value     = 1
  }

}
*/
/*
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
*/
### ------------------------------------------------------------#
###  ecs exec
### ------------------------------------------------------------#
/*
resource "aws_cloudwatch_metric_alarm" "memoryusage-rds" {
  alarm_name          = "cw-alarm-memoryusage-rds"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = 1
  actions_enabled     = "true"
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
  ok_actions = [
    aws_sns_topic.slack.arn
  ]

  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/EC2"
      metric_name = "CPUUtilization"
      period      = 300
      stat        = "Average"

      dimensions = {
        InstanceId = "i-0ae8fbc814be61944"
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      namespace   = "AWS/EC2"
      metric_name = "CPUUtilization"
      period      = 300
      stat        = "Average"

      dimensions = {
        InstanceId = "i-0b962baa1e29b2385"
      }
    }
  }

  # 計算式用metric_query
  metric_query {
    id          = "e1"
    return_data = true
    expression  = "m1>m2"
    label       = "CPUUsage"
  }
}
*/