# -------------------------------------------------------------#
#  network
# -------------------------------------------------------------#

module "network" {
  source      = "../../modules/network"
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = data.aws_caller_identity.current.account_id
  vpc_cidr   = "10.0.0.0/16"
  azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  azs_suffix = ["a", "c", "d"]
  subnets = {
    public  = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
    private = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
  }
}

# -------------------------------------------------------------#
#  ec2 ws
# -------------------------------------------------------------#

module "ec2_ws" {
  source      = "../../modules/ec2-ws"
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  vpc_id     = module.network.vpc_id
  allowed_cidr_blocks = [
    "119.170.82.158/32",
  ]
}
