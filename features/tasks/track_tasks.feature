Feature: Manage Tasks
  As a DrewApp user
  I want to be able to track my task status
  So that I know what work I'm currently doing and what to do next

  Scenario: Start a task
    Given I have added the task "Fix the roof"
    And I am on the task page
    When I start the task
    Then I should see the "Fix the roof" task is started
    When I go off and do some work then return
    Then I should see the "Fix the roof" task is started

  Scenario: Stop a task
    Given I have added the task "Fix the roof"
    And the "Fix the roof" task has been started
    And I am on the task page
    When I stop the task
    Then I should see the "Fix the roof" task is no longer started
    When I go off and do some work then return
    Then I should see the "Fix the roof" task is no longer started
