# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

When /^page has "([^"]*)"$/ do |arg1|
  #STDERR.puts page.body
  page.body.should have_selector(arg1)
end

When /^page has content "([^"]*)"$/ do |arg1|
  #STDERR.puts page.body
  page.body.should have_content(arg1)
end

When /^"([^"]*)" is suspended$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^\w+ visits link from email$/ do
  @new_mail.should_not be_nil
  @new_mail.body.to_s =~ /(http\S+)/
  link = $1
  link.should_not be_nil
  #STDERR.puts "link = #{link}"
  visit link
end

When /^"([^"]*)" is (not )?confirmed$/ do |arg1, bool|
  account = Accounts::Account.first( :email => arg1 )
  should_be_confirmed = !bool

  if (should_be_confirmed) then
    account.should_not be_nil
    account.status.should include :email_confirmed
  else
    account.status.should_not include :email_confirmed if account
  end
end

When /^\w+ visits? "([^"]*)"$/ do |arg1|
  visit arg1
  #save_and_open_page
end

When /^I should see raw html: "([^"]*)"$/ do |arg1|
  page.html.should match /#{arg1}/ 
end

When /^I have unregistered "([^"]*)"$/ do |arg1|
  account = Accounts::Account.all( :email => arg1 )
  account.destroy if account
  Accounts::Account.all( :email => arg1 ).should have(0).items
end

When /^"([^"]*)" is (not )?registered$/ do |arg1, bool|
  Accounts::Account.all( :email => arg1 ).should have(bool ? 0 : 1).items
end

When /^"([^"]*)" opens an email containing "([^"]*)"$/ do |arg1, arg2|
  Mail::TestMailer.deliveries.accounts.should include(arg1)
  @new_mail = Mail::TestMailer.deliveries.get(arg1)
  @new_mail.should_not be_nil
  @new_mail.body.should match /#{arg2}/
end

When /^"([^"]*)" should receive an email$/ do |arg1|
  Mail::TestMailer.deliveries.accounts.should include(arg1)
  Mail::TestMailer.deliveries.peek(arg1).should_not be_nil
end

When /^"([^"]*)" should not receive an email$/ do |arg1|
  msg = Mail::TestMailer.deliveries.peek(arg1)
  msg.should be_nil
end

When /^(?:\S+ )(?:is|has) logged out$/ do
  visit '/logout'
end

When /^I register "([^"]*)" with password "([^"]*)"$/ do |arg1, arg2|
  account = Accounts::Account.create ({ :email => arg1 })
  account.set_password arg2
end

When /^"([^"]*)" is registered with password "([^"]*)"$/ do |arg1, arg2|
  account = Accounts::Account.first ({ :email => arg1 })
  account.should_not be_nil
  account.confirm_password(arg2).should be_true
end

When /^"([^"]*)" is authenticated with password "([^"]*)"$/ do |arg1, arg2|
  visit '/logon'
  current_path.should be == '/logon'
  fill_in('email', :with => arg1)
  fill_in('password', :with => arg2)
  click_button("Submit")
  current_path.should be == '/welcome'
  page.body.should match "Welcome #{arg1}"
end

Then /^"([^"]*)" form\-input should contain "([^"]*)"$/ do |arg1, arg2|
  find("input[@name=#{arg1}]").value.should be == arg2
end

