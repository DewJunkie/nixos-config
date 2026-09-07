{ self, inputs, ... }: {
  flake.nixosConfigurations.nix-dlm = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit (inputs) breezy-desktop nixpkgs-dewjunkie nixpkgs-unstable; };
    modules = [
      ({ pkgs, ... }: {
        nixpkgs.hostPlatform = "x86_64-linux";
        nix.settings.download-buffer-size = 524288000; # 500 MB
        time.timeZone = "America/Chicago";
        system.stateVersion = "25.05";

        nixpkgs.config.permittedInsecurePackages = [
          "libsoup-2.74.3"
          "pnpm-10.29.2"
        ];

        environment.systemPackages = with pkgs; [
          amdgpu_top
          nvtopPackages.amd
        ];
      })
      self.nixosModules.base
      self.nixosModules.desktop
      self.nixosModules.networking
      self.nixosModules.bluetooth
      self.nixosModules.virtualization
      self.nixosModules.viture
      self.nixosModules.llm
      self.nixosModules.DewJunkie
      self.nixosModules.gemini
      self.nixosModules.performance
      self.nixosModules.development
      self.nixosModules.vpn
      inputs.breezy-desktop.nixosModules.breezy-desktop
      ./_configuration.nix
      ./_hardware.nix
    ];
  };
}
