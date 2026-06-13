# this resource can be used if the EKS cluster is launched without 
# the EKS module, if using the EKS module, the add on can be encoded
# within the EKS module block

# note: using this addon requires an Amazon Linux or Ubuntu AMI


# resource "aws_eks_addon" "pod_identity" {
#   cluster_name  = "your-eks-cluster-name" # Replace with your cluster name
#   addon_name    = "eks-pod-identity-agent"
#   addon_version = "v1.3.0-eksbuild.1"     # Use the latest version for your K8s release

#   resolve_conflicts_on_update = "OVERWRITE"
# }