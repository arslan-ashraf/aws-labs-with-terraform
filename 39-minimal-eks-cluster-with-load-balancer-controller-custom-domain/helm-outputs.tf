# Helm installation outputs
output "helm_load_balancer_controller_metadata" {
  description = "Metadata Block outlining status of the deployed Helm release."
  value = helm_release.load_balancer_controller.metadata
}