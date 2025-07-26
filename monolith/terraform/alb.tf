# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#
/*
resource "aws_lb" "api" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${local.PJPrefix}-${local.EnvPrefix}-api-alb"
  security_groups    = [aws_security_group.public.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "api_http" {
  default_action {
    target_group_arn = aws_lb_target_group.api.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.api.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_target_group" "api" {
  deregistration_delay = "0"

  health_check {
    enabled             = "true"
    path                = "/api/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
    timeout             = "120"
    interval            = "300"
    matcher             = "200"
  }
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  name                          = "${local.PJPrefix}-${local.EnvPrefix}-api-tg"
  port                          = "3001"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  target_type                   = "ip"
  vpc_id                        = aws_vpc.this.id

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }
}
*/
# ------------------------------------------------------------#
#  flask
# ------------------------------------------------------------#
/*
resource "aws_lb" "flask" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${local.PJPrefix}-${local.EnvPrefix}-flask-alb"
  security_groups    = [aws_security_group.public.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "flask_http" {
  default_action {
    target_group_arn = aws_lb_target_group.flask.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.flask.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_target_group" "flask" {
  deregistration_delay = "0"

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "20"
    unhealthy_threshold = "5"
  }
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  name                          = "${local.PJPrefix}-${local.EnvPrefix}-flask-tg"
  port                          = "3001"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  target_type                   = "ip"
  vpc_id                        = aws_vpc.this.id

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }
}
*/
# ------------------------------------------------------------#
#  flask bg
# ------------------------------------------------------------#
/*
resource "aws_lb" "flask" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${local.PJPrefix}-${local.EnvPrefix}-flask-alb"
  security_groups    = [aws_security_group.public.id]
  subnets            = data.aws_subnets.public.ids

}

resource "aws_lb_listener" "flask_http" {
  default_action {
    target_group_arn = aws_lb_target_group.flask["blue"].arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.flask.arn
  port              = "80"
  protocol          = "HTTP"

  lifecycle {
    ignore_changes = [
      default_action[0].target_group_arn,
      default_action[0].forward
    ]
  }
}

resource "aws_lb_target_group" "flask" {
  for_each = toset(["blue", "green"])

  deregistration_delay = "0"

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "20"
    unhealthy_threshold = "5"
  }
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  name                          = "${local.PJPrefix}-${local.EnvPrefix}-flask-tg-${each.value}"
  port                          = "3001"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  target_type                   = "ip"
  vpc_id                        = aws_vpc.this.id

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }
}
*/
# ------------------------------------------------------------#
#  flask2
# ------------------------------------------------------------#
/*
resource "aws_lb" "flask2" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${local.PJPrefix}-${local.EnvPrefix}-flask2-alb"
  security_groups    = [aws_security_group.public.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "flask2_http" {
  default_action {
    target_group_arn = aws_lb_target_group.flask2.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.flask2.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_target_group" "flask2" {
  deregistration_delay = "0"

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "20"
    unhealthy_threshold = "5"
  }
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  name                          = "${local.PJPrefix}-${local.EnvPrefix}-flask2-tg"
  port                          = "3001"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  target_type                   = "ip"
  vpc_id                        = aws_vpc.this.id

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }
}
*/
/*
# ------------------------------------------------------------#
#  django
# ------------------------------------------------------------#

resource "aws_lb" "django" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${local.PJPrefix}-${local.EnvPrefix}-django-alb"
  security_groups    = [aws_security_group.public.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "django_http" {
  default_action {
    target_group_arn = aws_lb_target_group.django.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.django.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_target_group" "django" {
  deregistration_delay = "0"

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "20"
    unhealthy_threshold = "5"
  }
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  name                          = "${local.PJPrefix}-${local.EnvPrefix}-django-tg"
  port                          = "3001"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  target_type                   = "ip"
  vpc_id                        = aws_vpc.this.id

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }
}
*/
# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#
/*
resource "aws_lb" "web" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${local.PJPrefix}-${local.EnvPrefix}-web-alb"
  security_groups    = [aws_security_group.public.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "web_http" {
  default_action {
    target_group_arn = aws_lb_target_group.web.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_target_group" "web" {
  deregistration_delay = "0"

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "20"
    unhealthy_threshold = "5"
  }
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  name                          = "${local.PJPrefix}-${local.EnvPrefix}-web-tg"
  port                          = "3001"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  target_type                   = "ip"
  vpc_id                        = aws_vpc.this.id

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }
}
*/

# ------------------------------------------------------------#
#  code server
# ------------------------------------------------------------#

resource "aws_lb" "code_server" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${local.PJPrefix}-${local.EnvPrefix}-code-server-alb"
  security_groups    = [aws_security_group.public.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "code_server_https" {
  default_action {
    target_group_arn = aws_lb_target_group.code_server.arn
    type             = "forward"
  }
  certificate_arn   = aws_acm_certificate.code_server.arn
  load_balancer_arn = aws_lb.code_server.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-2019-08"
}

resource "aws_lb_target_group" "code_server" {
  deregistration_delay = "0"

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "20"
    unhealthy_threshold = "5"
  }
  target_type                   = "instance"
  load_balancing_algorithm_type = "round_robin"
  name                          = "${local.PJPrefix}-${local.EnvPrefix}-code-server-tg"
  port                          = "8080"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  vpc_id                        = aws_vpc.this.id

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }
}

resource "aws_lb_target_group_attachment" "code_server" {
  target_group_arn = aws_lb_target_group.code_server.arn
  target_id        = data.aws_instance.code_server.id
  port             = 8080
}