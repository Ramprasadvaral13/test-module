variable "vpc_cidr"{
    type = string

}

variable "subnets" {
    type = map(object({
      cidr = string
      az = string
      public = bool 
    }))
  
}

variable "route_cidr" {
    type = string
  
}

  
