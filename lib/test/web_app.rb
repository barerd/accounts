# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

require 'accounts'
require 'accounts/model'
require 'sinatra/base'

class MyWebApp < Sinatra::Base
  use Accounts::Server;

  before do
  end

  get '/' do
    "Welcome visitor!"
  end

  get '/welcome' do
    account = Accounts::Account.get(session[:account_id]) or return 403
    "Welcome #{account.email}!"
  end

  get '/logon' do
    @email = params[:email] || ''
    haml :logon
  end

  get '/logout' do
    session[:account_id] = nil
    redirect to('/logon')
  end

  get '/register' do
    haml :register
  end

  get '/forgot-password' do
    haml :forgot_password
  end

  get '/change-password' do
    return 403 unless session[:account_id]
    haml :change_password
  end

  get '/change-email' do
    return 403 unless session[:account_id]
    haml :change_email
  end
end
