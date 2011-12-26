@pages
Feature: This demo app has the following pages

  @logon
  Scenario: Display the logon page to unauthenticated visitors
    When someone visits "/logon"
    Then page has "form input[@type='text'][@name='email']"
    And page has "form input[@type='password'][@name='password']"
    And page has "form button[@type='submit'][@value='Submit']"
    And page has "link[@href='/reset-password']"
    And page has "link[@href='/register']"

  @registration
  Scenario: Display the registration page to unauthenticated visitors
    When someone visits "/register"
    Then page has "form input[@type='text'][@name='email']"
    And page has "form button[@type='submit']"

  @forgot-password
  Scenario: Display the request reset password page to unauthenticated visitors
    When someone visits "/forgot-password"
    Then page has "form input[@type='text'][@name='email']"
    And page has "form button[@type='submit']"

  @forgot-password-confirm
  Scenario: Display the request reset password confirmation page
    When "alice@wunderland.com" submits request to reset password
    Then I should see "We are sending an e-mail to alice@wunderland.com with a one-time link"

  @forgot-password-confirm-string-safe
  Scenario: Request reset password confirmation page is safe from script injection
    When {<script type="text/javascript">alert('hi')</script>} submits request to reset password
    Then I should see raw html: "We are sending an e-mail to &lt;script type="

  @reset-password
  Scenario: Display the request reset password page to unauthenticated visitors
    When someone visits "/reset-password"
    And page has "form input[@type='password'][@name='password']"
    And page has "form input[@type='password'][@name='password2']"
    And page has "form button[@type='submit']

  @change-email
  Scenario: Display the request change e-mail page to authenticated visitors
    Given that "alice@wunderland.com" is authenticated
    When "alice@wunderland.com" visits "/forgot-password"
    Then page has "form input[@type='text'][@name='email']"
    And page has "form button[@type='submit']
