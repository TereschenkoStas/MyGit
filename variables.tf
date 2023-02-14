variable "token" {
}

variable "cloud_id" {
}


variable "folder_id" {
}


variable "CPU_test" {
  type = string
}

variable "memory_test" {
  type = string
}

variable "disk_test" {
  type = string
}

variable "ssh_key_private" {
  description = "Path to ssh private key, which would be used to access workers"
  default     = "~/.ssh/id_rsa"
}
