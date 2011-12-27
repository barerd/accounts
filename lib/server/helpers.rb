require 'mail'
require 'haml'
require 'mail-store-agent'
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

    def self.mail_registration_confirmation(email)
      engine = MailRenderer.new File.read('lib/views/mail/register_confirm_mail.haml')
      #STDERR.puts engine.render(:link => email)
      account = Authenticatable::Account.create ({ :email => email })
      tok = Authenticatable::ActionToken.create({ :account => account, :action => 'reset password' })
      link = "#{PROTOCOL}://#{SITE}/response-token/#{tok.id}"
      mail = Mail.deliver do
        from  'admin@accounts.test'
        to email
        subject 'your registration to accounts.test'
        body engine.render(:link => link)
      end
    end
  end
end
