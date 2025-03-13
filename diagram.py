from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import ELB
from diagrams.aws.storage import S3
from diagrams.aws.compute import EKS
from diagrams.programming.framework import Flask
from diagrams.programming.language import Bash
from diagrams.onprem.client import Users
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.iac import Terraform
from diagrams.aws.devtools import Codebuild, Codepipeline

with Diagram("AWS Architecture", show=False, direction="LR"):
    # External users accessing the system
    users = Users("Internet Users")

    # Load Balancer
    load_balancer = ELB("Load Balancer")

    # GitHub Actions for CI/CD (Split into two roles)
    github_actions_infra = GithubActions("GitHub Actions - Infra")
    github_actions_app = GithubActions("GitHub Actions - App")

    # Terraform for Infrastructure Deployment
    terraform = Terraform("Terraform IaC")

    # Main Cloud Provider Boundary
    with Cluster("Cloud Provider"):

        # **Public Subnet**
        with Cluster("Public Subnet"):
            mongo_vm = EC2("VM with MongoDB")
            backup_script = Bash("Backup Script")

        # **Private Subnet**
        with Cluster("K8s Cluster in Private Subnet"):
            eks_cluster = EKS("Kubernetes Cluster")
            web_app = Flask("Containerized Web App")

        # **Storage for Backups**
        backup_bucket = S3("DB Backup Storage")

    # **Connections**
    users >> load_balancer >> eks_cluster
    eks_cluster >> web_app
    backup_script >> Edge(label="Stores backups") >> backup_bucket
    mongo_vm >> Edge(label="Runs") >> backup_script

    # **SSH Connection Representation**
    users >> Edge(label="SSH Access", style="dashed", color="blue") >> mongo_vm

    # **CI/CD Pipeline**
    github_actions_infra >> Edge(label="Deploys Infra") >> terraform >> Edge(label="Provisions") >> eks_cluster
    github_actions_app >> Edge(label="Builds & Pushes Image") >> Codebuild("Build Image") >> Codepipeline("Push to ECR")
    github_actions_app >> Edge(label="Deploys App") >> eks_cluster
