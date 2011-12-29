@change-password
Feature: Users can change their passwords

  @registers-confirms
  Scenario: Alice requests to register
    Given "alice@wunder.land" is not registered
    When she visits "/register"
    And she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then she should see "We are sending an e-mail to alice@wunder.land with a one-time link"

  Scenario: Alice changes her password
    Given "alice@wunder.land" has received an email containing "http://accounts.test/response-token/"
    When "alice@wunder.land" visits link from email
    Then alice should see "Change Password"
    And she fills in "password" with "caterpillar" 
    And she fills in "password2" with "caterpillar" 
    And she presses "Submit"
    Then she should see "You have changed your password."
    And "alice@wunder.land" should receive but not open an email containing "The password for alice@wunder.land has changed."

  Scenario: Alice can log on with password "caterpillar"
    Given "alice@wunder.land" has received an email containing "The password for alice@wunder.land has changed."
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
    And she should see "Access denied"

  Scenario: Alice attempts to visit restricted page without first authenticating
    Given Alice has logged out
    When she visits "/welcome"
    And she should see "Access denied"

  Scenario: Alice changes her password redux
    Given "alice@wunder.land" can log on with password "caterpillar"
    When "alice@wunder.land" visits "/change-password"
    Then alice should see "Change Password"
    And she fills in "password" with "whiterabbit" 
    And she fills in "password2" with "whiterabbit" 
    And she presses "Submit"
    Then she should see "You have changed your password.  A confirmation will be sent"
    And "alice@wunder.land" should receive an email containing "The password for alice@wunder.land has changed."
    And "alice@wunder.land" can log on with password "whiterabbit"
    And "alice@wunder.land" can not log on with password "caterpillar"

  Scenario: Only authenticated users can change their password
    Given "dormouse@wunder.land" is not registered
    When "dormouse@wunder.land" visits "/change-password"
    Then he should see "Permission denied"

  Scenario: Alice forgets her password
    Given "alice@wunder.land" visits "/forgot-password"
    When she fills in "email" with "alice@wunder.land" 
    And she presses "Submit"
    Then she should see "We are sending an e-mail to alice@wunder.land with a one-time link"
    And "alice@wunder.land" should receive an email containing "http://accounts.test/response-token/"

  Scenario: Alice forgets her password and obtains link to reset it
    Given "alice@wunder.land" should receive an email containing "http://accounts.test/response-token/"
    When "alice@wunder.land" visits link from email
    Then alice should see "Change Password"
    But "she remembers it again and goes to tea with Caterpillar. :)"
