# -*- mode: ruby -*-
# vi: set ft=ruby :

require "open-uri"

proxy = ENV["http_proxy"] || ""

local_domain = "oas.local"
foreman_ip = "192.168.12.42"
foreman_hostname = "foreman1"
foreman_fqdn = "#{foreman_hostname}.#{local_domain}"
oauth_consumer_key = "wingaethe6dah0ohcemipu3aiduu7Ue5"
oauth_consumer_secret = "aum7ohh8Kahm6ooj9lae6pi0roapaira"
reverse_zone = "12.168.192.in-addr.arpa"

foreman_installer_options = [
  "-v",
  "--detailed-exitcodes",
  "--enable-foreman-compute-ovirt",
  "--enable-foreman-compute-ec2",
  "--enable-foreman-plugin-puppetdb",
  "--foreman-foreman-url=https://#{foreman_fqdn}",
  "--enable-foreman-proxy",
  "--foreman-proxy-tftp=true",
  "--foreman-proxy-tftp-servername=#{foreman_ip}",
  "--foreman-proxy-dhcp=true",
  "--foreman-proxy-dhcp-interface=$(/usr/local/bin/get_interface.sh -i #{foreman_ip})",
  "--foreman-proxy-dhcp-gateway=",
  "--foreman-proxy-dhcp-range=",
  "--foreman-proxy-dhcp-nameservers=$(/usr/local/bin/get_nameserver.sh)",
  "--foreman-proxy-dns=true",
  "--foreman-proxy-dns-interface=$(/usr/local/bin/get_interface.sh -i #{foreman_ip})",
  "--foreman-proxy-dns-zone=#{local_domain}",
  "--foreman-proxy-dns-reverse=#{reverse_zone}",
  "--foreman-proxy-dns-forwarders=$(/usr/local/bin/get_nameserver.sh)",
  "--foreman-proxy-foreman-base-url=https://#{foreman_fqdn}",
  "--foreman-proxy-oauth-consumer-key=#{oauth_consumer_key}",
  "--foreman-proxy-oauth-consumer-secret=#{oauth_consumer_secret}",
]

foreman_installer_command = "sudo foreman-installer #{foreman_installer_options.join(" ")}"

puts "Foreman Installer Command: #{foreman_installer_command}"

hosts_content = <<-EOF
127.0.0.1     localhost localhost.localdomain localhost4 localhost4.localdomain4
::1           localhost localhost.localdomain localhost6 localhost6.localdomain6
#{foreman_ip} #{foreman_fqdn} #{foreman_hostname}
EOF

hosts_file = Tempfile.new("hosts")
hosts_file.write(hosts_content)
hosts_file.close

# get jq if needed
if not File.exists? "tmp/jq-linux64"
  FileUtils.mkdir_p "tmp"
  puts "Getting jq"
  File.open("tmp/jq-linux64", "wb") do |local_jq|
    open("https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64", "rb") do |remote_jq|
     local_jq.write(remote_jq.read)
    end
  end
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "centos-7.2"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.2_chef-provisionerless.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: foreman_ip #nic2

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  # put host-only nic in promiscuous mode
  config.vm.provider "virtualbox" do |vbox|
    vbox.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
  end

  # install jq
  config.vm.provision "file", source: "tmp/jq-linux64", destination: "/tmp/jq-linux64"
  config.vm.provision "shell", inline: "sudo chown -v root:root /tmp/jq-linux64"
  config.vm.provision "shell", inline: "sudo chmod -v +x /tmp/jq-linux64"
  config.vm.provision "shell", inline: "sudo mv -v /tmp/jq-linux64 /usr/local/bin/jq"

  # host naming
  config.vm.hostname = foreman_fqdn
  config.vm.provision "file", source: hosts_file.path, destination: "/tmp/hosts"
  config.vm.provision "shell", inline: "sudo tee /etc/hosts < /tmp/hosts"
  config.vm.provision "shell", inline: "rm -v /tmp/hosts"

  # host tools
  config.vm.provision "file", source: "bin", destination: "/tmp"
  config.vm.provision "shell", inline: "sudo chown -v root:root /tmp/bin/*"
  config.vm.provision "shell", inline: "sudo mv -v /tmp/bin/* /usr/local/bin"
  config.vm.provision "shell", inline: "rm -rv /tmp/bin"

  # set environment
  config.vm.provision "shell", inline: "/usr/local/bin/set_environment.sh -n http_proxy -v '#{proxy}'"
  config.vm.provision "shell", inline: "/usr/local/bin/set_environment.sh -n https_proxy -v '#{proxy}'"

  # foreman provision
  config.vm.provision "shell", inline: "if test ! -f /etc/yum.repos.d/puppetlabs.repo; then sudo rpm -iv http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm; fi"
  config.vm.provision "shell", inline: "sudo yum -y -v install epel-release http://yum.theforeman.org/releases/1.11/el7/x86_64/foreman-release.rpm"
  config.vm.provision "shell", inline: "sudo yum -y -v install foreman-installer"

  # foreman install, execute twice to ensure convergency
  config.vm.provision "shell", inline: "#{foreman_installer_command};#{foreman_installer_command}"

end
