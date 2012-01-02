# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

module Accounts
  module Helpers
    class ::Accounts::AccountsError < Exception
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

    def site
      scheme = request.env['rack.url_scheme']
      host = request.env['HTTP_HOST'] # includes port number
      "#{scheme}://#{host}"
    end

    def send_change_password_link(account)
      tok = ::Accounts::ActionToken.create({ :account => account, :action => 'reset password' })
      link = "#{site}/response-token/#{tok.id}"
      Accounts.deliver_change_password_link[account.email, link]
    end

    def send_change_email_confirmation(account, new_email)
      tok = ::Accounts::ActionToken.create({ 
        :account => account,
        :action => 'change email',
        :params => {:new_email => new_email}
      })
      link = "#{site}/response-token/#{tok.id}"
      Accounts.deliver_change_email_confirmation[account.email, new_email, link]
    end

    def on_email_confirmed(account)
      account.status << :email_confirmed
      account.taint! :status  # taint!() defined in model.rb
      account.save
      Accounts.deliver_new_account_admin_notification[account.email]
    end

    def respond_to_token(id)
      token = ::Accounts::ActionToken.get(id)

      raise ::Accounts::AccountsError.new 404, %Q{Page not found.  Go to <a href="/">home page</a>.} \
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
      account = ::Accounts::Account.first(:email => email) \
        or return false
      account.confirm_password(password) or return false
      session[:account_id] = account.id
    end

    def register_new_account(email)
      account = ::Accounts::Account.create ({ :email => email })
      account.saved? or return "We are unable to register you at this time.  Please try again later."
      tok = ::Accounts::ActionToken.create({ :account => account, :action => 'reset password' })
      link = "#{site}/response-token/#{tok.id}"
      Accounts.deliver_registration_confirmation[account.email, link]
    end
  end
end
