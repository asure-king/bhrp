variable "prefix" {
  description = "The prefix used for all resources in this demo"
  default = "bhrp"
}

variable "location" {
  description = "The Azure location where all resources in this demo should be created"
  default = "CentralUS"
}

variable "environment" {
  description = "Enviroment where this services will be used"
}

variable "environment_abrev" {
  description = "Enviroment Abreviation"
}
