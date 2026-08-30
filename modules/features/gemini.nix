{ self, inputs, ... }: {
  flake.nixosModules.gemini = { config, pkgs, nixpkgs-unstable, ... }:
    let
      pkgs-unstable = import nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config = config.nixpkgs.config;
      };
    in
    {
      environment.systemPackages = [
        pkgs-unstable.antigravity-cli
        pkgs-unstable.antigravity-ide
      ];
    };
}
