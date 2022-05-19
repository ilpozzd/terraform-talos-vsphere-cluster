output "cluster_endpoint" {
  description = "API endpoint of the cluster."
  value       = local.cluster_control_plane.endpoint
}

output "cluster_id" {
  description = "Qunique identificator of the cluster."
  sensitive   = true
  value       = module.secrets.cluster_secrets.id
}

output "cluster_nodes" {
  description = "List of all nodes in the cluster."
  value       = {
    control_plane = module.control_plane_vm.default_ip_addresses
    worker        = module.worker_vm.default_ip_addresses
  }
}

output "kubeconfig" {
  description = "Configuration file for obtaining administrative access to the cluster."
  sensitive   = true
  value       = yamlencode(local.kubeconfig)
}

output "talosconfig" {
  description = "Configuration file for obtaining administrative access to Talos virtual machines."
  sensitive   = true
  value       = yamlencode(local.talosconfig)
}

output "kubernetes_admin_pki" {
  description = "Cerificates and keys for obtaining administrative access to the cluster."
  sensitive   = true
  value = {
    cluster_ca_certificate = base64decode(module.secrets.cluster_secrets.ca.crt)
    client_certificate     = base64decode(module.secrets.kubernetes_admin_pki.crt)
    client_key             = base64decode(module.secrets.kubernetes_admin_pki.key)
  }
}
