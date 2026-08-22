resource "kubernetes_manifest" "on_demand_nodepool" {
  depends_on = [
    kubernetes_manifest.example_ec2_nodeclass
  ]

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"

    metadata = {
      name = "on_demand_nodepool"
    }

    spec = {
      template = {
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "example_ec2nodeclass"
          }

          taints        = []
          startupTaints = []

          requirements = [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = ["linux"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values   = ["t3", "t3a"]
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "In"
              values   = ["micro", "small", "medium", "large"]
            },
            {
              key      = "topology.kubernetes.io/zone"
              operator = "In"
              values = [
                "us-east-1a",
                "us-east-1b"
              ]
            }
          ]
        }
      }

      limits = {
        cpu = "50"
      }

      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "30s"
      }
    }
  }
}