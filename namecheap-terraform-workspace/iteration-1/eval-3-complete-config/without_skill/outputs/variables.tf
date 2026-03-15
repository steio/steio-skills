variable "namecheap_api_user" {
  type        = string
  description = "Namecheap API username"
}

variable "namecheap_api_key" {
  type        = string
  description = "Namecheap API key"
}

variable "namecheap_user_name" {
  type        = string
  description = "Namecheap user name (account in Namecheap dashboard)"
}

variable "client_ip" {
  type        = string
  description = "Your machine's outbound IP address allowed by Namecheap API"
}
