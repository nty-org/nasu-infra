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