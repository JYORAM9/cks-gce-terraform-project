variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in"
  default     = ""
}

variable "google_credentials" {
  type        = string
  description = "The gcp creds"
  default     = ""
}

variable "region" {
  type        = string
  description = "The region to host the vm in"
  default     = ""
}

variable "zone" {
  type        = string
  description = "The zone to host the vm in"
  default     = ""
}