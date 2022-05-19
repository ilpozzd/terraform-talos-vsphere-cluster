locals {
  machine_secrets               = defaults(var.machine_secrets, module.secrets.machine_secrets)
  talos_admin_pki               = defaults(var.talos_admin_pki, module.secrets.talos_admin_pki)
  cluster_secrets               = defaults(var.cluster_secrets, module.secrets.cluster_secrets)
  control_plane_cluster_secrets = defaults(var.control_plane_cluster_secrets, module.secrets.control_plane_cluster_secrets)

  cluster_control_plane = defaults(var.cluster_control_plane, {
    endpoint = "https://${replace(var.control_plane_machine_network_interfaces[0][0].addresses[0], "/[/].*/", "")}:6443"
  })

  kubeconfig = {
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        name = var.cluster_name
        cluster = {
          server                     = local.cluster_control_plane.endpoint
          certificate-authority-data = module.secrets.cluster_secrets.ca.crt
        }
      }
    ]
    users = [
      {
        name = "admin@${var.cluster_name}"
        user = {
          client-certificate-data = module.secrets.kubernetes_admin_pki.crt
          client-key-data         = module.secrets.kubernetes_admin_pki.key
        }
      }
    ]
    contexts = [
      {
        context = {
          cluster   = var.cluster_name
          namespace = "default"
          user      = "admin@${var.cluster_name}"
        }
        name = "admin@${var.cluster_name}"
      }
    ]
    current-context = "admin@${var.cluster_name}"
  }

  talosconfig = {
    context = "admin@${var.cluster_name}"
    contexts = {
      "admin@${var.cluster_name}" = merge(
        { endpoints = module.control_plane_vm.default_ip_addresses },
        { nodes = concat(module.control_plane_vm.default_ip_addresses, module.worker_vm.default_ip_addresses) },
        { ca = local.machine_secrets.ca.crt },
        local.talos_admin_pki
      )
    }
  }
}
