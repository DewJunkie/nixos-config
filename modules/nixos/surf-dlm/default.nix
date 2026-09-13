{ self, inputs, ... }: {
  flake.nixosConfigurations.surf-dlm = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit (inputs) breezy-desktop nixpkgs-dewjunkie nixpkgs-unstable; };
    modules = [
      ({ pkgs, ... }: {
        networking.hostName = "surf-dlm";

        system.stateVersion = "26.05";

        environment.systemPackages = with pkgs; [
          brightnessctl
        ];
      })
      self.nixosModules.base
      self.nixosModules.dmckinney
      self.nixosModules.desktop
      self.nixosModules.gemini
      self.nixosModules.development
      ./_hardware-configuration.nix
    ];
  };
}
