Feature: A website needs to maintain user accounts with e-mail and secure password
  Users must have a way to reset their e-mails and passwords

  @signon-form
  Scenario: Display the logon page to unauthenticated visitors
    When someone visits "/logon"
    Then page has "form input[@type='text'][@name='email']"
    And page has "form input[@type='password'][@name='password']"
    And page has "form button[@type='submit']"
    And page has "link[@href='/reset-password']"
    And page has "link[@href='/register']"

  Scenario: Request to register
    When "alice@wunderland.com" registers 
    Then "alice@wunderland.com" receives email with register-confirmation link
    And "alice@wunderland.com" is suspended

  Scenario: Confirm registration
    Given "alice@wunderland.com" receives email with register-confirmation link
    When "alice@wunderland.com" visits registration-confirmation link
    Then "alice@wunderland.com" is authenticated
    And "alice@wunderland.com" e-mail is confirmed
    And administrator receives email with registration notification
    And "alice@wunderland.com" can change password to "lookingglass"
    And register-confirmation link will return page-not-found

  Scenario: Request to reset password
    When "alice@wunderland.com" submits request to reset password
    Then "alice@wunderland.com" receives e-mail with reset-password link

  Scenario: Visit reset-password link
    When "alice@wunderland.com" visits reset-password link
    Then "alice@wunderland.com" is authenticated
    And "alice@wunderland.com" can change password to "grasshopper"

  Scenario: Request to change e-mail
    When "alice@wunderland.com" submits request to change e-mail to "rabbit@hole.com"
    Then "rabbit@hole.com" receives email with change-email-confirmation link
    And "alice@wunderland.com" receives email with change-email-notification message and dispute-change-email link

  Scenario: Visit change-email link
    When "rabbit@hole.com" visits change-email link
    Then "rabbit@hole.com" is authenticated
    And "rabbit@hole.com" e-mail is confirmed
    And user "alice@wunderland.com" does not exist

  Scenario: Receive change-email notification
    When "alice@wunderland.com" visits dispute-change-email link
    Then "rabbit@hole.com" is suspended
    And "rabbit@hole.com" receives email with dispute notification
    And "alice@wunderland.com" receives email with dispute confirmation
    And administrator receives email with dispute confirmation
