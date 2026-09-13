{ self, inputs, ... }: {
  flake.nixosModules.gaming = { config, pkgs, ... }: {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      (bottles.override {
        removeWarningPopup = true;
      })
      ckan
      prismlauncher
      wine
    ];
  };
}

