{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    /* nvim.url = "github:rivera-bl/dotfiles?dir=nvim"; */
    nvim.url = "/home/nixos/nixos/home/nvim";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{ self, nixos-hardware, nixpkgs, nvim, ... }: {
    nixosConfigurations = {
      navi = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { _module.args = inputs; }
          ./hosts/navi/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen #although it is 8th-gen
        ];
      };
    };
  };
}
