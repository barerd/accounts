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

    SITE ||= 'accounts.test' # may define outside before including
    PROTOCOL ||= 'http'
    ADMIN_EMAIL ||= 'admin@' + SITE

    class MailRenderer < Haml::Engine

      @@const_vars = Object.new
      @@const_vars.instance_variable_set(:@site, SITE)

      def render(locals) 
        super(@@const_vars, locals)
      end
    end

    Mail.defaults do
      delivery_method :test # don't use '='!
      Mail::TestMailer.deliveries = MailStoreAgent.new
    end

    def self.send_mail_with_template(account, path, *params)
      engine = MailRenderer.new File.read path
      #STDERR.puts engine.render(:link => email)
      Mail.deliver do
        from ADMIN_EMAIL
        to account.email
        subject 'your registration to accounts.test'
        body engine.render *params
      end
    end

    def self.mail_registration_confirmation(account)
      tok = Authenticatable::ActionToken.create({ :account => account, :action => 'reset password' })
      link = "#{PROTOCOL}://#{SITE}/response-token/#{tok.id}"
      self.send_mail_with_template account, 'lib/views/mail/register_confirm_mail.haml', :link => link
    end

    def self.mail_change_password_link(account)
      tok = Authenticatable::ActionToken.create({ :account => account, :action => 'reset password' })
      link = "#{PROTOCOL}://#{SITE}/response-token/#{tok.id}"
      self.send_mail_with_template account, 'lib/views/mail/change_password_mail.haml', :link => link
    end

    def self.mail_change_password_confirmation(account)
      self.send_mail_with_template account, 'lib/views/mail/change_password_confirm_mail.haml', \
        :email => account.email
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
      account = Authenticatable::Account.first(:email => email) or return false
      session[:account_id] = account.id
    end
  end
end
