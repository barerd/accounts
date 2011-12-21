$: << ::File.dirname(__FILE__) + '../lib'
ENV['DEVEL'] = '1'

require 'rubygems'
require 'rspec'
require 'model'

describe Authenticatable::Account do

  it 'contains e-mails and passwords and flags' do
    account = Authenticatable::Account.new ({:email => "stewie@foo.bar"})
account.save
    account.should be_saved
    account.password.should be_nil
    account.status.should be_nil
    account.last_logon.should be_nil
    account.created_at.should_not be_nil
    account.updated_at.should_not be_nil
  end

  it 'new user e-mail is initially invalid' do
    pending
  end

  it 'stores passwords as hashes' do
    pending
  end

  it 'can confirm password' do
    pending
  end
end

describe Authenticatable::ActionToken do

  it 'contains account id and confirmation tokens' do
    pending
  end

  it 'can create a token for a specific action' do
    pending
  end

  it 'creating a new token for an action removes any previous token' do
    pending
  end

  it 'can return account and action given token' do
    pending
  end

  it 'has an expire date' do
    pending
  end
end
