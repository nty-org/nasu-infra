# ------------------------------------------------------------#
#  ipset
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  api
## ------------------------------------------------------------#
/*
resource "aws_wafv2_ip_set" "api_maintenance" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-api-maintenance"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["119.170.93.74/32"]

  lifecycle {
    ignore_changes = [addresses]
  }

}
*/
## ------------------------------------------------------------#
##  code server
## ------------------------------------------------------------#

resource "aws_wafv2_ip_set" "code_server_maintenance" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-code-server-maintenance"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["119.170.93.74/32", ""]

  lifecycle {
    ignore_changes = [addresses]
  }

}

# ------------------------------------------------------------#
#  webacl
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  api
## ------------------------------------------------------------#
/*
resource "aws_wafv2_web_acl" "api" {
  name  = "${local.PJPrefix}-${local.EnvPrefix}-api-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "${local.PJPrefix}-${local.EnvPrefix}-api-maintenance"
    priority = "0"

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.api_maintenance.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = "${local.PJPrefix}-${local.EnvPrefix}-api-maintenance"
      sampled_requests_enabled   = "true"
    }
  }

  rule {
    name     = "${local.PJPrefix}-${local.EnvPrefix}-api-block-from-overseas"
    priority = "1"

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = [
          "CN",
          "RU",
        ]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = "${local.PJPrefix}-${local.EnvPrefix}-api-block-from-overseas"
      sampled_requests_enabled   = "true"
    }
  }

  custom_response_body {
    key          = "maintenance_html"
    content      = file("./maintenance.html")
    content_type = "TEXT_HTML"
  }

  visibility_config {
    cloudwatch_metrics_enabled = "true"
    metric_name                = "${local.PJPrefix}-${local.EnvPrefix}-api-waf"
    sampled_requests_enabled   = "true"
  }

  lifecycle {
    ignore_changes = [default_action]
  }

}

resource "aws_wafv2_web_acl_association" "api" {
  resource_arn = aws_lb.flask.arn
  web_acl_arn  = aws_wafv2_web_acl.api.arn
}

resource "aws_wafv2_ip_set" "api_whitelist" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-api-whitelist"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = []

  lifecycle {
    ignore_changes = [addresses]
  }

}

resource "aws_wafv2_ip_set" "api_blacklist" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-api-blacklist"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = []

  lifecycle {
    ignore_changes = [addresses]
  }

}

resource "aws_wafv2_web_acl" "api" {
    name        = "CreatedByALB-6106840769859af9"
    scope       = "REGIONAL"

    default_action {
        allow {}
    }

    rule {
        name     = "AWS-AWSManagedRulesAmazonIpReputationList"
        priority = 0

        override_action {
            count {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesAmazonIpReputationList"
                vendor_name = "AWS"
            }
        }

        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "AWS-AWSManagedRulesCommonRuleSet"
        priority = 1

        override_action {
            count {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesCommonRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
        priority = 2

        override_action {
            count {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesKnownBadInputsRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
        sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "${local.PJPrefix}-${local.EnvPrefix}-api-whitelist"
        priority = 3

        action {
            allow {}
        }

        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.api_whitelist.arn
            }
        }

        visibility_config {
        cloudwatch_metrics_enabled = "true"
        metric_name                = "${local.PJPrefix}-${local.EnvPrefix}-api-whitelist"
        sampled_requests_enabled   = "true"
        }
    }

    rule {
        name     = "${local.PJPrefix}-${local.EnvPrefix}-api-blacklist"
        priority = 4

        action {
            count {}
        }

        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.api_blacklist.arn
            }
        }

        visibility_config {
        cloudwatch_metrics_enabled = "true"
        metric_name                = "${local.PJPrefix}-${local.EnvPrefix}-api-blacklist"
        sampled_requests_enabled   = "true"
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = "true"
        metric_name                = "CreatedByALB-6106840769859af9"
        sampled_requests_enabled   = "true"
    }

    lifecycle {
    ignore_changes = [default_action]
  }

}
*/
## ------------------------------------------------------------#
##  codeserver
## ------------------------------------------------------------#

resource "aws_wafv2_web_acl" "code_server" {
  name  = "${local.PJPrefix}-${local.EnvPrefix}-code-server-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "${local.PJPrefix}-${local.EnvPrefix}-code-server-maintenance"
    priority = "0"

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.code_server_maintenance.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = "${local.PJPrefix}-${local.EnvPrefix}-code-server-maintenance"
      sampled_requests_enabled   = "true"
    }
  }

  custom_response_body {
    key          = "maintenance_html"
    content      = file("./maintenance.html")
    content_type = "TEXT_HTML"
  }

  visibility_config {
    cloudwatch_metrics_enabled = "true"
    metric_name                = "${local.PJPrefix}-${local.EnvPrefix}-code-server-waf"
    sampled_requests_enabled   = "true"
  }

  lifecycle {
    ignore_changes = [default_action]
  }

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-code-server"
  }

}

resource "aws_wafv2_web_acl_association" "code_server" {
  resource_arn = aws_lb.code_server.arn
  web_acl_arn  = aws_wafv2_web_acl.code_server.arn
}

## ------------------------------------------------------------#
##  ddos detection
## ------------------------------------------------------------#
/*
resource "aws_wafv2_web_acl" "code_server" {
    name        = "${local.PJPrefix}-${local.EnvPrefix}-ddos-waf"
    scope       = "REGIONAL"

    default_action {
        allow {}
    }
    
    rule {
        name     = "AWS-AWSManagedRulesAntiDDoSRuleSet"
        priority = 0

        override_action {
            none {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesAntiDDoSRuleSet"
                vendor_name = "AWS"
                
                managed_rule_group_configs {
                  aws_managed_rules_anti_ddos_rule_set {
                    sensitivity_to_block = "LOW"
                    
                    client_side_action_config {
                      challenge {
                        sensitivity = "HIGH"
                        usage_of_action = "DISABLED"
                        exempt_uri_regular_expression {
                          regex_string = "\\/test\\/" # アプリ側の仕様に合わせ、パスを指定
                        }
                      }
                    }
                  }
                  
                }
                
                rule_action_override {
                  name = "ChallengeAllDuringEvent"
                  
                  action_to_use {
                    count {
                    }
                  }
                }
                
                rule_action_override {
                  name = "ChallengeDDoSRequests"
                  
                  action_to_use {
                    count {
                    }
                  }
                }
                
                rule_action_override {
                  name = "DDoSRequests"
                  
                  action_to_use {
                    count {
                    }
                  }
                }
            }
        }

        visibility_config {
        cloudwatch_metrics_enabled = "true"
        metric_name                = "AWS-AWSManagedRulesAntiDDoSRuleSet"
        sampled_requests_enabled   = "true"
        }
    }
    
    custom_response_body {
        key          = "maintenance_html"
        content      = file("./maintenance.html")
        content_type = "TEXT_HTML"
    }

    visibility_config {
        cloudwatch_metrics_enabled = "true"
        metric_name                = "${local.PJPrefix}-${local.EnvPrefix}-ddos-waf"
        sampled_requests_enabled   = "true"
    }

    lifecycle {
    ignore_changes = [default_action]
  }

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-ddos"
  }

}
*/