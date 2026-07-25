// the IAM policy used here is from the K8s-sigs, download it with:
// curl -o load-balancer-controller-iam-policy.json \
// https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.0/docs/install/iam_policy.json

data "aws_iam_policy_document" "load_balancer_controller_document" {
  source_policy_documents = [
    file("${path.module}/load-balancer-controller-iam-policy.json")
  ]
}

resource "aws_iam_policy" "load_balancer_controller_policy" {
  name   = "load_balancer_controller_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.load_balancer_controller_document.json
}