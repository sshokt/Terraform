variable gcp_project {
  type        = string
  description = "nom de projet"
}

variable sql_name  {
  type = string
  description = "nom de l'instance de la bdd"

}

variable gcp_region {
type = string
description = "Region"
default = "europe-central1"
}