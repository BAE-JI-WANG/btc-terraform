# ######################
# COMMON
# ######################
variable "environment" {
  description = "Runtime Environment such as default, develop, stage, production"
  type = string
}


# ######################
# Dynamo DB
# ######################
variable "lock_table_name" {
  description = "dynamo db locking table name"
  type = string
}