# resource "aws_iam_role" "external_dns_role" {
#   name = "external_dns_role"
#   assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_policy.json
# }

# resource "aws_iam_role_policy_attachment" "external_dns_policy_attach" {
#   role       = aws_iam_role.external_dns_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
# }