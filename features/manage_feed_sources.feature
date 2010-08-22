Feature: Manage feed_sources

  Scenario: Register new feed source
    Given I am on the new feed source page
    When I fill in "Url" with "url 1"
    And I select "Blog" from "Feed type"
    And I press "Save"
    Then I should see "Url: url 1"
    And I should see "Feed type: Blog"

  Scenario: Edit an existing feed source
    Given the following feed_source:
      | url   | feed_type |
      | url 1 | Blog      |
    And I am on the edit page for "url 1"
    When I fill in "Url" with "url 2"
    And I select "Github" from "Feed type"
    And I press "Save"
    Then I should see "Url: url 2"
    And I should see "Feed type: Github"

  Scenario: Delete feed_source
    Given the following feed_sources:
      | url   | feed_type   |
      | url 1 | feed_type 1 |
      | url 2 | feed_type 2 |
      | url 3 | feed_type 3 |
      | url 4 | feed_type 4 |
    When I delete the 3rd feed_source
    Then I should see the following feed_sources:
      | Url   | Feed type   |
      | url 1 | feed_type 1 |
      | url 2 | feed_type 2 |
      | url 4 | feed_type 4 |

