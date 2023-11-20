provider "google" {
   credentials = file("./credentials.json")
}
provider "google-beta" {
    credentials = file("./credentials.json")
}

module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}

resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig-${var.env_name}"
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.project_id
  network_name = "${var.network}-${var.env_name}"
  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    }
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }

}

module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id        = var.project_id
  name              = "${var.cluster_name}-${var.env_name}"
  initial_node_count = var.num_nodes
  regional          = false
  region            = var.region
  zones             = var.zones
  network           = module.gcp-network.network_name
  subnetwork        = module.gcp-network.subnets_names[0]
  ip_range_pods     = var.ip_range_pods_name
  ip_range_services = var.ip_range_services_name
  deletion_protection = false
  node_pools = [
    {
      name           = "node-pool"
      machine_type   = var.machine_type
      node_locations = "us-central1-c"
      initial_node_count = var.num_nodes
      min_count      = var.min_count
      max_count      = var.max_count
      disk_size_gb   = var.disksize
      preemptible    = false
      auto_repair    = false
      auto_upgrade   = true
      node_pools_tags = "emea-tac-lab"
    },
  ]
  remove_default_node_pool = true
}

resource "null_resource" "defender_deploy" {
    depends_on = [ local_file.kubeconfig ]

    provisioner "local-exec" {
      command = "python generate_daemonset.py -u ${var.user} -p ${var.password} -c ${var.console} -o ${var.orchestrator} -r ${var.runtime}  -t ${var.console_type}"
    }
     provisioner "local-exec" {
      command = "kubectl --kubeconfig ./kubeconfig-${var.env_name} create ns twistlock --insecure-skip-tls-verify"
    } 
    provisioner "local-exec" {
      command = "kubectl --kubeconfig ./kubeconfig-${var.env_name} apply -f daemonset.yaml --insecure-skip-tls-verify"
    }  
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

