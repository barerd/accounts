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

    def self.send_mail_with_template(account, path)
      engine = MailRenderer.new File.read path
      #STDERR.puts engine.render(:link => email)
      tok = Authenticatable::ActionToken.create({ :account => account, :action => 'reset password' })
      link = "#{PROTOCOL}://#{SITE}/response-token/#{tok.id}"
      Mail.deliver do
        from ADMIN_EMAIL
        to account.email
        subject 'your registration to accounts.test'
        body engine.render(:link => link)
      end
    end

    def self.mail_registration_confirmation(account)
      self.send_mail_with_template account, 'lib/views/mail/register_confirm_mail.haml'
    end

    def self.mail_change_password_link(account)
      self.send_mail_with_template account, 'lib/views/mail/change_password_mail.haml'
    end

    def email_confirmed(token)
      token.account.status << :email_confirmed
      token.save
      Mail.deliver do
        from ADMIN_EMAIL
        to ADMIN_EMAIL
        subject 'new account has confirmed e-mail'
        body "#{token.account.email} has registered and confirmed"
      end
    end

    def respond_to_token(id)
      token = Authenticatable::ActionToken.get(id)

      if !token then
        raise Accounts::AccountsError.new 404, %Q{Page not found.  Go to <a href="/">home page</a>.}
      end

      if !token.account.status.include? :email_confirmed then
        email_confirmed token
      end

      case token.action
      when 'reset password' then
        redirect '/change-password'
      else
        nil
      end
      token.destroy
    end
  end
end
