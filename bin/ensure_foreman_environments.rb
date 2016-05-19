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
  envs = JSON.parse(File.open(options[:source]).read)
  envs.each do |env_name, env_params|
    hammer_cmd = "#{HAMMER} environment info '--name=#{env_name}'"
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
    hammer_cmd_parts = ["#{HAMMER} environment"]
    if not $?.success?
      hammer_cmd_parts.push "create"
    else
      hammer_cmd_parts.push "update"
    end
    hammer_cmd_parts.push "'--name=#{env_name}'"
    env_params.each do |param_name, param_value|
      hammer_cmd_parts.push("'--#{param_name}=#{param_value}'")
    end
    hammer_cmd = hammer_cmd_parts.join(" ")
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
  end
end
