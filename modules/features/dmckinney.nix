{ self, inputs, ... }: {
  flake.nixosModules.dmckinney = { config, pkgs, ... }: {
    users.groups.dmckinney = { };
    users.users.dmckinney = {
      isNormalUser = true;
      description = "Duane McKinney";
      extraGroups = [
        "networkmanager"
        "dmckinney"
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUR99cLGL6qic9Qq7lmncvAXG5FTospm/oPPl1kvNY2 dmckinney"
      ];
    };

    security.sudo.extraConfig = ''
      dmckinney ALL=(ALL) NOPASSWD: ALL
    '';
  };
}

