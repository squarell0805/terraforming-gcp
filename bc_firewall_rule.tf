# ====================================
# INGRESS RULES
# ====================================

# High Priority SSH/RDP Access from Broadcom Networks
resource "google_compute_firewall" "allow_ingress_from_brcm" {
  name        = "${var.env_name}-allow-ingress-from-brcm"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Allow ingress from Broadcom networks"
  direction   = "INGRESS"
  priority    = 1100

  allow {
    protocol = "tcp"
    ports    = ["443", "22", "80", "3389"]
  }

  source_ranges = ["192.19.0.0/16"]
  target_tags   = ["demo-https", "demo-rdp", "demo-http", "demo-web", "demo-ssh"]
}

# HTTPS from Internet
resource "google_compute_firewall" "allow_https_from_internet" {
  name        = "${var.env_name}-allow-https-from-internet"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Allow HTTPS from internet"
  direction   = "INGRESS"
  priority    = 1100

  allow {
    protocol = "tcp"
    ports    = ["443", "53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# HTTPS from Cloudflare
resource "google_compute_firewall" "allow_https_ingress_cloudflare" {
  name        = "${var.env_name}-allow-https-ingress-cloudflare"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Allow HTTPS from Cloudflare networks"
  direction   = "INGRESS"
  priority    = 1080

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = "${var.cloudflare_networks}"
  target_tags   = ["allow-https-cloudflare"]
}

# Deny HTTPS to Cloudflare targets (higher priority deny)
resource "google_compute_firewall" "deny_https_ingress_cloudflare" {
  name        = "${var.env_name}-deny-https-ingress-cloudflare"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Deny HTTPS to Cloudflare targets from other sources"
  direction   = "INGRESS"
  priority    = 1090

  deny {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-https-cloudflare"]
}

# SSH/RDP Access from trusted networks
resource "google_compute_firewall" "ssh_rdp_access" {
  name        = "${var.env_name}-ssh-rdp-access"
  network     = "${google_compute_network.pcf-network.name}"
  description = "SSH and RDP access from trusted networks"
  direction   = "INGRESS"
  priority    = 100

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = "${var.broadcom_networks}"
  target_tags   = ["demo-ssh", "demo-rdp"]
}

# TAS OpsManager access
resource "google_compute_firewall" "tas_opsmanager_2222" {
  name        = "${var.env_name}-tas-opsmanager-2222"
  network     = "${google_compute_network.pcf-network.name}"
  description = "TAS OpsManager SSH access on port 2222"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  source_ranges = ["34.145.18.128/26", "192.19.0.0/16"]
  target_tags   = ["allow-tas-opsmanager"]
}

# Internal network ingress
resource "google_compute_firewall" "allow_internal_ingress" {
  name        = "${var.env_name}-allow-internal-ingress"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Allow common ingress from internal systems"
  direction   = "INGRESS"
  priority    = 65534

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = "${var.internal_networks}"
}

# ====================================
# EGRESS RULES
# ====================================
# Default Deny Egress (lowest priority)
resource "google_compute_firewall" "deny_egress" {
  name        = "${var.env_name}-deny-egress"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Disable default egress with lowest priority to allow only egress defined in other rules"
  direction   = "EGRESS"
  priority    = 65534

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}

# Allow Internal Egress
resource "google_compute_firewall" "allow_internal_egress" {
  name        = "${var.env_name}-allow-internal-egress"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Allow egress between internal systems"
  direction   = "EGRESS"
  priority    = 65532

  allow {
    protocol = "all"
  }

  destination_ranges = "${var.internal_networks}"
}

# Allow Common Egress Ports
resource "google_compute_firewall" "allow_common_egress" {
  name        = "${var.env_name}-allow-common-egress"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Allow limited egress connections externally (trusted ports)"
  direction   = "EGRESS"
  priority    = 65533

  allow {
    protocol = "tcp"
    ports    = ["25", "80", "443", "587", "1344", "43"]
  }

  destination_ranges = ["0.0.0.0/0"]
}

# Private Google Access (IPv4)
resource "google_compute_firewall" "allow_private_google_access_egress" {
  name        = "${var.env_name}-allow-private-google-access-egress-0"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Allow egress to Private Google Access"
  direction   = "EGRESS"
  priority    = 2000

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = "${var.private_google_access_ipv4}"
}

# Private Google Access (IPv6)
resource "google_compute_firewall" "allow_private_google_access_ipv6_egress" {
  name        = "${var.env_name}-allow-private-google-access-ipv6-egress-0"
  network     = "${google_compute_network.pcf-network.name}"
  description = "Allow egress to Private Google Access with IPv6"
  direction   = "EGRESS"
  priority    = 2000

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = "${var.private_google_access_ipv6}"
}

# OpsManager Ports
resource "google_compute_firewall" "opsman_ports" {
  name        = "${var.env_name}-opsman-ports"
  network     = "${google_compute_network.pcf-network.name}"
  description = "OpsManager egress ports"
  direction   = "EGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["443", "80", "22", "53", "5985", "5986", "6868"]
  }
  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  allow {
    protocol = "icmp"
  }

  destination_ranges = ["0.0.0.0/0"]
}

# ====================================
# GKE CLUSTER RULES
# ====================================

# GKE Health Check Access
# resource "google_compute_firewall" "gke_allow_tcp_hc_ingress" {
#   name        = "${var.env_name}-gke-allow-tcp-hc-ingress"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow TCP ingress to GKE nodes from Google Health Check CIDRs"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "tcp"
#   }

#   source_ranges = "${var.google_health_check_ranges}"
#   target_tags   = ["gke-broadcom"]
# }

# GKE Trusted Network Access
# resource "google_compute_firewall" "gke_allow_tcp_trusted_ingress" {
#   name        = "${var.env_name}-gke-allow-tcp-trusted-ingress"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow TCP ingress to GKE nodes from trusted clients on specified ports"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "udp"
#     ports    = ["53"]
#   }

#   allow {
#     protocol = "tcp"
#     ports = [
#       "80", "8080", "8081", "443", "8443", "8004", "4434", "26000", "8888", "7861",
#       "53", "5473", "9091", "9092", "9093", "9094", "9404", "9999", "1111",
#       "2181", "2888", "3888", "5672", "15672", "15692", "9419", "4369", "25672",
#       "3306", "3307", "3308", "6032", "27017", "27018", "27019", "2379", "2380",
#       "8383", "8686", "8200", "8201", "4171", "4150", "5432", "9187", "2022",
#       "8009", "9090", "9300", "9200", "5044", "5601", "30000-32767"
#     ]
#   }

#   source_ranges = "${var.broadcom_networks}"
#   target_tags   = ["gke-broadcom"]
# }

# ====================================
# COMPLETE GKE CLUSTER RULES
# ====================================

# GKE Environment ey0av - All Traffic
# resource "google_compute_firewall" "gke_environment_ey0av_all" {
#   name        = "${var.env_name}-gke-environment-ey0av-b22fa442-all"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "GKE cluster internal communication"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "esp"
#   }

#   allow {
#     protocol = "ah"
#   }

#   allow {
#     protocol = "sctp"
#   }

#   allow {
#     protocol = "tcp"
#   }

#   allow {
#     protocol = "udp"
#   }

#   source_ranges = ["240.4.160.0/21"]
#   target_tags   = ["gke-environment-ey0av-b22fa442-node"]
# }

# # GKE Environment ey0av - Deny External Kubelet
# resource "google_compute_firewall" "gke_environment_ey0av_exkubelet" {
#   name        = "${var.env_name}-gke-environment-ey0av-b22fa442-exkubelet"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Deny external kubelet access"
#   direction   = "INGRESS"
#   priority    = 1000

#   deny {
#     protocol = "tcp"
#     ports    = ["10255"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["gke-environment-ey0av-b22fa442-node"]
# }

# # GKE Environment ey0av - Allow Internal Kubelet
# resource "google_compute_firewall" "gke_environment_ey0av_inkubelet" {
#   name        = "${var.env_name}-gke-environment-ey0av-b22fa442-inkubelet"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow internal kubelet access"
#   direction   = "INGRESS"
#   priority    = 999

#   allow {
#     protocol = "tcp"
#     ports    = ["10255"]
#   }

#   source_ranges = ["240.4.160.0/21"]
#   source_tags   = ["gke-environment-ey0av-b22fa442-node"]
#   target_tags   = ["gke-environment-ey0av-b22fa442-node"]
# }

# # GKE Environment ey0av - VMs Access
# resource "google_compute_firewall" "gke_environment_ey0av_vms" {
#   name        = "${var.env_name}-gke-environment-ey0av-b22fa442-vms"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow VM access to GKE nodes"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "tcp"
#     ports    = ["1-65535"]
#   }

#   allow {
#     protocol = "udp"
#     ports    = ["1-65535"]
#   }

#   source_ranges = ["10.24.197.64/28"]
#   target_tags   = ["gke-environment-ey0av-b22fa442-node"]
# }

# # GKE Environment nzb0b - All Traffic
# resource "google_compute_firewall" "gke_environment_nzb0b_all" {
#   name        = "${var.env_name}-gke-environment-nzb0b-6152f9ed-all"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "GKE cluster internal communication"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "esp"
#   }

#   allow {
#     protocol = "ah"
#   }

#   allow {
#     protocol = "sctp"
#   }

#   allow {
#     protocol = "tcp"
#   }

#   allow {
#     protocol = "udp"
#   }

#   allow {
#     protocol = "icmp"
#   }

#   source_ranges = ["240.2.208.0/21"]
#   target_tags   = ["gke-environment-nzb0b-6152f9ed-node"]
# }

# # GKE Environment nzb0b - Deny External Kubelet
# resource "google_compute_firewall" "gke_environment_nzb0b_exkubelet" {
#   name        = "${var.env_name}-gke-environment-nzb0b-6152f9ed-exkubelet"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Deny external kubelet access"
#   direction   = "INGRESS"
#   priority    = 1000

#   deny {
#     protocol = "tcp"
#     ports    = ["10255"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["gke-environment-nzb0b-6152f9ed-node"]
# }

# # GKE Environment nzb0b - Allow Internal Kubelet
# resource "google_compute_firewall" "gke_environment_nzb0b_inkubelet" {
#   name        = "${var.env_name}-gke-environment-nzb0b-6152f9ed-inkubelet"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow internal kubelet access"
#   direction   = "INGRESS"
#   priority    = 999

#   allow {
#     protocol = "tcp"
#     ports    = ["10255"]
#   }

#   source_ranges = ["240.2.208.0/21"]
#   source_tags   = ["gke-environment-nzb0b-6152f9ed-node"]
#   target_tags   = ["gke-environment-nzb0b-6152f9ed-node"]
# }

# # GKE Environment nzb0b - VMs Access
# resource "google_compute_firewall" "gke_environment_nzb0b_vms" {
#   name        = "${var.env_name}-gke-environment-nzb0b-6152f9ed-vms"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow VM access to GKE nodes"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "tcp"
#     ports    = ["1-65535"]
#   }

#   allow {
#     protocol = "udp"
#     ports    = ["1-65535"]
#   }

#   allow {
#     protocol = "icmp"
#   }

#   source_ranges = ["10.24.193.160/28"]
#   target_tags   = ["gke-environment-nzb0b-6152f9ed-node"]
# }

# # GKE Shepherd Demo - All Traffic
# resource "google_compute_firewall" "gke_shepherd_demo_all" {
#   name        = "${var.env_name}-gke-shepherd-demo-gke-8bc83d61-all"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "GKE cluster internal communication"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "tcp"
#   }

#   allow {
#     protocol = "udp"
#   }

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "esp"
#   }

#   allow {
#     protocol = "ah"
#   }

#   allow {
#     protocol = "sctp"
#   }

#   source_ranges = ["240.0.0.0/18"]
#   target_tags   = ["gke-shepherd-demo-gke-8bc83d61-node"]
# }

# # GKE Shepherd Demo - Deny External Kubelet
# resource "google_compute_firewall" "gke_shepherd_demo_exkubelet" {
#   name        = "${var.env_name}-gke-shepherd-demo-gke-8bc83d61-exkubelet"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Deny external kubelet access"
#   direction   = "INGRESS"
#   priority    = 1000

#   deny {
#     protocol = "tcp"
#     ports    = ["10255"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["gke-shepherd-demo-gke-8bc83d61-node"]
# }

# # GKE Shepherd Demo - Allow Internal Kubelet
# resource "google_compute_firewall" "gke_shepherd_demo_inkubelet" {
#   name        = "${var.env_name}-gke-shepherd-demo-gke-8bc83d61-inkubelet"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow internal kubelet access"
#   direction   = "INGRESS"
#   priority    = 999

#   allow {
#     protocol = "tcp"
#     ports    = ["10255"]
#   }

#   source_ranges = ["240.0.0.0/18"]
#   source_tags   = ["gke-shepherd-demo-gke-8bc83d61-node"]
#   target_tags   = ["gke-shepherd-demo-gke-8bc83d61-node"]
# }

# # GKE Shepherd Demo - VMs Access
# resource "google_compute_firewall" "gke_shepherd_demo_vms" {
#   name        = "${var.env_name}-gke-shepherd-demo-gke-8bc83d61-vms"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow VM access to GKE nodes"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "tcp"
#     ports    = ["1-65535"]
#   }

#   allow {
#     protocol = "udp"
#     ports    = ["1-65535"]
#   }

#   source_ranges = ["10.24.25.0/26"]
#   target_tags   = ["gke-shepherd-demo-gke-8bc83d61-node"]
# }

# IAP Access
# resource "google_compute_firewall" "allow_iap_tcp_ingress" {
#   name        = "${var.env_name}-allow-iap-tcp-ingress"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow TCP ingress from IAP Proxy"
#   direction   = "INGRESS"
#   priority    = 1000

#   allow {
#     protocol = "tcp"
#     ports    = ["22", "3389"]
#   }

#   source_ranges = "${var.iap_ranges}"
#   target_tags   = ["allow-iap"]
# }

# Legacy VMware to PostgreSQL
# resource "google_compute_firewall" "allow_legacy_vmw_prj_to_postgres" {
#   name        = "${var.env_name}-allow-legacy-vmw-dtnz01-tds-gp-partner-cert"
#   network     = "${google_compute_network.pcf-network.name}"
#   description = "Allow legacy VMware networks to PostgreSQL"
#   direction   = "INGRESS"
#   priority    = 1100

#   allow {
#     protocol = "tcp"
#     ports    = ["5432"]
#   }

#   source_ranges = "${var.legacy_vmware_networks}"
#   target_tags   = ["tds-gp-partner-cert"]
# }