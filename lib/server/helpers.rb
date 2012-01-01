require 'model'

module Accounts
  module Helpers
    class Accounts::AccountsError < Exception
      attr_accessor :code
      attr_accessor :message

      def initialize(code, message)
        @code = code
        @message = message
      end

      def return_error_page
        [ @code, @message ]
      end
    end

    ADMIN_EMAIL ||= 'admin@accounts.test'

    def site
      scheme = request.env['rack.url_scheme']
      host = request.env['HTTP_HOST'] # includes port number
      "#{scheme}://#{host}"
    end

    def send_registration_confirmation(account)
      tok = Authenticatable::ActionToken.create({ :account => account, :action => 'reset password' })
      link = "#{site}/response-token/#{tok.id}"
      Mail.deliver do
        from ADMIN_EMAIL
        to account.email
        subject 'Your e-mail is confirmed'
        body %Q{You have registered for accounts.test.

Follow this link to confirm your e-mail address: #{link}
        }
      end
    end

    def send_change_password_link(account)
      tok = Authenticatable::ActionToken.create({ :account => account, :action => 'reset password' })
      link = "#{site}/response-token/#{tok.id}"
      Mail.deliver do
        from ADMIN_EMAIL
        to account.email
        subject 'How to change your password'
        body "Follow this link to change your password: #{link}"
      end
      #STDERR.puts "Sent change password link to #{account.email}"
    end

    def send_change_password_confirmation(account)
      Mail.deliver do
        from ADMIN_EMAIL
        to account.email
        subject 'Your password has changed'
        body "The password for #{account.email} has changed."
      end
    end

    def send_change_email_confirmation(account, new_email)
      tok = Authenticatable::ActionToken.create({ 
        :account => account,
        :action => 'change email',
        :params => {:new_email => new_email}
      })
      link = "#{site}/response-token/#{tok.id}"
      Mail.deliver do
        from ADMIN_EMAIL
        to new_email
        subject 'You requested to change your e-mail'
        body %Q{You have requested to change your e-mail to #{new_email}."

You must visit this link to confirm: #{link}

#{account.email} has also been sent a notification e-mail.
        }
      end
    end

    def send_change_email_notification(account, new_email)
      Mail.deliver do
        from ADMIN_EMAIL
        to account.email
        subject 'You requested to change your e-mail'
        body %Q{You have requested to change your e-mail to #{new_email}."

An e-mail has been sent to #{new_email}.

Please open that mail and follow the instructions.
        }
      end
    end

    def on_email_confirmed(account)
      account.status << :email_confirmed
      account.taint! :status  # taint!() defined in model.rb
      account.save
      Mail.deliver do
        from ADMIN_EMAIL
        to ADMIN_EMAIL
        subject 'new account has confirmed e-mail'
        body "#{account.email} has registered and confirmed"
      end
    end

    def respond_to_token(id)
      token = Authenticatable::ActionToken.get(id)

      raise Accounts::AccountsError.new 404, %Q{Page not found.  Go to <a href="/">home page</a>.} \
        unless token

      begin
        on_email_confirmed token.account \
          unless token.account.status.include? :email_confirmed

        case token.action
        when 'change email' then
          token.account.email = token.params[:new_email]
          token.account.save or return "We are unable to change your e-mail right now.  Try again later."
          session[:account_id] = token.account.id # this visitor is authenticated
          redirect to("/logon?email=#{token.params[:new_email]}")
        when 'reset password' then
          session[:account_id] = token.account.id # this visitor is authenticated
          redirect '/change-password'
        else
          nil
        end
      ensure
        token.destroy or raise "Failed to destroy token #{token.id}"
      end
    end

    def authenticate!(email, password)
      account = Authenticatable::Account.first(:email => email) \
        or return false
      account.confirm_password(password) or return false
      session[:account_id] = account.id
    end

    def register_new_account(email)
      account = Authenticatable::Account.create ({ :email => email })
      account.saved? or return "We are unable to register you at this time.  Please try again later."
      send_registration_confirmation account
    end
  end
end
