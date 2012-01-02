# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)
require 'accounts/model'

module Accounts
  class Server < Sinatra::Base

    # TODO - This uses a cookie.
    # You might want to replace this with something like Rack::Session::Pool
    enable :sessions

    configure :development do
      Mail.defaults do
        delivery_method Mail::SingleFileDelivery::Agent, :filename => '/tmp/mail-test-fifo'
      end
    end

    configure :test do
      DataMapper.auto_migrate!  # empty database
      STDERR.puts "called DataMapper.auto_migrate!"

      Mail.defaults do
        delivery_method(:test)
        Mail::TestMailer.deliveries = MailStoreAgent.new
      end
    end

    helpers do
      require 'accounts/helpers.rb'
      include ::Accounts::Helpers
    end

    module Accounts
      class AccountsError; end
    end

    error ::Accounts::AccountsError do
      env['sinatra.error'].return_error_page
    end

    not_found do
      %Q{Page not found.  Go to <a href="home">home page</a>.}
    end

    error 403 do
      "Access denied"
    end

    post '/logon' do
      email = params[:email]
      password = params[:password]

      if authenticate! email, password then
        redirect to('/welcome')
      else
        session[:account_id] = nil
        return 403
      end
    end

    post '/register' do
      email = params[:email]
      account = ::Accounts::Account.first({ :email => email })
      case
      when !account
        register_new_account email
        return "Check your e-mail."
      when account.status.include?(:email_confirmed)
        return %Q{#{email} is already registered.  You may <a href="/logon?email=#{email}"log on</a>.}
      else
        send_change_password_link account
        return "#{email} has already registered.  Check your e-mail to set your password."
      end
    end

    post '/forgot-password' do
      email = params[:email]
      account = ::Accounts::Account.first({ :email => email }) \
        or return "#{email} does not match any account"
      send_change_password_link account
      "Check your e-mail to change your password."
    end

    post '/change-password' do
      return 403 unless session[:account_id]
      account = ::Accounts::Account.get(session[:account_id]) \
        or return 403
      account.set_password params[:password]
      send_change_password_confirmation account
      "You have changed your password."
    end

    post '/change-email' do
      return 403 unless session[:account_id]
      account = ::Accounts::Account.get(session[:account_id]) \
        or return 403
      new_email = params[:email]
      ::Accounts::Account.count(:email => new_email) == 0 \
        or return "#{new_email} is already taken"
      send_change_email_confirmation account, new_email
      send_change_email_notification account, new_email
      "Check your e-mail."
    end

    get '/response-token/:token' do
      respond_to_token params[:token]
    end
  end
end
