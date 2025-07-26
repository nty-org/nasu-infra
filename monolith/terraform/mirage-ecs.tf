# ------------------------------------------------------------#
#  alb
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  mirage ecs
# ------------------------------------------------------------#
/*
resource "aws_lb" "mirage_ecs" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs-alb"
  security_groups    = [aws_security_group.public.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "mirage_ecs_http" {
  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  load_balancer_arn = aws_lb.mirage_ecs.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_listener" "mirage_ecs_https" {
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
      message_body = "404 Not Found"
    }
  }
  certificate_arn   = aws_acm_certificate.api.arn
  load_balancer_arn = aws_lb.mirage_ecs.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-2019-08"
}

resource "aws_lb_listener_rule" "mirage_ecs_launched" {
  listener_arn = aws_lb_listener.mirage_ecs_https.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mirage_ecs.arn
  }

  condition {
    host_header {
      values = [
        "*.api.${local.zone_name}",
      ]
    }
  }
}


resource "aws_lb_target_group" "mirage_ecs" {
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
  port                 = 80
  target_type          = "ip"
  vpc_id               = aws_vpc.this.id
  protocol             = "HTTP"
  deregistration_delay = 10

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 6
  }
}
*/
/*
resource "aws_lb_listener_rule" "mirage_ecs_web" {
  listener_arn = aws_lb_listener.mirage_ecs_http.arn
  priority     = 1

  // If you want to use OIDC authentication, you need to set the following tf variables.
  // oauth_client_id, oauth_client_secret
  // You must set the OAuth callback URL to https://${var.domain}/oauth2/idresponse
  // See also https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/listener-authenticate-users.html
  dynamic "action" {
    for_each = var.oauth_client_id != "" ? [1] : []
    content {
      type = "authenticate-oidc"
      authenticate_oidc {
        authorization_endpoint = jsondecode(data.http.oidc_configuration.response_body)["authorization_endpoint"]
        issuer                 = jsondecode(data.http.oidc_configuration.response_body)["issuer"]
        token_endpoint         = jsondecode(data.http.oidc_configuration.response_body)["token_endpoint"]
        user_info_endpoint     = jsondecode(data.http.oidc_configuration.response_body)["userinfo_endpoint"]
        scope                  = "email"
        client_id              = var.oauth_client_id
        client_secret          = var.oauth_client_secret
      }
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mirage-ecs-http.arn
  }

  condition {
    host_header {
      values = [
        "mirage.${var.domain}",
      ]
    }
  }
}
*/
# ------------------------------------------------------------#
#  ecs
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  mirage ecs
# ------------------------------------------------------------#
/*
data "aws_ecs_task_definition" "mirage_ecs" {
  task_definition = aws_ecs_task_definition.mirage_ecs.family
}

resource "aws_cloudwatch_log_group" "mirage_ecs" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
  }
}

resource "aws_ecs_task_definition" "mirage_ecs" {
  container_definitions = jsonencode([
    {
      name   = "mirage-ecs"
      image  = "ghcr.io/acidlemon/mirage-ecs:v2.0.0"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name      = "MIRAGE_DOMAIN"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/MIRAGE_DOMAIN"
        },
        {
          name      = "MIRAGE_LOG_LEVEL"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/MIRAGE_LOG_LEVEL"
        },
        {
          name      = "MIRAGE_CONF"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/MIRAGE_CONF"
        },
        {
          name      = "HTMLDIR"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/HTMLDIR"
        }
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
  }
}
*/
/*
resource "aws_ecs_service" "mirage_ecs" {
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE"
    weight            = "1"
  }

  cluster = aws_ecs_cluster.this.id

  deployment_circuit_breaker {
    enable   = "true"
    rollback = "true"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "1"
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "0"

  load_balancer {
    container_name   = "mirage-ecs"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.mirage_ecs.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.mirage_ecs.family}:${max(aws_ecs_task_definition.mirage_ecs.revision, data.aws_ecs_task_definition.mirage_ecs.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
    ]
  }
}
*/
# ------------------------------------------------------------#
#  ssm
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  mirage ecs
# ------------------------------------------------------------#
/*
resource "aws_ssm_parameter" "mirage_domain" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/MIRAGE_DOMAIN"
  type  = "String"
  value = "api.${local.zone_name}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
  }
}

resource "aws_ssm_parameter" "mirage_log_level" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/MIRAGE_LOG_LEVEL"
  type  = "String"
  value = "info"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
  }
}

resource "aws_ssm_parameter" "mirage_conf" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/MIRAGE_CONF"
  type  = "String"
  value = "s3://${aws_s3_bucket.mirage_ecs.bucket}/config.yaml"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
  }
}

resource "aws_ssm_parameter" "htmldir" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/HTMLDIR"
  type  = "String"
  value = "s3://${aws_s3_bucket.mirage_ecs.bucket}/html"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
  }
}
*/
# ------------------------------------------------------------#
#  s3
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  mirage ecs
# ------------------------------------------------------------#

resource "aws_s3_bucket" "mirage_ecs" {
  bucket = "${local.PJPrefix}-${local.EnvPrefix}-mirage-ecs"
}

resource "aws_s3_object" "config" {
  bucket = aws_s3_bucket.mirage_ecs.id
  key    = "config.yaml"
  source = "config.yaml"
}

resource "aws_s3_object" "html" {
  for_each = toset(["launcher.html", "layout.html", "list.html"])
  bucket   = aws_s3_bucket.mirage_ecs.id
  key      = "html/${each.value}"
  source   = format("./html/%s", each.value)
}

# ------------------------------------------------------------#
#  acm
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#
/*
resource "aws_acm_certificate" "api" {
  domain_name       = "*.api.${local.zone_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
*/
# ------------------------------------------------------------#
#  route53
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#
/*
resource "aws_route53_record" "api_alias" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "*.api.${local.zone_name}"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.mirage_ecs.dns_name}"
    zone_id                = aws_lb.mirage_ecs.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "acm_validation_api" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}
*/

# ------------------------------------------------------------#
#  共通リソース
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  acm
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#
/*
resource "aws_acm_certificate" "web" {
  domain_name       = "web.${local.zone_name}"
  validation_method = "DNS"
  provider          = aws.virginia

  lifecycle {
    create_before_destroy = true
  }
}
*/
# ------------------------------------------------------------#
#  route53
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#
/*
resource "aws_route53_record" "api_alias" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "*.api.${local.zone_name}"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.mirage_ecs.dns_name}"
    zone_id                = aws_lb.mirage_ecs.zone_id
    evaluate_target_health = true
  }
}
*/
/*
resource "aws_route53_record" "acm_validation_web" {
  for_each = {
    for dvo in aws_acm_certificate.web.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 300
  type    = each.value.type
  zone_id = data.aws_route53_zone.this.zone_id
}
*/
# ------------------------------------------------------------#
#  cloudfront
# ------------------------------------------------------------#
/*
resource "aws_cloudfront_origin_access_control" "web_vue3" {
  name                              = "${local.PJPrefix}-${local.EnvPrefix}-web-origin-access-control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "this" {
  comment     = ""
  default_ttl = "10"
  max_ttl     = "10"
  min_ttl     = "10"
  name        = "${local.PJPrefix}-${local.EnvPrefix}-cache-policy"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = "true"
    enable_accept_encoding_gzip   = "true"

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["Origin"]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "cache_control_no_cache" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-cache-control-no-cache"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = false
      value    = "no-cache, no-store, must-revalidate"
    }
  }
}
*/
# ------------------------------------------------------------#
#  secrets manager
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#
/*
resource "aws_secretsmanager_secret" "web" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/web"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}
*/
# ------------------------------------------------------------#
#  IAM
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  github actions OIDC
# ------------------------------------------------------------#
/*
resource "aws_iam_openid_connect_provider" "github_actions_mirage_ecs" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

resource "aws_iam_role" "github_actions_mirage_ecs" {
  assume_role_policy   = data.aws_iam_policy_document.github_actions_mirage_ecs_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-github-actions-mirage-ecs-role"
  path                 = "/"

}

data "aws_iam_policy_document" "github_actions_mirage_ecs_assume_role_policy" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:usan73/nasu-app-flask:*"]
    }
  }
}

resource "aws_iam_policy" "github_actions_mirage_ecs" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-github-actions-mirage-ecs-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.github_actions_mirage_ecs.json
}

data "aws_iam_policy_document" "github_actions_mirage_ecs" {

  statement {
    effect = "Allow"

    actions = [
      "ecs:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = ["arn:aws:iam::${local.account_id}:role/${local.PJPrefix}-${local.EnvPrefix}-ecs-task-role"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:FilterLogEvents",
    ]

    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "github_actions_mirage_ecs" {
  role       = aws_iam_role.github_actions_mirage_ecs.name
  policy_arn = aws_iam_policy.github_actions_mirage_ecs.arn
}
*/