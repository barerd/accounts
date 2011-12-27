# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2010

require 'data_mapper'
require 'dm-types/enum'
require 'dm-types/flag'
require 'digest/sha2'

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

    #@@logger = Logger.new(STDOUT)

    # override .save
    # @see http://blog.jayfields.com/2006/12/ruby-alias-method-alternative.html
    base_save = self.instance_method(:save)

    define_method(:save) do |*a|
      result = base_save.bind(self).call(*a)

      if !result then
        STDERR.puts "Cannot save #{self.class.to_s}"
        STDERR.puts self.pretty_inspect
        self.errors.each {|e| STDERR.puts e.to_s}
      end
      result
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

    @@digest = Digest::SHA2.new

    property :id, String, :key => true, :default => lambda { |res, tok| @@digest.hexdigest(rand.to_s) }
    property :action, String, :unique => :account 
    belongs_to :account
    property :expires, DateTime, :default => Time.new + 24 * 3600 # one day

    # override .save
    # @see http://blog.jayfields.com/2006/12/ruby-alias-method-alternative.html
    base_save = self.instance_method(:save)

    define_method(:save) do |*args|
      # If there is a previous instance, delete it
      if self.class.all *args then
        self.class.destroy *args
      end
      base_save.bind(self).call *args
    end
  end

end

DataMapper.finalize
DataMapper.auto_upgrade!  # preserve existing database
