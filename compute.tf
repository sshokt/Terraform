resource "google_compute_instance_template" "template" {
  name         = "wp-template"
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata_startup_script = file("scripts/startup.sh")
}

resource "google_compute_health_check" "hc" {
  name = "wp-health-check"

  check_interval_sec  = 5
  timeout_sec         = 5
  unhealthy_threshold = 2
  healthy_threshold   = 2

  http_health_check {
    port = 80
  }
}

resource "google_compute_region_instance_group_manager" "mig" {
  name               = "wp-mig"
  region             = var.region
  base_instance_name = "wp"

  version {
    instance_template = google_compute_instance_template.template.id
  }

  target_size = 2

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_autoscaler" "autoscaler" {
  name   = "wp-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.mig.id

  autoscaling_policy {
    max_replicas = 3
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_backend_service" "backend" {
  name          = "wp-backend"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.hc.id]

  backend {
    group = google_compute_region_instance_group_manager.mig.instance_group
  }

  depends_on = [
    google_compute_region_instance_group_manager.mig
  ]
}

resource "google_compute_url_map" "url_map" {
  name            = "wp-url-map"
  default_service = google_compute_backend_service.backend.id
}

resource "google_compute_target_http_proxy" "proxy" {
  name    = "wp-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "wp-forwarding-rule"
  target     = google_compute_target_http_proxy.proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
}
