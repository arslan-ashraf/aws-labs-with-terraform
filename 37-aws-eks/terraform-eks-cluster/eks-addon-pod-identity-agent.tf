# get pod identity agent version compatible with EKS version
# NOTE: FOR LEARNING ONLY, WE DON'T USE THIS RESOURCE
data "aws_eks_addon_version" "pod_identity_agent_default_verison" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = aws_eks_cluster.example_eks_cluster.version
}


# get latest pod identity agent version compatible with EKS version
data "aws_eks_addon_version" "pod_identity_agent_latest" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = aws_eks_cluster.example_eks_cluster.version
  most_recent        = true
}


resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = var.eks_cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.pod_identity_agent_latest.version

  resolve_conflicts_on_create = "OVERWRITE" # concerning versions
  resolve_conflicts_on_update = "OVERWRITE" # concerning versions

  depends_on = [
    aws_eks_node_group.private_nodes
  ]
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