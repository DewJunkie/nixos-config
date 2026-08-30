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

  # Gaming & host-specific applications
  programs.steam.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    asusctl
    (bottles.override {
      removeWarningPopup = true;
    })
    ckan
    gnomeExtensions.battery-health-charging
    polkit
    prismlauncher
    wine
  ];
}
