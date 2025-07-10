resource "google_compute_instance" "nat-vm" {
  name         = "${var.env_name}-nat-vm"
  machine_type = "${var.nat_vm_machine_type}"
  zone         = "${element(var.zones, 1)}"

  timeouts {
    create = "10m"
  }

  boot_disk {
    initialize_params {
      image = "${var.nat_vm_instance_image}"
      size  = 30
    }
  }

  network_interface {
    subnetwork = "${var.shared_vpc_subnet}"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.management-subnet.name}"
  }

  can_ip_forward = true

  metadata = {
    ssh-keys               = "${format("ubuntu:%s", tls_private_key.nat-vm.public_key_openssh)}"
    block-project-ssh-keys = "TRUE"
    user-data              = "${file("${path.module}/nat-vm-cloud-config.yaml")}"
  }
}

resource "tls_private_key" "nat-vm" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "google_compute_route" "nat-vm-route" {
  name             = "${var.env_name}-nat-vm-route"
  dest_range       = "0.0.0.0/0" # The destination IP range for this route (e.g., your on-premises network)
  network          = "${google_compute_network.pcf-network.name}" # Link to your VPC network
  next_hop_instance = "${google_compute_instance.nat-vm.self_link}" # The self_link of your next hop VM
  description      = "Route to external network via next-hop VM"
  priority         = 100
  tags             = "${var.nat_vm_tags}"
}
