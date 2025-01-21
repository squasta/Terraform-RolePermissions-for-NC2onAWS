#
#  This code is the Terraform version of the Nutanix official CloudFormation Template provided to set up roles and permissions
#  required for deploying and managing Nutanix Cloud Clusters on AWS available at the following URL :
#  https://s3.us-east-1.amazonaws.com/prod-gcf-567c917002e610cce2ea/aws_cf_clusters_high.json and refered in Nutanix 
#  NC2 on AWS Deployment Guide here : https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Clusters-AWS:aws-clusters-aws-getting-started-c.html 
# 
# /!\ This code is PROVIDED AS IS without any official support of Nutanix /!\
# It can be used if you don't want to create CF Stack and prefer to use Terraform to deploy the roles and permissions
#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.8"
}

# cf. https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html 
provider "aws" {
  region  = var.AWS_REGION
}



#
# VARIABLES DEFINITION
#

variable "AWS_REGION" {
  description = "The AWS region to deploy to"
  default     = "eu-central-1"     # eu-west-3	= Paris Region, eu-central-1 = Frankfurt Region
}

variable arn_partition {
  description = "ARN partition used in current AWS environment."
  type = string
  default = "aws"
}

variable aws_endpoint {
  description = "AWS endpoint used in current environment."
  type = string
  default = "amazonaws.com"
}

variable gateway_account_id {
  description = "ID of AWS account where GW is deployed."
  type = string
  default = "257431198911"  # This is Nutanix AWS Account for MCM DO NOT CHANGE IT
}

variable gateway_role_name {
  description = "Role for Gateway to be able to assume role and get access to resources."
  type = string
  # Please DO NOT CHANGE THAT DEFAULT VALUE
  default = "Nutanix-Clusters-High-Nc2-Orchestrator-Role-Prod"
}

variable gateway_external_id {
  description = "External Id for Gateway to utilize when assuming role."
  type = string
  # This is your NC2 Customer ID to be used in the ExternalId field of the AssumeRole API call.
  # Customer ID can be see in cloud.nutanix.com URL (click on your customer account to see all organization details, customer ID is in the URL)

}

variable cluster_node_role_name {
  description = "Role for Cluster Nodes."
  type = string
  # Please DO NOT CHANGE THAT DEFAULT VALUE
  default = "Nutanix-Clusters-High-Nc2-Cluster-Role-Prod"
}

#
# MCM Gateway
#
 
resource "aws_iam_role" "mcm_gateway_role" {
  name = var.gateway_role_name
  path = "/"
  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = join("", ["arn:", var.arn_partition, ":iam::", var.gateway_account_id, ":root"])
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.gateway_external_id
          }
        }
      }
    ]
  })
}


# ==> 
# aws_iam_role_policy
# The inline_policy argument is deprecated. Use the aws_iam_role_policy resource instead.


# IAM Role Policy
# cf. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy

resource "aws_iam_role_policy" "mcm_gateway_policy" {
  name = join("", [var.gateway_role_name, "-Policy"])
  role = aws_iam_role.mcm_gateway_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*Image",
          "ec2:*Images",
          "ec2:*Instances",
          "ec2:*PlacementGroup",
          "ec2:*SecurityGroup*",
          "ec2:AcceptVpcPeeringConnection",
          "ec2:AllocateAddress",
          "ec2:AllocateHosts",
          "ec2:AssociateAddress",
          "ec2:AssociateDhcpOptions",
          "ec2:AssociateRouteTable",
          "ec2:AttachInternetGateway",
          "ec2:CreateDefaultSubnet",
          "ec2:CreateDhcpOptions",
          "ec2:CreateInternetGateway",
          "ec2:CreateKeyPair",
          "ec2:CreateNatGateway",
          "ec2:CreateNetworkAcl",
          "ec2:CreateNetworkInterface",
          "ec2:CreateRoute",
          "ec2:CreateRouteTable",
          "ec2:CreateSubnet",
          "ec2:CreateTags",
          "ec2:CreateVpc",
          "ec2:CreateVpcEndpoint",
          "ec2:CreateVpcPeeringConnection",
          "ec2:DeleteDhcpOptions",
          "ec2:DeleteEgressOnlyInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DeleteKeyPair",
          "ec2:DeleteNatGateway",
          "ec2:DeleteNetworkAcl",
          "ec2:DeleteNetworkAclEntry",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:DeleteRoute",
          "ec2:DeleteRouteTable",
          "ec2:DeleteSnapshot",
          "ec2:DeleteSubnet",
          "ec2:DeleteTags",
          "ec2:DeleteVpc",
          "ec2:DeleteVpcEndpoints",
          "ec2:DeleteVpcPeeringConnection",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeHosts",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribePlacementGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeVpcs",
          "ec2:DetachInternetGateway",
          "ec2:DetachNetworkInterface",
          "ec2:DisassociateAddress",
          "ec2:DisassociateIamInstanceProfile",
          "ec2:DisassociateRouteTable",
          "ec2:DisassociateSubnetCidrBlock",
          "ec2:DisassociateVpcCidrBlock",
          "ec2:ModifyImageAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifySubnetAttribute",
          "ec2:ModifyVpcAttribute",
          "ec2:ModifyVpcEndpoint",
          "ec2:ReleaseAddress",
          "ec2:ReleaseHosts",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:*Volume",
          "ec2:*Volumes",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "iam:CreateServiceLinkedRole",
          "iam:GetRole",
          "iam:ListInstanceProfilesForRole",
          "iam:PassRole",
          "s3:CreateBucket",
          "s3:GetObject",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:PutBucketPolicy",
          "s3:PutBucketTagging",
          "s3:GetBucketTagging",
          "s3:PutObject",
          "s3:PutLifecycleConfiguration",
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketPublicAccessBlock",
          "servicequotas:GetServiceQuota",
          "servicequotas:ListServiceQuotas",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


#
# Cluster node role
#


resource "aws_iam_role" "cluster_node_role" {
  name = var.cluster_node_role_name
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = join("", ["ec2.", var.aws_endpoint])
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_instances_description_read_access_for_agents_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2InstancesDescriptionReadAccessForAgents"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_instances_description_read_access_for_networking_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2InstancesDescriptionReadAccessForNetworking"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_networks_description_read_access_for_networking_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2NetworksDescriptionReadAccessForNetworking"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_subnets_tags_full_access_for_networking_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2SubnetsTagsFullAccessForNetworking"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = [
          "arn:*:ec2:*:*:subnet/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_network_interfacess_full_access_for_networking_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2NetworkInterfacessFullAccessForNetworking"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeNetworkInterfaceAttribute",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DetachNetworkInterface",
          "ec2:DescribeTags"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = [
          "arn:*:ec2:*:*:network-interface/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_security_groups_full_access_for_networking_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2SecurityGroupsFullAccessForNetworking"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeTags"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = [
          "arn:*:ec2:*:*:security-group/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_private_ip_addresses_full_access_for_networking_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2PrivateIpAddressesFullAccessForNetworking"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_route_tables_full_access_for_networking_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2RouteTablesFullAccessForNetworking"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRoute",
          "ec2:DescribeRouteTables"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_s3_buckets_list_access_for_hibernate_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-S3BucketsListAccessForHibernate"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          "arn:*:s3:::nutanix-clusters-hb-*",
          "arn:*:s3:::*-nutanix-cluster-hibernate"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_s3_objects_full_access_for_hibernate_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-S3ObjectsFullAccessForHibernate"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "arn:*:s3:::nutanix-clusters-hb-*/*",
          "arn:*:s3:::*-nutanix-cluster-hibernate/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_s3_buckets_list_access_for_snap2_s3_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-S3BucketsListAccessForSnap2S3"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          "arn:*:s3:::nutanix-clusters*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_s3_objects_full_access_for_snap2_s3_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-S3ObjectsFullAccessForSnap2S3"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "arn:*:s3:::nutanix-clusters*/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_network_interfaces_delete_access_for_hibernate_policy" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2NetworkInterfacesDeleteAccessForHibernate"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachNetworkInterface",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_private_ip_addresses_assign_access_for_agents" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2PrivateIpAddressesAssignAccessForAgents"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:AssignPrivateIpAddresses"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_read_access_for_troubleshooting" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2ReadAccessForTroubleshooting"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaceAttribute",
          "ec2:DescribeNetworkInterfacePermissions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribePlacementGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:GetConsoleOutput"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "cluster_node_ec2_read_access_for_service_quotas" {
  name = join("", [var.cluster_node_role_name, "-Policy-EC2ReadAccessForServiceQuotas"])
  role = aws_iam_role.cluster_node_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "servicequotas:GetServiceQuota",
          "servicequotas:ListServiceQuotas"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


# IAM Instance Profile
# cf. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
# Use an instance profile to pass an IAM role to an EC2 instance
# cf. 
resource "aws_iam_instance_profile" "cluster_node_profile" {
  name = var.cluster_node_role_name
  role = aws_iam_role.cluster_node_role.name
}

