{ self, inputs, ... }: {
  flake.nixosConfigurations.surf-dlm = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit (inputs) breezy-desktop nixpkgs-dewjunkie nixpkgs-unstable; };
    modules = [
      ({ pkgs, ... }: {
        networking.hostName = "surf-dlm";

        users.groups.dmckinney = { };
        users.users.dmckinney = {
          isNormalUser = true;
          description = "Duane McKinney";
          extraGroups = [
            "networkmanager"
            "dmckinney"
            "wheel"
          ];
        };

        system.stateVersion = "26.05";

        security.sudo.extraConfig = ''
          dmckinney ALL=(ALL) NOPASSWD: ALL
        '';

        environment.systemPackages = with pkgs; [
          brightnessctl
        ];
      })
      self.nixosModules.base
      self.nixosModules.desktop
      self.nixosModules.gemini
      ./_hardware-configuration.nix
    ];
  };
}
