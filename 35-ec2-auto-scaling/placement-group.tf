# aws_placement_group influences the physical placement of EC2
# instances within AWS data centers for performance or HA needs
# used to achieve low network latency or spread instances across
# distinct physical hardware racks

resource "aws_placement_group" "ec2_autoscaling_placement_group" {
  name = "ec2_autoscaling_placement_group"

  strategy = "spread"
  # strategy determines the placement strategy for the group which
  # must be one of the following:

  # cluster - packs instances close together inside a single AZ only,
  # best for low-latency network performance

  # spread - places instances on distinct physical hardware racks to
  # reduce correlated failures, max 7 instances per AZ, multi-AZ support

  # partition - divides the group into logical partitions, instances in
  # one partition do not share hardware with other partitions, multi-AZ support


  # partition_count is the number of partitions to create 
  # (valid values are 1 to 7, defaults to 2), only valid if 
  # strategy = "partition"
  # partition_count = 3
}