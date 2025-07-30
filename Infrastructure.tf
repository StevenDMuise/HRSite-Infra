terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_security_group" "EC2SecurityGroup" {
    description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
    name = "eks-cluster-sg-hr-service-cluster-698150943"
    tags = {
        Name = "eks-cluster-sg-hr-service-cluster-698150943"
        kubernetes.io/cluster/hr-service-cluster = "owned"
    }
    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        description = "kubernetes.io/rule/nlb/client=a2d75a6bf04cb4824b064b40f8d8c728"
        from_port = 31162
        protocol = "tcp"
        to_port = 31162
    }
    ingress {
        security_groups = [
            "sg-0058d04837bce569f"
        ]
        description = "Allows EFA traffic, which is not matched by CIDR rules."
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
    ingress {
        security_groups = [
            "${aws_security_group.EC2SecurityGroup2.id}"
        ]
        description = "Allow unmanaged nodes to communicate with control plane (all ports)"
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        description = "kubernetes.io/rule/nlb/mtu"
        from_port = 3
        protocol = "icmp"
        to_port = 4
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
    egress {
        security_groups = [
            "sg-0058d04837bce569f"
        ]
        description = "Allows EFA traffic, which is not matched by CIDR rules."
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_security_group" "EC2SecurityGroup2" {
    description = "Communication between all nodes in the cluster"
    name = "eksctl-hr-service-cluster-cluster-ClusterSharedNodeSecurityGroup-FdwB0DUqQFXs"
    tags = {
        alpha.eksctl.io/cluster-name = "hr-service-cluster"
        eksctl.cluster.k8s.io/v1alpha1/cluster-name = "hr-service-cluster"
        alpha.eksctl.io/eksctl-version = "0.211.0"
        alpha.eksctl.io/cluster-oidc-enabled = "false"
        Name = "eksctl-hr-service-cluster-cluster/ClusterSharedNodeSecurityGroup"
    }
    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        security_groups = [
            "sg-0c7018a51cdd4561c"
        ]
        description = "Allow nodes to communicate with each other (all ports)"
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
    ingress {
        security_groups = [
            "sg-0058d04837bce569f"
        ]
        description = "Allow managed and unmanaged nodes to communicate with each other (all ports)"
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_iam_instance_profile" "IAMInstanceProfile" {
    path = "/"
    name = "eks-b2cc1c84-b070-385d-652e-682c5a791365"
    roles = [
        "eksctl-hr-service-cluster-nodegrou-NodeInstanceRole-UWCc3faDJnFa"
    ]
}

resource "aws_subnet" "EC2Subnet" {
    availability_zone = "us-west-2d"
    cidr_block = "192.168.0.0/19"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "EC2Subnet2" {
    availability_zone = "us-west-2c"
    cidr_block = "192.168.64.0/19"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = true
}

resource "aws_eks_cluster" "EKSCluster" {
    name = "hr-service-cluster"
    role_arn = "arn:aws:iam::176448595866:role/eksctl-hr-service-cluster-cluster-ServiceRole-WYvQlXVKDIFt"
    version = "1.33"
    vpc_config {
        security_group_ids = [
            "${aws_security_group.EC2SecurityGroup3.id}"
        ]
        subnet_ids = [
            "subnet-03d16466aa3ae71c7",
            "subnet-06d9665d49434ed33",
            "subnet-052867894b36ad985",
            "subnet-0807dcbb4733961b6",
            "subnet-0faf55f08b90c67a1",
            "subnet-0286daf039e0b5707"
        ]
    }
}

resource "aws_ecr_repository" "ECRRepository" {
    name = "hr-service"
}

resource "aws_instance" "EC2Instance" {
    ami = "ami-0100a64ae7193f8c8"
    instance_type = "t3.medium"
    availability_zone = "us-west-2c"
    tenancy = "default"
    subnet_id = "subnet-052867894b36ad985"
    ebs_optimized = false
    vpc_security_group_ids = [
        "${aws_security_group.EC2SecurityGroup.id}",
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
    source_dest_check = true
    root_block_device {
        volume_size = 80
        volume_type = "gp3"
        delete_on_termination = true
    }
    user_data = "TUlNRS1WZXJzaW9uOiAxLjAKQ29udGVudC1UeXBlOiBtdWx0aXBhcnQvbWl4ZWQ7IGJvdW5kYXJ5PSIvLyIKCi0tLy8KQ29udGVudC1UeXBlOiBhcHBsaWNhdGlvbi9ub2RlLmVrcy5hd3MKCi0tLQphcGlWZXJzaW9uOiBub2RlLmVrcy5hd3MvdjFhbHBoYTEKa2luZDogTm9kZUNvbmZpZwpzcGVjOgogIGNsdXN0ZXI6CiAgICBhcGlTZXJ2ZXJFbmRwb2ludDogaHR0cHM6Ly80MTFENTE4NzE2NzdFMUYyMEFDNUU2MkYwQjBBNTc5Qi5ncjcudXMtd2VzdC0yLmVrcy5hbWF6b25hd3MuY29tCiAgICBjZXJ0aWZpY2F0ZUF1dGhvcml0eTogTFMwdExTMUNSVWRKVGlCRFJWSlVTVVpKUTBGVVJTMHRMUzB0Q2sxSlNVUkNWRU5EUVdVeVowRjNTVUpCWjBsSlVrSk1VMUI2ZWxORVRXTjNSRkZaU2t0dldrbG9kbU5PUVZGRlRFSlJRWGRHVkVWVVRVSkZSMEV4VlVVS1FYaE5TMkV6Vm1sYVdFcDFXbGhTYkdONlFXVkdkekI1VGxSQk0wMXFUWGxOUkUweFRrUkdZVVozTUhwT1ZFRXpUV3BGZVUxRVVYZE9SRVpoVFVKVmVBcEZla0ZTUW1kT1ZrSkJUVlJEYlhReFdXMVdlV0p0VmpCYVdFMTNaMmRGYVUxQk1FZERVM0ZIVTBsaU0wUlJSVUpCVVZWQlFUUkpRa1IzUVhkblowVkxDa0Z2U1VKQlVVUk5jRTVrTlhKNmRreGpNRkppV0ZkeFkwbEtWRk4xU2pOV1JXUlRaV2QzVFZaeFltdEtWMmhPWTBrNFJFOUVlV1ZaYWk5a2NFaHZXR01LVkhkWGRGb3daR3hMTDFWRlVWTTRNa0pMWkRCT1JVZGliVmxtY1RaMGFtZE9OM1JhZEhBeVRIUjNWRmxWUWxkaFNXNWxaa0pEV0c1VGMwSm9OV2xLZWdwd1NHVnRNVXBZU0dkT1ZVa3ZhMUo1YzFkaU1rWnBjRU5VWkVoeFpIUjVWV1kyZDBaU2FHMWlVbHB2TlRkRWJHZDRlVWd3TkhOMVNuUXZWMk5MTUhsWENrRldkRW8xUjNaVVRTdENNMk55WjNSRlZHOUVOM0J2T0VkSFFVeFphM1YzYjBSUVV6UmtRbEZWYTA1bU1tSnVkakpaY0RSTGVsSTVNbTR3Wm5jNWJWTUtkVXcwVDFoamIxZDBlREEzWW04cmF6SjNhbTFaVmtSamVGRm5SRGhxUm5kS1dWaEhhMkl5YUV4cU1YRlBjM3BrTUc5ME5rRndkRk5SVVZKUmFYcGpNUXBuUlhjME1sSnRVSGx4VDBkMlFYa3ZjVVF3TjJSU2FqUTVkR3RLUVdkTlFrRkJSMnBYVkVKWVRVRTBSMEV4VldSRWQwVkNMM2RSUlVGM1NVTndSRUZRQ2tKblRsWklVazFDUVdZNFJVSlVRVVJCVVVndlRVSXdSMEV4VldSRVoxRlhRa0pVVjFSMWVFOTVjV2RLZFZwMGFrd3pSMDVrWlVoSlprTnNka2Q2UVZZS1FtZE9Wa2hTUlVWRWFrRk5aMmR3Y21SWFNteGpiVFZzWkVkV2VrMUJNRWREVTNGSFUwbGlNMFJSUlVKRGQxVkJRVFJKUWtGUlFVbFhjMVU0VGxaQ1ZRbzVaMVo1WjNVMlRrTjVRMnRuV2xGTVpUZFFWVlZwU1VVNVRXeHhkalZUVFRGbll6UlFiWEUyVmt4dE5Fb3lhRFZXWkhoa1EwZHZPRmxGYjJjemQwdDRDbmhrVFRkeVFrRk5SMnhLVHpaWVluTkJiMlF6Y1V4aGIwNVNkVzVZZUdSUFExbDZlbU41V0RCWVRrb3ZaQ3RLTlRVd04yUldkREVyV1ZCQ1RFMUhNMDhLTDAxRlRqVTFSeTlGVTAxdlpFUTFjeTl4YUZjMVJVazRNR295WVZSSFkyRTJiVkJpYzBOVVFUZGtVSEpWV21oMWVXMWlka1JrZFZwdVlXTnRUVkIxUndwaGRrcFphM05RYzJWVldEUldURFJVTUZKNk0yWjRPUzlTZUhBekwwTkhaRlJXV2k5TWNTc3liRVZPYVROcVNrMTZVbWR0UVZKa1lVcHNNMXA2Tm01M0NuYzBVak40Ym14NlVGQlpPSHBCV1dOWGNXOUJiSE5zT1dWUFVtUnpZelZUYkRGR2IwRXdhV1JvZHl0RE9UaDViRkp2VWt0clZqRnplWGxoYzBwdVQxQUtZbVpGY1ZWaWJubGxVMHRGQ2kwdExTMHRSVTVFSUVORlVsUkpSa2xEUVZSRkxTMHRMUzBLCiAgICBjaWRyOiAxMC4xMDAuMC4wLzE2CiAgICBuYW1lOiBoci1zZXJ2aWNlLWNsdXN0ZXIKICBrdWJlbGV0OgogICAgY29uZmlnOgogICAgICBtYXhQb2RzOiAxNwogICAgICBjbHVzdGVyRE5TOgogICAgICAtIDEwLjEwMC4wLjEwCiAgICBmbGFnczoKICAgIC0gIi0tbm9kZS1sYWJlbHM9ZWtzLmFtYXpvbmF3cy5jb20vc291cmNlTGF1bmNoVGVtcGxhdGVWZXJzaW9uPTEsYWxwaGEuZWtzY3RsLmlvL2NsdXN0ZXItbmFtZT1oci1zZXJ2aWNlLWNsdXN0ZXIsYWxwaGEuZWtzY3RsLmlvL25vZGVncm91cC1uYW1lPWhyLXNlcnZpY2Utbm9kZXMsZWtzLmFtYXpvbmF3cy5jb20vbm9kZWdyb3VwLWltYWdlPWFtaS0wMTAwYTY0YWU3MTkzZjhjOCxla3MuYW1hem9uYXdzLmNvbS9jYXBhY2l0eVR5cGU9T05fREVNQU5ELGVrcy5hbWF6b25hd3MuY29tL25vZGVncm91cD1oci1zZXJ2aWNlLW5vZGVzLGVrcy5hbWF6b25hd3MuY29tL3NvdXJjZUxhdW5jaFRlbXBsYXRlSWQ9bHQtMGNmODBlMzllMzA1Mzg1ZjgiCgotLS8vLS0="
    iam_instance_profile = "eks-b2cc1c84-b070-385d-652e-682c5a791365"
    tags = {
        alpha.eksctl.io/nodegroup-type = "managed"
        Name = "hr-service-cluster-hr-service-nodes-Node"
        alpha.eksctl.io/nodegroup-name = "hr-service-nodes"
        eks:cluster-name = "hr-service-cluster"
        kubernetes.io/cluster/hr-service-cluster = "owned"
        k8s.io/cluster-autoscaler/hr-service-cluster = "owned"
        eks:nodegroup-name = "hr-service-nodes"
        k8s.io/cluster-autoscaler/enabled = "true"
    }
}

resource "aws_instance" "EC2Instance2" {
    ami = "ami-0100a64ae7193f8c8"
    instance_type = "t3.medium"
    availability_zone = "us-west-2d"
    tenancy = "default"
    subnet_id = "subnet-03d16466aa3ae71c7"
    ebs_optimized = false
    vpc_security_group_ids = [
        "${aws_security_group.EC2SecurityGroup.id}",
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
    source_dest_check = true
    root_block_device {
        volume_size = 80
        volume_type = "gp3"
        delete_on_termination = true
    }
    user_data = "TUlNRS1WZXJzaW9uOiAxLjAKQ29udGVudC1UeXBlOiBtdWx0aXBhcnQvbWl4ZWQ7IGJvdW5kYXJ5PSIvLyIKCi0tLy8KQ29udGVudC1UeXBlOiBhcHBsaWNhdGlvbi9ub2RlLmVrcy5hd3MKCi0tLQphcGlWZXJzaW9uOiBub2RlLmVrcy5hd3MvdjFhbHBoYTEKa2luZDogTm9kZUNvbmZpZwpzcGVjOgogIGNsdXN0ZXI6CiAgICBhcGlTZXJ2ZXJFbmRwb2ludDogaHR0cHM6Ly80MTFENTE4NzE2NzdFMUYyMEFDNUU2MkYwQjBBNTc5Qi5ncjcudXMtd2VzdC0yLmVrcy5hbWF6b25hd3MuY29tCiAgICBjZXJ0aWZpY2F0ZUF1dGhvcml0eTogTFMwdExTMUNSVWRKVGlCRFJWSlVTVVpKUTBGVVJTMHRMUzB0Q2sxSlNVUkNWRU5EUVdVeVowRjNTVUpCWjBsSlVrSk1VMUI2ZWxORVRXTjNSRkZaU2t0dldrbG9kbU5PUVZGRlRFSlJRWGRHVkVWVVRVSkZSMEV4VlVVS1FYaE5TMkV6Vm1sYVdFcDFXbGhTYkdONlFXVkdkekI1VGxSQk0wMXFUWGxOUkUweFRrUkdZVVozTUhwT1ZFRXpUV3BGZVUxRVVYZE9SRVpoVFVKVmVBcEZla0ZTUW1kT1ZrSkJUVlJEYlhReFdXMVdlV0p0VmpCYVdFMTNaMmRGYVUxQk1FZERVM0ZIVTBsaU0wUlJSVUpCVVZWQlFUUkpRa1IzUVhkblowVkxDa0Z2U1VKQlVVUk5jRTVrTlhKNmRreGpNRkppV0ZkeFkwbEtWRk4xU2pOV1JXUlRaV2QzVFZaeFltdEtWMmhPWTBrNFJFOUVlV1ZaYWk5a2NFaHZXR01LVkhkWGRGb3daR3hMTDFWRlVWTTRNa0pMWkRCT1JVZGliVmxtY1RaMGFtZE9OM1JhZEhBeVRIUjNWRmxWUWxkaFNXNWxaa0pEV0c1VGMwSm9OV2xLZWdwd1NHVnRNVXBZU0dkT1ZVa3ZhMUo1YzFkaU1rWnBjRU5VWkVoeFpIUjVWV1kyZDBaU2FHMWlVbHB2TlRkRWJHZDRlVWd3TkhOMVNuUXZWMk5MTUhsWENrRldkRW8xUjNaVVRTdENNMk55WjNSRlZHOUVOM0J2T0VkSFFVeFphM1YzYjBSUVV6UmtRbEZWYTA1bU1tSnVkakpaY0RSTGVsSTVNbTR3Wm5jNWJWTUtkVXcwVDFoamIxZDBlREEzWW04cmF6SjNhbTFaVmtSamVGRm5SRGhxUm5kS1dWaEhhMkl5YUV4cU1YRlBjM3BrTUc5ME5rRndkRk5SVVZKUmFYcGpNUXBuUlhjME1sSnRVSGx4VDBkMlFYa3ZjVVF3TjJSU2FqUTVkR3RLUVdkTlFrRkJSMnBYVkVKWVRVRTBSMEV4VldSRWQwVkNMM2RSUlVGM1NVTndSRUZRQ2tKblRsWklVazFDUVdZNFJVSlVRVVJCVVVndlRVSXdSMEV4VldSRVoxRlhRa0pVVjFSMWVFOTVjV2RLZFZwMGFrd3pSMDVrWlVoSlprTnNka2Q2UVZZS1FtZE9Wa2hTUlVWRWFrRk5aMmR3Y21SWFNteGpiVFZzWkVkV2VrMUJNRWREVTNGSFUwbGlNMFJSUlVKRGQxVkJRVFJKUWtGUlFVbFhjMVU0VGxaQ1ZRbzVaMVo1WjNVMlRrTjVRMnRuV2xGTVpUZFFWVlZwU1VVNVRXeHhkalZUVFRGbll6UlFiWEUyVmt4dE5Fb3lhRFZXWkhoa1EwZHZPRmxGYjJjemQwdDRDbmhrVFRkeVFrRk5SMnhLVHpaWVluTkJiMlF6Y1V4aGIwNVNkVzVZZUdSUFExbDZlbU41V0RCWVRrb3ZaQ3RLTlRVd04yUldkREVyV1ZCQ1RFMUhNMDhLTDAxRlRqVTFSeTlGVTAxdlpFUTFjeTl4YUZjMVJVazRNR295WVZSSFkyRTJiVkJpYzBOVVFUZGtVSEpWV21oMWVXMWlka1JrZFZwdVlXTnRUVkIxUndwaGRrcFphM05RYzJWVldEUldURFJVTUZKNk0yWjRPUzlTZUhBekwwTkhaRlJXV2k5TWNTc3liRVZPYVROcVNrMTZVbWR0UVZKa1lVcHNNMXA2Tm01M0NuYzBVak40Ym14NlVGQlpPSHBCV1dOWGNXOUJiSE5zT1dWUFVtUnpZelZUYkRGR2IwRXdhV1JvZHl0RE9UaDViRkp2VWt0clZqRnplWGxoYzBwdVQxQUtZbVpGY1ZWaWJubGxVMHRGQ2kwdExTMHRSVTVFSUVORlVsUkpSa2xEUVZSRkxTMHRMUzBLCiAgICBjaWRyOiAxMC4xMDAuMC4wLzE2CiAgICBuYW1lOiBoci1zZXJ2aWNlLWNsdXN0ZXIKICBrdWJlbGV0OgogICAgY29uZmlnOgogICAgICBtYXhQb2RzOiAxNwogICAgICBjbHVzdGVyRE5TOgogICAgICAtIDEwLjEwMC4wLjEwCiAgICBmbGFnczoKICAgIC0gIi0tbm9kZS1sYWJlbHM9ZWtzLmFtYXpvbmF3cy5jb20vc291cmNlTGF1bmNoVGVtcGxhdGVWZXJzaW9uPTEsYWxwaGEuZWtzY3RsLmlvL2NsdXN0ZXItbmFtZT1oci1zZXJ2aWNlLWNsdXN0ZXIsYWxwaGEuZWtzY3RsLmlvL25vZGVncm91cC1uYW1lPWhyLXNlcnZpY2Utbm9kZXMsZWtzLmFtYXpvbmF3cy5jb20vbm9kZWdyb3VwLWltYWdlPWFtaS0wMTAwYTY0YWU3MTkzZjhjOCxla3MuYW1hem9uYXdzLmNvbS9jYXBhY2l0eVR5cGU9T05fREVNQU5ELGVrcy5hbWF6b25hd3MuY29tL25vZGVncm91cD1oci1zZXJ2aWNlLW5vZGVzLGVrcy5hbWF6b25hd3MuY29tL3NvdXJjZUxhdW5jaFRlbXBsYXRlSWQ9bHQtMGNmODBlMzllMzA1Mzg1ZjgiCgotLS8vLS0="
    iam_instance_profile = "eks-b2cc1c84-b070-385d-652e-682c5a791365"
    tags = {
        alpha.eksctl.io/nodegroup-type = "managed"
        eks:cluster-name = "hr-service-cluster"
        k8s.io/cluster-autoscaler/enabled = "true"
        k8s.io/cluster-autoscaler/hr-service-cluster = "owned"
        kubernetes.io/cluster/hr-service-cluster = "owned"
        eks:nodegroup-name = "hr-service-nodes"
        alpha.eksctl.io/nodegroup-name = "hr-service-nodes"
        Name = "hr-service-cluster-hr-service-nodes-Node"
    }
}

resource "aws_volume_attachment" "EC2VolumeAttachment" {
    volume_id = "vol-0dd5588d48097c9b8"
    instance_id = "i-0cef7facac5067cab"
    device_name = "/dev/xvda"
}

resource "aws_volume_attachment" "EC2VolumeAttachment2" {
    volume_id = "vol-031f8c09d949e5f95"
    instance_id = "i-013403adabd6eb689"
    device_name = "/dev/xvda"
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment" {
    network_interface_id = "eni-063a3d3388bc7658a"
    device_index = 1
    instance_id = "i-0cef7facac5067cab"
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment2" {
    network_interface_id = "eni-08fc903b8235a214b"
    device_index = 0
    instance_id = "i-0cef7facac5067cab"
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment3" {
    network_interface_id = "eni-09a5586ced289ffd3"
    device_index = 1
    instance_id = "i-013403adabd6eb689"
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment4" {
    network_interface_id = "eni-0b43453d9210dcd91"
    device_index = 0
    instance_id = "i-013403adabd6eb689"
}

resource "aws_vpc" "EC2VPC" {
    cidr_block = "192.168.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = {
        eksctl.cluster.k8s.io/v1alpha1/cluster-name = "hr-service-cluster"
        alpha.eksctl.io/cluster-oidc-enabled = "false"
        alpha.eksctl.io/eksctl-version = "0.211.0"
        Name = "eksctl-hr-service-cluster-cluster/VPC"
        alpha.eksctl.io/cluster-name = "hr-service-cluster"
    }
}

resource "aws_security_group" "EC2SecurityGroup3" {
    description = "Communication between the control plane and worker nodegroups"
    name = "eksctl-hr-service-cluster-cluster-ControlPlaneSecurityGroup-nStaxkwlSra2"
    tags = {
        alpha.eksctl.io/cluster-name = "hr-service-cluster"
        eksctl.cluster.k8s.io/v1alpha1/cluster-name = "hr-service-cluster"
        Name = "eksctl-hr-service-cluster-cluster/ControlPlaneSecurityGroup"
        alpha.eksctl.io/cluster-oidc-enabled = "false"
        alpha.eksctl.io/eksctl-version = "0.211.0"
    }
    vpc_id = "${aws_vpc.EC2VPC.id}"
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_lb_target_group" "ElasticLoadBalancingV2TargetGroup" {
    health_check {
        interval = 30
        port = "traffic-port"
        protocol = "TCP"
        timeout = 10
        unhealthy_threshold = 3
        healthy_threshold = 3
    }
    port = 31162
    protocol = "TCP"
    target_type = "instance"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    name = "k8s-default-hrservic-8217cbd4d4"
}

resource "aws_cloudtrail" "CloudTrailTrail" {
    name = "management-events"
    s3_bucket_name = "aws-cloudtrail-logs-176448595866-9ca48a31"
    include_global_service_events = true
    is_multi_region_trail = true
    enable_log_file_validation = false
    enable_logging = true
}
