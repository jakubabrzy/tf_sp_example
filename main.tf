terraform {
  required_version = ">= 1.4.0"
}

variable "environment" {
  type        = string
  description = "Deployment environment (used inside the test JSON)."
  default     = "staging"
}

variable "bump" {
  type        = bool
  description = "Toggle to change the JSON payload between runs."
  default     = false
}

locals {
  # Test data as an inline JSON object.
  service_config = jsonencode({
    name        = "dashboard-service"
    environment = var.environment
    replicas    = var.bump ? 5 : 3
    enabled     = !var.bump
    tags        = var.bump ? ["frontend", "dashboard", "test", "eu"] : ["frontend", "dashboard", "test"]
    limits = {
      cpu    = "500m"
      memory = var.bump ? "512Mi" : "256Mi"
    }
    endpoints = [
      {
        path    = "/health"
        methods = ["GET"]
        public  = true
      },
      {
        path    = "/api/v1/data"
        methods = ["GET", "POST"]
        public  = false
      }
    ]
  })
}

resource "terraform_data" "service_config" {
  input = local.service_config
}

output "service_config_json" {
  description = "The rendered service configuration JSON."
  value       = jsondecode(local.service_config)
}
