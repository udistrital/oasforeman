require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "open-uri"

RSpec::Core::RakeTask.new(:spec)

task :default => nil

file 'tmp/vagrant_1.8.1_x86_64.rpm' do |file_task|
  File.open(file_task.to_s, "wb") do |file|
    begin
      open("https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm", "rb") do |content|
        begin
          file.write(content.read)
        rescue => e
          raise "Bajando archivo #{e}"
        end
      end
    rescue => e
      raise "Abriendo archivo tmp #{e}"
    end
  end
end

namespace :docker do
  task :build => ['tmp/vagrant_1.8.1_x86_64.rpm'] do
    system "docker", "build", "-t", "foo", "."
  end
end
