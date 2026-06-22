{ self, inputs, ... }: {
  flake.nixosModules.bluetooth = { config, pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
