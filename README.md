# My NixOS Journey

* After trying to port my development environment using Docker (tmux, neovim, zsh and fzf) to Windows with no avail, because of various imcompatibilities like not being able to use ctrl-space, I've decided to deep dive once for all to NixOS, so I can have a reproducible system that I can virtualize and isolate from the Windows environment. Because WSL2 gave me headaches with my company VPN. Besides, it looks *fun* and I've wanted to switch from Arch from a long time now.

## NixOS box with Vagrant

* For ease of experimentation we will build a NixOS VM with Vagrant

```
git clone https://github.com/nix-community/nixbox
cd nixbox
packer build --only=virtualbox-iso nixos-x86_64.json
vagrant box add nixbox-21.05 nixos-21.05-virtualbox-x86_64.box
vagrant init nixbox-21.05
vagrant up
vagrant ssh
```

* `make update` which is supposed to update the iso_url to the latest, throws a ruby error, and changing the iso_url manually throws an ssh error. We can [follow this](https://nixos.org/manual/nixos/stable/index.html#sec-upgrading) to update the `nixos-channel` manually to upgrade to `22.05`. Be sure to run the commands as `root`.

```
sudo su
nix-channel --list | grep nixos
nix-channel --add https://nixos.org/channels/nixos-22.05 nixos
nix-channel --update nixos; nixos-rebuild switch 
```

## My first Flake

### Setup Environment

* To enable the use of Flakes we gotta add this to `configuration.nix`

```
nix = {
  package = pkgs.nixFlakes;
  extraOptions = ''
    experimental-features = nix-command flakes
  '';
};
```

* Since we don't have anything installed we have to exec vim on a `nix-shell`

```
nix-shell -p neovim
sudo nvim /etc/nixos/configuration.nix
```

* After adding the changes in the previous point, we must `rebuild` our system

```
sudo nixos-rebuild switch
```

### Build a Flake

* There is this [repository of templates](https://github.com/NixOS/templates) from where we can start out flakes

```
nix flake new -t templates#go-hello .
```

* To build a flake we have various options, like `nix build .#<pkg-name>` or `nix build github:<user>/<repo>/<branch>`, in this case the simplest form is to just build the `default`

```
nix build
```

* The output is under the `result` folder, so

```console
$ ./result/bin/go-hello
Hello Nix!
```

### Build and Run a Flake

* We can also build and run a Flake at the same time if we execute `nix run` after adding

```
apps = forAllSystems (system: {
  default = {
      type = "app";
      program = "${self.packages.${system}.go-hello}/bin/go-hello";
  };
});
```

### Dev Environment with a Flake

* We can even ship our dev environment tools inside a flake

```
devShells = forAllSystems (system:
  let pkgs = nixpkgsFor.${system};
  in {
    default = pkgs.mkShell {
      buildInputs = with pkgs; [ go gopls gotools go-tools ];
    };
  });
```

* Then jump into the development shell with `nix develop`, and we will have all those tools installed

## Resources

* The *My first Flake* section is a vague copy of me following [this blogspot](https://xeiaso.net/blog/nix-flakes-1-2022-02-21)

## TODO

- [x] upload nixbox-21.05 to vagrant cloud
```
Vagrant.configure("2") do |config|
  config.vm.box = "dusk/nixos"
  config.vm.box_version = "21.05"
end
```
- [ ] write a flake to install my editor environment
    - [ ] install neovim
- [ ] create a box with nixos 22.05
    - [ ] for now use a provisioner to *manually* change to the 22.05 channel
    - [ ] try out the vagrant-nixos-plugin to provision
      - https://github.com/nix-community/vagrant-nixos-plugin

- [ ] configure the system on /etc/nixox/configuration.nix

