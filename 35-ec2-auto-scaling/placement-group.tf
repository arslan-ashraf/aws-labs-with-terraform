resource "aws_placement_group" "ec2-autoscaling-placement-group" {
  name     = "ec2-autoscaling-placement-group"

  # strategy determines the placement strategy for the group which
  # must be one of the following:
  # cluster - packs instances close together inside a single AZ,
  # best for low-latency network performance

  # spread - places instances on distinct physical hardware racks to
  # reduce correlated failures, max 7 instances per AZ

  # partition - divides the group into logical partitions, instances in
  # one partition do not share hardware with other partitions
  strategy = "cluster"
}