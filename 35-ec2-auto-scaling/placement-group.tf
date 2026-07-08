resource "aws_placement_group" "app_placement" {
  name     = "ec2_placement_group"

  # strategy determines he placement strategy for the group which
  # must be one of the following:
  # cluster - Packs instances close together inside a single Availability Zone. Best for low-latency network performance.spread: Places instances on distinct physical hardware racks to reduce correlated failures. Max 7 instances per AZ.partition: Divides the group into logical partitions; instances in one partition do not share hardware with other partitions.
  strategy = "cluster"
}