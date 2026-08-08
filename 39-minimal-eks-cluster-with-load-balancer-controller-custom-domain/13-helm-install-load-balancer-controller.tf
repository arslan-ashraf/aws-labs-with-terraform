resource "helm_release" "load_balancer_controller" {
  depends_on = [
    aws_iam_role.load_balancer_controller_role,
    aws_eks_node_group.eks_worker_nodes,
    aws_eks_pod_identity_association.lbc,
    aws_eks_addon.podidentity
  ]        

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system" 
  # version  = "1.13.0"    # uses latest if not specified

  wait            = true   # wait for resources to become "Ready"
  timeout         = 600
  cleanup_on_fail = true 

  set = [
    # Create Service Account via Helm   
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    # Service Account Name 
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    # EKS Cluster Name
    {
      name  = "clusterName"
      value = "${aws_eks_cluster.main.id}"
    },
    # VPC Id     
    {
      name  = "vpcId"
      value = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
    },
    # AWS Region
    {
      name  = "region"
      value = "${var.aws_region}"
    }     
  ]       
}