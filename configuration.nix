{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.loader.grub = {
    enable = true;
    devices = [ "nodev" ];
    efiInstallAsRemovable = true;
    efiSupport = true;
  };

  networking = {
    hostName = "navi";

    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };

    wireless = {
      enable = true;
      interfaces = [ "wlp0s20f3" ];
      networks = {
        "JMRivera." = {
          pskRaw = "20e0852468f9cf0a1e848676bce12598fdff9668e778b6575bf64154e4e2fdef";
        };
      };
    };
  }; 

  system.stateVersion = "22.05"; # Did you read the comment?

}

