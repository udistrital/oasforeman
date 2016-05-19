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
  subnets = JSON.parse(File.open(options[:source]).read)
  subnets.each do |subnet_name, subnet_params|
    hammer_cmd = "#{HAMMER} subnet info '--name=#{subnet_name}'"
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
    hammer_cmd_parts = ["#{HAMMER} subnet"]
    if not $?.success?
      hammer_cmd_parts.push "create"
    else
      hammer_cmd_parts.push "update"
    end
    hammer_cmd_parts.push "'--name=#{subnet_name}'"
    subnet_params.each do |param_name, param_value|
      if param_value.kind_of? Hash
        if param_value["command"]
          inner_hammer_cmd = param_value["command"]
          puts "command> Running #{inner_hammer_cmd}"
          final_param_value = `#{inner_hammer_cmd}`.chop
        end
      else
        final_param_value = param_value
      end
      hammer_cmd_parts.push("'--#{param_name}=#{final_param_value}'")
    end
    hammer_cmd = hammer_cmd_parts.join(" ")
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
  end
end
