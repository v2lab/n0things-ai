# prepare AWS

require 'JSON'
require 'aws-sdk'

module N0
  CONFIG_PATH = 'data/n0-config.json'

  # load config...
  File.open(CONFIG_PATH, 'r') do |f|
    CONFIG = JSON.load f.readlines.join
  end

  def N0.db(admin=false)
    creds = CONFIG[if admin then 'simpledb_admin' else 'simpledb_access' end]
    AWS.config(:access_key_id => creds['access_key_id'],
               :secret_access_key => creds['secret_access_key'])
    AWS::SimpleDB.new
  end
end
