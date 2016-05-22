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
  oses = JSON.parse(File.open(options[:source]).read)
  oses.each do |os_title, os_params|
    hammer_cmd = "#{HAMMER} os info '--title=#{os_title}'"
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
    hammer_cmd_parts = ["#{HAMMER} os"]
    if not $?.success?
      hammer_cmd_parts.push "create"
    else
      hammer_cmd_parts.push "update '--title=#{os_title}'"
    end
    hammer_cmd_parts.push "'--description=#{os_title}'"
    os_params.each do |param_name, param_value|
      hammer_cmd_parts.push("'--#{param_name}=#{param_value}'")
    end
    hammer_cmd = hammer_cmd_parts.join(" ")
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
  end
end
