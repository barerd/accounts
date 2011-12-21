# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2010

require 'data_mapper'
require 'dm-types/enum'
require 'dm-types/flag'
require 'digest/sha1'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres:accounts')
DataMapper::Property::String.length(255)
DataMapper::Property::Boolean.allow_nil(false)
DataMapper::Property::Boolean.default(false)

#DataMapper::Model.raise_on_save_failure = true

#=begin
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
        self.errors.each {|e| STDERR.puts e.to_s}
      end
    end
  end
end
#=end

module Authenticatable

  class Account
    include DataMapper::Resource
    property :id, Serial
    property :email, String, :unique => true
    property :password, String, :required => false # a hash
    property :status, Flag[:suspended, :email_confirmed]
    property :last_logon, DateTime, :required => false
    timestamps :created_at
    timestamps :updated_at

    def set_password(arg)
      self.update({ :password =>  hashish(arg)})
    end

    def confirm_password(arg)
      hashish(arg) == self.password
    end

    private

    @@digest = Digest::SHA2.new
    SALT = 'b593b7bf01cd29d9cc15d11f9d81f586e255fd252fab264129e6046934876c23' # random

    # Can't name this "hash".  Name already taken.
    def hashish(arg)
      @@digest.hexdigest(SALT + arg)
    end
  end

  # An action-token represents permission for the agent to perform an action on behalf of a user.
  class ActionToken
    include DataMapper::Resource
    property :token, String, :key => true
    belongs_to :account
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
