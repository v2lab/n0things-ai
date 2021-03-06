# prepare AWS

require 'json'
require 'aws-sdk'
require 'time'

module N0
  CONFIG_PATH = 'data/n0-config.json'

  # load config...
  begin
    File.open(CONFIG_PATH, 'r') do |f|
      CONFIG = (JSON.load f.readlines.join).merge({
        'files'=> {
          'ids'=> 'data/ids.csv',
          'shapes'=> 'data/shapes.csv',
          'weights'=> 'data/weights.csv',
          'clusters'=> 'data/clusters.csv',
          'clusters_json'=> 'data/clusters.json',
          'cache'=> 'data/shapes_cache.json'
        },
        'cached' => ['Timestamp','Contour','Color','HuMoments', 'DefectsCount']
      })
    end
  rescue SystemCallError => e
    puts "
I can't find the configuration file in 'data' directory.
Make sure VirtualBox shared folders are correctly set up.\n\n"
    exit 1
  end


  def N0.db(admin=false)
    creds = CONFIG[if admin then 'simpledb_admin' else 'simpledb_access' end]
    AWS.config(:access_key_id => creds['access_key_id'],
               :secret_access_key => creds['secret_access_key'])
    AWS::SimpleDB.new
  end

  def N0.timestamp(t = Time.now)
    t.utc.iso8601.gsub(%r{[-:.]},'')
  end

  def N0.load_json(tag)
    begin
      File.open( CONFIG['files'][tag], 'r' ) {|f| JSON.load f.readlines.join}
    rescue
      nil
    end
  end

  def N0.save_json(tag,obj)
    File.open( CONFIG['files'][tag],'w') {|f| f.puts JSON.pretty_generate obj}
  end

  def N0.decode(s)
    if s =~ /^\s*[\[{]/
      JSON.load s
    else
      s
    end
  end
end
