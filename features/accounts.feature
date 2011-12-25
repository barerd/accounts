@transactions
Feature: A website needs to maintain user accounts with e-mail and secure password
  Users must have a way to reset their e-mails and passwords

  Scenario: Unauthenticated user requests to register
    When "alice@wunderland.com" registers 
    Then "alice@wunderland.com" receives email with register-confirmation link
    And "alice@wunderland.com" is suspended

  Scenario: Registered user requests to register
    When "alice@wunderland.com" registers 
    Then page has "text('You are already registered')"

  Scenario: Confirm registration
    Given "alice@wunderland.com" receives email with register-confirmation link
    When "alice@wunderland.com" visits registration-confirmation link
    Then "alice@wunderland.com" is authenticated
    And "alice@wunderland.com" e-mail is confirmed
    And administrator receives email with registration notification
    And "alice@wunderland.com" can change password to "lookingglass"
    And register-confirmation link will return page-not-found

  Scenario: Confirm registration with stale link
    Given "alice@wunderland.com" has already confirmed her registration
    When "alice@wunderland.com" visits stale registration-confirmation link
    Then response is redirected to "/"

  Scenario: Request to reset password
    When "alice@wunderland.com" submits request to reset password
    Then "alice@wunderland.com" receives e-mail with reset-password link

  Scenario: Visit reset-password link
    When "alice@wunderland.com" visits reset-password link
    Then "alice@wunderland.com" is authenticated
    And "alice@wunderland.com" can change password to "grasshopper"

  Scenario: Visit stale reset-password link
    Given "alice@wunderland.com" has already visited reset-password link
    When "alice@wunderland.com" visits reset-password link
    Then response is redirected to "/"

  Scenario: Request to change e-mail
    When "alice@wunderland.com" submits request to change e-mail to "rabbit@hole.com"
    Then "rabbit@hole.com" receives email with change-email-confirmation link
    And "alice@wunderland.com" receives email with change-email-notification message and dispute-change-email link

  Scenario: Receive change-email notification
    When "alice@wunderland.com" visits dispute-change-email link
    Then "rabbit@hole.com" is suspended
    And "rabbit@hole.com" receives email with dispute notification
    And "alice@wunderland.com" receives email with dispute confirmation
    And administrator receives email with dispute confirmation
