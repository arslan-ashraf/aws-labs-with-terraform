resource "aws_iam_role" "pod_identity_ebs_volumes_role" {
  name               = "pod_identity_ebs_volumes_role"

  # pod_identity_trust_policy has already been defined
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_policy.json
}

resource "aws_iam_policy" "read_secrets_policy" {
  name   = "secrets-manager-read-policy"
  policy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.pod_identity_ebs_volumes_role.name
  policy_arn = aws_iam_policy_document.read_secrets_policy.arn
}