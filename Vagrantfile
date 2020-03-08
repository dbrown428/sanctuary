require 'json'

scriptDir = File.expand_path(".") + "/provision"
aliasesPath = scriptDir + "/aliases"

# TODO - read these values from .env file
settings = {
    :name => "sanctuary-dev",
    :box => "laravel/homestead",
    :box_version => "9.3.0",
    :hostname => "sanctuary",
    :ip => "192.168.10.34",
    :memory => "1024",
    :cpus => "1",
    :guest_folder => "/home/vagrant/sanctuary",
    :database_name => "sanctuary",
}

Vagrant.configure("2") do |config|
    # Add aliases
    config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Box
    config.vm.box = settings[:box]
    config.vm.box_version = settings[:box_version]
    config.vm.hostname = settings[:hostname]

    # VirtualBox
    config.vm.provider "virtualbox" do |vb|
        vb.name = settings[:name]
        vb.customize ["modifyvm", :id, "--memory", settings[:memory]]
        vb.customize ["modifyvm", :id, "--cpus", settings[:cpus]]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    end

    # Network
    config.vm.network "private_network", ip: settings[:ip]
    config.vm.network "forwarded_port", guest: "80", host: "8000", auto_correct: true
    config.vm.network "forwarded_port", guest: "5432", host: "54320", auto_correct: true

    # Shared Folder
    config.vm.synced_folder ".", settings[:guest_folder]

    # Provision
    config.vm.provision "shell" do |s|
        s.path = scriptDir + "/provision.sh"
        s.args = [
            settings[:hostname],
            settings[:guest_folder],
            settings[:database_name],
        ]
    end
end
