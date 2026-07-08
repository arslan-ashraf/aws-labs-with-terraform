resource "aws_placement_group" "app_placement" {
  name     = "app-cluster-pg"
  strategy = "cluster"
}