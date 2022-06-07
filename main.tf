terraform {
  experiments = [
    module_variable_optional_attrs
  ]

  required_version = ">= 1.1.9, < 2.0.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.1.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

module "secrets" {
  source  = "ilpozzd/secrets/talos"
  version = "1.0.0"

  validity_period_hours = var.validity_period_hours
}

module "control_plane_vm" {
  source  = "ilpozzd/vsphere-vm/talos"
  version = "1.1.2"

  datacenter     = var.datacenter
  datastores     = var.datastores
  hosts          = var.hosts
  resource_pool  = var.resource_pool
  folder         = var.folder
  remote_ovf_url = var.remote_ovf_url

  vm_count = var.control_plane_count
  num_cpus = var.control_plane_num_cpus
  memory   = var.control_plane_memory

  disks              = var.control_plane_disks
  network_interfaces = var.control_plane_network_interfaces

  create_init_node = true

  talos_base_configuration = var.talos_base_configuration
  talos_admin_pki          = local.talos_admin_pki

  machine_base_configuration  = var.machine_base_configuration
  machine_extra_configuration = var.control_plane_machine_extra_configuration
  machine_secrets             = local.machine_secrets

  machine_type               = "controlplane"
  machine_cert_sans          = var.control_plane_machine_cert_sans
  machine_network            = var.machine_network
  machine_network_hostnames  = var.control_plane_machine_network_hostnames
  machine_network_interfaces = var.control_plane_machine_network_interfaces

  cluster_name                        = var.cluster_name
  cluster_control_plane               = local.cluster_control_plane
  cluster_discovery                   = var.cluster_discovery
  control_plane_cluster_configuration = var.control_plane_cluster_configuration

  cluster_secrets               = local.cluster_secrets
  control_plane_cluster_secrets = local.control_plane_cluster_secrets

  cluster_inline_manifests       = var.cluster_inline_manifests
  cluster_extra_manifests        = var.cluster_extra_manifests
  cluster_extra_manifest_headers = var.cluster_extra_manifest_headers
}

module "worker_vm" {
  source  = "ilpozzd/vsphere-vm/talos"
  version = "1.1.2"

  datacenter     = var.datacenter
  datastores     = reverse(var.datastores)
  hosts          = reverse(var.hosts)
  resource_pool  = var.resource_pool
  folder         = var.folder
  remote_ovf_url = var.remote_ovf_url

  vm_count = var.worker_count
  num_cpus = var.worker_num_cpus
  memory   = var.worker_memory

  disks              = var.worker_disks
  network_interfaces = var.worker_network_interfaces

  talos_base_configuration = var.talos_base_configuration

  machine_base_configuration  = var.machine_base_configuration
  machine_extra_configuration = var.worker_machine_extra_configuration
  machine_secrets             = local.machine_secrets

  machine_type               = "worker"
  machine_cert_sans          = var.worker_machine_cert_sans
  machine_network            = var.machine_network
  machine_network_hostnames  = var.worker_machine_network_hostnames
  machine_network_interfaces = var.worker_machine_network_interfaces

  cluster_name          = var.cluster_name
  cluster_control_plane = local.cluster_control_plane
  cluster_discovery     = var.cluster_discovery

  cluster_secrets = local.cluster_secrets
}

resource "local_file" "kubeconfig" {
  count    = var.kubeconfig_path != "" ? 1 : 0
  filename = var.kubeconfig_path
  content  = yamlencode(local.kubeconfig)
}

resource "local_file" "talosconfig" {
  count    = var.talosconfig_path != "" ? 1 : 0
  filename = var.talosconfig_path
  content  = yamlencode(local.talosconfig)
}
