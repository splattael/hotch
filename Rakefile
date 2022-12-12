# frozen_string_literal: true

require "bundler/gem_tasks"

task default: :test

desc "Run tests. Not yet..."
task :test do
  abort "No tests yet. Sorry :-("
end

desc "Run examples"
namespace :test do
  desc "Run files in examples/"
  task :examples do
    chdir "examples" do
      ENV["HOTCH_VIEWER"] = nil

      Dir.glob("*.rb").sort.each do |file|
        puts "=" * 80
        sh "bundle", "exec", "ruby", file

        puts
      end
    end
  end
end
