variable "name" {
  description = "Package name (e.g. cainjector, acmeresolver, controller, webhook)"
}

variable "suffix" {
  description = "Package name suffix (e.g. version stream)"
  default     = ""
}

variable "extra_packages" {
  description = "Additional packages to install."
  type        = list(string)
  default     = []

}

# agent runs as root while others as non-root, this variable is for that
variable "run-as" {
  description = "The user with which this should run as"
  default     = 65532
}

# agent and server require `run` while oidc-discovery-provider doesn't, this variable tries to handle that
variable "command" {
  description = "The user with which this should run as"
  default     = ""
}
module "accts" {
  source = "../../../tflib/accts"
  run-as = var.run-as
}

output "config" {
  value = jsonencode({
    contents = {
      packages = concat(["spire-${var.name}"], var.extra_packages)
    }
    accounts = module.accts.block
    entrypoint = {
      command = var.command
    }
  })
}