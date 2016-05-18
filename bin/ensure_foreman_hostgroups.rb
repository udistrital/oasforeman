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

def get_hostgroup_by_name(hostgroup_name)
  hammer_cmd = "#{HAMMER} hostgroup list --search 'name = #{hostgroup_name}'"
  hammer_out = `#{hammer_cmd}`
  hostgroups = JSON.parse(hammer_out)
  if hostgroups.size == 1
    return hostgroups.first
  elsif hostgroups.size == 0
    return {}
  else
    raise "Hostgroup name '#{hostgroup_name}' matches more than 1 hostgroup"
  end
end

def create_or_update_hostgroup(hostgroup_name, desired_hostgroup_params, current_hostgroup)
  hammer_cmd_parts = [ "#{HAMMER} hostgroup" ]
  if current_hostgroup.empty?
    hammer_cmd_parts.push("create --name=#{hostgroup_name}")
  end
  hammer_cmd = hammer_cmd_parts.join(" ")
  hammer_out = `#{hammer_cmd}`
  puts hammer_out
end

if File.exists? options[:source]
  hostgroups = JSON.parse(File.open(options[:source]).read)
  hostgroups.each do |hostgroup_name, desired_hostgroup_params|
    current_hostgroup = get_hostgroup_by_name hostgroup_name
    is_updated = desired_hostgroup_params.all? do |key, val|
      current_hostgroup[key] == val
    end
    is_not_updated = !is_updated
    if is_not_updated or current_hostgroup.empty?
      create_or_update_hostgroup(hostgroup_name, desired_hostgroup_params, current_hostgroup)
    end
  end
end
