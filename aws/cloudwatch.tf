# ------------------------------------------------------------#
#  dashboard
# ------------------------------------------------------------#

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
resource "aws_cloudwatch_metric_alarm" "open_search_cpu" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-open-search-cpu"
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
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis"
    "CacheNodeId"    = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}

resource "aws_cloudwatch_metric_alarm" "open_search_memory" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-open-search-cpu"
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
    "CacheClusterId" = "${local.PJPrefix}-${local.EnvPrefix}-redis"
    "CacheNodeId"    = "${local.PJPrefix}-${local.EnvPrefix}-redis-001"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

}
*/