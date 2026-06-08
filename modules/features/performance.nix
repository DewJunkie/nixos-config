{ self, inputs, ... }: {
  flake.nixosModules.performance = { config, pkgs, ... }: {
    services.tuned = {
      enable = true;
      
      # For GNOME users, it's better to map the PPD "performance" profile
      # to the TuneD "accelerator-performance" profile and set it as default.
      # This ensures the GNOME power slider correctly reflects and controls TuneD.
      ppdSupport = true;
      ppdSettings = {
        profiles = {
          performance = "accelerator-performance";
          balanced = "balanced";
          power-saver = "powersave";
        };
        main.default = "performance";
      };

      # Also recommend it as the default for cases where PPD might not be active
      # or for initial daemon selection.
      recommend = {
        accelerator-performance = { };
      };
    };
  };
}
