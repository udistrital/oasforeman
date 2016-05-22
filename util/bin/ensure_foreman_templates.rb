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
  templates = JSON.parse(File.open(options[:source]).read)
  templates.each do |template_name, template_params|
    hammer_cmd = "#{HAMMER} template info '--name=#{template_name}'"
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
    hammer_cmd_parts = ["#{HAMMER} template"]
    if not $?.success?
      hammer_cmd_parts.push "create"
    else
      hammer_cmd_parts.push "update"
    end
    hammer_cmd_parts.push "'--name=#{template_name}'"
    template_params.each do |param_name, param_value|
      hammer_cmd_parts.push("'--#{param_name}=#{param_value}'")
    end
    hammer_cmd = hammer_cmd_parts.join(" ")
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
  end
end
