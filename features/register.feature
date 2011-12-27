@register
Feature: Visitors can register

  Scenario: Display the registration page to unauthenticated visitors
    When someone visits "/register"
    Then page has "form input[@type='text'][@name='email']"
    And page has "form button[@type='submit']"

  @registers
  Scenario: Unregistered user requests to register
    Given "alice@wunder.land" is not registered
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then I should see "We are sending an e-mail to alice@wunder.land with a one-time link"
    And "alice@wunder.land" should receive email with register-confirmation link

  Scenario: Registered user requests to register
    When "alice@wunder.land" registers 
    Then page has "text('You are already registered')"

  Scenario: Confirm registration
    Given "alice@wunder.land" receives email with register-confirmation link
    When "alice@wunder.land" visits registration-confirmation link
    Then "alice@wunder.land" is authenticated
    And "alice@wunder.land" e-mail is confirmed
    And administrator receives email with registration notification
    And "alice@wunder.land" can change password to "lookingglass"
    And register-confirmation link will return page-not-found

  Scenario: Confirm registration with stale link
    Given "alice@wunder.land" has already confirmed her registration
    When "alice@wunder.land" visits stale registration-confirmation link
    Then response is redirected to "/"

  Scenario: Registered user can log on
    Given "alice@wunder.land" has already confirmed her registration
    When she visits "/logon"
    And she fills in "input[@name='email']" with "alice@wunder.land" 
    And she fills in "input[@name='password']" with "grasshopper" 
    Then she should see "Welcome alice@wunder.land"

