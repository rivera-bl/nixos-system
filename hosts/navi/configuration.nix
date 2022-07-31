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
    autoRepeatDelay = 250;
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

  users.defaultUserShell = pkgs.zsh;

  users.users.nixos = {
    isNormalUser = true;
    useDefaultShell = true;
    createHome = true;
    # gotta add 'zsh' to .bashrc and .bash_profile
    # to not install environment.systemPackages.zsh
    /* shell = pkgs.zsh; */
    extraGroups = [
      "wheel"
      "docker"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAlCFaSGwP7WEVAAtNjLNb60DjcNN5RCxddh7k+6rCw5"
    ];
  };

  /* programs.fish.enable = true; */

  virtualisation.docker.enable = true;

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.overlays = [ (self: super:{
    kubectl = super.kubectl.overrideAttrs (oldAttrs: rec {
      version = "1.21.3";
      src = self.fetchFromGitHub {
        owner = "kubernetes";
        repo = "kubernetes";
        rev = "v${version}";
        sha256 = "sha256-GMigdVuqJN6eIN0nhY5PVUEnCqjAYUzitetk2QmX5wQ=";
        };
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    wget 
    ripgrep
    tree # replace with broot
    git
    zsh
    kubectl
    go 
    /* fish fishPlugins.done */
    xclip xsel
    cmake gcc
    minikube
    nvim.packages.x86_64-linux.default
    # language servers
    cargo rustc rnix-lsp
    terraform terraform-ls
    sumneko-lua-language-server
    yaml-language-server
  ];

  environment.pathsToLink = [ "/share/zsh" ];

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
