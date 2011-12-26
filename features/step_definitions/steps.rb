Then /^page has "([^"]*)"$/ do |arg1|
  page.should have_selector(arg1)
end

Given /^"([^"]*)" registers$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" receives email with register\-confirmation link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" is suspended$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" visits registration\-confirmation link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" is authenticated$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" e\-mail is confirmed$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^administrator receives email with registration notification$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" can change password to "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^register\-confirmation link will return page\-not\-found$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" submits request to reset password$/ do |arg1|
  visit '/forgot-password'
  with_scope('form.forgot_password') do
    fill_in('email', :with => arg1)
    click_button("Submit")
  end
end

Given /^"([^"]*)" receives e\-mail with reset\-password link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" visits reset\-password link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" submits request to change e\-mail to "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" receives email with change\-email\-confirmation link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" receives email with change\-email\-notification message and dispute\-change\-email link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" visits dispute\-change\-email link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" receives email with dispute notification$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" receives email with dispute confirmation$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^administrator receives email with dispute confirmation$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" has already confirmed her registration$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" visits stale registration\-confirmation link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^response is redirected to "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" has already visited reset\-password link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^someone visits "([^"]*)"$/ do |arg1|
  visit arg1
end

Given /^that "([^"]*)" is authenticated$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" visits "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end
