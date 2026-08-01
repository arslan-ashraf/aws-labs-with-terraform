resource "aws_launch_template" "eks_nodes_group_launch_template" {
  name          = "eks_nodes_launch_template"
  instance_type = var.node_instance_types

  vpc_security_group_ids = [
    data.terraform_remote_state.vpc_network.outputs.eks_worker_nodes_security_group_id
  ]

  # Best Practice: Force IMDSv2 for security compliance
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}