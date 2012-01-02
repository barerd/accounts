# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)
require 'accounts/model'

module Accounts
  class << self 
    attr_accessor :page_not_found
    attr_accessor :redirect_after_logon
    attr_accessor :post_forgot_password_response
    attr_accessor :changed_your_password_response
    attr_accessor :post_register_new_account_response 
    attr_accessor :post_register_new_account_again_response  # Proc(email)
    attr_accessor :post_register_already_registered_response # Proc(email)
    attr_accessor :post_forgot_password_email_does_not_match_response  # Proc(email)
    attr_accessor :post_change_email_response

    def configure
      yield self
    end
  end

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

    error ::Accounts::AccountsError do
      env['sinatra.error'].return_error_page
    end

    post '/logon' do
      email = params[:email]
      password = params[:password]

      if authenticate! email, password then
        redirect to Accounts.redirect_after_logon
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
        return Accounts.post_register_new_account_response
      when account.status.include?(:email_confirmed)
        return Accounts.post_register_already_registered_response[email]
      else
        send_change_password_link account
        return Accounts.post_register_new_account_again_response[email]
      end
    end

    post '/forgot-password' do
      email = params[:email]
      account = ::Accounts::Account.first({ :email => email }) \
        or return Accounts.post_forgot_password_email_does_not_match_response
      send_change_password_link account
      Accounts.post_forgot_password_response
    end

    post '/change-password' do
      return 403 unless session[:account_id]
      account = ::Accounts::Account.get(session[:account_id]) \
        or return 403
      account.set_password params[:password]
      send_change_password_confirmation account
      Accounts.changed_your_password_response
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
      Accounts.post_change_email_response
      "Check your e-mail."
    end

    get '/response-token/:token' do
      respond_to_token params[:token]
    end
  end
end

Accounts.configure do |config|
  config.changed_your_password_response = "You have changed your password."
  config.redirect_after_logon = "/welcome"
  config.post_register_new_account_response = "Check your e-mail."
  config.post_register_new_account_again_response = ->(email) {
    "#{email} has already registered.  Check your e-mail to set your password."
  }
  config.post_register_already_registered_response = ->(email) {
    %Q{#{email} is already registered.  You may <a href="/logon?email=#{email}"log on</a>.}
  }
  config.post_forgot_password_response = "Check your e-mail to change your password."
  config.post_forgot_password_email_does_not_match_response = ->(email) {
    "#{email} does not match any account" 
  }
  config.post_change_email_response = "Check your e-mail."
end
