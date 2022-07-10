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

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    # font = "Lat2-Terminus16";
    # keyMap = "la-latin1";
    useXkbConfig = true; # so the caps:swap works on tty
  };

  services = {
    xserver = {
      enable = true;
      layout = "latam";
      libinput.enable = true; # Enable touchpad support (enabled default in most desktopManager).
      xkbOptions = "caps:swapescape";
      displayManager.startx.enable = true; # don't start the graphical interface
    };

    openssh = {
      enable = true;
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.nixos = {
    isNormalUser = true;
    useDefaultShell = true;
    createHome = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    tmux
    zsh
  ];

  system.stateVersion = "22.05";
}
