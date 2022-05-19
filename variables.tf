variable "datacenter" {
  description = "VMware datacenter name."
  type        = string
}

variable "datastores" {
  description = "VMWare datastore(s) where all virtual machine`s data will be placed in."
  type        = list(string)
}

variable "hosts" {
  description = "ESXi host(s) where virtual machines will be created."
  type        = list(string)
}

variable "resource_pool" {
  description = "VMWare resource pool where virtual machines will be created."
  type        = string
}

variable "folder" {
  description = "Folder to create the virtual machines in."
  type        = string
}

variable "remote_ovf_url" {
  description = "URL to the remote Talos OS ovf/ova file."
  type        = string
}

variable "control_plane_count" {
  description = "Number of control plane virtual machines."
  type        = number
  default     = 2
}

variable "worker_count" {
  description = "Number of worker virtual machines."
  type        = number
  default     = 0
}

variable "control_plane_num_cpus" {
  description = "The total number of virtual processor cores to assign to control plane virtual machines."
  type        = number
  default     = 2
}

variable "worker_num_cpus" {
  description = "The total number of virtual processor cores to assign to worker virtual machines."
  type        = number
  default     = 4
}

variable "control_plane_memory" {
  description = "The size of control plane virtual machines RAM, in Mb."
  type        = number
  default     = 2048
}

variable "worker_memory" {
  description = "The size of worker virtual machines RAM, in Mb."
  type        = number
  default     = 4096
}

variable "control_plane_disks" {
  description = "A specification list for a virtual disk devices on control plane virtual machines."
  type = list(object({
    label = string
    size  = number
  }))
}

variable "worker_disks" {
  description = "A specification list for a virtual disk devices on worker virtual machines."
  type = list(object({
    label = string
    size  = number
  }))
  default = []
}

variable "control_plane_network_interfaces" {
  description = "A specification list for a virtual NIC on control plane virtual machines."
  type = list(object({
    name = string
  }))
}

variable "worker_network_interfaces" {
  description = "A specification list for a virtual NIC on worker virtual machines."
  type = list(object({
    name = string
  }))
  default = []
}

variable "talos_base_configuration" {
  description = "Talos high-level configuration. See https://www.talos.dev/v1.0/reference/configuration/#config."
  type = object({
    version = string
    persist = bool
  })

  default = {
    version = "v1alpha1"
    persist = false
  }
}

variable "machine_secrets" {
  description = "Secret data used to create Talos stack (if not set will be generated automaticly). See https://www.talos.dev/v1.0/reference/configuration/#machineconfig."
  type = object({
    token = optional(string)
    ca = object({
      crt = optional(string)
      key = optional(string)
    })
  })

  default = {
    ca = {}
  }
}

variable "talos_admin_pki" {
  description = "Base64 encoded certificate (signed by machine_secrets.ca.crt) and key (in ED25519) to provide access to virtual machine trought talosctl (required if node type is 'controlplane' init node will be create; if not set will be generate automaticly)."
  type = object({
    crt = optional(string)
    key = optional(string)
  })
  default = {}
}

variable "machine_base_configuration" {
  description = "Machine configuration used in all nodes. See https://www.talos.dev/v1.0/reference/configuration/#machineconfig."
  type = object({
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
      disabled    = bool
      servers     = optional(list(string))
      bootTimeout = optional(string)
    }))
    features = optional(object({
      rbac = optional(bool)
    }))
  })
}

variable "control_plane_machine_extra_configuration" {
  description = "Optional control plane machine extra configuration. See https://www.talos.dev/v1.0/reference/configuration/#machineconfig."
  type = object({
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
    sysctl = optional(map(string))
    sysfs  = optional(map(string))
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
  default = {}
}

variable "worker_machine_extra_configuration" {
  description = "Optional worker machine extra configuration. See https://www.talos.dev/v1.0/reference/configuration/#machineconfig."
  type = object({
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
    sysctl = optional(map(string))
    sysfs  = optional(map(string))
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
  default = {}
}

variable "control_plane_machine_cert_sans" {
  description = "A list of certSANs for *count* control planes (optional). See https://www.talos.dev/v1.0/reference/configuration/#machineconfig."
  type        = list(list(string))
  default     = []
}

variable "worker_machine_cert_sans" {
  description = "A list of certSANs for *count* workers (optional). See https://www.talos.dev/v1.0/reference/configuration/#machineconfig."
  type        = list(list(string))
  default     = []
}

variable "machine_network" {
  description = "Network configuration used in all nodes. See https://www.talos.dev/v1.0/reference/configuration/#networkconfig."
  type = object({
    nameservers = optional(list(string))
    extraHostEntries = optional(list(object({
      ip      = string
      aliases = list(string)
    })))
    kubespan = optional(object({
      enabled = bool
    }))
  })
  default = {}
}

variable "control_plane_machine_network_hostnames" {
  description = "A list of hostnames for *count* control planes (if not set will be generated automaticly). See https://www.talos.dev/v1.0/reference/configuration/#networkconfig."
  type        = list(string)
  default     = []
}

variable "worker_machine_network_hostnames" {
  description = "A list of hostnames for *count* workers (if not set will be generated automaticly). See https://www.talos.dev/v1.0/reference/configuration/#networkconfig."
  type        = list(string)
  default     = []
}

variable "control_plane_machine_network_interfaces" {
  description = "A list of network interfaces for *count* control planes (if not set DHCP will be used). Not less than one element with one static IP address required. See https://www.talos.dev/v1.0/reference/configuration/#device."
  type = list(list(object({
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
      dhcp   = optional(bool)
      vlanId = number
      mtu    = number
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
  default = []
}

variable "worker_machine_network_interfaces" {
  description = "A list of network interfaces for *count* workers (if not set DHCP will be used). See https://www.talos.dev/v1.0/reference/configuration/#device."
  type = list(list(object({
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
      dhcp   = optional(bool)
      vlanId = number
      mtu    = number
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
  default = []
}

variable "cluster_secrets" {
  description = "Secret data used in all Kubernetes nodes. See https://www.talos.dev/v1.0/reference/configuration/#clusterconfig."
  type = object({
    id     = optional(string)
    secret = optional(string)
    token  = optional(string)
    ca = object({
      crt = optional(string)
      key = optional(string)
    })
  })

  default = {
    ca = {}
  }
}

variable "control_plane_cluster_secrets" {
  description = "Secret data used in Kubernetes control plane nodes. See https://www.talos.dev/v1.0/reference/configuration/#clusterconfig."
  type = object({
    aescbcEncryptionSecret = optional(string)
    aggregatorCA = object({
      crt = optional(string)
      key = optional(string)
    })
    serviceAccount = object({
      key = optional(string)
    })
    etcd = object({
      ca = object({
        crt = optional(string)
        key = optional(string)
      })
    })
  })

  default = {
    aggregatorCA = {}
    etcd = {
      ca = {}
    }
    serviceAccount = {}
  }
}

variable "cluster_name" {
  description = "Configures the cluster`s name. See https://www.talos.dev/v1.0/reference/configuration/#clusterconfig."
  type        = string
}

variable "cluster_control_plane" {
  description = "Provides control plane specific configuration options. Required if init node is outside of this cluster. See https://www.talos.dev/v1.0/reference/configuration/#controlplaneconfig."
  type = object({
    endpoint           = optional(string)
    localAPIServerPort = optional(number)
  })
  default = {}
}

variable "cluster_discovery" {
  description = "Configures cluster member discovery. See https://www.talos.dev/v1.0/reference/configuration/#clusterdiscoveryconfig."
  type = object({
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
  default = {
    enabled = true
  }
}

variable "control_plane_cluster_configuration" {
  description = "Cluster configuration used in Kubernetes control plane nodes. See https://www.talos.dev/v1.0/reference/configuration/#clusterconfig."
  type = object({
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
  default = {}
}

variable "cluster_inline_manifests" {
  description = "A list of inline Kubernetes manifests. See https://www.talos.dev/v1.0/reference/configuration/#clusterconfig."
  type = list(object({
    name     = string
    contents = string
  }))
  default = []
}

variable "cluster_extra_manifests" {
  description = "A list of urls that point to additional manifests. These will get automatically deployed as part of the bootstrap. See https://www.talos.dev/v1.0/reference/configuration/#clusterconfig."
  type        = list(string)
  default     = []
}

variable "cluster_extra_manifest_headers" {
  description = "A map of key value pairs that will be added while fetching the extraManifests. See https://www.talos.dev/v1.0/reference/configuration/#clusterconfig."
  type        = map(string)
  default     = {}
}

variable "validity_period_hours" {
  description = "The number of hours after initial issuing that all generated certificates become invalid."
  type        = number
  default     = 8760
}

variable "kubeconfig_path" {
  description = "Path to save kubeconfig file (include filename; if not set config will not be created)."
  type        = string
  default     = ""
}

variable "talosconfig_path" {
  description = "Path to save talosconfig file (include filename; if not set config will not be created)."
  type        = string
  default     = ""
}

variable "vmtoolsd_extra_manifest" {
  description = "A link to talos-vmtoolsd Kubernetes manifest."
  type        = string
  default     = "https://raw.githubusercontent.com/mologie/talos-vmtoolsd/release-0.3/deploy/0.3.yaml"
}
