# data "aws_eks_addon_version" "external_dns_latest" {
#   addon_name         = "external-dns"
#   kubernetes_version = aws_eks_cluster.example_eks_cluster.version
#   most_recent        = true
# }

# resource "aws_eks_addon" "external_dns" {
#   depends_on = [
#     aws_iam_role.external_dns_role,
#     aws_eks_pod_identity_association.external_dns_PIA,
#     aws_eks_addon.pod_identity_agent,
#     aws_eks_node_group.eks_worker_nodes
#   ]  
#   cluster_name                = aws_eks_cluster.example_eks_cluster.name
#   addon_name                  = "external-dns"
#   addon_version               = data.aws_eks_addon_version.external_dns_latest.version

#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"

#   service_account_role_arn = aws_iam_role.external_dns_role.arn
# }