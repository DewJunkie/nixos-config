{ self, inputs, ... }: {
  flake.nixosModules.vpn = { config, pkgs, ... }: {
    environment.systemPackages = [
      pkgs.wireguard-tools
    ];

    # WireGuard support is built into NetworkManager and kernel.
    # Connections can be imported safely without committing secrets to git:
    #   sudo nmcli connection import type wireguard file /path/to/wg0.conf
  };
}
