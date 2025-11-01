# ------------------------------------------------------------#
#  synthetics
# ------------------------------------------------------------#

locals {
  rendered_file = {
    for key, value in var.synthetics_canaries :
    key => templatefile("${path.module}/canary_script/template/canary.js.tpl", {
      hostname = value.hostname,
      path     = value.path,
    })
  }

  zip_file = {
    for key, rendered in local.rendered_file :
    key => "canary_${sha256(rendered)}.zip"
  }
}

resource "null_resource" "create_canary_dirs" {
  for_each = var.synthetics_canaries

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/canary_script/${each.key}"
  }
}

data "archive_file" "synthetics" {
  for_each = var.synthetics_canaries
  depends_on = [null_resource.create_canary_dirs]

  type        = "zip"
  output_path = "${path.module}/canary_script/${each.key}/${local.zip_file[each.key]}"

  source {
    content  = local.rendered_file[each.key]
    filename = "canary_${each.key}.js"
  }
}
