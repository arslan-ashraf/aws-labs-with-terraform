resource "aws_iam_role" "load_balancer_controller_role" {
  name = "load_balancer_controller_role"

  # pod_identity_trust_policy has already been defined
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_policy.json
}

#####################################################################
# the IAM policy used here is from the K8s-sigs, download it with:
# curl -o load-balancer-controller-iam-policy.json \
# https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.0/docs/install/iam_policy.json
#####################################################################

data "aws_iam_policy_document" "load_balancer_controller_document" {
  # this policy allows the Load Balancer Controller to manage
  # AWS resources such as ELBs, Target Groups, and Security Groups
  source_policy_documents = [
    file("${path.module}/10-load-balancer-controller-iam-policy.json")
  ]
}

# NOTE: we can also bring the policy in without downloading it and
# storing it in a local file, we need the "hashicorp/http" provider
# and the "http" data resource:

# data "http" "load_balancer_controller_policy_json" {
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

#   # Optional request headers
#   request_headers = {
#     Accept = "application/json"
#   }
# }

# then we can set the policy field of aws_iam_policy below as:
# policy = data.http.load_balancer_controller_policy_json.response_body
resource "aws_iam_policy" "load_balancer_controller_policy" {
  name   = "load_balancer_controller_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.load_balancer_controller_document.json
}

resource "aws_iam_role_policy_attachment" "lb_controller_role_policy_attachment" {
  role       = aws_iam_role.load_balancer_controller_role.name
  policy_arn = aws_iam_policy.load_balancer_controller_policy.arn
}