Feature: Resources should have proper tagging set
    In order to have reliable identification of deployed resources
    As users of the Infrastructure Catalog
    We'll ensure all resources are properly tagged.

    Scenario: Ensure all resources have tags
        Given I have resource that supports tags defined
        Then it must contain tags
        And its value must not be null

    Scenario Outline: Ensure all resources have required tags
        Given I have resource that supports tags defined
        When it has tags
        Then it must contain <tag>
        And its value must not be null

        Examples:
            | tag     |
            | project |
