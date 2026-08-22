resource "kubernetes_manifest" "example_ec2nodeclass" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"

    metadata = {
      name = "example_ec2nodeclass"
    }

    spec = {
      amiFamily = "AL2023"

      amiSelectorTerms = [
        {
          alias = "al2023@latest"
        }
      ]

      role = aws_iam_role.karpenter_node_role.arn

      subnetSelectorTerms = [
        {
          tags = {
            "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
            "kubernetes.io/role/elb"                        = "1"
          }
        }
      ]

      securityGroupSelectorTerms = [
        {
          tags = {
            "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
          }
        }
      ]

      tags = {
        "karpenter.sh/discovery" = var.eks_cluster_name
      }

      blockDeviceMappings = [
        {
          deviceName = "/dev/xvda"

          ebs = {
            volumeSize          = "20Gi"
            volumeType          = "gp3"
            encrypted           = true
            deleteOnTermination = true
          }
        }
      ]

      metadataOptions = {
        httpTokens              = "required"
        httpPutResponseHopLimit = 2
      }
    }
  }
}