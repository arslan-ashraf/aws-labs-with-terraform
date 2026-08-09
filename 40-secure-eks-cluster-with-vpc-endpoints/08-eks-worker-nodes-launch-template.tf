# retrieve the latest Amazon Linux 2 EKS-optimized AMI
data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.example_eks_cluster.version}-v*"]
  }
  most_recent = true
  owners      = ["602401143452"] # AWS owner ID for EKS AMIs
}


resource "aws_launch_template" "eks_worker_nodes_config" {
  name_prefix   = "eks-isolated-nodes-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = "t3.medium"

  # Enforce IMDSv2 for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  # Root volume configuration
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Critical User Data for Private / Air-gapped Clusters
  # Explictly instructs the bootstrap script to use the internal endpoint
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${aws_eks_cluster.main.name} \
      --b64-cluster-ca ${aws_eks_cluster.main.certificate_authority[0].data} \
      --apiserver-endpoint ${aws_eks_cluster.main.endpoint}
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-isolated-worker-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
