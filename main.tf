
resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

locals {
  script = file("${path.module}/startup-script.sh")
}
# Create a single Compute Engine instance
resource "google_compute_instance" "cks1" {
  name         = "cks1"
  machine_type = "n1-standard-8"
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  # Install Flask
  metadata_startup_script = local.script

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_instance" "cks2" {
  name         = "cks2"
  machine_type = "n1-standard-8"
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  # Install Flask
  metadata_startup_script = local.script

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "flask" {
  name    = "flask-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "kubernetes" {
  name    = "k8s-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["6443", "443", "2379"]
  }
  source_ranges = ["10.0.0.0/0"]
}

resource "google_compute_firewall" "calico" {
  name    = "calico-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["179", "5473"]
  }
  source_ranges = ["10.0.0.0/0"]
}

resource "google_compute_firewall" "calico" {
  name    = "calico-app-firewall"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "udp"
    ports    = ["4789"]
  }
  allow {
    protocol = "tcp"
    ports    = ["179", "5473"]
  }
  source_ranges = ["10.0.0.0/0"]
}

output "Web-server-CKS1-URL" {
  value = join("", ["http://", google_compute_instance.cks1.network_interface.0.access_config.0.nat_ip, ":8080"])
}
output "Web-server-CKS2-URL" {
  value = join("", ["http://", google_compute_instance.cks2.network_interface.0.access_config.0.nat_ip, ":8080"])
}

