resource "google_sql_database_instance" "sql" {
  name             = var.sql_name
  database_version = "POSTGRES_15"
  region           = var.gcp_region

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}