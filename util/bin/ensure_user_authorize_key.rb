#!/usr/bin/env ruby

#    foreman.vm.provision "shell", name: "git 2/5", inline: "sudo -u git mkdir -pv /home/git/.ssh"
#    foreman.vm.provision "shell", name: "git 3/5", inline: "sudo chmod -v 700 /home/git/.ssh"
#    foreman.vm.provision "shell", name: "git 4/5", inline: "sudo -u git touch /home/git/.ssh/authorized_keys"
#    foreman.vm.provision "shell", name: "git 5/5", inline: "sudo chmod -v 600 /home/git/.ssh/authorized_keys"

require "optparse"
require "json"
require "fileutils"

options = { :user => "", :authorize_key => "" }
OptionParser.new do |opts|
  opts.on("--user=", "System user") do |value|
    options[:user] = value
  end
  opts.on("--authorize-key=", "id_rsa.pub file") do |value|
    options[:authorize_key] = value
  end
end.parse!

home_dir = nil
File.open("/etc/passwd", "r") do |passwd|
  passwd.read.lines.each do |line|
    user = line.split(":")
    if user[0] == options[:user]
      home_dir = user[5]
      break
    end
  end
end

if home_dir
  ssh_dir = "#{home_dir}/.ssh"
  if not File.exists? ssh_dir
    FileUtils.mkdir_p ssh_dir
    FileUtils.chown options[:user], nil, ssh_dir
    FileUtils.chmod 0700, ssh_dir
  end
  authorized_keys = "#{ssh_dir}/authorized_keys"
  if not File.exists? authorized_keys
    FileUtils.touch authorized_keys
    FileUtils.chown options[:user], nil, authorized_keys
    FileUtils.chmod 0600, authorized_keys
  end
  authorized = false
  File.open(authorized_keys, "r") do |pub_keys|
    pub_keys.read.lines.each do |line|
      if line == File.open(options[:authorize_key]).read
        authorized = true
        break
      end
    end
  end
  if not authorized
    File.open(authorized_keys, "a") do |pub_key|
      pub_key.write File.open(options[:authorize_key]).read + "\n"
    end
  end
end
