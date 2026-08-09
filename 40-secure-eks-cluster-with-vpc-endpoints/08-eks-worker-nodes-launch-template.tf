# retrieve the latest Amazon Linux 2 EKS-optimized AMI
data "aws_ami" "eks_worker_ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.example_eks_cluster.version}-v*"]
  }
  most_recent = true
  owners      = ["602401143452"] # AWS owner ID for EKS AMIs
}


resource "aws_launch_template" "eks_worker_nodes_config" {
  image_id      = data.aws_ami.eks_worker_ami.id
  instance_type = var.worker_node_instance_type

  # enforce IMDSv2 for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  # EBS volume configuration
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # critical user data for private / air-tight clusters
  # explictly the bootstrap script to use the internal endpoint
  # and not the public internet to find the control EKS plane
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${aws_eks_cluster.example_eks_cluster.name} \
      --b64-cluster-ca ${aws_eks_cluster.example_eks_cluster.certificate_authority[0].data} \
      --apiserver-endpoint ${aws_eks_cluster.example_eks_cluster.endpoint}
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks_worker_nodes_config"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
