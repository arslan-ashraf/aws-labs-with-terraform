resource "aws_launch_template" "eks_nodes_group_launch_template" {
  name          = "eks_nodes_launch_template"
  instance_type = var.node_instance_type

  vpc_security_group_ids = [
    data.terraform_remote_state.vpc_network.outputs.eks_worker_nodes_security_group_id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.node_disk_size
      volume_type = "gp3"
      encrypted   = true
    }
  }

  # Best Practice: Force IMDSv2 for security compliance
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "eks_worker_node" }
}