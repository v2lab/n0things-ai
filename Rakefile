BEGIN {
  $LOAD_PATH << 'lib'
  require 'n0'
  require 'securerandom'
  require 'csv'
}

task :default => :help

#desc 'list SimpleDB domains and some metadata'
task :list_db do
  db = N0.db(:admin)
  db.domains.each do |domain|
    p domain
    p domain.metadata.to_h
  end
end

desc 'fetch newest submissions'
task :fetch do
  # First load local cache
  puts "Loading local cache"
  cache = N0.load_json('cache') || {}
  # find latest timestamp
  latest = cache.values.map{|v|v["Timestamp"]}.max
  puts "Most recent cached timestamp: #{latest}"
  # but let's distrust that for now...
  cache_dirty = false

  begin
    puts "Requesting the most recently uploaded shapes"
    db = N0.db() # not an admin
    shapes = db.domains['Shape'].items.
      where('Timestamp is not null'). # FIXME query later than latest with some margin
      order(:Timestamp,:desc).
      limit(N0::CONFIG['clustering_sample_size'])
    count = shapes.count
    w = Math.log10(count+1).ceil
    shapes.each_with_index do |shape,i|
      printf "%#{w}d/%d %s\n",i+1,count,shape.name
      if cache.has_key? shape.name
        puts " -- using cached record"
        next
      end
      h = shape.attributes.to_h
      cache[shape.name] = {}
      N0::CONFIG['cached'].each do |k|
        cache[shape.name][k] = N0.decode h[k][0]
      end
      cache_dirty = true
    end
  rescue SocketError
    puts "Network error, no new data\nUsing local cache"
  end

  if cache.size > N0::CONFIG['clustering_sample_size']
    puts "Discarding the oldest cached records"
    cache_dirty = true
    cache_shift while cache.size > N0::CONFIG['clustering_sample_size']
  end

  if cache_dirty
    puts "Updating local cache"
    N0.save_json 'cache', cache
  end

  puts "Format data tables for the clusterer"
  File.open(N0::CONFIG['files']['ids'], 'w') do |ids_file|
    File.open(N0::CONFIG['files']['shapes'], 'w') do |shapes_file|
      cache.each do |id, rec|
        ids_file.puts id
        lst = [ rec['HuMoments'], rec['Color'], rec['Contour'].size, rec['DefectsCount'].to_i].flatten
        shapes_file.puts lst.join("\t")
      end
    end
  end
  exit 0
end

desc 'perform clustering'
task :cluster do
  system 'octave octave/cluster.m'
end

desc 'upload cluster generation'
task :upload do
  timestamp = N0.timestamp
  ids = CSV.read(N0::CONFIG['files']['ids']).map{|x| x[0]}
  clusters = CSV.read(N0::CONFIG['files']['clusters'], col_sep: "\t")
  weights = CSV.read(N0::CONFIG['files']['weights'], col_sep: "\t")[0].map{|x| x.to_f}
  weights = JSON.generate weights

  db = N0.db() # not an admin
  gen_items = db.domains['Generation'].items
  clu_items = db.domains['Cluster'].items

  clusters.each do |cluster_array|
    rep = ids[ cluster_array[0].to_i - 1 ]
    centroid = JSON.generate cluster_array[1..-1].map{|x| x.to_f}
    id = SecureRandom.uuid
    puts "            Id: #{id}"
    puts "    Generation: #{timestamp}"
    puts "      Centroid: #{centroid}"
    puts "Representative: #{rep}"
    puts

    clu_items.create( id,
                     Generation: timestamp,
                     Centroid: centroid,
                     Representative: rep )
  end

  puts "Generation: #{timestamp}"
  puts "   Mapping: #{weights}"
  puts

  gen_items.create( timestamp,
                   Timestamp: timestamp,
                   Mapping: weights )

end

desc 'update the software from github'
task :self_update do
  system 'git pull'
end

task :help do
  system 'rake -T'
end
