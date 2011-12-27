When /^page has "([^"]*)"$/ do |arg1|
  #STDERR.puts page.body
  page.body.should have_selector(arg1)
end

When /^page has content "([^"]*)"$/ do |arg1|
  #STDERR.puts page.body
  page.body.should have_content(arg1)
end

When /^"([^"]*)" registers$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" has received email with register\-confirmation link$/ do |arg1|
  @alice_register_confirmation_mail.should_not be_nil
end

When /^"([^"]*)" is suspended$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" visits registration\-confirmation link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" is authenticated$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" e\-mail is confirmed$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^administrator receives email with registration notification$/ do
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" can change password to "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^register\-confirmation link will return page\-not\-found$/ do
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" submits request to reset password$/ do |arg1|
  visit '/forgot-password'
  with_scope('form.forgot_password') do
    fill_in('email', :with => arg1)
    click_button("Submit")
  end
end

# Javascipt injection example
When /^{([^}]*)} submits request to reset password$/ do |arg1|
  visit '/forgot-password'
  with_scope('form.forgot_password') do
    fill_in('email', :with => arg1)
    click_button("Submit")
  end
end

When /^"([^"]*)" receives e\-mail with reset\-password link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" visits reset\-password link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" submits request to change e\-mail to "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" receives email with change\-email\-confirmation link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" receives email with change\-email\-notification message and dispute\-change\-email link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" visits dispute\-change\-email link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" receives email with dispute notification$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" receives email with dispute confirmation$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^administrator receives email with dispute confirmation$/ do
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" has already confirmed her registration$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" visits stale registration\-confirmation link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^response is redirected to "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" has already visited reset\-password link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^\w+ visits? "([^"]*)"$/ do |arg1|
  visit arg1
end

When /^that "([^"]*)" is authenticated$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I should see raw html: "([^"]*)"$/ do |arg1|
  page.html.should match /#{arg1}/ 
end

When /^"([^"]*)" is registered$/ do |arg1|
  Authenticatable::Account.all( :email => arg1 ).should have(1).item
end

When /^"([^"]*)" is not registered$/ do |arg1|
  Authenticatable::Account.all( :email => arg1 ).should have(0).items
end

Then /^"([^"]*)" should receive email containing "([^"]*)"$/ do |arg1, arg2|
  Mail::TestMailer.deliveries.accounts.should include(arg1)
  @alice_register_confirmation_mail = Mail::TestMailer.deliveries.get(arg1)
  @alice_register_confirmation_mail.body.should match(arg2)
end

