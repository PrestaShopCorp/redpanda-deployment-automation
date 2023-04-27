variable "region" {
  default = "europe-west1"
}

variable "availability_zone" {
  description = "The zone where the cluster will be deployed [a,b,...]"
  default     = ["b"]
  type        = list(string)
}

variable "instance_group_name" {
  description = "The name of the GCP instance group"
  default     = "redpanda-group"
}

variable "subnet" {
  description = "The name of the existing subnet where the machines will be deployed"
  default = "redpanda-vm"
}

variable "project_name" {
  description = "The project name on GCP."
  default = "ps-data-redpanda"
}

variable "allow_stopping_for_update" {
  type        = bool
  default     = false
}

variable "nodes" {
  description = "The number of nodes to deploy."
  type        = number
  default     = "3"
}

variable "ha" {
  description = "Whether to use placement groups to create an HA topology"
  type        = bool
  default     = false
}

variable "client_nodes" {
  description = "The number of clients to deploy."
  type        = number
  default     = "1"
}

variable "disks" {
  description = "The number of local disks on each machine."
  type        = number
  default     = 1
}

variable "image" {
  # See https://cloud.google.com/compute/docs/images#os-compute-support
  # for an updated list.
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable machine_type {
  # List of available machines per region/ zone:
  # https://cloud.google.com/compute/docs/regions-zones#available
  default = "n2-standard-2"
  # default = "t2d-standard-2"
}

variable monitor_machine_type {
  default = "n2-standard-2"
}

variable client_machine_type {
  default = "n2-standard-2"
}

variable "public_key_path" {
  description = "The ssh key."
  default = "/home/jeremie/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  description = "The ssh user. Must match the one in the public ssh key's comments."
  default = "jeremie.bourseau@prestashop.com"
}

variable "enable_monitoring" {
  default = "yes"
}

variable "labels" {
  description = "passthrough of GCP labels"
  default     = {
    "purpose"      = "redpanda-cluster"
    "created-with" = "terraform"
  }
}
