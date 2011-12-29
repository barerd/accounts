@register
Feature: Visitors can register

  Scenario: Unregistered user requests to register
    Given I have unregistered "alice@wunder.land"
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then she should see "Check your e-mail"
    And "alice@wunder.land" should receive an email

  Scenario: Unconfirmed user requests to register again will get another e-mail
    Given "alice@wunder.land" is registered
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then page has content "Check your mail"
    And "alice@wunder.land" should receive an email

  Scenario: Confirm registration with stale link doesn't do anything
    Given "alice@wunder.land" opens an email containing "http://accounts.test/response-token/"
    When "alice@wunder.land" visits link from email
    Then Alice should see "Page not found"
    And "admin@accounts.test" should not receive an email
    And "alice@wunder.land" is not confirmed

  Scenario: Confirm registration with active link is successful
    Given "alice@wunder.land" opens an email containing "http://accounts.test/response-token/"
    When "alice@wunder.land" visits link from email
    Then alice should see "Change Password"
    And "admin@accounts.test" should receive an email
    And "admin@accounts.test" opens an email containing "alice@wunder.land has registered and confirmed"
    And "alice@wunder.land" is confirmed

  Scenario: Confirmed user requests to register again will fail
    Given "alice@wunder.land" is registered
    When I visits "/register"
    And I fills in "email" with "alice@wunder.land" 
    And I presses "Submit"
    Then page has content "alice@wunder.land is already registered"
    And "alice@wunder.land" should not receive an email
