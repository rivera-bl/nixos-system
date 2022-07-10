## Why?

* After trying to port my development environment using Docker (tmux, neovim, zsh and fzf) to Windows with no avail, because of various imcompatibilities like not being able to use ctrl-space, I've decided to deep dive once for all to NixOS, so I can have a reproducible system that I can virtualize and isolate from the Windows environment. WSL2 gave me headaches with my company VPN too. Besides, seems *fun* and I've wanted to switch from Arch from a long time now.

## Constraints

- Won't use Home Manager because I don't see the point. I can just move my dotfiles to .config and manage the installations through configuration.nix

## NixOS install on X1

### Burn USB

```
wget https://channels.nixos.org/nixos-22.05/latest-nixos-minimal-x86_64-linux.iso
sudo dd bs=1M if=/path/to/iso/latest-nixos-minimal-x86_64-linux.iso of=/dev/sdb status=progress conv=fsync
```

### Run Installer

1. Press `enter` on Lenovo menu
2. `F1` to disable `secure boot`
3. `F12` to select the boot device
4. Run the installer
5. Set a password for the `nixos` user with `passwd nixos` to SSH from other machine
6. Make sure to have an internet connection

### SSH into X1

```
ssh-keygen -t dsa -f key
ssh-copy-id -i key nixos@<ip>
ssh nixos@<ip>
```

### UEFI Partitions

```
sudo -i
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart primary 512MiB -8GiB
parted /dev/nvme0n1 -- mkpart primary linux-swap -8GiB 100%
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 3 esp on
```

### Formatting

```
mkfs.ext4 -L nixos /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p2
mkfs.fat -F 32 -n boot /dev/nvme0n1p3
```

### Install

TODO: pass this `configuration.nix` on the installation

```
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt
mount /dev/nvme0n1p3 /mnt/boot
nixos-generate-config --root /mnt
nixos-install
reboot
```

## NetworkManager


## Git

- Git can't be configured through `configuration.nix`, only with `home manager`
- Will have to track `~/.gitconfig` in `dotfiles` repository


```
git config --global user.name "rivera-bl"
git config --global user.email "rivera.pablo1090@gmail.com"
git config --global init.defaultBranch "main"
ssh-keygen -t ed25519
echo "IdentityFile ~/.ssh/github" >> ~/.ssh/config
```

- Clone and symlink `configuration.nix`

```
mkdir -p ~/code/nix
cd !$
git clone git@github.com:rivera-bl/nixos-system.git
rm /etc/nixos/configuration.nix
ln -s ~/code/nix/nixos-system/configuration.nix /etc/nixos/configuration.nix
```

## Secrets Management

- Use [sops-nix][4]
- Here's an [youtube video][5] explaining `sops`
- This is an [example][6] of `sops-nix` used in nixos configuration

### Goal

- For now just to manage the ssh keys for `git` and the wireless `psk` as secrets
- For backup should have an `age` and `pgp` keys to encrypt/decrypt the secrets
- Would be great to store the `pgp` inside a yubikey, and this be our backup key

## NixOS VM with Vagrant

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
### Known Issues

* When mounting a directory from the host to the vagrant vm with `config.vm.synced_folder`, it gets wiped out if we do a `nixos-rebuild switch`. We can restart the vm for the directory to be mounted again.

* `nix-env -i` can be an intensive memory proccess when it has to look for every item in the store to match the requested package. That's why we have to provision the vm with at least 4GB of RAM if we want to query the store without limitations. Although there are more smart ways of selecting the `.drv` for installation. For example we can use `nix repl` with `:l <nixpkgs>` to load the store, and `<pkg-name>` to output it's exact `.drv` location.

## Resources

- [Video: Wil Taylor][1]
- [Repository: multiple hosts/modules][2]
- [Docs: writing modules][3]

[1]: https://www.youtube.com/watch?v=mJbQ--iBc1U&list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq-&index=8
[2]: https://github.com/jakubgs/nixos-config
[3]: https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules
[4]: https://github.com/Mic92/sops-nix
[5]: https://www.youtube.com/watch?v=V2PRhxphH2w
[6]: https://github.com/Mic92/dotfiles/tree/master/nixos

## TODO

- [x] install nixos on X1
- [ ] create a flake for configuration.nix
  - [ ] use modules/roles
- [ ] configure network manager for wireless connection
- [ ] configure git
- [ ] manage secrets
- [x] upload nixbox-21.05 to vagrant cloud
- [x] share dev/nix folder with vagrant
- [x] install rnix-lsp on vim with treesitter support
    treesitter is not automatically highlighting when opening .nix files
