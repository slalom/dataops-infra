"""
Builds the architecture diagram

Usage:

> python create_diagram.py

"""

from diagrams import Cluster, Diagram
from diagrams.aws import compute
from diagrams.aws import database
from diagrams.aws import network
from diagrams.aws import storage
from diagrams.aws import security
from diagrams.generic.blank import Blank
from diagrams import generic

from diagrams.onprem.analytics import Singer, Dbt, Tableau
from diagrams.onprem.database import MySQL, PostgreSQL
from diagrams.onprem.workflow import Airflow
from diagrams.saas.analytics import Snowflake

from diagrams.generic.device import Mobile, Tablet
from diagrams.onprem.client import User, Users

from diagrams.onprem.iac import Terraform

from diagrams.aws.integration import Eventbridge

from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker
from diagrams.onprem.network import Internet
from diagrams.aws.migration import TransferForSftp
from diagrams.aws.analytics import Glue
from diagrams.aws.management import Cloudwatch

graph_attr = {
    # "fontsize": "45",
    # "bgcolor": "transparent"
}

with Diagram(
    "Kitchen Sink Lab",
    show=False,
    filename="diagram",
    graph_attr=graph_attr,
    direction="TB",
):

    with Cluster("Admin"):
        tf = Terraform("IAC")
        # docker = Docker("Docker")
        admin = User("Admin User")

    with Cluster("End Users"):
        users = Users("End Users")

    with Cluster("AWS"):

        with Cluster("VPC"):

            routetable = network.RouteTable("Route Tables")
            firewall = network.VPC("VPC Firewall Rules")

            with Cluster("Public Subnets") as public1:
                rs1 = database.Redshift("Redshift\nCluster")
                postgres = PostgreSQL("Postgres\n(RDS)")
                mySQL = MySQL("MySQL\n(RDS)")
                airflow = Airflow("Airflow Server\n(ECS Fargate)")
                # with Cluster("Public Subnet (2)") as pub2:
                nat = network.NATGateway("NAT\nGateway")
                # rs2 = database.Redshift("Redshift\n(node 2)")
                elb = network.ELB("Elastic Load\nBalancer")

            with Cluster("Private Subnets") as priv1:
                Blank("")
                singer1 = Singer("Singer.io\nExtract/Loads\n(ECS Fargate)")
                Blank("")
                Blank("")
                Blank("")
                # with Cluster("Private Subnet (2)") as priv2:
                tableau = Tableau("Tableau Server\n(EC2)")

        with Cluster("S3 Data Lake"):
            s3data = storage.S3("Data Bucket")
            s3meta = storage.S3("Metadata Bucket")
            s3logs = storage.S3("Logging Bucket")
            sftp = TransferForSftp("SFTP\nTransfer Service")
            py_fn1 = compute.Lambda("File Listener\n(Lambda Python)")
            glue = Glue("Spark Transforms\n(Glue)")

        # with Cluster("AWS Serverless"):
        events = Eventbridge("Event Triggers\n(AWS Eventbridge)")
        secrets = security.SecretsManager("AWS Secrets\nManager")
        cw = Cloudwatch("Cloudwatch Logs")

    source = Internet("External\nData Source")

    py_fn1 << s3data << py_fn1
    glue << s3data << glue

    nat << singer1
    nat >> source
    elb >> tableau
    s3meta >> singer1 >> s3data
    singer1 << secrets
    singer1 << events
    rs1 << singer1
    users >> elb
    source >> singer1
    rs1 >> tableau
    s3data << sftp
    singer1 >> cw

    routetable >> public1
