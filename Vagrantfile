Vagrant.configure("2") do |config|
  # config.vm.box = "nixbox-21.05"
  # config.vm.hostname = "nixos"
  config.vm.box = "dusk/nixos"
  config.vm.box_version = "21.05"
  config.vm.define "nixos"

  if Vagrant.has_plugin?("vagrant-vbguest") then
        config.vbguest.auto_update = false
  end

  config.vm.provider :virtualbox do |vb|
      vb.name = "nixos"
      vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true
end
