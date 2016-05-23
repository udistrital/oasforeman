# -*- mode: ruby -*-
# vi: set ft=ruby :

require "open-uri"
require "json"

if not File.exists? "tmp"
  FileUtils.mkdir_p "tmp"
end

proxy = "#{ENV["http_proxy"]}"
puppet_environment = "desarrollo"
hiera_repo = "https://github.com/andresvia/oashiera.git"
puppet_repo = "https://github.com/andresvia/oaspuppet.git"

# general foreman settings
foreman_ip = "192.168.12.42"
foreman_hostname = "foreman1"
foreman_local_domain = "oas.local"

# general katello settings
katello_ip = "192.168.12.40"
katello_hostname = "katello1"
katello_local_domain = "oas.local"

# configuraciones del home base de katello (es multi-homed)
katello_base_hostname = "katello1"
katello_base_domain = "oas.local"
katello_base_subnet_name = "virtualbox-local"
katello_base_network = "10.0.2.0"
katello_base_mask = "255.255.255.0"
katello_base_ip = "10.0.2.15"
katello_base_interface = "enp0s3"
katello_base_mac = "0A5C0DE50001" # OAS Codes 0001

# settings for provisioning with foreman
foreman_provision_ip = "192.168.12.42"
foreman_provision_network = "192.168.12.0"
foreman_provision_mask = "255.255.255.0"
foreman_provision_domain = "oas.local"
foreman_provision_reverse_zone = "12.168.192.in-addr.arpa"
foreman_provision_subnet_name = "oas-local"
foreman_provision_range = "192.168.12.201 192.168.12.250"
foreman_provision_extra_domains = [] # esta vacio por la naturaleza de aprovisionamiento en local para dev
foreman_provision_gateway = "" # de haber un router a internet en la zona de aprovisionamiento iria aquí

# settings to get katello provisioned by foreman
katello_provision_domain = "oas.local"
katello_provision_ip = "192.168.12.40"
katello_provision_interface = "enp0s8"
katello_provision_mac = "0A5C0DE50002" # OAS Codes 0002

# calculated settings
# foreman
foreman_provision_domains_parts = ([ foreman_provision_domain ] + foreman_provision_extra_domains)
foreman_provision_domains = foreman_provision_domains_parts.join(",")
foreman_fqdn = "#{foreman_hostname}.#{foreman_local_domain}"
foreman_remote_access = foreman_ip # o foreman_fqdn
foreman_url = "https://#{foreman_remote_access}"
foreman_proxy_puppet_url = "https://#{foreman_remote_access}:8140/"
foreman_proxy_template_url = "http://#{foreman_remote_access}:8000/"
# katello
katello_fqdn = "#{katello_hostname}.#{katello_local_domain}"
katello_provision_fqdn = katello_fqdn

# foreman installer options for first run
foreman_installer_options_1 = [
  "--detailed-exitcodes",
  "--enable-foreman-compute-ovirt",
  "--enable-foreman-compute-ec2",
  "--foreman-foreman-url='#{foreman_url}'",
  "--puppet-server-git-repo=true",
  "--enable-foreman-plugin-bootdisk",
  "--enable-foreman-proxy",
  "--foreman-proxy-tftp=true",
  "--foreman-proxy-tftp-servername='#{foreman_provision_ip}'",
  "--foreman-proxy-dhcp=true",
  "--foreman-proxy-dhcp-interface=\"$(/usr/local/bin/get_interface.rb --ip '#{foreman_provision_ip}')\"",
  "--foreman-proxy-dhcp-gateway='#{foreman_provision_gateway}'",
  "--foreman-proxy-dhcp-range='#{foreman_provision_range}'",
  "--foreman-proxy-dhcp-nameservers='#{foreman_provision_ip}'",
  "--foreman-proxy-dns=true",
  "--foreman-proxy-dns-interface=$(/usr/local/bin/get_interface.rb --ip '#{foreman_provision_ip}')",
  "--foreman-proxy-dns-zone='#{foreman_provision_domain}'",
  "--foreman-proxy-dns-reverse='#{foreman_provision_reverse_zone}'",
  "--foreman-proxy-dns-forwarders=$(/usr/local/bin/get_nameserver.sh)",
  "--foreman-proxy-foreman-base-url='#{foreman_url}'",
  "--foreman-proxy-template-url=#{foreman_proxy_template_url}",
  "--foreman-proxy-puppet-url='#{foreman_proxy_puppet_url}'",
  "--puppet-server-foreman-url='#{foreman_url}'",
  "--puppet-environment=#{puppet_environment}",
  "--puppet-server-git-repo-user=git",
  "--puppet-server-git-repo-group=git",
  "--puppet-server-git-repo-mode=0755",
  "--puppet-server-git-repo-path=/home/git/puppet.git",
]

# foreman installer options for second run (link proxy)
foreman_installer_options_2 = foreman_installer_options_1 + [
  "--foreman-proxy-oauth-consumer-key=$(sudo /usr/local/bin/get_foreman_answer.rb --classname foreman --param oauth_consumer_key)",
  "--foreman-proxy-oauth-consumer-secret=$(sudo /usr/local/bin/get_foreman_answer.rb --classname foreman --param oauth_consumer_secret)",
]

foreman_installer_command_1 = "sudo foreman-installer #{foreman_installer_options_1.join(" ")}"
foreman_installer_command_2 = "sudo foreman-installer #{foreman_installer_options_2.join(" ")}"

etc_hosts_content = <<-EOF
127.0.0.1     localhost localhost.localdomain localhost4 localhost4.localdomain4
::1           localhost localhost.localdomain localhost6 localhost6.localdomain6
#{foreman_ip} #{foreman_fqdn} #{foreman_hostname}
#{katello_ip} #{katello_fqdn} #{katello_hostname}
EOF

etc_hosts_file = File.open("tmp/hosts", "w")
etc_hosts_file.write(etc_hosts_content)
etc_hosts_file.close

domains_content = {
  foreman_local_domain => {
    "dns" => foreman_ip,
  },
}

extra_domains_content = foreman_provision_domains_parts.map do |domain|
  {domain => {}}
end

extra_domains_content.each do |extra_domain_content|
  domains_content.merge!extra_domain_content
end

domains_file = File.open("tmp/foreman_domains.json", "w")
domains_file.write(JSON.generate(domains_content))
domains_file.close

subnets_content = {
  foreman_provision_subnet_name => {
    "network" => foreman_provision_network,
    "mask" => foreman_provision_mask,
    "domains" => foreman_provision_domains,
    "dhcp-id" => { "command" => "hammer --output=json proxy info --name #{foreman_fqdn}|/usr/local/bin/jq -r .Id" }, # quieres mejorar esto?
    "dns-id" => { "command" => "hammer --output=json proxy info --name #{foreman_fqdn}|/usr/local/bin/jq -r .Id" },
    "tftp-id" => { "command" => "hammer --output=json proxy info --name #{foreman_fqdn}|/usr/local/bin/jq -r .Id" },
  },
  katello_base_subnet_name => {
    "network" => katello_base_network,
    "mask" => katello_base_mask,
    "domains" => foreman_provision_domains,
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

default_partition_table = "Kickstart default"

additional_partition_tables = [
]

all_partition_tables = [ default_partition_table ] + additional_partition_tables

hostgroups_content = {
  "grupo-oas" => {
    "architecture" => "x86_64",
    "domain" => foreman_provision_domain,
    "medium" => "CentOS vault", # sujeto a cambio en cuanto se tenga katello
    "operatingsystem" => "CentOS 7.2",
    "partition-table" => default_partition_table,
    "puppet-ca-proxy" => foreman_fqdn,
    "puppet-proxy" => foreman_fqdn,
    "root-pass" => "oasmaster",
    "subnet" => foreman_provision_subnet_name,
  },
  "grupo-plataforma" => {
    "environment" => "plataforma",
    "parent" => "grupo-oas",
  },
  "grupo-bootstrap" => {
    "parent" => "grupo-plataforma",
    "medium" => "CentOS mirror",
    "operatingsystem" => "BootstrapCentOS 7",
  },
  "grupo-desarrollo" => {
    "environment" => "desarrollo",
    "parent" => "grupo-oas",
    "medium" => "CentOS mirror",
    "operatingsystem" => "BootstrapCentOS 7",
  },
  "grupo-pruebas" => {
    "environment" => "pruebas",
    "parent" => "grupo-oas",
  },
  "grupo-produccion" => {
    "environment" => "produccion",
    "parent" => "grupo-oas",
  },
}

hostgroups_file = File.open("tmp/foreman_hostgroups.json", "w")
hostgroups_file.write(JSON.generate(hostgroups_content))
hostgroups_file.close

media_content = {
  "CentOS vault" => {
    "os-family" => "Redhat",
    "path" => "http://vault.centos.org/centos/$version/os/$arch",
  },
}

media_file = File.open("tmp/foreman_media.json", "w")
media_file.write(JSON.generate(media_content))
media_file.close

templates_content = {
  "Kickstart bootstrap PXELinux" => {
    "file" => "/tmp/templates/Kickstart_bootstrap_PXELinux.erb",
    "type" => "PXELinux"
  },
}

templates_file = File.open("tmp/foreman_templates.json", "w")
templates_file.write(JSON.generate(templates_content))
templates_file.close

# bootstrap hace boot desde repositorios
# en internet, este es el default para bootstrap
bootstrap_pxe_config_templates = [
  "Kickstart bootstrap PXELinux", # esta es custom made
]

# default hace boot desde repositorios
# locales
default_pxe_config_templates = [
  "PXELinux chain iPXE",
  "Kickstart default iPXE",
]

default_provision_config_templates = [
  "Kickstart default",
  "Kickstart default finish",
  "Kickstart default user data",
]

additional_config_templates = [
  "Kickstart default PXELinux",
]

bootstrap_config_templates = bootstrap_pxe_config_templates + default_provision_config_templates
default_config_templates   =   default_pxe_config_templates + default_provision_config_templates

all_config_templates = bootstrap_pxe_config_templates + default_pxe_config_templates + default_provision_config_templates + additional_config_templates

oses_content = {
  "CentOS 7.2" => {
      "name" => "CentOS",
      "major" => "7",
      "minor" => "2.1511", # disponible siempre en vault, disponible en mirror solo si es latest
      "architectures" => "i386,x86_64",
      "family" => "Redhat",
      "media" => "CentOS vault", # en vault se mantienen copias archivadas
      "partition-tables" => all_partition_tables.join(","),
      "config-templates" => all_config_templates.join(",")
  },
  "BootstrapCentOS 7" => {
      "name" => "BootstrapCentOS",
      "major" => "7", # en mirror 7 es un enlace al "latest"
      "architectures" => "i386,x86_64",
      "family" => "Redhat",
      "media" => "CentOS mirror", # las imagenes de boot no estan en vault pero si en mirror [mirror|vault].centos.org/centos/[version]/os/x86_64/images/pxeboot/
      "partition-tables" => all_partition_tables.join(","),
      "config-templates" => all_config_templates.join(",")
  },
}

oses_file = File.open("tmp/foreman_oses.json", "w")
oses_file.write(JSON.generate(oses_content))
oses_file.close

bootstrap_config_templates_params =  bootstrap_config_templates.map do |config_template|
  {
    "config-template-id" => {
      "command" => "hammer --output=json template info --name '#{config_template}'|/usr/local/bin/jq -r .Id"
    }
  }
end

default_config_templates_params =  default_config_templates.map do |config_template|
  {
    "config-template-id" => {
      "command" => "hammer --output=json template info --name '#{config_template}'|/usr/local/bin/jq -r .Id"
    }
  }
end

os_default_templates_content = {
  "BootstrapCentOS 7" => bootstrap_config_templates_params,
  "CentOS 7.2" => default_config_templates_params,
}

os_default_templates_file = File.open("tmp/foreman_os_default_templates.json", "w")
os_default_templates_file.write(JSON.generate(os_default_templates_content))
os_default_templates_file.close

host_parameters = [ "keymap=es" ]
if proxy != ""
  host_parameters.push("proxy=#{proxy}")
end

hosts_content = {
  "#{katello_fqdn}" => {
    "hostgroup" => "grupo-#{puppet_environment}",
    "interface" => [
      {
        "managed" => "false",
        "primary" => "true",
        "provision" => "false",
        "identifier" => katello_base_interface,
        "mac" => katello_base_mac,
        "ip" => katello_base_ip,
        "subnet_id" => { "command" => "hammer --output=json subnet info '--name=#{katello_base_subnet_name}'|/usr/local/bin/jq -r .Id"}, # en realidad la subnet no es de katello exclusivamente...
        "domain_id" => { "command" => "hammer --output=json domain info '--name=#{katello_base_domain}'|/usr/local/bin/jq -r .Id"}, # en realidad el dominio no es de katello exclusivamente...
      },
      {
        "managed" => "true",
        "primary" => "false",
        "provision" => "true",
        "identifier" => katello_provision_interface,
        "mac" => katello_provision_mac,
        "ip" => katello_provision_ip,
        "subnet_id" => { "command" => "hammer --output=json subnet info '--name=#{foreman_provision_subnet_name}'|/usr/local/bin/jq -r .Id"},
        "domain_id" => { "command" => "hammer --output=json domain info '--name=#{foreman_provision_domain}'|/usr/local/bin/jq -r .Id"},
      },
    ],
  },
}

# add parameters if any
if not host_parameters.empty?
  hosts_content.each do |host, params|
    hosts_content[host]["parameters"] = host_parameters.join(",")
  end
end

hosts_file = File.open("tmp/foreman_hosts.json", "w")
hosts_file.write(JSON.generate(hosts_content))
hosts_file.close

# get jq if needed
if not File.exists? "tmp/jq-linux64"
  puts "Getting jq"
  File.open("tmp/jq-linux64", "wb") do |local_jq|
    open("https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64", "rb") do |remote_jq|
     local_jq.write(remote_jq.read)
    end
  end
end

Vagrant.configure(2) do |config|
  config.vm.box = "centos-7.2"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.2_chef-provisionerless.box"

  # foreman vm config
  config.vm.define :foreman, primary: true do |foreman|
    foreman.vm.network "private_network", ip: foreman_ip

    # provision more ram and cpu
    foreman.vm.provider "virtualbox" do |vbox|
      vbox.memory = 4096
      vbox.cpus = 2
    end

    # install jq
    foreman.vm.provision "file", source: "tmp/jq-linux64", destination: "/tmp/jq-linux64"
    foreman.vm.provision "shell", name: "install jq 1/3", inline: "sudo chown -v root:root /tmp/jq-linux64"
    foreman.vm.provision "shell", name: "install jq 2/3", inline: "sudo chmod -v +x /tmp/jq-linux64"
    foreman.vm.provision "shell", name: "install jq 3/3", inline: "sudo mv -v /tmp/jq-linux64 /usr/local/bin/jq"

    # host naming
    foreman.vm.hostname = foreman_fqdn
    foreman.vm.provision "file", source: etc_hosts_file.path, destination: "/tmp/hosts"
    foreman.vm.provision "shell", name: "host naming 1/2", inline: "sudo tee /etc/hosts < /tmp/hosts"
    foreman.vm.provision "shell", name: "host naming 2/2", inline: "rm -v /tmp/hosts"

    # tools
    foreman.vm.provision "file", source: "util/bin", destination: "/tmp"
    foreman.vm.provision "shell", name: "tools 1/3", inline: "sudo chown -v root:root /tmp/bin/*"
    foreman.vm.provision "shell", name: "tools 2/3", inline: "sudo mv -v /tmp/bin/* /usr/local/bin"
    foreman.vm.provision "shell", name: "tools 3/3", inline: "rm -rv /tmp/bin"

    # environment
    foreman.vm.provision "shell", name: "environment 1/2", inline: "/usr/local/bin/set_environment.sh -n http_proxy -v '#{proxy}'"
    foreman.vm.provision "shell", name: "environment 2/2", inline: "/usr/local/bin/set_environment.sh -n https_proxy -v '#{proxy}'"

    # foreman provision
    foreman.vm.provision "shell", name: "foreman provision 1/3", inline: "if test ! -f /etc/yum.repos.d/puppetlabs.repo; then sudo rpm -iv http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm; fi"
    foreman.vm.provision "shell", name: "foreman provision 2/3", inline: "sudo yum -y -v install epel-release http://yum.theforeman.org/releases/1.11/el7/x86_64/foreman-release.rpm"
    foreman.vm.provision "shell", name: "foreman provision 3/3", inline: "sudo yum -y -v install foreman-installer git-daemon vim"

    # provision git
    foreman.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/tmp/id_rsa_pub"
    foreman.vm.provision "shell", name: "git 1/3", inline: "egrep '^git:' /etc/passwd||sudo useradd -s /usr/bin/git-shell -m -r git"
    foreman.vm.provision "shell", name: "git 2/3", inline: "sudo /usr/local/bin/ensure_user_authorize_key.rb --authorize-key /tmp/id_rsa_pub --user git"
    # foreman.vm.provision "shell", name: "git 3/3", inline: "rm -v /tmp/id_rsa_pub"

    # foreman install, execute thrice (or maybe twice) to ensure convergency
    foreman.vm.provision "shell", name: "foreman install", inline: "#{foreman_installer_command_1};#{foreman_installer_command_2}||#{foreman_installer_command_2}"

    # puppet environments setup
    foreman.vm.provision "shell", name: "environments writable by git", inline: "chown root:git /etc/puppet/environments&&chmod 775 /etc/puppet/environments"

    # puppet run, execute twice to ensure convergency
    foreman.vm.provision "shell", name: "puppet run", inline: "sudo puppet agent --test 2>/dev/null||true" # nunca fallar porque puede que el ambiente no esté aun

    # foreman domains provision
    foreman.vm.provision "file", source: domains_file.path, destination: "/tmp/foreman_domains.json"
    foreman.vm.provision "shell", name: "domains 1/2", inline: "sudo /usr/local/bin/ensure_foreman_domains.rb --source /tmp/foreman_domains.json"
    foreman.vm.provision "shell", name: "domains 2/2", inline: "rm -v /tmp/foreman_domains.json"

    # foreman subnets provision
    foreman.vm.provision "file", source: subnets_file.path, destination: "/tmp/foreman_subnets.json"
    foreman.vm.provision "shell", name: "subnets 1/2", inline: "sudo /usr/local/bin/ensure_foreman_subnets.rb --source /tmp/foreman_subnets.json"
    foreman.vm.provision "shell", name: "subnets 2/2", inline: "rm -v /tmp/foreman_subnets.json"

    # foreman environments provision
    foreman.vm.provision "file", source: environments_file.path, destination: "/tmp/foreman_environments.json"
    foreman.vm.provision "shell", name: "environments 1/2", inline: "sudo /usr/local/bin/ensure_foreman_environments.rb --source /tmp/foreman_environments.json"
    foreman.vm.provision "shell", name: "environments 2/2", inline: "rm -v /tmp/foreman_environments.json"

    # foreman media provision
    foreman.vm.provision "file", source: media_file.path, destination: "/tmp/foreman_media.json"
    foreman.vm.provision "shell", name: "media 1/2", inline: "sudo /usr/local/bin/ensure_foreman_media.rb --source /tmp/foreman_media.json"
    foreman.vm.provision "shell", name: "media 2/2", inline: "rm -v /tmp/foreman_media.json"

    # foreman templates provision
    foreman.vm.provision "file", source: "templates", destination: "/tmp"
    foreman.vm.provision "file", source: templates_file.path, destination: "/tmp/foreman_templates.json"
    foreman.vm.provision "shell", name: "templates 1/3", inline: "sudo /usr/local/bin/ensure_foreman_templates.rb --source /tmp/foreman_templates.json"
    foreman.vm.provision "shell", name: "templates 2/3", inline: "rm -v /tmp/foreman_templates.json"
    foreman.vm.provision "shell", name: "templates 2/3", inline: "rm -rv /tmp/templates"

    # foreman oses provision
    foreman.vm.provision "file", source: oses_file.path, destination: "/tmp/foreman_oses.json"
    foreman.vm.provision "shell", name: "oses 1/2", inline: "sudo /usr/local/bin/ensure_foreman_oses.rb --source /tmp/foreman_oses.json"
    foreman.vm.provision "shell", name: "oses 2/2", inline: "rm -v /tmp/foreman_oses.json"

    # foreman os default templates provision
    foreman.vm.provision "file", source: os_default_templates_file.path, destination: "/tmp/foreman_os_default_templates.json"
    foreman.vm.provision "shell", name: "os default templates 1/2", inline: "sudo /usr/local/bin/ensure_foreman_os_default_templates.rb --source /tmp/foreman_os_default_templates.json"
    foreman.vm.provision "shell", name: "os default templates 2/2", inline: "rm -v /tmp/foreman_os_default_templates.json"

    # foreman hostgroups provision
    foreman.vm.provision "file", source: hostgroups_file.path, destination: "/tmp/foreman_hostgroups.json"
    foreman.vm.provision "shell", name: "hostgroups 1/2", inline: "sudo /usr/local/bin/ensure_foreman_hostgroups.rb --source /tmp/foreman_hostgroups.json"
    foreman.vm.provision "shell", name: "hostgroups 2/2", inline: "rm -v /tmp/foreman_hostgroups.json"

    # foreman hosts provision
    foreman.vm.provision "file", source: hosts_file.path, destination: "/tmp/foreman_hosts.json"
    foreman.vm.provision "shell", name: "hosts 1/2", inline: "sudo /usr/local/bin/ensure_foreman_hosts.rb --source /tmp/foreman_hosts.json"
    foreman.vm.provision "shell", name: "hosts 2/2", inline: "rm -v /tmp/foreman_hosts.json"

    # generate pxe
    foreman.vm.provision "shell", name: "generate pxe", inline: "sudo hammer template build-pxe-default"

    # ipxe.lkrn provision
    foreman.vm.provision "shell", name: "ipxe.lkrn", inline: "sudo cp -v /usr/share/ipxe/ipxe.lkrn /var/lib/tftpboot/ipxe.lkrn"

    # hiera provision
    foreman.vm.provision "file", source: "files/hiera.yaml", destination: "/tmp/hiera.yaml"
    foreman.vm.provision "shell", name: "hiera 1/5", inline: "sudo cp -v /tmp/hiera.yaml /etc/hiera.yaml"
    foreman.vm.provision "shell", name: "hiera 2/5", inline: "sudo chown -v root:root /etc/hiera.yaml"
    foreman.vm.provision "shell", name: "hiera 3/5", inline: "sudo chmod -v 644 /etc/hiera.yaml"
    foreman.vm.provision "shell", name: "hiera 4/5", inline: "gem list|grep hiera-eyaml||sudo gem install hiera-eyaml"
    foreman.vm.provision "shell", name: "hiera 5/5", inline: "sudo rm -v /tmp/hiera.yaml"

    # keys provision
    foreman.vm.provision "shell", name: "keys 1/7", inline: "sudo rm -rvf /tmp/keys"
    foreman.vm.provision "file", source: "keys", destination: "/tmp/keys"
    foreman.vm.provision "shell", name: "keys 2/7", inline: "sudo chown -Rv root:puppet /tmp/keys"
    foreman.vm.provision "shell", name: "keys 3/7", inline: "sudo chmod -Rv 750 /tmp/keys"
    foreman.vm.provision "shell", name: "keys 4/7", inline: "sudo chmod -v 751 /tmp/keys"
    foreman.vm.provision "shell", name: "keys 5/7", inline: "sudo mkdir -vp /etc/eyaml"
    foreman.vm.provision "shell", name: "keys 6/7", inline: "cd /tmp/keys&&sudo tar cf - .|sudo tar xvf - -C /etc/eyaml"
    foreman.vm.provision "shell", name: "keys 7/7", inline: "sudo rm -rv /tmp/keys"

    # hiera repo provision
    foreman.vm.provision "shell", name: "hiera repo 1/3", inline: "test ! -d /var/lib/hiera||test -d /var/lib/hiera/.git||rm -rv /var/lib/hiera"
    foreman.vm.provision "shell", name: "hiera repo 2/3", inline: "test -d /var/lib/hiera/.git||(cd /var/lib&&sudo git clone #{hiera_repo} hiera)"
    foreman.vm.provision "shell", name: "hiera repo 3/3", inline: "cd /var/lib/hiera&&sudo git pull"

    # show the url and the generated admin password
    foreman.vm.provision "shell", name: "fin", inline: <<-FIN
      echo
      echo Ya puede:
      echo
      echo git clone #{puppet_repo}
      echo cd #{puppet_repo.split("/").last.gsub /\.git$/, ""}
      echo git remote add foreman git@#{foreman_ip}:puppet.git
      echo git push foreman master:#{puppet_environment}
      echo
      echo Iniciar sesión en #{foreman_url}
      echo La contraseña inicial del usuario admin es: $(sudo /usr/local/bin/get_foreman_answer.rb --classname foreman --param admin_password)
      echo
    FIN
  end

  # katello vm config
  config.vm.define :katello, autostart: false do |katello|
    katello.vm.base_mac = katello_base_mac
    katello.vm.network "private_network", ip: katello_provision_ip, mac: katello_provision_mac
    katello.vm.boot_timeout = 3600
    # set host only interface with highest priority to boot
    # provision more ram and cpu
    katello.vm.provider "virtualbox" do |vbox|
      vbox.customize ["modifyvm", :id, "--nicbootprio2", "1", "--boot1", "net", "--boot2", "disk", "--ioapic", "off"]
      vbox.memory = 4096
      vbox.cpus = 2
      vbox.gui = true
    end
  end

end
