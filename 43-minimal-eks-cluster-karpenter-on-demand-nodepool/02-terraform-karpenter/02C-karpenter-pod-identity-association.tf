# pod identity association needs three things:
# 1. the corresponding addon/driver to be installed in eks cluster
# 2. the IAM role with permissions to reach out to AWS services
# 3. the correct k8s service account in the correct namespace

resource "aws_eks_pod_identity_association" "karpenter_PIA" {
  cluster_name    = local.eks_cluster_name
  namespace       = "kube-system"
  service_account = "karpenter-sa"
  role_arn        = aws_iam_role.karpenter_controller_role.arn

  depends_on = [aws_eks_addon.pod_identity_agent]
}