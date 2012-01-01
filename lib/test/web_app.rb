# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

require 'accounts'
require 'accounts/model'
require 'sinatra/base'

class MyWebApp < Sinatra::Base
  use Accounts::Server;

  before do
  end

  get '/welcome' do
    account = Accounts::Account.get(session[:account_id]) or return 403
    "Welcome #{account.email}"
  end
end
