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

def get_os_by_name(os_name)
  hammer_cmd = "#{HAMMER} os info --title='#{os_name}'"
  hammer_out = `#{hammer_cmd}`
  begin
    os = JSON.parse(hammer_out)
    return os
  rescue
    return {}
  end
end

def create_or_update_os(os_name, desired_os_params, current_os)
  hammer_cmd_parts = [ "#{HAMMER} os" ]
  if current_os.empty?
    hammer_cmd_parts.push("create --name='#{os_name}'")
  end
  desired_major = desired_os_params["Major version"]
  if desired_major
    hammer_cmd_parts.push("--major=#{desired_major}")
  end
  hammer_cmd = hammer_cmd_parts.join(" ")
  hammer_out = `#{hammer_cmd}`
  puts hammer_out
end

if File.exists? options[:source]
  oses = JSON.parse(File.open(options[:source]).read)
  oses.each do |os_name, desired_os_params|
    current_os = get_os_by_name os_name
    is_updated = desired_os_params.all? do |key, val|
      current_os[key] == val
    end
    is_not_updated = !is_updated
    if is_not_updated or current_os.empty?
p desired_os_params
p current_os
      create_or_update_os(os_name, desired_os_params, current_os)
    end
  end
end
