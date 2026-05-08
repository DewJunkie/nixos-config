{ self, inputs, ... }: {
  flake.nixosModules.base = { config, pkgs, breezy-desktop, ... }: {
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.enableContainers = true;

    console.font = "CaskaydiaMono NF";

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

    nix.settings = {
      download-buffer-size = 524288000; # 500 MB
      experimental-features = [ "nix-command" "flakes" ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [
      "libsoup-2.74.3"
    ];

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

    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-mono
    ];

    system.stateVersion = "25.05";
  };
}
