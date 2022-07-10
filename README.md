## Why?

- After trying to port my development environment using Docker (tmux, neovim, zsh and fzf) to Windows with no avail, because of various imcompatibilities like not being able to use ctrl-space, I've decided to deep dive once for all to NixOS, so I can have a reproducible system that I can virtualize and isolate from the Windows environment. WSL2 gave me headaches with my company VPN too. Besides, seems *fun* and I've wanted to switch from Arch from a long time now.

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

## configuration.nix

`sudo nixos-rebuild switch --flake .#`

### NetworkManager


### Git

- Git can't be configured through `configuration.nix`, only with `home-manager`
- Will have to track `~/.gitconfig` in `dotfiles` repository

```
git config --global user.name "rivera-bl"
git config --global user.email "rivera.pablo1090@gmail.com"
git config --global init.defaultBranch "main"
ssh-keygen -t ed25519
echo "IdentityFile ~/.ssh/github" >> ~/.ssh/config
```

### Secrets Management

- Use [sops-nix][4]
- Here's a [youtube video][5] explaining `sops`
- This is an [example][6] of `sops-nix` used in nixos configuration

Goal:
  - For now just to manage the ssh keys for `git` and the wireless `psk` as secrets
  - For backup should have an `age` and `pgp` keys to encrypt/decrypt the secrets
  - Would be great to store the `pgp` inside a yubikey, and this be our backup key

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
