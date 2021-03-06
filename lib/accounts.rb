# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

require 'accounts/version'
require 'accounts/model'
require 'accounts/configure'
require 'accounts/helpers'

module Accounts

  class Server < ::Sinatra::Base

    helpers do
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
        halt 403
      end
    end

    post '/register' do
      email = params[:email]
      account = ::Accounts::Account.first({ :email => email })
      case
      when !account
        register_new_account email
        halt Accounts.post_register_new_account_response
      when account.status.include?(:email_confirmed)
        halt Accounts.post_register_already_registered_response[email]
      end
      send_change_password_link account
      Accounts.post_register_new_account_response
    end

    post '/forgot-password' do
      email = params[:email]
      account = ::Accounts::Account.first({ :email => email }) \
        or halt Accounts.post_forgot_password_email_does_not_match_response[email]
      send_change_password_link account
      Accounts.post_forgot_password_response
    end

    post '/change-password' do
      halt 403 unless session[:account_id]
      account = ::Accounts::Account.get(session[:account_id]) \
        or halt 403
      account.set_password params[:password]
      Accounts.deliver_change_password_confirmation[account.email]
      Accounts.changed_your_password_response
    end

    post '/change-email' do
      halt 403 unless session[:account_id]
      account = ::Accounts::Account.get(session[:account_id]) \
        or halt 403
      new_email = params[:email]
      ::Accounts::Account.count(:email => new_email) == 0 \
        or halt "#{new_email} is already taken"
      send_change_email_confirmation account, new_email
      Accounts.deliver_change_email_notification[account.email, new_email]
      Accounts.post_change_email_response
    end

    get '/response-token/:token' do
      respond_to_token params[:token]
    end
  end
end
