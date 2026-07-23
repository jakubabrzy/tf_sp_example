terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources into."
  default     = "eu-west-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "staging"
}

locals {
  service_config = jsonencode({
    name        = "dashboard-service"
    environment = var.environment
    replicas    = 3
    enabled     = true
    tags        = ["frontend", "dashboard", "test"]
    limits = {
      cpu    = "500m"
      memory = "256Mi"
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

  feature_flags = <<-JSON
    {
      "newDashboard": true,
      "betaCharts": false,
      "maxItems": 50,
      "rolloutRegions": ["eu-west-1", "us-east-1"]
    }
  JSON
}
