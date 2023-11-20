variable "project_id" {
  description = "The project ID of your project"
}

variable "cluster_name" {
  description = "The name for the GKE cluster"
}
variable "env_name" {
  description = "The environment for the GKE cluster"

}
variable "region" {
  description = "The region to host the cluster in"
}

variable "network" {
  description = "The VPC network created to host the cluster in"
  default     = "gke-network"
}
variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet"
}

variable "machine_type" {
  description = "Machine defualt type"
}
variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}
variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-services"
}

variable "service-account-id" {
  description = "The ID of service account of GCP"
  default     = "serviceaccount-id"
}

variable "min_count" {
  description = "Minimum number of node pool"
}

variable "max_count" {
  description = "Maximum number of node pool"
}

variable "num_nodes" {
  description = "Initial number of nodes"
}

variable "zones" {
  description = "Default zones to deploy GKE cluster"
}

variable "disksize" {
  description = "Disk Size in GB"
}

variable "user" {
  description = "Prisma Cloud username"
}

variable "password" {
  description = "Prisma Cloud Password"
}

variable "console" {
  description = "Prisma Cloud console address"
}

variable "orchestrator" {
  description = "Orchestrator type kubernertes, openshift, ecs"
}

variable "runtime" {
  description = "Container runtime docker,crio,containerd"
}
variable "console_type" {
  description = "Console deployment type SAAS or selfhosted"
}
