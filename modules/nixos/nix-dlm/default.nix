{ self, inputs, ... }: {
  flake.nixosConfigurations.nix-dlm = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit (inputs) breezy-desktop nixpkgs-dewjunkie; };
    modules = [
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      self.nixosModules.base
      self.nixosModules.desktop
      self.nixosModules.networking
      self.nixosModules.bluetooth
      self.nixosModules.virtualization
      self.nixosModules.viture
      self.nixosModules.llm
      self.nixosModules.DewJunkie
      self.nixosModules.performance
      inputs.breezy-desktop.nixosModules.breezy-desktop
      ./_configuration.nix
      ./_hardware.nix
    ];
  };
}
