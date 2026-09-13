if Rake::Task.task_defined?("spec")
  namespace :spec do
    desc "Run the full spec suite, including system specs"
    task :all do
      ENV["INCLUDE_SYSTEM"] = "1"
      Rake::Task["spec"].invoke
    end
  end
end
