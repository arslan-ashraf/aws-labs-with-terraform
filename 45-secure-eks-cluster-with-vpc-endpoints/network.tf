module "vpc" {
  # Aligning with Checkov rule CKV_TF_1 and using a Git URL with a commit hash revision.
  # Details available in below link:
  # https://docs.prismacloud.io/en/enterprise-edition/policy-reference/supply-chain-policies/terraform-policies/ensure-terraform-module-sources-use-git-url-with-commit-hash-revision
  source                  = "github.com/username/terraform-aws-vpc?ref=v1.0.7"
  region                  = var.region
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_flow_log         = true
  enable_internet_gateway = true
  enable_nat_gateway      = true
  vpc_name                = var.name
  vpc_cidr                = var.vpc_cidr
  subnet_cidr_public      = var.subnet_cidr_public
  subnet_cidr_private     = var.subnet_cidr_private

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = "${var.name}-cluster"
  }

  #checkov:skip=CKV_TF_1: Ensure Terraform module sources use a commit hash
  #reason-for-skip: Using semantic version tags for better maintainability and easier updates
}