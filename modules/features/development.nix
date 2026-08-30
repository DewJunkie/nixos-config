{ self, inputs, ... }: {
  flake.nixosModules.development = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      cmake
      dotnet-sdk_10
      gcc_multi
      gh
      github-copilot-cli
      gnumake
      javaPackages.compiler.openjdk21
      kubectl
      meld
      opencode
      tree-sitter
      uv
      vscode
    ];
  };
}
