@change-password

  Feature: Users can change their passwords

  Scenario: Alice changes her password
    Given "alice@wunder.land" is registered
    When "alice@wunder.land" visits "/forgot-password"
    And "alice@wunder.land" can change password to "lookingglass"
    And register-confirmation link will return page-not-found

  Scenario: Registered user can log on
    Given "alice@wunder.land" has already confirmed her registration
    When she visits "/logon"
    And she fills in "input[@name='email']" with "alice@wunder.land" 
    And she fills in "input[@name='password']" with "grasshopper" 
    Then she should see "Welcome alice@wunder.land"

