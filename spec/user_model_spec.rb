require 'rubygems'
require 'rspec'

$: << ::File.dirname(__FILE__) + '../lib'

require 'model'

describe Authenticatable::Account do

  it 'contains e-mails and passwords and flags' do
    pending
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
