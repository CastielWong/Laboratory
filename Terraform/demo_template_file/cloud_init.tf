data "template_file" "init-script" {
  template = file("scripts/${var.INIT_FILE}")
  vars = {
    REGION = var.AWS_REGION
  }
}

data "template_file" "shell-script" {
  template = file("scripts/${var.VOLUME_INIT_SCRIPT}")
  vars = {
    DEVICE = var.INSTANCE_DEVICE_NAME
  }
}

data "template_cloudinit_config" "demo-cloudinit" {
  gzip          = false
  base64_encode = false

  part {
    # filename     = var.INIT_FILE
    content_type = "text/cloud-config"
    content      = data.template_file.init-script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}
