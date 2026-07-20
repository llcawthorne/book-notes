Dirs = %w{
  capable def destructuring functional hello interop lazy let 
  logic macro map namespace read record sequences spec state test thread vector}



puts Dirs
puts "#{Dirs.count} subdirectories"

def rake(dir, *args)
  sargs = args.map {|x| x.to_s}

  puts
  puts
  puts "Building #{dir}"
  puts "===================="
  puts
  Dir.chdir(dir) do
    ruby "-S", "rake", *sargs
  end
end

task :default do
  Dirs.each {|d| rake d, :default}
end

task :runtest do
  Dirs.each do |d|
    Dir.chdir(d) do
      puts 
      puts d
      sh "boot runtest"
    end
  end
end

