resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.eks_cluster_name
  addon_name   = "eks-pod-identity-agent"
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