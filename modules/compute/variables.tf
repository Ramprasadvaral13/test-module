variable "name_prefix" {
    type = string
  
}

variable "instance_profile_name" {
    default = "AdminSSMRole"
    type = string
  
}

variable "min_size" {
    type = number
  
}

variable "max_size" {
    type = number
  
}

variable "desired_capacity" {
    type = number
  
}

variable "volume_size" {
    type = number
  
}

variable "instance_type" {
    type = string
  
}

variable "vpc_id" {
    type = string
  
}

variable "subnet_ids" {
    type = list(string)
  
}

variable "key_name" {
    type = string
  
}