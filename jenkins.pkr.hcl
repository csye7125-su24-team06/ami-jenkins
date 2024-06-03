source "amazon-ebs" "ubuntu" {
  region          = var.region
  ami_name        = "${var.ami_name_prefix}-{{timestamp}}"
  ami_description = var.ami_description
  tags            = var.tags
  instance_type   = var.instance_type
  source_ami      = var.source_ami
  ssh_username    = var.ssh_username
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "scripts/jenkins/"
    destination = "/tmp/"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DOMAIN=${var.domain}",
      "EMAIL=${var.email}",
      "JENKINS_USER=${var.jenkins_user}",
      "JENKINS_PASSWORD=${var.jenkins_password}"
    ]
    scripts = [
      "scripts/install-dependencies.sh",
      "scripts/install-jenkins.sh",
      "scripts/setup-jenkins.sh",
      "scripts/install-caddy.sh",
      "scripts/setup-caddy.sh",
      "scripts/install-docker.sh",
      "scripts/setup-docker.sh"
    ]
  }
}
