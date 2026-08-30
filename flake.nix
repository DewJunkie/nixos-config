{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    breezy-desktop.url = "github:johnrizzo1/breezy-desktop-nixos";
    nixpkgs-dewjunkie.url = "github:DewJunkie/nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      inputs.import-tree ./modules
    );
}
