{ self, inputs, ... }: {
  flake.nixosModules.networking = { config, pkgs, ... }: {
    networking = {
      useDHCP = false;
      hostName = "nix-dlm";
      usePredictableInterfaceNames = false;
      # Enable networking
      networkmanager = {
        enable = true;
        settings.main.no-auto-default = "a0:ce:c8:85:e7:c6";
        ensureProfiles.profiles = {
          "br0" = {
            connection = {
              id = "br0";
              type = "bridge";
              interface-name = "br0";
              autoconnect = true;
            };
            bridge = {
              stp = false;
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
            ethernet.mac-address = "a0:ce:c8:85:e7:c6";
          };
          "br0-slave-eth0" = {
            connection = {
              id = "br0-slave-eth0";
              type = "ethernet";
              interface-name = "eth0";
              master = "br0";
              slave-type = "bridge";
              autoconnect = true;
            };
            ipv4.method = "disabled";
            ipv6.method = "ignore";
          };
        };
      };
    };

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
