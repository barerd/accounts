$: << '../lib'

require 'rubygems'
require 'rspec'

# suppress excessive warnings from DataMapper libraries
$VERBOSE=nil
require 'accounts/model'
$VERBOSE=false

# Make sure we're still seeing warnings about our own code
FOO=:bar
FOO=:baz

begin
  DataMapper.auto_migrate!  # empty database
  STDERR.puts "called DataMapper.auto_migrate!"
end

describe Accounts::Account do

  it 'contains e-mails and passwords and flags' do
    account = Accounts::Account.create :email => "stewie@family.guy"
    account.should be_saved
    account.password.should be_nil
    account.status.should have(0).flags
    account.last_logon.should be_nil
    account.created_at.should_not be_nil
    account.updated_at.should_not be_nil
  end

  it 'cannot create account with duplicate e-mail' do
    account = Accounts::Account.create :email => "stewie@family.guy"
    account.should_not be_saved
  end

  it 'new user e-mail is initially invalid' do
    account = Accounts::Account.create :email => "lois@family.guy"
    #puts account.status.inspect
    account.status.include?(:email_confirmed).should be_false
    account.status.include?(:suspended).should be_false
  end

  it 'responds to .set_password' do
    account = Accounts::Account.create :email => "brian@family.guy"
    account.should respond_to :set_password
    account.set_password('hotforlois').should be_true
  end

  it 'can confirm password' do
    account = Accounts::Account.create :email => "peter@family.guy"
    account.set_password('notsosmart').should be_true
    account.confirm_password('notsosmart').should be_true
    account.confirm_password('notsobright').should be_false
  end

  it 'stores passwords as hashes' do
    Accounts::Account.all.each do |acct|
      if !acct.password.nil?
        acct.password.should be_instance_of String
        acct.password.length.should be == 64
        acct.password.should_not match(/[^0-9a-f]/)
      end
    end
  end
end

describe Accounts::ActionToken do
  before :all do
    @meg = Accounts::Account.create :email => 'meg@familyguy.com' 
    @chris = Accounts::Account.create :email => 'chris@familyguy.com' 
  end

  it 'can create a token for a user to perform a specific action' do
    tok = Accounts::ActionToken.create :account => @meg, :action => 'party' 
    tok.should be_saved
    tok.id.should be_instance_of String
    tok.id.length.should be == 64
    tok.id.should_not match(/[^0-9a-f]/)
  end

  it 'creating a new TokenAction for an action replaces any previous token' do
    tas = Accounts::ActionToken.all(:account => @meg, :action => 'party')
    tas.should_not be_nil
    tas.should have(1).item

    tok = Accounts::ActionToken.create :account => @meg, :action => 'party' 
    tok.should be_saved
    tok.id.should_not be == tas[0].id
  end

  it 'can return account and action given token' do
    tok = Accounts::ActionToken.create :account => @chris, :action => 'act stupid' 
    ta_found = Accounts::ActionToken.get(tok.id)
    ta_found.account.should be == @chris
    ta_found.action.should be == 'act stupid'
  end

  it 'has an expire date' do
    Accounts::ActionToken.all.each do |tok|
      tok.expires.should be_kind_of DateTime
      tok.expires.should > DateTime.new
    end
  end
end
