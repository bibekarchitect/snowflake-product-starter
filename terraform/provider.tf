# Use the TOML profile written in the workflow:
#   file:  $HOME/.snowflake/config
#   block: [ci]
provider "snowflake" {
  profile = "ci"
}