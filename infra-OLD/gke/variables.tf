variable "project_id" { 
  type = string 
  }

variable "region" { 
  type = string  
  default = "europe-west4" 
}

variable "location" { 
  type = string  
  default = "europe-west4" 
}

variable "network_name" { 
  type = string  
  default = "vpc-data-platform" 
}

variable "subnet_name" { 
  type = string  
  default = "subnet-data-platform-ew4" 
}
variable "ip_range_pods" { 
  type = string  
  default = "10.40.0.0/14" 
}
variable "ip_range_svc" { 
  type = string  
  default = "10.44.0.0/20" 
}
variable "gke_name" { 
  type = string  
  default = "gke-datahub-ew4" 
}
variable "gke_release_channel" { 
  type = string  
  default = "REGULAR" 
}
variable "gke_machine_type" { 
  type = string  
  default = "e2-standard-4" 
}
variable "gke_min_nodes" { 
  type = number  
  default = 1 
}
variable "gke_max_nodes" { 
  type = number  
  default = 4 
}
variable "master_authorized_cidrs" {
  type    = list(string)
  default = []
}
variable "private_cluster" { 
  type = bool 
  default = true 
}
variable "enable_workload_identity" { 
  type = bool 
  default = true 
}
variable "workload_pool" { 
  type = string 
  default = null 
}
