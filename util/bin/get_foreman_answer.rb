#!/usr/bin/env ruby

require "optparse"
require "yaml"

options = { :classname => "", :param => "" }
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
  foreman_answer_class = foreman_answers[options[:classname]]
  if foreman_answer_class
    puts foreman_answer_class[options[:param]]
  end
end
