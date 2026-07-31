# pod identity association needs three things:
# 1. the corresponding addon/driver to be installed in eks
# 2. the IAM role with permissions to reach out to AWS services
# 3. the correct k8s service account in the correct namespace

resource "aws_eks_pod_identity_association" "ebs_volumes_PIA" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.pod_identity_ebs_volumes_role.arn

  # wait for the pod identity agent addon to be created first
  depends_on = [aws_eks_addon.pod_identity_agent]
}