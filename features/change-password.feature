# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

@change-password
Feature: Users can change their passwords

  @registers-confirms
  Scenario: Alice requests to register
    Given I have unregistered "alice@wunder.land"
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then she should see "Check your e-mail"

  Scenario: Alice changes her password
    Given "alice@wunder.land" opens an email containing "/response-token/"
    Then she visits link from email
    And she should see "Change Password"
    And she fills in "password" with "caterpillar" 
    And she fills in "password2" with "caterpillar" 
    And she presses "Submit"
    Then she should see "You have changed your password."
    And "alice@wunder.land" should receive an email
    And "admin@accounts.test" should receive an email
    And "admin@accounts.test" opens an email containing "alice@wunder.land has registered and confirmed"

  Scenario: Alice can log on with password "caterpillar"
    Given "alice@wunder.land" opens an email containing "The password for alice@wunder.land has changed."
    When she visits "/logon"
    And she fills in "email" with "alice@wunder.land" 
    And she fills in "password" with "caterpillar"
    And she presses "Submit"
    Then she should be on "/welcome"
    And she should see "Welcome alice@wunder.land"

  Scenario: Alice can not log on with password "alice"
    When she visits "/logon"
    And she fills in "email" with "alice@wunder.land" 
    And she fills in "password" with "alice"
    And she presses "Submit"
    Then she should be on "/logon"
    And she should not see "Welcome alice@wunder.land"

  Scenario: Alice attempts to visit restricted page without first authenticating
    Given Alice has logged out
    When she visits "/welcome"
    And she should not see "Welcome alice@wunder.land"

  Scenario: Alice changes her password again
    Given Alice visits "/logon"
    And she fills in "email" with "alice@wunder.land" 
    And she fills in "password" with "caterpillar"
    And she presses "Submit"
    And she visits "/change-password"
    Then she fills in "password" with "whiterabbit" 
    And she fills in "password2" with "whiterabbit" 
    And she presses "Submit"
    Then she should see "You have changed your password."

  Scenario: Alice tries to log on with her defunct password
    Given "alice@wunder.land" opens an email containing "The password for alice@wunder.land has changed."
    When she visits "/logon"
    And she fills in "email" with "alice@wunder.land" 
    And she fills in "password" with "caterpillar"
    And she presses "Submit"
    Then she should not see "Welcome alice@wunder.land"

  Scenario: Only authenticated users can change their password
    Given I have unregistered "dormouse@alice.com"
    When he visits "/change-password"
    Then he should not see "Change Password"

  Scenario: Alice forgets her password
    Given Alice visits "/forgot-password"
    When she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then she should see "Check your e-mail"
    And "alice@wunder.land" should receive an email

  Scenario: Alice can reset her password again
    Given "alice@wunder.land" opens an email containing "/response-token/"
    When she visits link from email
    Then alice should see "Change Password"
    #But she remembers it again and goes to tea with Caterpillar. :)

  Scenario: Unknown user attempts to reset password
    Given MadHatter visits "/forgot-password"
    When he fills in "email" with "madhatter@wunder.land" 
    And he presses "Submit"
    Then he should see "madhatter@wunder.land does not match any account"
