#---
# Excerpted from "Getting Clojure",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
#---
SUB_DIRS = []

def add_all(a, other)
  other.each {|x| a << x}
end

def lein_run(subdir)
  sub_run(subdir, 'lein run')
end

def lein_test(subdir)
  sub_run(subdir, 'lein test')
end

def sub_rake(subdir)
  sub_run(subdir, 'rake')
end

def sub_run(subdir, cmd)
  task :subdirs => subdir

  task subdir do
    cd subdir do
      sh cmd
    end
  end
end

def boot_runtest
  task :this do
    sh "boot runtest"
  end
end

# desc "Run the tests in this sub directories"
# task :subdirs do
#   SUB_DIRS.each do |sd|
#     puts "Doing subdir #{sd}"
#     cd(sd) do
#       sh "rake"
#     end
#   end
# end

task :this

task :subdirs

task :default => [:this, :subdirs]

desc "Run the boot repl"
task :repl do
  sh 'boot repl'
end

