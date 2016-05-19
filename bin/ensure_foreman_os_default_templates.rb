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
  os_default_templates = JSON.parse(File.open(options[:source]).read)
  os_default_templates.each do |os_name, default_templates|
    base_hammer_cmd = "#{HAMMER} os set-default-template '--id=#{os_name}'"
    default_templates.each do |default_template_params|
      hammer_cmd_parts = [ base_hammer_cmd ]
      default_template_params.each do |param_name, param_value|
        final_param_value = param_value
        if param_value.kind_of? Hash
          if param_value["command"]
            inner_hammer_cmd = param_value["command"]
            puts "command> Running #{inner_hammer_cmd}"
            final_param_value = `#{inner_hammer_cmd}`.chop
          end
        end
        hammer_cmd_parts.push("'--#{param_name}=#{final_param_value}'")
      end
      hammer_cmd = hammer_cmd_parts.join(" ")
      puts "Running #{hammer_cmd}"
      `#{hammer_cmd}`
    end
  end
end
