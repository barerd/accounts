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
  @last_register_confirmation_mail.should_not be_nil
  @last_register_confirmation_mail.body.to_s =~ /(http\S+)/
  link = $1
  link.should_not be_nil
  #STDERR.puts "link = #{link}"
  visit link
  account = Authenticatable::Account.first( :email => arg1 )
  account.status.should include :email_confirmed
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

When /^"([^"]*)" is (not )?registered$/ do |arg1, bool|
  Authenticatable::Account.all( :email => arg1 ).should have(bool ? 0 : 1).items
end

When /^"([^"]*)" (?:\w+ )?received? an email containing "([^"]*)"$/ do |arg1, arg2|
  Mail::TestMailer.deliveries.accounts.should include(arg1)
  @last_register_confirmation_mail = Mail::TestMailer.deliveries.get(arg1)
  @last_register_confirmation_mail.body.should match(arg2)
end

When /^"([^"]*)" (?:\w+ )?received? but not open(?:ed)? an email containing "([^"]*)"$/ do |arg1, arg2|
  Mail::TestMailer.deliveries.accounts.should include(arg1)
  @last_register_confirmation_mail = Mail::TestMailer.deliveries.peek(arg1)
  @last_register_confirmation_mail.body.should match(arg2)
end

When /^"([^"]*)" should not receive an email containing "([^"]*)"$/ do |arg1, arg2|
  msg = Mail::TestMailer.deliveries.peek(arg1)
  msg.body.should_not match(arg2) if !msg.nil?
end

When /^"([^"]*)" has already confirmed her registration$/ do |arg1|
  visit '/register'
  fill_in("email", :with => arg1)
  click_button("Submit")
  @last_register_confirmation_mail = Mail::TestMailer.deliveries.get(arg1)
  @last_register_confirmation_mail.should_not be_nil
  @last_register_confirmation_mail.body.to_s =~ /change your password: (http\S+)/
  link = $1
  link.should_not be_nil
  #STDERR.puts "link = #{link}"
  visit link
  Authenticatable::ActionToken.count(:account => Authenticatable::Account.first(:email => arg1)).should be == 0
end
