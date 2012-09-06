BEGIN {
  $LOAD_PATH << 'lib'
  require 'n0'
  require 'securerandom'
  require 'csv'
}

task :default => :help

desc 'list SimpleDB domains and some metadata'
task :list_db do
  db = N0.db(:admin)
  db.domains.each do |domain|
    p domain
    p domain.metadata.to_h
  end
end

desc 'fetch newest submissions'
task :fetch do
  db = N0.db() # not an admin
  shapes = db.domains['Shape'].items.
    where('Timestamp is not null').
    order(:Timestamp,:desc).
    limit(N0::CONFIG['clustering_sample_size'])

  i = 1
  File.open(N0::CONFIG['files']['ids'], 'w') do |ids_file|
    File.open(N0::CONFIG['files']['shapes'], 'w') do |shapes_file|
      File.open(N0::CONFIG['files']['shapes_json'], 'w') do |shapes_json|
        shapes_json.puts "{"
        shapes.each do |shape|
          puts "#{i}/#{shapes.count} #{shape.name}"
          ids_file.puts shape.name
          lst = [ JSON.load(shape.attributes[:HuMoments].values[0]),
                  JSON.load(shape.attributes[:Color].values[0]),
                  JSON.load(shape.attributes[:VertexCount].values[0]),
                  JSON.load(shape.attributes[:DefectsCount].values[0]) ].flatten
          shapes_file.puts lst.join("\t")

          # save contour / color in json file
          shapes_json.puts "'#{shape.name}' : {"
          shapes_json.puts "'contour': #{shape.attributes[:Contour].values[0]}, "
          shapes_json.puts "'color': #{shape.attributes[:Color].values[0]} "
          if i < shapes.count
            shapes_json.puts "},"
          else
            shapes_json.puts "}"
          end
          i += 1
        end
        shapes_json.puts "}"
      end
    end
  end
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
