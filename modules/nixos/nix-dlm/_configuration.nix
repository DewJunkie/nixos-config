{ config, pkgs, ... }:

{
  # Define a user account.
  users.groups.dmckinney = { };
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
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAsT5ME+ygIbLGqh2TyNVCx7aHGC+3EdFXMj4geHzSWArI/ToTP0g8YNFugTPF7EtXSaFF3YczAKx7GrBgAvH2EDCswDfUNDbvHeeCPCrEwfOmbvPPbn0PIKbvkeYBmB5AmmkOdH4leaXwREOZXH4PEkH9OehvmWTwHk2htxIRobcyyhh9zS5FrwralkyPUl2sfDunuxmdL56D/p+NwOuSep2PRGxW9dZBWNhp/pQbKZkUkRK2Gw4F8LIV2T3XOE3K1AqbQx4a23xhHjUQoLOcpPwrJMobBcX0thIHONzlaUhJ3l+2UBoD0LvR3w+qr96bvECNIuMdEGhhQ3llJjRtCw=="
    ]
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
