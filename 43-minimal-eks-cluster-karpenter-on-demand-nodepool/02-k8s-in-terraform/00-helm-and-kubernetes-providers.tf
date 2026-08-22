data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.example_eks_cluster.id
}

# connect Helm Terraform API to EKS cluster
# allows installation of Helm charts using Terraform, we use it
# to install the load balancer controller
provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.example_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.example_eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


# connect Kubernetes Terraform API to EKS cluster
# allows creation of Kubernetes resources using Terraform instead
# of yaml files, this is only a best practice when Terraform results
# need to be dynamically injected into a Kubernetes resource
provider "kubernetes" {
  host                   = aws_eks_cluster.example_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.example_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}