{ self, inputs, ... }: {
  flake.nixosModules.viture = { config, pkgs, breezy-desktop, ... }: {
    nixpkgs.overlays = [
      breezy-desktop.overlays.default
    ];

    # Breezy Desktop for Viture XR glasses
    services.breezy-desktop = {
      enable = true;
      gnome.enable = true;
    };
  };
}
