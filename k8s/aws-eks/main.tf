# IAM for EKS cluster
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_oidc_demo_role" {
  name               = "EksOidcDemoRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_oidc_demo_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_oidc_demo_role.name
}

# Create a VPC for the EKS cluster
resource "aws_vpc" "eks_vpc" {

  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames                 = true
  enable_dns_support                   = true

  tags = { Name = "EksOidcDemoVpc" }
}

resource "aws_subnet" "subnet_a" {
  availability_zone = "us-west-2a"
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = { Name = "EksOidcDemoVpc-A" }
}

resource "aws_subnet" "subnet_b" {
  availability_zone = "us-west-2b"
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = { Name = "EksOidcDemoVpc-B" }
}


# Create an EKS cluster
resource "aws_eks_cluster" "oidc_demo_cluster" {
  name     = "OidcDemoCluster"
  role_arn = aws_iam_role.eks_oidc_demo_role.arn

  vpc_config {
    endpoint_public_access = true
    subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  }

  # Policy attachment is created before EKS cluster created, and torn down after EKS Cluster is deleted
  depends_on = [
    aws_iam_role_policy_attachment.eks_oidc_demo_role_policy_attachment,
  ]
}

# Do not provision a node group - not required for interacting with the Kubernetes API server

# Configure OIDC
resource "aws_eks_identity_provider_config" "oidc_demo_config" {
  cluster_name = aws_eks_cluster.oidc_demo_cluster.name

  oidc {
    identity_provider_config_name = "OidcDemoConfig"
    client_id                     = var.k8s_oidc_client_id
    issuer_url                    = var.k8s_oidc_issuer_url
    username_claim                = var.k8s_oidc_username_claim
    username_prefix               = var.k8s_oidc_username_prefix
    groups_claim                  = var.k8s_oidc_groups_claim
    groups_prefix                 = var.k8s_oidc_groups_prefix
  }
}