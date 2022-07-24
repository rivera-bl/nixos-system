{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nvim.url = "github:rivera-bl/dotfiles?dir=nvim";
  };

  outputs = inputs@{ nixpkgs, nvim, ... }: {
    nixosConfigurations = {
      navi = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
           { _module.args = inputs; }
          ./hosts/navi/configuration.nix
        ];
      };
    };
  };
}
