module Accounts
  class << self 
    attr_accessor :page_not_found # String
    attr_accessor :redirect_after_logon # String
    attr_accessor :post_forgot_password_response # String
    attr_accessor :changed_your_password_response # String
    attr_accessor :post_register_new_account_response  # String
    attr_accessor :post_register_already_registered_response # Proc(email)
    attr_accessor :post_forgot_password_email_does_not_match_response  # Proc(email)
    attr_accessor :post_change_email_response # String
    attr_accessor :admin_email # String
    attr_accessor :deliver_registration_confirmation  # Proc(email, link)
    attr_accessor :deliver_change_password_link # Proc(email, link)
    attr_accessor :deliver_change_password_confirmation # Proc(email)
    attr_accessor :deliver_change_email_confirmation # Proc(old_email, new_email, link)
    attr_accessor :new_account_admin_notification #Proc(email)
    attr_accessor :deliver_change_email_notification #Proc(old_email, new_email)

    def configure
      yield self
    end
  end
end

# Set defaults - can be overiden
Accounts.configure do |config|

  config.changed_your_password_response = "You have changed your password."
  config.redirect_after_logon = "/welcome"
  config.post_register_new_account_response = "Check your e-mail."
  config.post_register_already_registered_response = ->(email) {
    %Q{#{email} is already registered.  You may <a href="/logon?email=#{email}"log on</a>.}
  }
  config.post_forgot_password_response = "Check your e-mail to change your password."
  config.post_forgot_password_email_does_not_match_response = ->(email) {
    "#{email} does not match any account" 
  }
  config.post_change_email_response = "Check your e-mail."
  config.admin_email = 'admin@accounts.test'

  config.deliver_registration_confirmation = ->(email, link) {
    Mail.deliver do
      from Accounts.admin_email
      to email
      subject 'Your e-mail is confirmed'
      body %Q{You have registered for accounts.test.

Follow this link to confirm your e-mail address: #{link}
      }
    end
  }

  config.deliver_change_password_link = ->(email, link) {
    Mail.deliver do
      from Accounts.admin_email
      to email
      subject 'How to change your password'
      body "Follow this link to change your password: #{link}"
    end
  }

  config.deliver_change_password_confirmation = ->(email) {
    Mail.deliver do
      from Accounts.admin_email
      to email
      subject 'Your password has changed'
      body "The password for #{email} has changed."
    end
  }

  config.deliver_change_email_confirmation = ->(old_email, new_email, link) {
    Mail.deliver do
      from Accounts.admin_email
      to new_email
      subject 'You requested to change your e-mail'
      body %Q{You have requested to change your e-mail to #{new_email}."

  You must visit this link to confirm: #{link}

  #{old_email} has also been sent a notification e-mail.
      }
    end
  }
  config.new_account_admin_notification = ->(email) {
    Mail.deliver do
      from Accounts.admin_email
      to Accounts.admin_email
      subject 'new account has confirmed e-mail'
      body "#{email} has registered and confirmed"
    end
  }

  config.deliver_change_email_notification = ->(old_email, new_email) {
    Mail.deliver do
      from Accounts.admin_email
      to old_email
      subject 'You requested to change your e-mail'
      body %Q{You have requested to change your e-mail to #{new_email}."

An e-mail has been sent to #{new_email}.

Please open that mail and follow the instructions.
      }
    end
  }
end

