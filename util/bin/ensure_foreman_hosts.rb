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
  show_output = false
  hosts = JSON.parse(File.open(options[:source]).read)
  hosts.each do |host_name, host_params|
    hammer_cmd = "#{HAMMER} host info '--name=#{host_name}'"
    puts "Running #{hammer_cmd}"
    `#{hammer_cmd}`
    hammer_cmd_parts = ["#{HAMMER} host"]
    if not $?.success?
      hammer_cmd_parts.push "create '--name=#{host_name.split(".")[0]}'"
    else
      # hammer_cmd_parts.push "update '--name=#{host_name}'" - actualizar un host es complejo
      hammer_cmd_parts.pop
      hammer_cmd_parts.push "echo hammer host update '--name=#{host_name}'"
      STDERR.puts "Updating a host is complex and is not supported yet!"
      STDERR.puts "if you want to use this as the method of provision"
      STDERR.puts "delete the host and re-provision again"
      STDERR.puts "or execute the 'hammer host update' command bellow"
      STDERR.puts "after removing the problematic parts"
      show_output = true
    end
    host_params.each do |param_name, param_value|
      if param_value.kind_of? Array
        param_value.each do |internal_params|
          inner_hammer_cmd_parts = []
          if internal_params.kind_of? Hash
            internal_params.each do |internal_param_name, internal_param_value|
              if internal_param_value.kind_of? Hash
                if internal_param_value["command"]
                  inner_hammer_cmd = internal_param_value["command"]
                  puts "command>> Running #{inner_hammer_cmd}"
                  inner_hammer_out = `#{inner_hammer_cmd}`.chop
                  inner_hammer_cmd_parts.push("#{internal_param_name}=#{inner_hammer_out}")
                end
              else
                inner_hammer_cmd_parts.push("#{internal_param_name}=#{internal_param_value}")
              end
            end
          else
            raise "An array of non-hashes is unsupported"
          end
          hammer_cmd_parts.push("'--#{param_name}=#{inner_hammer_cmd_parts.join(",")}'")
        end
      else
        hammer_cmd_parts.push("'--#{param_name}=#{param_value}'")
      end
    end
    hammer_cmd = hammer_cmd_parts.join(" ")
    puts "Running #{hammer_cmd}"
    if show_output
      puts `#{hammer_cmd}`
    else
      `#{hammer_cmd}`
    end
  end
end
