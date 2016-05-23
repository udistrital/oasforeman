#!/usr/bin/env ruby

require "optparse"
require "facter"

options = { :ip => "" }
OptionParser.new do |opts|
  opts.on("--ip=", "IP address") do |value|
    options[:ip] = value
  end
end.parse!

begin
  Facter[:interfaces].value.split(",").each do |interface|
    begin
      if Facter["ipaddress_#{interface}".to_sym].value == options[:ip]
        puts interface
        exit 0
      end
    rescue
      next
    end
  end
  STDERR.puts "interface not found"
  exit 1
rescue => e
  STDERR.puts e
  exit 2
end
