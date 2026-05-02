{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-dewjunkie.url = "github:DewJunkie/nixpkgs";
    breezy-desktop.url = "github:johnrizzo1/breezy-desktop-nixos";
  };
  outputs = { self, nixpkgs, breezy-desktop, nixpkgs-dewjunkie, ... }: {
    nixosConfigurations.nix-dlm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit breezy-desktop nixpkgs-dewjunkie; };
      modules = [ 
        ./configuration.nix
        breezy-desktop.nixosModules.breezy-desktop
        {
          services.breezy-desktop = {
            enable = true;

            # Pick your desktop environment:
            gnome.enable = true;   # GNOME Shell extension + UI
            # kwin.enable = true;  # KDE Plasma 6 KWin plugin + UI

            # Optional:
            # vulkan.enable = true; # Vulkan layer for XR gaming
          };
        }
      ];
    };
  };
}
