#!/usr/bin/env ruby

require "optparse"
require "yaml"

options = {}
OptionParser.new do |opts|
  opts.on("--classname=", "Class Name") do |value|
    options[:classname] = value
  end
  opts.on("--param=", "Parameter") do |value|
    options[:param] = value
  end
end.parse!

foreman_answers_file = "/etc/foreman-installer/scenarios.d/foreman-answers.yaml"

if File.exists? foreman_answers_file
  foreman_answers = YAML.load(open(foreman_answers_file).read)
  puts foreman_answers[options[:classname]][options[:param]]
end
