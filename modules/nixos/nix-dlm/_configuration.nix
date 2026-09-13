{ config, pkgs, ... }:

{
  # Host-specific applications & hardware utilities
  environment.systemPackages = with pkgs; [
    asusctl
    gnomeExtensions.battery-health-charging
    polkit
  ];
}
