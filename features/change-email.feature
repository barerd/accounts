@change-email
Feature: Users can change their e-mails

  @email-taken
  Scenario: Alice cannot change her e-mail to one that is already taken
    Given I register "alice@wunder.land" with password "caterpillar"
    And I register "caterpillar@wunder.land" with password "caterpillar"
    And "alice@wunder.land" is authenticated with password "caterpillar"
    When Alice visits "/change-email"
    And she fills in "email" with "caterpillar@wunder.land" 
    And she presses "Submit"
    Then she should see "caterpillar@wunder.land is already taken"

  @request-change-email
  Scenario: Alice requests to change email to an available email
    Given "alice@wunder.land" is registered with password "caterpillar"
    And "alice@wunder.land" is authenticated with password "caterpillar"
    When she visits "/change-email"
    And she fills in "email" with "alice@looking.glass" 
    And she presses "Submit"
    Then she should see "Check your e-mail"
    And "alice@wunder.land" opens an email containing "You have requested to change your e-mail to alice@looking.glass"
    And "alice@looking.glass" receives an email containing "http://accounts.test/response-token/"

  Scenario: Alice can still log on with her previous e-mail
    Given "alice@wunder.land" is registered with password "caterpillar"
    When she visits "/logon"
    And she fills in "email" with "alice@wunder.land" 
    And she fills in "password" with "caterpillar"
    And she presses "Submit"
    Then she should be on "/welcome"
    And she should see "Welcome alice@wunder.land"

  Scenario: Alice follows confirmation link
    Given "alice@looking.glass" opens an email containing "http://accounts.test/response-token/"
    When she visits link from email
    And "email" form-input should contain "alice@looking.glass" 
    And she fills in "password" with "caterpillar"
    And she presses "Submit"
    Then she should be on "/welcome"
    And she should see "Welcome alice@looking.glass"

  Scenario: Alice can not log on with her previous e-mail
    Given "alice@looking.glass" is registered with password "caterpillar"
    When she visits "/logon"
    And she fills in "email" with "alice@wunder.land" 
    And she fills in "password" with "caterpillar"
    And she presses "Submit"
    Then she should see "Access denied"
