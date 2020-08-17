Feature: Security groups should meet security guidelines
    In order to secure resources
    As users of the Infrastructure Catalog
    We'll ensure inbound traffic is protected from known vulnerabilities.

    Scenario Outline: Well-known insecure protocol exposure on Public Network for ingress traffic
        Given I have AWS Security Group defined
        When it has ingress
        Then it must not have <proto> protocol and port <portNumber> for 0.0.0.0/0

        Examples:
            | ProtocolName  | proto | portNumber |
            | HTTP          | tcp   | 443        |
            | Telnet        | tcp   | 23         |
            | SSH           | tcp   | 22         |
            | MySQL         | tcp   | 3306       |
            | MSSQL         | tcp   | 1443       |
            | NetBIOS       | tcp   | 139        |
            | RDP           | tcp   | 3389       |
            | Jenkins Slave | tcp   | 50000      |