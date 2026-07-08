# aws_placement_group influences the physical placement of EC2
# instances within AWS data centers for performance or HA needs
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

  # partition_count is the number of partitions to create 
  # (valid values are 1 to 7, defaults to 2), only valid if 
  # strategy = "partition"
  # partition_count = 3
}