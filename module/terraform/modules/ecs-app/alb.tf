# ------------------------------------------------------------#
#  alb
# ------------------------------------------------------------#

resource "aws_lb" "app" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}-alb"
  security_groups    = [var.public_security_group_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "app_http" {
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

  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_listener" "app_https" {
  default_action {
    target_group_arn = aws_lb_target_group.app.arn
    type             = "forward"
  }

  certificate_arn   = var.certificate_arn
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-2019-08"

}

resource "aws_lb_target_group" "app" {
  deregistration_delay = "0"

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    matcher             = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "20"
    unhealthy_threshold = "5"
  }
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  name                          = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}-tg"
  port                          = "3001"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  target_type                   = "ip"
  vpc_id                        = var.vpc_id

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }
}
