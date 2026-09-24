{ self, inputs, ... }: {
  flake.nixosModules.development = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      clang
      clang-tools
      cmake
      dotnet-sdk_10
      gcc_multi
      gh
      github-copilot-cli
      gnumake
      javaPackages.compiler.openjdk21
      kubectl
      meld
      nixfmt
      nodejs
      opencode
      python3
      tree-sitter
      uv
      vscode
    ];
  };
}
