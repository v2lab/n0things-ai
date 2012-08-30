BEGIN {
  $LOAD_PATH << 'lib'
  require 'n0'
}

task :default do
  puts 'TODO what shouled we do by default?'
end

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
      shapes.each do |shape|
        printf "%d/%d %s\n", i, shapes.count, shape.name
        i += 1
        ids_file.puts shape.name
        lst = [ JSON.load(shape.attributes[:HuMoments].values[0]),
                JSON.load(shape.attributes[:Color].values[0]),
                JSON.load(shape.attributes[:VertexCount].values[0]),
                JSON.load(shape.attributes[:DefectsCount].values[0]) ].flatten
        shapes_file.puts lst.join("\t")
      end
    end
  end
end

desc 'perform clustring'
task :cluster do
  system 'octave octave/cluster.m'
end
