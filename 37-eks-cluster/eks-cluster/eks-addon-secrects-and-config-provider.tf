# note: the AWS ASCP (Amazon Secrets and Configuration Provider)
# automatically also installs the Kubernetes native pluggin (driver)
# Secrets Store CSI Driver, AWS ASCP pulls secrets from AWS Secrets
# Manager and hands them over to CSI Driver which then mounts those
# secrets into ephemeral in-memory temporary volumes through the 
# custom object SecretProviderClass
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.eks_cluster_name
  addon_name   = "aws-secrets-store-csi-driver-provider"


  # configuration_values { ... }
}