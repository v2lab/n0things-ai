# prepare AWS

require 'JSON'
require 'aws-sdk'

module N0
  CONFIG_PATH = 'data/n0-aws-credentials.json'
  File.open(CONFIG_PATH, 'r') do |f|
    CONFIG = JSON.load f.readlines.join
  end
end

creds = N0::CONFIG['simpledb_access']
puts creds.inspect

AWS.config(:access_key_id => creds['access_key_id'],
           :secret_access_key => creds['secret_access_key'])

# load n0things classes if any...
