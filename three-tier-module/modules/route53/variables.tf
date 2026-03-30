variable "zone_name" {
  description = "Public Route 53 hosted zone name."
  type        = string
}

variable "record_name" {
  description = "DNS record name to create."
  type        = string
}

variable "alias_name" {
  description = "Alias DNS name target."
  type        = string
}

variable "alias_zone_id" {
  description = "Hosted zone ID of the alias target."
  type        = string
}
