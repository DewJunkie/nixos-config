{ config, pkgs, ... }:

{
  # Define a user account.
  users.groups.dmckinney = {};
  users.users.dmckinney = {
    isNormalUser = true;
    description = "Duane McKinney";
    extraGroups = [ 
      "networkmanager"
      "dmckinney"
      "kvm"
      "libvirtd"
      "podman"
      "wheel"
    ];
  };

  security.sudo.extraConfig = ''
    dmckinney ALL=(ALL) NOPASSWD: ALL
  '';

  programs.neovim = {
    defaultEditor = true;
    enable = true;
    viAlias = true;
  };

  # Install applications
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.thunderbird.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    asusctl
    (bottles.override {
      removeWarningPopup = true;
    })
    # citrix_workspace
    antigravity
    ckan
    cmake
    digikam
    discord
    dotnet-sdk_10
    fd
    gcc_multi
    gemini-cli
    gh
    git
    github-copilot-cli
    gnome-boxes
    gnomeExtensions.battery-health-charging
    gnomeExtensions.gsconnect
    gnumake
    javaPackages.compiler.openjdk21
    kubectl
    libreoffice
    litellm
    lmstudio
    meld
    microsoft-edge
    ollama
    opencode
    podman-compose
    podman-desktop
    polkit
    powershell
    prismlauncher
    remmina
    ripgrep
    tree-sitter
    virt-viewer
    usbutils
    vscode
    wezterm
    wine
  ];
}
