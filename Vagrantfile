Vagrant.configure("2") do |config|
  # config.vm.box = "nixbox-21.05"
  config.vm.box = "dusk/nixos"
  config.vm.box_version = "21.05"
  config.vm.hostname = "nixos"
  config.vm.define "nixos"

  if Vagrant.has_plugin?("vagrant-vbguest") then
        config.vbguest.auto_update = false
  end

  config.vm.provider :virtualbox do |vb|
      vb.name = "nixos"
      vb.memory = 4096
      vb.cpus = 2
      vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
  end

  config.vm.synced_folder "~/dev/nix/", "/home/vagrant/dusk", disabled: false
end
