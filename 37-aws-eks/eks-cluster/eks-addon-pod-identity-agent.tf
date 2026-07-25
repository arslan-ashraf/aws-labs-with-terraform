# get pod identity agent version compatible with EKS version
data "aws_eks_addon_version" "pia_default" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = aws_eks_cluster.main.version
}


resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.eks_cluster_name
  addon_name   = "eks-pod-identity-agent"

  # resolve_conflicts_on_create = "OVERWRITE" # concerning versions
  # resolve_conflicts_on_update = "OVERWRITE" # concerning versions
}

# to get the addon_name, run the command to see all available addons:

# aws eks describe-addon-versions  \
#    --query 'sort_by(addons  &owner)[].{
#     publisher: publisher, 
#     owner: owner, 
#     addonName: addonName, 
#     type: type
#   }' \
#    --output table