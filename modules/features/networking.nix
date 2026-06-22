{ self, inputs, ... }: {
  flake.nixosModules.networking = { config, pkgs, ... }: {
    networking = {
      useDHCP = false;
      hostName = "nix-dlm";
      usePredictableInterfaceNames = false;
      
      # Standard NixOS bridge configuration
      bridges."br0".interfaces = [ "eth0" ];
      interfaces."br0" = {
        #useDHCP = true;
        macAddress = "a0:ce:c8:85:e7:c6";
      };

      # NetworkManager configuration
      networkmanager = {
        enable = true;
        unmanaged = [ "eth0"  ];
      };
    };

    systemd.services.NetworkManager-wait-online.serviceConfig.TimeoutStartSec = "15s";

    networking.firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [ "br0" ];
      allowedTCPPortRanges = [
        # GSConnect/KDE Connect
        {from = 1714; to = 1764;}
      ];
      allowedUDPPortRanges = [
        # GSConnect/KDE Connect
        {from = 1714; to = 1764;}
      ];
    };

    boot.kernelModules = [ "br_netfilter" ];

    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 0;
      "net.bridge.bridge-nf-call-ip6tables" = 0;
      "net.bridge.bridge-nf-call-arptables" = 0;
    };
  };
}
