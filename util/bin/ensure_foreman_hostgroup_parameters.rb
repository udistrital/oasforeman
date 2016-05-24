#!/usr/bin/env ruby

require "optparse"
require "json"

options = { :source => "" }
HAMMER = "hammer --output=json"

OptionParser.new do |opts|
  opts.on("--source=", "JSON File") do |value|
    options[:source] = value
  end
end.parse!

if File.exists? options[:source]
  hostgroup_params = JSON.parse(File.open(options[:source]).read)
  hostgroup_params.each do |hg_name, hg_params|
    hammer_cmd_base = "#{HAMMER} hostgroup set-parameter '--hostgroup=#{hg_name}'"
    hg_params.each do |hg_param|
      hammer_cmd_parts = [ hammer_cmd_base ]
      hg_param.each do |hg_param_name, hg_param_value|
        hammer_cmd_parts.push("'--#{hg_param_name}=#{hg_param_value}'")
      end
      hammer_cmd = hammer_cmd_parts.join(" ")
      puts "Running #{hammer_cmd}"
      `#{hammer_cmd}`
    end
  end
end
