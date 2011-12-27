@register
Feature: Visitors can register

  @registration-page
  Scenario: Display the registration page to unauthenticated visitors
    When someone visits "/register"
    Then page has "form input[@type='text'][@name='email']"
    And page has "form button[@type='submit']"

  @registers @registers-again @confirms-registration
  Scenario: Unregistered user requests to register
    Given "alice@wunder.land" is not registered
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then I should see "We are sending an e-mail to alice@wunder.land with a one-time link"
    And "alice@wunder.land" should receive email containing "http://accounts.test/response-token/"

  @registers-again
  Scenario: Registered user requests to register
    Given "alice@wunder.land" is registered
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then page has content "alice@wunder.land is already registered"
    And "alice@wunder.land" should receive email containing "http://accounts.test/response-token/"

  @registers @confirms-registration
  Scenario: Confirm registration
    Given "alice@wunder.land" has received email with register-confirmation link
    When "alice@wunder.land" visits registration-confirmation link
    Then alice should see "Change Password"
    And administrator receives email with registration notification

  Scenario: Confirm registration with stale link
    Given "alice@wunder.land" has already confirmed her registration
    When "alice@wunder.land" visits stale registration-confirmation link
    Then response should be "page not found"
