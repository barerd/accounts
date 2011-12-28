@register
Feature: Visitors can register

  @registration-page
  Scenario: Display the registration page to unauthenticated visitors
    When someone visits "/register"
    Then page has "form input[@type='text'][@name='email']"
    And page has "form button[@type='submit']"

  @registers @registers-again @confirms-registration @registers-once
  Scenario: Unregistered user requests to register
    Given "alice@wunder.land" is not registered
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then I should see "We are sending an e-mail to alice@wunder.land with a one-time link"
    And "alice@wunder.land" should receive an email containing "http://accounts.test/response-token/"

  @registers-again
  Scenario: Registered user requests to register again will get another e-mail
    Given "alice@wunder.land" is registered
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then page has content "alice@wunder.land is already registered"
    And "alice@wunder.land" should receive but not open an email containing "http://accounts.test/response-token/"

  @registers @confirms-registration
  Scenario: Confirm registration
    Given "alice@wunder.land" has received an email containing "http://accounts.test/response-token/"
    When "alice@wunder.land" visits link from email
    Then alice should see "Change Password"
    And "admin@accounts.test" should receive an email containing "alice@wunder.land has registered and confirmed"

  Scenario: Confirm registration with stale link doesn't do anything
    Given "alice@wunder.land" has already confirmed her registration
    When "alice@wunder.land" visits link from email
    Then Alice should see "Page not found"
    And "admin@accounts.test" should not receive an email containing "alice@wunder.land has registered and confirmed"
