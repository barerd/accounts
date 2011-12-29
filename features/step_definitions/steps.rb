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

When /^"([^"]*)" visits link from email$/ do |arg1|
  @new_mail.should_not be_nil
  @new_mail.body.to_s =~ /(http\S+)/
  link = $1
  link.should_not be_nil
  #STDERR.puts "link = #{link}"
  visit link
  account = Authenticatable::Account.first( :email => arg1 )
end

When /^"([^"]*)" is (not )?confirmed$/ do |arg1, bool|
  account = Authenticatable::Account.first( :email => arg1 )
  should_be_confirmed = !bool

  if (should_be_confirmed) then
    account.should_not be_nil
    account.status.should include :email_confirmed
  else
    account.status.should_not include :email_confirmed if account
  end
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

When /^\w+ visits? "([^"]*)"$/ do |arg1|
  visit arg1
end

When /^I should see raw html: "([^"]*)"$/ do |arg1|
  page.html.should match /#{arg1}/ 
end

When /^I have unregistered "([^"]*)"$/ do |arg1|
  account = Authenticatable::Account.all( :email => arg1 )
  account.destroy if account
  Authenticatable::Account.all( :email => arg1 ).should have(0).items
end

When /^"([^"]*)" is (not )?registered$/ do |arg1, bool|
  Authenticatable::Account.all( :email => arg1 ).should have(bool ? 0 : 1).items
end

When /^"([^"]*)" opens an email containing "([^"]*)"$/ do |arg1, arg2|
  Mail::TestMailer.deliveries.accounts.should include(arg1)
  @new_mail = Mail::TestMailer.deliveries.get(arg1)
  @new_mail.should_not be_nil
  @new_mail.body.should match(arg2)
end

When /^"([^"]*)" should receive an email$/ do |arg1|
  Mail::TestMailer.deliveries.accounts.should include(arg1)
  Mail::TestMailer.deliveries.peek(arg1).should_not be_nil
end

When /^"([^"]*)" should not receive an email$/ do |arg1|
  msg = Mail::TestMailer.deliveries.peek(arg1)
  msg.should be_nil
end

When /^"([^"]*)" has already confirmed her registration$/ do |arg1|
  # TODO - streamline this by doing it directly in database
  visit '/register'
  fill_in("email", :with => arg1)
  click_button("Submit")
  @new_mail = Mail::TestMailer.deliveries.get(arg1)
  @new_mail.should_not be_nil
  @new_mail.body.to_s =~ /change your password: (http\S+)/
  link = $1
  link.should_not be_nil
  #STDERR.puts "link = #{link}"
  visit link
  Authenticatable::ActionToken.count(:account => Authenticatable::Account.first(:email => arg1)).should be == 0
end

When /^(?:\S+ )(?:is|has) logged out$/ do
  visit '/logout'
end

