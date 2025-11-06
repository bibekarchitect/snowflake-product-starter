# Provider reads ~/.snowflake/config [ci] written by the workflow
provider "snowflake" {
  profile = "ci"
}