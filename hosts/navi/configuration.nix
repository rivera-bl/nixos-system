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
    useXkbConfig = true; # so the caps:swap works on tty
  };

  services.xserver = {
    autoRepeatDelay = 200;
    autorun = true;
    enable = true;
    libinput.enable = true;
    layout = "us"; # keyboard has less keys so can't use latam
    xkbOptions = "caps:swapescape,altwin:prtsc_rwin";

    displayManager = {
      lightdm.enable = true; # doesn't startx without this
      startx.enable = true;
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    permitRootLogin = "no";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.nixos = {
    isNormalUser = true;
    useDefaultShell = true;
    createHome = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "docker"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAlCFaSGwP7WEVAAtNjLNb60DjcNN5RCxddh7k+6rCw5"
    ];
  };

  virtualisation.docker.enable = true;

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    wget
    git
    fish
    ripgrep
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
