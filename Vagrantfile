# -*- mode: ruby -*-
# vi: set ft=ruby :

require "open-uri"
require "json"

if not File.exists? "tmp"
  FileUtils.mkdir_p "tmp"
end

proxy = ENV["http_proxy"] || ""

# general foreman settings
foreman_ip = "192.168.12.42"
foreman_hostname = "foreman1"
foreman_local_domain = "oas.local"
foreman_fqdn = "#{foreman_hostname}.#{foreman_local_domain}"

# settings for provisioning with foreman
foreman_provision_ip = "192.168.12.42"
foreman_provision_network = "192.168.12.0"
foreman_provision_mask = "255.255.255.0"
foreman_provision_domain = "oas.local"
foreman_provision_domains = [ foreman_provision_domain ].join(",")
foreman_provision_reverse_zone = "12.168.192.in-addr.arpa"
foreman_provision_subnet_name = "oas-local"
foreman_provision_range = "192.168.12.201 192.168.12.250"
foreman_provision_gateway = "192.168.12.1"

# foreman installer options for first run
foreman_installer_options_1 = [
  "-v",
  "--detailed-exitcodes",
  "--enable-foreman-compute-ovirt",
  "--enable-foreman-compute-ec2",
  "--foreman-foreman-url='https://#{foreman_fqdn}'",
  "--puppet-server-git-repo=true",
  "--enable-foreman-plugin-bootdisk",
  "--enable-foreman-proxy",
  "--foreman-proxy-tftp=true",
  "--foreman-proxy-tftp-servername='#{foreman_provision_ip}'",
  "--foreman-proxy-dhcp=true",
  "--foreman-proxy-dhcp-interface=\"$(/usr/local/bin/get_interface.sh -i '#{foreman_provision_ip}')\"",
  "--foreman-proxy-dhcp-gateway=",
  "--foreman-proxy-dhcp-range=' '",
  "--foreman-proxy-dhcp-nameservers=\"$(/usr/local/bin/get_nameserver.sh)\"",
  "--foreman-proxy-dns=true",
  "--foreman-proxy-dns-interface=$(/usr/local/bin/get_interface.sh -i '#{foreman_provision_ip}')",
  "--foreman-proxy-dns-zone='#{foreman_provision_domain}'",
  "--foreman-proxy-dns-reverse='#{foreman_provision_reverse_zone}'",
  "--foreman-proxy-dns-forwarders=$(/usr/local/bin/get_nameserver.sh)",
  "--foreman-proxy-foreman-base-url='https://#{foreman_fqdn}'",
]

# foreman installer options for second run
foreman_installer_options_2 = foreman_installer_options_1 + [
  "--foreman-proxy-oauth-consumer-key=$(sudo /usr/local/bin/get_foreman_answer.rb --classname foreman --param oauth_consumer_key)",
  "--foreman-proxy-oauth-consumer-secret=$(sudo /usr/local/bin/get_foreman_answer.rb --classname foreman --param oauth_consumer_secret)",
]

foreman_installer_command_1 = "sudo foreman-installer #{foreman_installer_options_1.join(" ")}"
foreman_installer_command_2 = "sudo foreman-installer #{foreman_installer_options_2.join(" ")}"

hosts_content = <<-EOF
127.0.0.1     localhost localhost.localdomain localhost4 localhost4.localdomain4
::1           localhost localhost.localdomain localhost6 localhost6.localdomain6
#{foreman_ip} #{foreman_fqdn} #{foreman_hostname}
EOF

hosts_file = File.open("tmp/hosts", "w")
hosts_file.write(hosts_content)
hosts_file.close

domains_content = {
  foreman_local_domain => {},
  "vagrant.local" => {},
}

domains_file = File.open("tmp/foreman_domains.json", "w")
domains_file.write(JSON.generate(domains_content))
domains_file.close

subnets_content = {
  foreman_provision_subnet_name => {
    "network" => foreman_provision_network,
    "mask"    => foreman_provision_mask,
    "domains" => foreman_provision_domains,
    "dhcp-id" => { "command" => "hammer --output=json proxy info --name #{foreman_fqdn}|/usr/local/bin/jq .Id" }, # quieres mejorar esto?
    "dns-id" => { "command" => "hammer --output=json proxy info --name #{foreman_fqdn}|/usr/local/bin/jq .Id" },
    "tftp-id" => { "command" => "hammer --output=json proxy info --name #{foreman_fqdn}|/usr/local/bin/jq .Id" },
  },
  "vagrant-local" => {
    "network" => "192.168.156.0",
    "mask"    => "255.255.254.0",
    "domains" => "vagrant.local",
  },
}

subnets_file = File.open("tmp/foreman_subnets.json", "w")
subnets_file.write(JSON.generate(subnets_content))
subnets_file.close

environments_content = {
  "production" => {}, # included by default
  "plataforma" => {},
  "desarrollo" => {},
  "pruebas" => {},
  "produccion" => {},
}

environments_file = File.open("tmp/foreman_environments.json", "w")
environments_file.write(JSON.generate(environments_content))
environments_file.close

models_content = {
  "VirtualBox" => {},
  "Sun V125" => {},
}

models_file = File.open("tmp/foreman_models.json", "w")
models_file.write(JSON.generate(models_content))
models_file.close

architectures_content = {
  "i386" => {},
  "x86_64" => {},
}

architectures_file = File.open("tmp/foreman_architectures.json", "w")
architectures_file.write(JSON.generate(architectures_content))
architectures_file.close

hostgroups_content = {
  "grupo-oas" => {
    "architecture" => "x86_64",
    "domain" => foreman_provision_domain,
    "medium" => "CentOS mirror", # sujeto a cambio en cuanto se tenga katello
    "operatingsystem" => "CentOS 7.2",
    "partition-table" => "Kickstart default",
    "puppet-ca-proxy" => foreman_fqdn,
    "puppet-proxy" => foreman_fqdn,
    "root-pass" => "oasmaster",
    "subnet" => foreman_provision_subnet_name,
  },
  "grupo-plataforma" => {
    "environment" => "plataforma",
    "parent" => "grupo-oas",
  },
  "grupo-desarrollo" => {
    "environment" => "desarrollo",
    "parent" => "grupo-oas",
  },
  "grupo-pruebas" => {
    "environment" => "pruebas",
    "parent" => "grupo-oas",
  },
  "grupo-produccion" => {
    "environment" => "produccion",
    "parent" => "grupo-oas",
  },
#  --puppet-class-ids PUPPETCLASS_IDS      List of puppetclass ids
#                                          Comma separated list of values.
#  --puppet-classes PUPPET_CLASS_NAMES     Comma separated list of values.
#  --puppet-proxy PUPPET_PROXY_NAME        Name of puppet proxy
#  --puppet-proxy-id PUPPET_PROXY_ID       Puppet proxy ID
#  --realm REALM_NAME                      Name to search by => (inclusión sujeta a cambio cuando segun disponibilidad de freeipa)
#  --realm-id REALM_ID                     Numerical ID or realm name
}

hostgroups_file = File.open("tmp/foreman_hostgroups.json", "w")
hostgroups_file.write(JSON.generate(hostgroups_content))
hostgroups_file.close

oses_content = {
  "CentOS 7.0" => {
      "name" => "CentOS",
      "major" => "7",
      "minor" => "0",
      "architectures" => "i386,x86_64",
      "family" => "Redhat",
      "media" => "CentOS mirror",
      "partition-tables" => "Kickstart default",
      "provisioning-templates" => "Kickstart default PXELinux,Kickstart default,Kickstart default finish,Kickstart default user data,Kickstart default iPXE",
      "config-templates" => "Kickstart default PXELinux,Kickstart default,Kickstart default finish,Kickstart default user data,Kickstart default iPXE",
  },
  "CentOS 7.1" => {
      "name" => "CentOS",
      "major" => "7",
      "minor" => "1",
      "architectures" => "i386,x86_64",
      "family" => "Redhat",
      "media" => "CentOS mirror",
      "partition-tables" => "Kickstart default",
      "provisioning-templates" => "Kickstart default PXELinux,Kickstart default,Kickstart default finish,Kickstart default user data,Kickstart default iPXE",
      "config-templates" => "Kickstart default PXELinux,Kickstart default,Kickstart default finish,Kickstart default user data,Kickstart default iPXE",
  },
  "CentOS 7.2" => {
      "name" => "CentOS",
      "major" => "7",
      "minor" => "2",
      "architectures" => "i386,x86_64",
      "family" => "Redhat",
      "media" => "CentOS mirror",
      "partition-tables" => "Kickstart default",
      "provisioning-templates" => "Kickstart default PXELinux,Kickstart default,Kickstart default finish,Kickstart default user data",
      "config-templates" => "Kickstart default PXELinux,Kickstart default,Kickstart default finish,Kickstart default user data",
  },
}

oses_file = File.open("tmp/foreman_oses.json", "w")
oses_file.write(JSON.generate(oses_content))
oses_file.close

# get jq if needed
if not File.exists? "tmp/jq-linux64"
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
  # provision ram and cpu
  config.vm.provider "virtualbox" do |vbox|
    vbox.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    vbox.memory = 4096
    vbox.cpus = 2
  end

  # install jq
  config.vm.provision "file", source: "tmp/jq-linux64", destination: "/tmp/jq-linux64"
  config.vm.provision "shell", name: "install jq 1/3", inline: "sudo chown -v root:root /tmp/jq-linux64"
  config.vm.provision "shell", name: "install jq 2/3", inline: "sudo chmod -v +x /tmp/jq-linux64"
  config.vm.provision "shell", name: "install jq 3/3", inline: "sudo mv -v /tmp/jq-linux64 /usr/local/bin/jq"

  # host naming
  config.vm.hostname = foreman_fqdn
  config.vm.provision "file", source: hosts_file.path, destination: "/tmp/hosts"
  config.vm.provision "shell", name: "host naming 1/2", inline: "sudo tee /etc/hosts < /tmp/hosts"
  config.vm.provision "shell", name: "host naming 2/2", inline: "rm -v /tmp/hosts"

  # tools
  config.vm.provision "file", source: "bin", destination: "/tmp"
  config.vm.provision "shell", name: "tools 1/3", inline: "sudo chown -v root:root /tmp/bin/*"
  config.vm.provision "shell", name: "tools 2/3", inline: "sudo mv -v /tmp/bin/* /usr/local/bin"
  config.vm.provision "shell", name: "tools 3/3", inline: "rm -rv /tmp/bin"

  # environment
  config.vm.provision "shell", name: "environment 1/2", inline: "/usr/local/bin/set_environment.sh -n http_proxy -v '#{proxy}'"
  config.vm.provision "shell", name: "environment 2/2", inline: "/usr/local/bin/set_environment.sh -n https_proxy -v '#{proxy}'"

  # foreman provision
  config.vm.provision "shell", name: "foreman provision 1/3", inline: "if test ! -f /etc/yum.repos.d/puppetlabs.repo; then sudo rpm -iv http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm; fi"
  config.vm.provision "shell", name: "foreman provision 2/3", inline: "sudo yum -y -v install epel-release http://yum.theforeman.org/releases/1.11/el7/x86_64/foreman-release.rpm"
  config.vm.provision "shell", name: "foreman provision 3/3", inline: "sudo yum -y -v install foreman-installer"

  # foreman install, execute thrice (or maybe twice) to ensure convergency
  config.vm.provision "shell", name: "foreman install", inline: "#{foreman_installer_command_1};#{foreman_installer_command_2}||#{foreman_installer_command_2}"

  # puppet run, execute twice to ensure convergency
  config.vm.provision "shell", name: "puppet run", inline: "sudo puppet agent --test;sudo puppet agent --test"

  # foreman domains provision
  config.vm.provision "file", source: domains_file.path, destination: "/tmp/foreman_domains.json"
  config.vm.provision "shell", name: "domains 1/2", inline: "sudo /usr/local/bin/ensure_foreman_domains.rb --source /tmp/foreman_domains.json"
  config.vm.provision "shell", name: "domains 2/2", inline: "rm -v /tmp/foreman_domains.json"

  # foreman subnets provision
  config.vm.provision "file", source: subnets_file.path, destination: "/tmp/foreman_subnets.json"
  config.vm.provision "shell", name: "subnets 1/2", inline: "sudo /usr/local/bin/ensure_foreman_subnets.rb --source /tmp/foreman_subnets.json"
  config.vm.provision "shell", name: "subnets 2/2", inline: "rm -v /tmp/foreman_subnets.json"

  # foreman environments provision
  config.vm.provision "file", source: environments_file.path, destination: "/tmp/foreman_environments.json"
  config.vm.provision "shell", name: "environments 1/2", inline: "sudo /usr/local/bin/ensure_foreman_environments.rb --source /tmp/foreman_environments.json"
  config.vm.provision "shell", name: "environments 2/2", inline: "rm -v /tmp/foreman_environments.json"

  # foreman architectures provision
  config.vm.provision "file", source: architectures_file.path, destination: "/tmp/foreman_architectures.json"
  config.vm.provision "shell", name: "architectures 1/2", inline: "sudo /usr/local/bin/ensure_foreman_architectures.rb --source /tmp/foreman_architectures.json"
  config.vm.provision "shell", name: "architectures 2/2", inline: "rm -v /tmp/foreman_architectures.json"

  # foreman models provision
  config.vm.provision "file", source: models_file.path, destination: "/tmp/foreman_models.json"
  config.vm.provision "shell", name: "models 1/2", inline: "sudo /usr/local/bin/ensure_foreman_models.rb --source /tmp/foreman_models.json"
  config.vm.provision "shell", name: "models 2/2", inline: "rm -v /tmp/foreman_models.json"

  # foreman oses provision
  config.vm.provision "file", source: oses_file.path, destination: "/tmp/foreman_oses.json"
  config.vm.provision "shell", name: "oses 1/2", inline: "sudo /usr/local/bin/ensure_foreman_oses.rb --source /tmp/foreman_oses.json"
  config.vm.provision "shell", name: "oses 2/2", inline: "rm -v /tmp/foreman_oses.json"

  # foreman hostgroups provision
  config.vm.provision "file", source: hostgroups_file.path, destination: "/tmp/foreman_hostgroups.json"
  config.vm.provision "shell", name: "hostgroups 1/2", inline: "sudo /usr/local/bin/ensure_foreman_hostgroups.rb --source /tmp/foreman_hostgroups.json"
  config.vm.provision "shell", name: "hostgroups 2/2", inline: "rm -v /tmp/foreman_hostgroups.json"

  # generate pxe
  config.vm.provision "shell", name: "generate pxe", inline: "sudo hammer template build-pxe-default"
end
