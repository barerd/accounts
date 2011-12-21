# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2010

require 'data_mapper'
require 'dm-types/enum'
require 'dm-types/flag'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres:accounts')
DataMapper::Property::String.length(255)
DataMapper::Property::Boolean.allow_nil(false)
DataMapper::Property::Boolean.default(false)

DataMapper::Model.raise_on_save_failure = true

# Override definition in dm-core / lib / dm-core / resource.rb
# http://github.com/datamapper/dm-core/blob/master/lib/dm-core/resource.rb
# Get it to log messages when there is a problem saving.
module DataMapper
  module Resource

    alias_method :orig_save, :save
    #@@logger = Logger.new(STDOUT)

    def save(*a)
      begin
        orig_save(*a)
      rescue
        STDERR.puts "Cannot save instance of #{self.class.to_s}"
        STDERR.puts self.pretty_inspect
        self.errors.each {|e| puts e.to_s}
        #raise "Cannot save instance of #{self.class.to_s}"
      end
    end
  end
end

module Authenticatable

  class Account
    include DataMapper::Resource
    property :id, Serial
    has n, :action_tokens
    property :email, String, :required => true
    property :password, String, :required => true # a hash
    property :status, Enum[:suspended, :email_confirmed]
    property :last_logon, DateTime
    timestamps :updated_at
  end

  # An action-token represents permission for the agent to perform an action on behalf of a user.
  class ActionToken
    include DataMapper::Resource
    property :token, String, :key => true
    has 1, :account
    property :action, String, :unique => :account
    property :expires, DateTime, :default => Time.new + 24 * 3600 # one day
  end

end

DataMapper.finalize

if ENV['DEVEL'] then
  DataMapper.auto_migrate!  # empty database
else
  DataMapper.auto_upgrade!  # preserve existing database
end
