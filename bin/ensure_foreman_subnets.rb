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

def get_domain_ids
  hammer_cmd = "#{HAMMER} domain list"
  hammer_out = `#{hammer_cmd}`
  domains = JSON.parse(hammer_out)
  domains.map {|domain| domain["Id"]}
end

def get_subnet_by_name(subnet_name)
  hammer_cmd = "#{HAMMER} subnet list --search 'name = #{subnet_name}'"
  hammer_out = `#{hammer_cmd}`
  subnets = JSON.parse(hammer_out)
  if subnets.size == 1
    subnet_domains = []
    get_domain_ids.each do |domain_id|
      hammer_cmd = "#{HAMMER} domain info --id #{domain_id}"
      hammer_out = `#{hammer_cmd}`
      domain_info = JSON.parse(hammer_out)
      domain_subnets = domain_info["Subnets"]
      if domain_subnets
        domain_subnets.each do |domain_subnet|
          subnet_domains.push(domain_info["Name"]) if domain_subnet["name"] == subnet_name
        end
      end
    end
    subnet_domains.sort!
    subnet_domains_info = { "Domains" => subnet_domains.join(",") }
    return subnets.first.merge subnet_domains_info
  elsif subnets.size == 0
    return {}
  else
    raise "Subnet name '#{subnet_name}' matches more than 1 subnet"
  end
end

def create_or_update_subnet(subnet_name, desired_subnet_params, current_subnet)
  hammer_cmd_parts = [ "#{HAMMER}", "subnet" ]
  if current_subnet.empty?
    hammer_cmd_parts.push("create --name=#{subnet_name}")
  else
    hammer_cmd_parts.push("update --id=#{current_subnet["Id"]}")
  end
  desired_network = desired_subnet_params["Network"]
  desired_mask = desired_subnet_params["Mask"]
  desired_domains = desired_subnet_params["Domains"]
  if desired_network
    hammer_cmd_parts.push("--network=#{desired_network}")
  end
  if desired_mask
    hammer_cmd_parts.push("--mask=#{desired_mask}")
  end
  if desired_domains
    hammer_cmd_parts.push("--domains=#{desired_domains}")
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
    if is_not_updated or current_subnet.empty?
      create_or_update_subnet(subnet_name, desired_subnet_params, current_subnet)
    end
  end
end
