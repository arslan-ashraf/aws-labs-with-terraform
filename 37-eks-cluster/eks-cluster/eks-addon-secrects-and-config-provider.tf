# note: the AWS ASCP (Amazon Secrets and Configuration Provider)
# automatically also installs the Kubernetes native pluggin (driver)
# Secrets Store CSI Driver, AWS ASCP pulls secrets from AWS Secrets
# Manager and hands them over to CSI Driver which then mounts those
# secrets into ephemeral in-memory temporary volumes through the 
# custom object SecretProviderClass
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.eks_cluster_name
  addon_name   = "aws-secrets-store-csi-driver-provider"

  # resolve_conflicts_on_create = "OVERWRITE" # concerning versions
  # resolve_conflicts_on_update = "OVERWRITE" # concerning versions

  # use this to configure the Secrets Store CSI Driver:
  # configuration_values = jsonencode({
  #   secrets-store-csi-driver = {}
  #   replicaCount = 4
  #   resources = {
  #     limits = {
  #       cpu    = "100m"
  #       memory = "150Mi"
  #     }
  #     requests = {
  #       cpu    = "100m"
  #       memory = "150Mi"
  #     }
  #   }
  # })
}