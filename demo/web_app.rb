# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

require 'rubygems'

# runtime
require 'sinatra/base'
require 'data_mapper'
require 'dm-types'
require 'dm-timestamps'
require 'dm-postgres-adapter'
require 'mail'
require 'logger'
require 'accounts'

# development
require 'mail-store-agent'
require 'mail-single_file_delivery'
require 'haml'
require 'pp'

DataMapper.auto_migrate!  # empty database
STDERR.puts "WARNING: called DataMapper.auto_migrate! to clear database"

class MyWebApp < Sinatra::Base

  use ::Accounts::Server;

    if app_file == $0
      # Invoced as a stand-along web app

      Mail.defaults do
        delivery_method Mail::SingleFileDelivery::Agent, :filename => '/tmp/mail-test-fifo'
      end
      STDERR.puts "Mail messages are going to /tmp/mail-test-fifo"
    else
      # Probably running under Cucumber

      Mail.defaults do
        delivery_method(:test)
        Mail::TestMailer.deliveries = MailStoreAgent.new
      end
      STDERR.puts "Mail messages are going to Mail::TestMailer.deliveries for access by test scripts"
    end

  configure do

    enable :logging

    # Web app class that uses Accounts::Server must define this.

    # This does not work
=begin
  use Rack::Session::Cookie, :key => 'rack.session',
    :path => '/',
    :expire_after => 14400, # In seconds
    :secret => 'secret_stuff'
=end
    enable :sessions # this breaks with Rack 1.4.0

    if app_file == $0
      require 'sinatra/reloader'
      register Sinatra::Reloader
      enable :reloader
    end
  end

  before do
    #STDERR.puts session.inspect
  end

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

  run! if !running? && app_file == $0
end
