{ self, inputs, ... }: {
  flake.nixosModules.base = { config, pkgs, breezy-desktop, ... }: {
    # Bootloader.
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    boot.enableContainers = true;

    console.font = "CaskaydiaMono NF";

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

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    systemd.settings.Manager = {
      DefaultTimeoutStartSec = "15s";
    };

    nixpkgs.overlays = [
      (final: prev: {
        # Disable tests for openldap to bypass flaky upstream server-side tests 
        # (e.g. test017-syncreplication-refresh) that often fail on i686-linux.
        # This is safe as it's used as a client-side dependency for Bottles/Wine.
        openldap = prev.openldap.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
      })
    ];

    programs.nix-ld.enable = true;

    programs.neovim = {
      defaultEditor = true;
      enable = true;
      viAlias = true;
    };

    environment.systemPackages = with pkgs; [
      btop
      fd
      git
      powershell
      ripgrep
      usbutils
      wget
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-mono
    ];
  };
}
