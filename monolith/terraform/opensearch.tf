# ------------------------------------------------------------#
#  domain
# ------------------------------------------------------------#
/*
resource "aws_opensearch_domain" "main" {
  domain_name    = "${local.PJPrefix}-${local.EnvPrefix}"
  engine_version = "OpenSearch_1.3"

  cluster_config {
    instance_type  = "t3.medium.search"
    instance_count = 1
  }

  access_policies = data.aws_iam_policy_document.opensearch_node.json

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  vpc_options {
    security_group_ids = [aws_security_group.private.id]
    subnet_ids         = [aws_subnet.private["ap-northeast-1a"].id]
  }
}

data "aws_iam_policy_document" "opensearch_node" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:user/${local.PJPrefix}-${local.EnvPrefix}-app"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:ap-northeast-1:${local.account_id}:domain/${local.PJPrefix}-${local.EnvPrefix}/*"]
  }
}
*/