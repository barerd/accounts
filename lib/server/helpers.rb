require 'model'

module Accounts
  module Helpers

    SITE ||= 'accounts.test' # may define outside before including
    PROTOCOL ||= 'http'

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
      mail = Mail.deliver do
        from  'admin@accounts.test'
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

    def respond_to_token(id)
      token = Authenticatable::ActionToken.get(id)
      case token.action
      when 'reset password' then
        redirect '/change-password'
      else
        nil
      end
    end
  end
end
