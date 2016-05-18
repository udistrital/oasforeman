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

def get_subnet_by_name(subnet_name)
  hammer_cmd = "#{HAMMER} subnet list --search 'name = #{subnet_name}'"
  hammer_out = `#{hammer_cmd}`
  subnets = JSON.parse(hammer_out)
  if subnets.size == 1
    return subnets.first
  elsif subnets.size == 0
    return {}
  else
    raise "Subnet name '#{subnet_name}' matches more than 1 subnet"
  end
end

def create_or_update_subnet(subnet_name, desired_subnet_params, current_subnet)
  hammer_cmd_parts = [ "#{HAMMER}", "subnet" ]
  if current_subnet == {}
    hammer_cmd_parts.push("create --name=#{subnet_name}")
  else
    hammer_cmd_parts.push("update --id=#{current_subnet["Id"]}")
  end
  desired_network = desired_subnet_params["Network"]
  desired_mask = desired_subnet_params["Mask"]
  if desired_network
    hammer_cmd_parts.push("--network=#{desired_network}")
  end
  if desired_mask
    hammer_cmd_parts.push("--mask=#{desired_mask}")
  end
  hammer_cmd = hammer_cmd_parts.join(" ")
  hammer_out = `#{hammer_cmd}`
  puts hammer_out
end

if File.exists? options[:source]
  subnets = JSON.parse(File.open(options[:source]).read)
  subnets.each do |subnet_name, desired_subnet_params|
    current_subnet = get_subnet_by_name subnet_name
    is_updated = desired_subnet_params.all? do |key, val|
      current_subnet[key] == val
    end
    is_not_updated = !is_updated
    if is_not_updated
      create_or_update_subnet(subnet_name, desired_subnet_params, current_subnet)
    end
  end
end
