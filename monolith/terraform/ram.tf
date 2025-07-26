# ------------------------------------------------------------#
#  resource configuration
# ------------------------------------------------------------#
/*
resource "aws_ram_resource_share" "resource_configuration_rds" {
  name                      = "${local.PJPrefix}-${local.EnvPrefix}-rds-rc-share"
  allow_external_principals = true

  tags = {
    
  }
}

resource "aws_ram_resource_association" "resource_configuration_rds" {
  resource_arn       = aws_vpclattice_resource_configuration.rds.arn
  resource_share_arn = aws_ram_resource_share.resource_configuration_rds.arn
}
*/
/*
resource "aws_ram_principal_association" "resource_configuration_rds" {
  principal          = "111111111111"
  resource_share_arn = aws_ram_resource_share.resource_configuration_rds.arn
}
*/