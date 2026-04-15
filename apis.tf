resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "sql" {
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "storage" {
  service = "storage.googleapis.com"
}