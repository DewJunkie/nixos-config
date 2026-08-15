{ self, inputs, ... }: {
  flake.nixosModules.desktop = { config, pkgs, breezy-desktop, ... }: {
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
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    
    hardware.amdgpu.opencl.enable = true;

    services.asusd = {
      enable = true;
    };

    #gamescope -w 1920 -h 1080 -W 3840 -H 2160 -f -F fsr -- %command%

    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };
  };
}
