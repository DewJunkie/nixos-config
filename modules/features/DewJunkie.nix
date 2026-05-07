{ self, inputs, ... }: {
  flake.nixosModules.DewJunkie = { config, pkgs, nixpkgs-dewjunkie, ... }:
    let
      pkgs-dewjunkie = import nixpkgs-dewjunkie {
        system = pkgs.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "libsoup-2.74.3"
          ];
        };
      };
    in
    {
      environment.systemPackages = [
        pkgs-dewjunkie.citrix_workspace
      ];
    };
}
