$: << ::File.dirname(__FILE__) + '../lib'
ENV['DEVEL'] = '1'

require 'rubygems'
require 'rspec'
require 'model'

describe Authenticatable::Account do

  it 'contains e-mails and passwords and flags' do
    account = Authenticatable::Account.create ({:email => "stewie@family.guy"})
    account.should be_saved
    account.password.should be_nil
    account.status.should have(0).flags
    account.last_logon.should be_nil
    account.created_at.should_not be_nil
    account.updated_at.should_not be_nil
  end

  it 'cannot create account with duplicate e-mail' do
    account = Authenticatable::Account.create ({:email => "stewie@family.guy"})
    account.should_not be_saved
  end

  it 'new user e-mail is initially invalid' do
    account = Authenticatable::Account.create ({:email => "lois@family.guy"})
    #puts account.status.inspect
    account.status.include?(:email_confirmed).should be_false
    account.status.include?(:suspended).should be_false
  end

  it 'responds to .set_password' do
    account = Authenticatable::Account.create ({:email => "brian@family.guy"})
    account.respond_to? :set_password
    account.set_password('hotforlois').should be_true
  end

  it 'can confirm password' do
    account = Authenticatable::Account.create ({:email => "peter@family.guy"})
    account.set_password('notsosmart').should be_true
    account.confirm_password('notsosmart').should be_true
    account.confirm_password('notsobright').should be_false
  end

  it 'stores passwords as hashes' do
    Authenticatable::Account.all.each do |acct|
      if !acct.password.nil?
        acct.password.is_a? String
        acct.password.length == 64
        acct.password !~ /[0-9a-f]/
      end
    end
  end
end

describe Authenticatable::ActionToken do
  before (:all) do
    @meg = Authenticatable::Account.create({ :email => 'meg@familyguy.com' })
    @chris = Authenticatable::Account.create({ :email => 'chris@familyguy.com' })
  end

  it 'can create a token for a user to perform a specific action' do
    token = Authenticatable::ActionToken.create({ :account => @meg, :action => 'party' })
    token.should be_saved
    token.id.is_a? String
    token.id.length == 64
    token.id !~ /[0-9a-f]/
  end

  it 'creating a new token for an action removes any previous token' do
    tokens = Authenticatable::ActionToken.all(:account => @meg, :action => 'party')
    tokens.should_not be_nil
    tokens.should have(1).item

    token = Authenticatable::ActionToken.create({ :account => @meg, :action => 'party' })
    token.should be_saved
    token.id.should_not == tokens[0].id
  end

  it 'can return account and action given token' do
    pending
  end

  it 'has an expire date' do
    pending
  end
end
