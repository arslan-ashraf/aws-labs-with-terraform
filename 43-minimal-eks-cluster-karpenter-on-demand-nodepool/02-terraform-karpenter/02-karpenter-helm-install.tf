resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "1.8.2"
  namespace        = "kube-system"
  create_namespace = false

  set = [
    {
      name  = "settings.clusterName"
      value = local.cluster_name
    },
    {
      name  = "settings.clusterEndpoint"
      value = local.cluster_endpoint
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "karpenter-sa"
    }
  ]

  # IMPORTANT: Ensure IAM role and Pod Identity are created
  # BEFORE Helm deploys Karpenter
  depends_on = [
    aws_iam_role.karpenter_controller_role,
    aws_iam_role_policy_attachment.karpenter_controller_attach,
    aws_eks_pod_identity_association.karpenter_PIA,
    aws_eks_access_entry.karpenter_node_access,
  ]
}