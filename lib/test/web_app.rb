# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

$: << './lib'

require 'rubygems'
require 'bundler'
Bundler.require(:test)
require 'accounts'

class MyWebApp < Sinatra::Base
  use Accounts::Server;

  DataMapper.auto_migrate!  # empty database
  STDERR.puts "WARNING: called DataMapper.auto_migrate! to clear database"

  enable :logging

  # Web app class must define this.
  # In a production environment you might want to replace this with something like Rack::Session::Pool
  enable :sessions

  not_found do
    %Q{Page not found.  Go to <a href="home">home page</a>.}
  end

  error 403 do
    "Access denied"
  end

  get '/' do
    %Q{Welcome visitor!  Please <a href="/logon">log on</a>.}
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

  if app_file == $0
    STDERR.puts "Running standalone"
    # Run as stand-along web app
    Mail.defaults do
      delivery_method Mail::SingleFileDelivery::Agent, :filename => '/tmp/mail-test-fifo'
    end
    require 'sinatra/reloader'
    register Sinatra::Reloader
    enable :reloader
    run!
  else
    # Probably running under Cucumber
    Mail.defaults do
      delivery_method(:test)
      Mail::TestMailer.deliveries = MailStoreAgent.new
    end
  end
end
