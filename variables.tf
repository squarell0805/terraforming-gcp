variable "project" {
  type = "string"
}

variable "env_name" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "buckets_location" {
  type    = "string"
  default = "US"
}

variable "management_cidr" {
  type        = "string"
  description = "cidr for management subnet"
  default     = "10.0.0.0/26"
}

variable "pas_cidr" {
  type        = "string"
  description = "cidr for pas subnet"
  default     = "10.0.4.0/24"
}

variable "services_cidr" {
  type        = "string"
  description = "cidr for services subnet"
  default     = "10.0.8.0/24"
}

variable "zones" {
  type = "list"
}

variable "opsman_image_url" {
  type        = "string"
  description = "Location of ops manager image on google cloud storage"
}

variable "optional_opsman_image_url" {
  type        = "string"
  description = "Location of ops manager image (to be used for optional extra instance) on google cloud storage"
  default     = ""
}

variable "opsman_machine_type" {
  type    = "string"
  default = "n1-standard-2"
}

variable "service_account_key" {
  type = "string"
}

variable "dns_suffix" {
  type = "string"
}

variable "ssl_cert" {
  type        = "string"
  description = "The contents of an SSL certificate to be used by the LB, optional if `ssl_ca_cert` is provided"
  default     = ""
}

variable "ssl_private_key" {
  type        = "string"
  description = "The contents of an SSL private key to be used by the LB, optional if `ssl_ca_cert` is provided"
  default     = ""
}

variable "ssl_ca_cert" {
  type        = "string"
  description = "The contents of a CA public key to be used to sign the generated LB certificate, optional if `ssl_cert` is provided"
  default     = ""
}

variable "ssl_ca_private_key" {
  type        = "string"
  description = "the contents of a CA private key to be used to sign the generated LB certificate, optional if `ssl_cert` is provided"
  default     = ""
}

variable "create_iam_service_account_members" {
  description = "If set to true, create an IAM Service Account project roles"
  default     = true
}

variable "external_database" {
  description = "standups up a cloud sql database instance for the ops manager and PAS"
  default     = false
}

variable "internetless" {
  description = "When set to true, all traffic going outside the 10.* network is denied."
  default     = false
}

/******************
 * OpsMan Options *
 ******************/

variable "opsman_storage_bucket_count" {
  type        = "string"
  description = "Optional configuration of a Google Storage Bucket for BOSH's blobstore"
  default     = "0"
}

variable "pas_sql_db_host" {
  type        = "string"
  description = "The host the user can connect from."
  default     = ""
}

variable "opsman_sql_db_host" {
  type        = "string"
  description = "The host the user can connect from."
  default     = ""
}

/*****************************
 * Isolation Segment Options *
 *****************************/

variable "isolation_segment" {
  description = "create the required infrastructure to deploy isolation segment"
  default     = false
}

variable "iso_seg_ssl_cert" {
  type        = "string"
  description = "the contents of an SSL certificate to be used by the LB, optional if `iso_seg_ssl_ca_cert` is provided"
  default     = ""
}

variable "iso_seg_ssl_private_key" {
  type        = "string"
  description = "The contents of an SSL private key to be used by the LB, optional if `iso_seg_ssl_ca_cert` is provided"
  default     = ""
}

variable "iso_seg_ssl_ca_cert" {
  type        = "string"
  description = "The contents of a CA public key to be used to sign the generated iso seg LB certificate, optional if `iso_seg_ssl_cert` is provided"
  default     = ""
}

variable "iso_seg_ssl_ca_private_key" {
  type        = "string"
  description = "The contents of a CA private key to be used to sign the generated iso seg LB certificate, optional if `iso_seg_ssl_cert` is provided"
  default     = ""
}

/********************************
 * Google Cloud Storage Options *
 ********************************/

variable "create_gcs_buckets" {
  description = "Create Google Storage Buckets for Elastic Runtime Cloud Controller's file storage"
  default     = true
}

variable "create_blobstore_service_account_key" {
  description = "Create a scoped service account key for gcs storage access"
  default     = true
}

/*****************************
 * PKS Options *
 *****************************/

variable "pks" {
  description = "Create the required infrastructure to deploy pks."
  default     = false
}

variable "pks_cidr" {
  type        = "string"
  description = "cidr for pks subnet"
  default     = "10.0.10.0/24"
}

variable "pks_services_cidr" {
  type        = "string"
  description = "cidr for pks services subnet"
  default     = "10.0.11.0/24"
}

variable "broadcom_networks" {
  type    = "list"
  default = [
    "192.19.0.0/16",
    "135.14.0.0/16"
  ]
}

variable "internal_networks" {
  type    = "list"
  default = [
    "240.224.0.0/11",
    "100.67.0.0/16",
    "172.22.0.0/16",
    "172.16.0.0/16",
    "172.24.0.0/13",
    "100.64.0.0/16",
    "10.0.0.0/8",
    "240.0.0.0/8",
    "172.18.0.0/16",
    "192.168.0.0/16",
    "172.21.0.0/16",
    "172.19.0.0/16"
  ]
}

variable "legacy_vmware_networks" {
  type    = "list"
  default = [
    "129.41.86.0/24",
    "199.246.40.0/24",
    "129.41.87.0/24",
    "129.42.208.0/24",
    "170.225.223.16/30",
    "192.19.0.0/16",
    "170.225.223.20/31",
    "155.190.1.0/24",
    "32.97.110.0/24"
  ]
}

variable "cloudflare_networks" {
  type     = "list"
  default  = [
    "103.21.244.0/22",
    "141.101.64.0/18",
    "162.158.0.0/15",
    "131.0.72.0/22",
    "173.245.48.0/20",
    "172.64.0.0/13",
    "108.162.192.0/18",
    "104.24.0.0/14",
    "10.0.0.0/8",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "197.234.240.0/22",
    "188.114.96.0/20",
    "198.41.128.0/17",
    "190.93.240.0/20",
    "104.16.0.0/13"
  ]
}

variable "google_health_check_ranges" {
  type     = "list"
  default  = [
    "209.85.204.0/22",
    "209.85.152.0/22",
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}

variable "private_google_access_ipv4" {
  type     = "list"
  default  = [
    "199.36.153.8/30"
  ]
}

variable "private_google_access_ipv6" {
  type     = "list"
  default  = [
    "2600:2d00:2:2000::/64"
  ]
}

variable "iap_ranges" {
  type     = "list"
  default  = [
     "35.235.240.0/20"
  ]
}
