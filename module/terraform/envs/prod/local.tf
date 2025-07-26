locals {

  PJPrefix  = "nasu"
  EnvPrefix = "prod"

  account_id = "267751904634"

  zone_name = "sunasuna.net"

  vpc_cidr = "10.1.0.0/16"

  azs = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d"
  ]

  azs_suffix = ["a", "c", "d"]

  subnets = {
    public  = ["10.1.0.0/20", "10.1.16.0/20", "10.1.32.0/20"]
    private = ["10.1.48.0/20", "10.1.64.0/20", "10.1.80.0/20"]
  }

  worker_queues = [
    "azure-japaneast1",
    "azure-australiaeast",
    "openai",
  ]

  slack_workspace_id = "T02KGURL8BG"

  slack_channel_id = "C05H3HTMLSY"

  slack_channel_name = "times_nasu"

  vercel_team_slug = "times_nasu"

}