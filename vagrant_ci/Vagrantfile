Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path = "puppet/modules"

    puppet.hiera_config_path = "puppet/manifests/hiera.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"
    puppet.options = "--debug --verbose"
    puppet.facter = {
    "vagrant" => "1",
    "server" => "servername",
    }
  end

end
