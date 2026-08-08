# resource "aws_iam_role" "external_dns_role" {
#   name = "external_dns_role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "external_dns_policy_attach" {
#   role       = aws_iam_role.external_dns_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
# }