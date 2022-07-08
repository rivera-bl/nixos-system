## My NixOS Journey

* After trying to port my development environment using Docker (tmux, neovim, zsh and fzf) to Windows with no avail, because of various imcompatibilities like not being able to use ctrl-space, I've decided to deep dive once for all to NixOS, so I can have a reproducible system that I can virtualize and isolate from the Windows environment. WSL2 gave me headaches with my company VPN too. Besides, seems *fun* and I've wanted to switch from Arch from a long time now.

* Here I'll build a `configuration.nix` using flakes.

## NixOS box with Vagrant

* For ease of experimentation use a NixOS VM with Vagrant. Build the box:

```
git clone https://github.com/nix-community/nixbox
cd nixbox
packer build --only=virtualbox-iso nixos-x86_64.json
vagrant box add nixbox-21.05 nixos-21.05-virtualbox-x86_64.box
vagrant init nixbox-21.05
vagrant up
vagrant ssh
```

* The box is at vagrant cloud `dusk/nixos`. I uploaded it manually following [this](https://blog.ycshao.com/2017/09/16/how-to-upload-vagrant-box-to-vagrant-cloud/), although there should be an automated way using post-processors/cli.

* `make update` which is supposed to update the iso_url to the latest, throws a ruby error, and changing the iso_url manually throws an ssh error. So I'll stick to the `21.05` box for now. 
    
* Nonetheless we can [follow this](https://nixos.org/manual/nixos/stable/index.html#sec-upgrading) to update the `nixos-channel` manually to upgrade to `22.05`. Be sure to run the commands as `root`.

```
sudo su
nix-channel --list | grep nixos
nix-channel --add https://nixos.org/channels/nixos-22.05 nixos
nix-channel --update nixos; nixos-rebuild switch 
```
## Known Issues

* When mounting a directory from the host to the vagrant vm with `config.vm.synced_folder`, it gets wiped out if we do a `nixos-rebuild switch`. We can restart the vm for the directory to be mounted again.

* `nix-env -i` can be an intensive memory proccess when it has to look for every item in the store to match the requested package. That's why we have to provision the vm with at least 4GB of RAM if we want to query the store without limitations. Although there are more smart ways of selecting the `.drv` for installation. For example we can use `nix repl` with `:l <nixpkgs>` to load the store, and `<pkg-name>` to output it's exact `.drv` location.

## Resources

- [jd Blogpost][1]
- [Wil Taylor YT][2]
- [NixOS example multiple hosts/modules][3]

[1]: https://jdisaacs.com/blog/nixos-config/
[2]: https://www.youtube.com/watch?v=mJbQ--iBc1U&list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq-&index=8
[3]: https://github.com/jakubgs/nixos-config

## TODO

- [ ] create a flake for configuration.nix
- [x] upload nixbox-21.05 to vagrant cloud
- [x] share dev/nix folder with vagrant
- [x] install rnix-lsp on vim with treesitter support
    treesitter is not automatically highlighting when opening .nix files
- [ ] create a box with nixos 22.05
    - [ ] for now use a provisioner to *manually* change to the 22.05 channel
    - [ ] try out the vagrant-nixos-plugin to provision
      - https://github.com/nix-community/vagrant-nixos-plugin
