{
  description = "NixOS System";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64";
    pkgs = import nixpkgs {inherit system;};
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      navi = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/navi/configuration.nix
        ];
      };
    };
  };
}
