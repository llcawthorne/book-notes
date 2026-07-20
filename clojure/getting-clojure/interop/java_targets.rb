#---
# Excerpted from "Getting Clojure",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
#---
JavaSources = FileList.new('*.java')

JUnitJar = '../../../jars/junit-4.12.jar'

ClassPath = "classes"

directory "classes"


task :compile_java => JavaSources + ["classes"]  do
  sh "javac -d classes -classpath #{ClassPath} #{JavaSources.join(' ')}"
end

task :clean do
  rm_rf "classes"
end

def run_java_class(clazz)
  sh "java  -enableassertions -classpath #{ClassPath} #{clazz}"
end
