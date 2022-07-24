{
  config,
  pkgs,
  inputs,
  nvim,
  ...
}: {
  imports = [
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
    devices = ["nodev"];
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
      interfaces = ["wlp0s20f3"];
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
      autorun = false;
      displayManager.startx.enable = true; # don't start the graphical interface

      layout = "latam";
      libinput.enable = true;
      xkbOptions = "caps:swapescape";
      desktopManager = {
        xterm.enable = false;
      };
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
    shell = pkgs.fish;
    extraGroups = ["wheel" "docker"];
  };

  virtualisation.docker.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    fish
    xclip xsel
    cmake gcc
    nvim.packages.x86_64-linux.default
    tree lazygit
    cargo rustc rnix-lsp
    terraform terraform-ls
    sumneko-lua-language-server
    yaml-language-server
  ];

  # does this even work?
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  environment.etc = {
    "xdg/user-dirs.defaults".text = ''
      XDG_CONFIG_HOME=~/.config
    '';
  };

  system.stateVersion = "22.05";
}
