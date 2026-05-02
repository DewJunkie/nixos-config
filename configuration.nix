# Edit this configuration file to define what should be installed on

# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, breezy-desktop, nixpkgs-dewjunkie, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.overlays = [
    breezy-desktop.overlays.default
    (final: prev: {
      citrix_workspace = (import nixpkgs-dewjunkie {
        system = prev.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "libsoup-2.74.3" ];
        };
      }).citrix_workspace;
    })
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allow nested virtualization
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  boot.enableContainers = true;

  console.font = "CaskaydiaMono NF";

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  hardware = {
    amdgpu.opencl.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # boot.kernelParams = [
  #   # The kernel module parameter gttsize is a is deprecated and will be removed in the future.
  #   #options amdgpu gttsize=120000

  #   # specified as 4KiB pages: 120 GB GTT
  #   "options ttm pages_limit=31457280"
  #   # specified as 4KiB pages: 60 GB pre-allocated
  #   "options ttm page_pool_size=15728640"
  # ];

  networking = {
    useDHCP = false;
    hostName = "nix-dlm";
    usePredictableInterfaceNames = false;
    # Enable networking
    networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        "br0" = {
          connection = {
            id = "br0";
            type = "bridge";
            interface-name = "br0";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
        "br0-slave-eth0" = {
          connection = {
            id = "br0-slave-eth0";
            type = "ethernet";
            interface-name = "eth0";
            master = "br0";
            slave-type = "bridge";
          };
        };
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPortRanges = [
      # GSConnect/KDE Connect
      {from = 1714; to = 1764;}
    ];
    allowedUDPPortRanges = [
      # GSConnect/KDE Connect
      {from = 1714; to = 1764;}
    ];
  };

  nix.settings = {
    download-buffer-size=524288000; # 500 MB
    experimental-features = [ "nix-command" "flakes" ];
  };


  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  
  services = {
    asusd = {
      enable = true;
      #enableUserService = true;
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [
      pkgs.hplipWithPlugin
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.spice-webdavd.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.dmckinney = {};
  users.users.dmckinney = {
    isNormalUser = true;
    description = "Duane McKinney";
    extraGroups = [ 
    	"networkmanager"
      "dmckinney"
      "kvm"
      "libvirtd"
      "podman"
      "wheel"
    ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  virtualisation = {
    containers.enable = true;
  	# Allow remote-viewer to redirect usb devices
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

  	spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;

      };
    };
  };

  programs.neovim = {
    defaultEditor = true;
    enable = true;
    viAlias = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.steam.enable = true;

  programs.thunderbird.enable = true;

  programs.virt-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    asusctl
    citrix_workspace
    cmake
    digikam
    fd
    gcc_multi
    git
    gnome-boxes
    gnomeExtensions.battery-health-charging
    gnomeExtensions.gsconnect
    gnumake
    javaPackages.compiler.openjdk21
    kubectl
    libreoffice
    microsoft-edge
    podman-compose
    podman-desktop
    polkit
    powershell
    prismlauncher
    remmina
    ripgrep
    tree-sitter
    virt-viewer
    vscode
    wezterm
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
