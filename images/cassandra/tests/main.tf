terraform {
  required_providers {
    oci = { source = "chainguard-dev/oci" }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

variable "digest" {
  description = "The image digest to run tests over."
}

data "oci_string" "ref" { input = var.digest }

data "oci_exec_test" "test" {
  for_each = toset(fileset(path.module, "*.sh"))

  digest = var.digest
  script = "${path.module}/${each.value}"
}

resource "kubernetes_manifest" "prerequisitesS" {
  for_each = fileset(path.module, "manifests/*.yaml")
  manifest = yamldecode(file("${path.module}/${each.value}"))
}

resource "kubernetes_manifest" "stateful_set" {
  manifest = yamldecode(templatefile("${path.module}/manifests/cassandra-stateful-set.yaml.tpl",
    {
      cassandra_tag  = data.oci_string.ref.pseudo_tag
      cassandra_repo = data.oci_string.ref.registry_repo
    })
  )
}
