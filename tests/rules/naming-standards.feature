Feature: Resources should match expected naming conventions
    In order to have reliable identification of deployed resources
    As users of the Infrastructure Catalog
    We'll ensure all resources are properly named.

    Scenario Outline: Naming standard on all available resources
        Given I have <resource_name> defined
        When it has <name_key>
        Then its value must match the "TestProject01-.*" regex

        Examples:
            | resource_name          | name_key |
            | AWS EC2 instance       | name     |
            | AWS ELB resource       | name     |
            | AWS RDS instance       | name     |
            | AWS S3 Bucket          | bucket   |
            | AWS EBS volume         | name     |
            | AWS Auto-Scaling Group | name     |
            | aws_key_pair           | key_name |

    # Bug: incorrect matches for aws_ecs_cluster
    #       | aws_ecs_cluster        | name     |

    Scenario Outline: Resources with the name tag should match naming convention
        Given I have resource that supports tags defined
        When it has a 'name' tag
        Then its value must match the "TestProject01-.*" regex
