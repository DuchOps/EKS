resource "aws_eks_cluster" "aws_eks" {
  name     = "duchess1"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks-master-sg.id]
    subnet_ids = var.subnet_id
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,  
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]

  tags = {
    Name = "duchess1"
  }
}

resource "aws_eks_node_group" "duch1" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "duch1"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.subnet_id

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }


  labels = {
    create_before_destroy = true
  }
  remote_access {
    ec2_ssh_key               = var.keypair-name
    source_security_group_ids = [aws_security_group.eks-node-sg.id]
  }
  

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}