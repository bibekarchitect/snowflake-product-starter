provider "snowflake" {
  account  = var.account
  username = var.username
  password = var.password
  role     = var.role
  region   = var.region
}
