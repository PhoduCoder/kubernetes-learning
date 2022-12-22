# Set the AWS region
provider "aws" {
  region = "REGION"
}

# Create the EKS cluster
resource "aws_eks_cluster" "cluster" {
  name     = "CLUSTER_NAME"
  role_arn = "ROLE_ARN"

  vpc_config {
    security_group_ids = [
      "SECURITY_GROUP_ID",
    ]

    subnet_ids = [
      "SUBNET_ID",
    ]
  }
}

# Output the EKS cluster endpoint and certificate authority data
output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.cluster.certificate_authority.0.data
}

# Create the GitOps repository
resource "aws_codecommit_repository" "gitops_repo" {
  repository_name = "GITOPS_REPO_NAME"
  repository_description = "GitOps repository for CLUSTER_NAME EKS cluster"
}

# Output the GitOps repository URL
output "gitops_repository_url" {
  value = aws_codecommit_repository.gitops_repo.clone_url_http
}

# Create an IAM user for the GitOps system
resource "aws_iam_user" "gitops_user" {
  name = "GITOPS_USER_NAME"
}

# Attach an IAM policy that allows the GitOps user to access the GitOps repository
resource "aws_iam_user_policy_attachment" "gitops_user_policy_attachment" {
  user       = aws_iam_user.gitops_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

# Create an IAM access key for the GitOps user
resource "aws_iam_access_key" "gitops_user_access_key" {
  user = aws_iam_user.gitops_user.name
}

# Output the IAM access key ID and secret for the GitOps user
output "gitops_user_access_key_id" {
  value = aws_iam_access_key.gitops_user_access_key.id
}

output "gitops_user_secret_access_key" {
  value = aws_iam_access_key.gitops_user_access_key.secret
}

# Create an IAM policy that allows the GitOps system to deploy resources to the EKS cluster
resource "aws_iam_policy" "gitops_deploy_policy" {
  name = "gitops-deploy-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "eks:*",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the GitOps deploy policy to the GitOps user
resource "aws_iam_user_policy_attachment" "gitops_deploy_policy_attachment" {
  user       = aws_iam_user.gitops_user.name
  policy_arn = aws_iam_policy.gitops_deploy_policy.arn
}

# Install the Istio operator on the EKS cluster
resource "kubernetes_custom_resource" "istio
"istio-operator" {
  api_version = "install.istio.io/v1alpha1"
  kind        = "IstioOperator"
  metadata {
    name = "istio-system"
  }
  spec {
    profile = "demo"
  }
}


