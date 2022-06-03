# Talos OS vSphere Cluster Terraform Module

Page in [Terraform Registry](https://registry.terraform.io/modules/ilpozzd/vsphere-cluster/talos/latest)

This module allows you to deploy a Kubernetes cluster based on Talos OS in the vSphere infrastructure.
The configuration of the virtual machines fully corresponds to the configuration of [Talos OS v1.0.x](https://www.talos.dev/v1.0/).

## Usage

```hcl
module "kubernetes-cluster" {
  source  = "ilpozzd/vsphere-cluster/talos"
  version = "1.1.0"

  datacenter = "Company_Datacenter"
  datastores = [
    "Datastore-1",
    "Datastore-2",
    "Datastore-3"
  ]
  hosts = [
    "host-1.company.local",
    "host-2.company.local",
    "host-3.company.local",
    "host-4.company.local"
  ]
  resource_pool  = "Kubernetes_Cluster"
  folder         = "Office/Kubernetes_Cluster"
  remote_ovf_url = "https://github.com/siderolabs/talos/releases/download/v1.0.5/vmware-amd64.ova"

  control_plane_count    = 3
  control_plane_num_cpus = 2
  control_plane_memory   = 2048
  control_plane_disks = [
    {
      label = "sda"
      size  = 20
    }
  ]
  control_plane_network_interfaces = [
    {
      name = "192_168_10_0"
    }
  ]

  worker_count    = 2
  worker_num_cpus = 4
  worker_memory   = 4096
  worker_disks = [
    {
      label = "sda"
      size  = 40
    }
  ]
  worker_network_interfaces = [
    {
      name = "192_168_10_0"
    }
  ]

  machine_base_configuration = {
    install = {
      disk       = "/dev/sda"
      image      = "ghcr.io/siderolabs/installer:latest"
      bootloader = true
      wipe       = false
    }
    time = {
      disabled = false
      servers = [
        "ntp.company.local"
      ]
      bootTimeout = "2m0s"
    }
    features = {
      rbac = true
    }
  }

  machine_network = {
    nameservers = [
      "192.168.1.10",
      "192.168.1.11"
    ]
  }

  control_plane_machine_network_interfaces = [
    [
      {
        interface = "eth0"
        addresses = [
          "192.168.10.10/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "192.168.10.1"
          }
        ]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "192.168.10.11/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "192.168.10.1"
          }
        ]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "192.168.10.12/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "192.168.10.1"
          }
        ]
      }
    ]
  ]

  worker_machine_network_interfaces = [
    [
      {
        interface = "eth0"
        addresses = [
          "192.168.10.13/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "192.168.10.1"
          }
        ]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "192.168.10.14/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "192.168.10.1"
          }
        ]
      }
    ]
  ]

  cluster_name = "kubernetes-cluster"
  kubeconfig_path = "./configs/kubeconfig"
  talosconfig_path = "./configs/talosconfig"
}
```

## Examples

* [Terragrunt Example](https://github.com/ilpozzd/talos-vsphere-cluster-terragrunt-example)

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.1.9, < 2.0.0 |
| [hashicorp/vsphere](https://registry.terraform.io/providers/hashicorp/vsphere/2.1.1) | 2.1.1 |

### vSphere Version >= `6.7u3`

### Required `Terraform Role` permissions in **vSphere**

Datastore:
* Allocate space
* Browse datastore
* Low level file operations
* Remove file
* Update virtual machine files
* Update virtual machine metadata

Folder:
* Create folder
* Delete folder
* Move folder
* Rename folder

Network:
* Assign network

Resource:
* Assign virtual machine to resource pool
* Migrate powered off virtual machine
* Migrate powered on virtual machine

Profile-driven storage:
* Profile-driven storage view

vApp:
* Import
* View OVF environment
* vApp application configuration
* vApp instance configuration
* vApp managedBy configuration
* vApp resource configuration

Virtual machine:
* Change Configuration
* Edit Inventory
* Guest Operations
* Interaction
* Provisioning

### Required objects to apply `roles`

| Object | Role | Defined in |
|---|---|---|
| vCenter | `Terraform Role` | This object |
| Datacenter | `Read-only Role` | This object |
| Datastore Cluster | `Terraform Role` | This object and it's children |
| Hosts Cluster | `Read-only Role` | This object |
| Hosts | `Terraform Role` | This object |
| DPG | `Terraform Role` | This object |
| Folder | `Terraform Role` | This object and it's children |
| Resource pool | `Terraform Role` | This object and it's children |

## Providers

| Name | Version |
|---|---|
| [hashicorp/vsphere](https://registry.terraform.io/providers/hashicorp/vsphere/2.1.1) | 2.1.1 |
| [hashicorp/local](https://registry.terraform.io/providers/hashicorp/local/2.2.3) | 2.2.3 |

## Modules

| Name | Version |
|---|---|
| [ilpozzd/secrets/talos](https://registry.terraform.io/modules/ilpozzd/secrets/talos/1.0.0) | 1.0.0 |
| [ilpozzd/vsphere-vm/talos](https://registry.terraform.io/modules/ilpozzd/vsphere-vm/talos/1.1.0) | 1.1.0 |

## Resources

| Name | Type |
|---|---|
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/2.2.3/docs/resources/file) | resource |
| [local_file.talosconfig](https://registry.terraform.io/providers/hashicorp/local/2.2.3/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| datacenter | VMware datacenter name. | `string` | `-` | Yes |
| datastores | VMWare datastore(s) where all data for the virtual machine will be placed in. | `list(string)` | `-` | Yes |
| hosts | ESXi host(s) where the virtual machine will be created. | `list(string)` | `-` | Yes |
| resource_pool | VMWare resource pool where the virtual machine will be created. | `string` | `-` | Yes |
| folder | Folder to create the virtual machines in. | `string` | `-` | Yes |
| remote_ovf_url | URL to the remote [Talos OS 1.0.x](https://github.com/siderolabs/talos/releases) ovf/ova file. | `string` | `-` | Yes |
| <a name="control-plane-count-cell"></a> control_plane_count | Number of 'controlplane' virtual machines.| `number` | `2` | No |
| <a name="worker-count-cell"></a> worker_count | Number of 'worker' virtual machines.| `number` | `0` | No |
| control_plane_num_cpus | The total number of virtual processor cores to assign to 'controlplane' virtual machines. | `number` | `2` | No |
| worker_num_cpus | The total number of virtual processor cores to assign to 'worker' virtual machines. | `number` | `4` | No |
| control_plane_memory | The amount of RAM for 'controlplane' virtual machines, in Mb. | `number` | `2048` | No |
| worker_memory | The amount of RAM for 'worker' virtual machines, in Mb. | `number` | `4096` | No |
| control_plane_disks | A specification list for a virtual disk devices on 'controlplane' virtual machines. Use only first disk to Talos installation in 'machine_base_configuration'. block | [`list`](#disks-input) | `-` | Yes |
| worker_disks | "A specification list for a virtual disk devices on 'worker' virtual machines. Use only first disk to Talos installation in 'machine_base_configuration' block. | [`list`](#disks-input) | `[]` | No |
| control_plane_network_interfaces | A specification list for a virtual NIC on 'controlplane' virtual machines. | [`list`](#network-interfaces-input) | `-` | Yes |
| worker_network_interfaces | A specification list for a virtual NIC on 'worker' virtual machines. | [`list`](#network-interfaces-input) | `[]` | No |
| talos_base_configuration | Talos OS top-level configuration. | [`object`](#talos-base-configuration-input) | [`object`](#talos-base-configuration-input) | No |
| machine_secrets | Secret data that is used to create trust relationships between virtual machines. | [`object`](#machine-secrets-input) | `-` | [No](#machine-secrets-input) |
| talos_admin_pki | Base64 encoded certificate (signed by [machine_secrets.ca.crt](#machine-secrets-input) and key (in ED25519) to provide access to virtual machine trought `talosctl`. | [`object`](#talos-admin-pki-input) | `{}` | [No](#talos-admin-pki-input) |
| machine_base_configuration | Basic configuration of all virtual machines. | [`object`](#machine-base-configuration-input) | `-` | Yes |
| control_plane_machine_extra_configuration | Extended configuration of 'controlplane' virtual machine. | [`object`](#machine-extra-configuration-input) | `{}` | No |
| worker_machine_extra_configuration | Extended configuration of 'worker' virtual machines. | [`object`](#machine-extra-configuration-input) | `{}` | No |
| control_plane_machine_cert_sans | A list of alternative names for [control_plane_count](#control-plane-count-cell) control planes (optional). | `list(list(string))` | `[]` | No |
| worker_machine_cert_sans | A list of alternative names for [worker_count](#worker-count-cell) workers (optional). | `list(list(string))` | `[]` | No |
| machine_network | General network configuration of the virtual machine. 'hostname' and 'interfaces' parameters are described in separate inputs. | [`object`](#machine-network-input) | `{}` | No |
| <a name="control-plane-machine-network-hostnames-cell"></a> control_plane_machine_network_hostnames | A list of hostnames for [control_plane_count](#control-plane-count-cell) of 'controlplane' virtual machines (if not set will be generated automatically). | `list(string)` | `[]` | No |
| <a name="worker-machine-network-hostnames-cell"></a> worker_machine_network_hostnames | A list of hostnames for [worker_count](#worker-count-cell) of 'worker' virtual machines (if not set will be generated automatically). | `list(string)` | `[]` | No |
| <a name="control-plane-machine-network-interfaces-cell"></a> control_plane_machine_network_interfaces | A list of network interfaces for [control_plane_count](#control-plane-count-cell) of 'controlplane' virtual machines (if not set DHCP will be used). Not less than one element with one static IP address required. | [`list`](#machine-network-interfaces-input) | `[]` | Yes |
| <a name="worker-machine-network-interfaces-cell"></a> worker_machine_network_interfaces | A list of network interfaces for [worker_count](#worker-count-cell) of 'worker' virtual machines (if not set DHCP will be used). | [`list`](#machine-network-interfaces-input) | `[]` | No |
| cluster_secrets | Secret data that is used to establish trust relationships between Kubernetes cluster nodes. | [`object`](#cluster-secrets-input) | `-` | [No](#cluster-secrets-input) |
| control_plane_cluster_secrets | Secret data required to establish trust relationships between components used by 'controlplane' nodes in the Kubernetes cluster. | [`object`](#control-plane-cluster-secrets-input) | `{}` | [No](#control-plane-cluster-secrets-input) |
| cluster_name | The name of the cluster. | `string` | `-` | Yes |
| cluster_control_plane | Data to define the API endpoint address for joining a node to the Kubernetes cluster. | [`object`](#cluster-control-plane-input) | `-` | [Yes/No](#cluster-control-plane-input) |
| cluster_discovery | Data that sets up the discovery of nodes in the Kubernetes cluster. | [`object`](#cluster-discovery-input) | [`object`](#cluster-discovery-input) | No |
| control_plane_cluster_configuration | Data that configure the components of the 'controlplane' nodes in the Kubernetes cluster. | [`object`](#control-plane-cluster-configuration-input) | `{}` | No |
| cluster_inline_manifests |A list of Kuberenetes manifests whose content is represented as a string. These will get automatically deployed as part of the bootstrap. | [`list`](#cluster-inline-manifests-input) | `[]` | No |
| cluster_extra_manifests | A list of `URLs` that point to additional manifests. These will get automatically deployed as part of the bootstrap. | `list(string)` | `[]` | No |
| cluster_extra_manifest_headers | A map of key value pairs that will be added while fetching the `cluster_extra_manifests`. | `map(string)` | `{}` | No |
| validity_period_hours | The number of hours after initial issuing that **ALL** generated certificates become invalid. | `number` | `8760` | No |
| kubeconfig_path | Path to save kubeconfig file (Include filename. If not set config will not be created). | `string` | `""` | No |
| talosconfig_path | Path to save talosconfig file (Include filename. If not set config will not be created). | `string` | `""` | No |
| vmtoolsd_extra_manifest | A link to talos-vmtoolsd Kubernetes manifest. | `string` | [`Link`](https://raw.githubusercontent.com/mologie/talos-vmtoolsd/release-0.3/deploy/0.3.yaml) | No |

### Disks Input

```hcl
list(object({
  label            = string
  size             = number
  eagerly_scrub    = optional(bool)
  thin_provisioned = optional(bool)
}))
```
* `label` - Any name for disk (label for Terraform)
* `size` - Capacity in **Gb**
* `eagerly_scrub` and `thin_provisioned` - See [vSphere Provider Documentation](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine#disk-options)

### Network Interfaces Input

```hcl
list(object({
  name = string
}))
```
* `name` - Distributed Port Group (DPG) name

### Talos Base Configuration Input

```hcl
object({
  version = string
  persist = bool
})
```

Default:

```hcl
{
  version = "v1alpha1"
  persist = false
}
```

See [Config](https://www.talos.dev/v1.0/reference/configuration/#config) section in Talos Configuration Reference for detail description.

### Machine Secrets Input

```hcl
object({
  token = string
  ca = object({
    crt = string
    key = string
  })
})
```

See [MachineConfig](https://www.talos.dev/v1.0/reference/configuration/#machineconfig) section in Talos Configuration Reference for detail description.

By default generated by [ilpozzd/secrets/talos](https://registry.terraform.io/modules/ilpozzd/secrets/talos/1.0.0). You can provide your own. If you provide this secrets you also must provide [talos_admin_pki](#talos-admin-pki)

### Talos Admin PKI Input

```hcl
object({
  crt = optional(string)
  key = optional(string)
})
```
* `crt` - Base64 encoded certificate in **PEM** format
* `key` - Base64 encoded key in **PEM** format

By default generated by [ilpozzd/secrets/talos](https://registry.terraform.io/modules/ilpozzd/secrets/talos/1.0.0).

### Machine Base Configuration 

```hcl
object({
  install = object({
    disk            = string
    extraKernelArgs = optional(list(string))
    image           = string
    bootloader      = bool
    wipe            = bool
    diskSelector = optional(object({
      size    = string
      model   = string
      busPath = string
    }))
    extensions = optional(list(string))
  })
  kubelet = optional(object({
    image      = string
    extraArgs  = optional(map(string))
    clusterDNS = optional(list(string))
    extraMounts = optional(list(object({
      destination = string
      type        = string
      source      = string
      options     = list(string)
    })))
    extraConfig = optional(map(string))
    nodeIP = optional(object({
      validSubnets = list(string)
    }))
  }))
  time = optional(object({
    disabled    = optional(bool)
    servers     = optional(list(string))
    bootTimeout = optional(string)
  }))
  features = optional(object({
    rbac = optional(bool)
  }))
})
```

See [MachineConfig](https://www.talos.dev/v1.0/reference/configuration/#machineconfig) section in Talos Configuration Reference for detail description.

### Machine Extra Configuration Input

```hcl
object({
  controlPlane = optional(object({
    controllerManager = object({
      disabled = bool
    })
    scheduler = object({
      disabled = bool
    })
  }))
  pods = optional(list(map(any)))
  disks = optional(list(object({
    device = string
    partitions = list(object({
      mountpoint = string
      size       = string
    }))
  })))
  files = optional(list(object({
    content     = string
    permissions = string
    path        = string
    op          = string
  })))
  env = optional(object({
    GRPC_GO_LOG_VERBOSITY_LEVEL = optional(string)
    GRPC_GO_LOG_SEVERITY_LEVEL  = optional(string)
    http_proxy                  = optional(string)
    https_proxy                 = optional(string)
    no_proxy                    = optional(bool)
  }))
  sysctls = optional(map(string))
  sysfs   = optional(map(string))
  registries = optional(object({
    mirrors = optional(map(object({
      endpoints = list(string)
    })))
    config = optional(map(object({
      tls = object({
        insecureSkipVerify = bool
        clientIdentity = optional(object({
          crt = string
          key = string
        }))
        ca = optional(string)
      })
      auth = optional(object({
        username      = optional(string)
        password      = optional(string)
        auth          = optional(string)
        identityToken = optional(string)
      }))
    })))
  }))
  systemDiskEncryption = optional(map(object({
    provider = string
    keys = optional(list(object({
      static = optional(object({
        passphrase = string
      }))
      nodeID = optional(map(string))
      slot   = optional(number)
    })))
    cipher    = optional(string)
    keySize   = optional(number)
    blockSize = optional(number)
    options   = optional(list(string))
  })))
  udev = optional(object({
    rules = list(string)
  }))
  logging = optional(object({
    destinations = list(object({
      endpoint = string
      format   = string
    }))
  }))
  kernel = optional(object({
    modules = list(object({
      name = string
    }))
  }))
})
```

See [MachineConfig](https://www.talos.dev/v1.0/reference/configuration/#machineconfig) section in Talos Configuration Reference for detail description.

### Machine Network Input

```hcl
object({
  nameservers = optional(list(string))
  extraHostEntries = optional(list(object({
    ip      = string
    aliases = list(string)
  })))
  kubespan = optional(object({
    enabled = bool
  }))
})
```
See [NetworkConfig](https://www.talos.dev/v1.0/reference/configuration/#networkconfig) section in Talos Configuration Reference for detail description. 

[hostname](#machine-network-hostnames-cell) and [interfaces](#machine-network-interfaces-cell) parameters are described in separate inputs.

### Machine Network Interfaces Input

```hcl
list(list(object({
  interface = string
  addresses = optional(list(string))
  routes = optional(list(object({
    network = string
    gateway = optional(string)
    source  = optional(string)
    metric  = optional(number)
  })))
  vlans = optional(list(object({
    addresses = list(string)
    routes = optional(list(object({
      network = string
      gateway = optional(string)
      source  = optional(string)
      metric  = optional(number)
    })))
    dhcp   = optional(boolbase64decode(module.secrets.kubernetes_admin_pki.key)
  mtu = optional(number)
  bond = optional(object({
    interfaces = list(string)
    mode       = string
    lacpRate   = string
  }))
  dhcp   = optional(bool)
  ignore = optional(bool)
  dummy  = optional(bool)
  dhcpOptions = optional(object({
    routeMetric = number
    ipv4        = optional(bool)
    ipv6        = optional(bool)
  }))
  wireguard = optional(object({
    privateKey   = string
    listenPort   = number
    firewallMark = number
    peers = list(object({
      publicKey                   = string
      endpoint                    = string
      persistentKeepaliveInterval = optional(string)
      allowedIPs                  = list(string)
    }))
  }))
  vip = optional(object({
    ip = string
    equinixMetal = optional(object({
      apiToken = string
    }))
    hcloud = optional(object({
      apiToken = string
    }))
  }))
})))
```

See [Device](https://www.talos.dev/v1.0/reference/configuration/#device) section in Talos Configuration Reference for detail description. 

### Cluster Secrets Input

```hcl
object({
  id     = string
  secret = string
  token  = string
  ca = object({
    crt = string
    key = string
  })
})
```
See [ClusterConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterconfig) section in Talos Configuration Reference for detail description. 

By default generated by [ilpozzd/secrets/talos](https://registry.terraform.io/modules/ilpozzd/secrets/talos/1.0.0). You can provide your own.

### Control Plane Cluster Secrets Input

```hcl
object({
  aescbcEncryptionSecret = optional(string)
  aggregatorCA = optional(object({
    crt = optional(string)
    key = optional(string)
  }))
  serviceAccount = optional(object({
    key = optional(string)
  }))
  etcd = optional(object({
    ca = object({
      crt = optional(string)
      key = optional(string)
    })
  }))
})
```

See [ClusterConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterconfig) section in Talos Configuration Reference for detail description.

By default generated by [ilpozzd/secrets/talos](https://registry.terraform.io/modules/ilpozzd/secrets/talos/1.0.0). You can provide your own.

### Cluster Control Plane Input

```hcl
object({
  endpoint           = optional(string)
  localAPIServerPort = optional(number)
})
```

See [ControlPlaneConfig](https://www.talos.dev/v1.0/reference/configuration/#controlplaneconfig) section in Talos Configuration Reference for detail description. 

Required if `init` node is outside of this cluster.

### Cluster Discovery Input

```hcl
object({
  enabled = bool
  registries = optional(object({
    kubernetes = optional(object({
      disabled = bool
    }))
    service = optional(object({
      disabled = bool
      endpoint = string
    }))
  }))
})
```

Default:

```hcl
{
  enabled = true
}
```

See [ClusterDiscoveryConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterdiscoveryconfig) section in Talos Configuration Reference for detail description.

### Control Plane Cluster Configuration Input

```hcl
object({
  network = optional(object({
    cni = optional(object({
      name = string
      urls = optional(list(string))
    }))
    dnsDomain      = optional(string)
    podSubnets     = optional(list(string))
    serviceSubnets = optional(list(string))
  }))
  apiServer = optional(object({
    image     = string
    extraArgs = optional(map(string))
    extraVolumes = optional(list(object({
      hostPath  = string
      mountPath = string
      readonly  = bool
    })))
    env                      = optional(map(string))
    certSANs                 = optional(list(string))
    disablePodSecurityPolicy = optional(bool)
    admissionControl = optional(list(object({
      name          = string
      configuration = map(any)
    })))
  }))
  controllerManager = optional(object({
    image     = string
    extraArgs = optional(map(string))
    extraVolumes = optional(list(object({
      hostPath  = string
      mountPath = string
      readonly  = bool
    })))
    env = optional(map(string))
  }))
  proxy = optional(object({
    disabled  = bool
    image     = optional(string)
    mode      = optional(string)
    extraArgs = optional(map(string))
  }))
  scheduler = optional(object({
    image     = string
    extraArgs = optional(map(string))
    extraVolumes = optional(list(object({
      hostPath  = string
      mountPath = string
      readonly  = bool
    })))
    env = optional(map(string))
  }))
  etcd = optional(object({
    image     = optional(string)
    extraArgs = optional(map(string))
    subnet    = optional(string)
  }))
  coreDNS = optional(object({
    disabled = bool
    image    = optional(string)
  }))
  externalCloudProvider = optional(object({
    enabled   = bool
    manifests = list(string)
  }))
  adminKubeconfig = optional(object({
    certLifetime = string
  }))
  allowSchedulingOnMasters = optional(bool)
})
```

See [ClusterConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterconfig) section in Talos Configuration Reference for detail description. 

### Cluster Inline Manifests Input

```hcl
list(object({
  name     = string
  contents = string
}))
```

See [ClusterConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterconfig) section in Talos Configuration Reference for detail description.

## Outputs

| Name | Description | Type | Sensitive |
|---|---|---|---|
| cluster_endpoint | API endpoint of the cluster. | `string` | `false` |
| cluster_id | Qunique identificator of the cluster. | `string` | `true` |
| cluster_nodes | List of all nodes in the cluster. | [`object`](#cluster-nodes-output) | `false` |
| kubeconfig | Configuration file for obtaining administrative access to the cluster. | `string` | `true` |
| talosconfig | Configuration file for obtaining administrative access to Talos virtual machines. | `string` | `true` |
| kubernetes_admin_pki | Cerificates and keys for obtaining administrative access to the cluster. | [`object`](#kubernetes-admin-pki-output) | `string` |

### Cluster Nodes Output

```hcl
{
  control_plane = list(string)
  worker        = list(string)
}
```

### Kubernetes Admin PKI Output

```hcl
{
  cluster_ca_certificate = string
  client_certificate     = string
  client_key             = string
}
```

## Authors

Module is maintained by [Ilya Pozdnov](https://github.com/ilpozzd).

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.
