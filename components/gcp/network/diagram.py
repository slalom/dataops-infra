# from diagrams import Diagram, Cluster
# from diagrams.aws.compute import EC2, ECS
# from diagrams.aws.database import RDS
# from diagrams.aws.network import ELB, VPC, TransitGateway
#
# with Diagram("vpc", show=False, direction="TB") as diag:
#     with Cluster("VPC"):
#         with Cluster(f"Private Subnet 1"):
#             ECS("ECS Cluster (e.g.)")
#         with Cluster(f"Private Subnet 2"):
#             ec2 = EC2("EC2 Instance (e.g.)")
#             ec2
#         with Cluster(f"Public Subnet 1") as publicnet1:
#             nat = TransitGateway("NAT Gateway")
#             igw = TransitGateway("Internet Gateway")
#             nat
#             igw
#         with Cluster(f"Public Subnet 2") as publicnet2:
#             pass
#         # ec2 >> nat
#         # ecs >> nat
#         # nat >> igw

