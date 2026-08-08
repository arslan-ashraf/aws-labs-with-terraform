# resource "aws_eks_pod_identity_association" "external_dns_PIA" {
#   cluster_name    = aws_eks_cluster.example_eks_cluster.name
#   namespace       = "external-dns"
#   service_account = "external-dns"
#   role_arn        = aws_iam_role.external_dns_role.arn
# }