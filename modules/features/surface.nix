{ self, inputs, ... }: {
  flake.nixosModules.surface =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      unbindTypecover = pkgs.writeShellScript "unbind-typecover" ''
        ACTION="''${1:-poweroff}"
        if [ "$ACTION" = "poweroff" ] || [ "$ACTION" = "halt" ]; then
          for dev in /sys/bus/usb/devices/*/idVendor; do
            if [ -f "$dev" ]; then
              read -r vendor < "$dev" 2>/dev/null || true
              if [ "$vendor" = "045e" ]; then
                devpath="''${dev%/idVendor}"
                devname="''${devpath##*/}"
                echo "$devname" > /sys/bus/usb/drivers/usb/unbind 2>/dev/null || true
              fi
            fi
          done
        fi
      '';
    in
    {
      # Fix for Microsoft Surface Go / Surface Type Cover shutdown hang:
      # The Surface Type Cover (USB 045e:096f) fails to cleanly disconnect during
      # shutdown, leaving the Surface Embedded Controller (EC) in an active/error state.
      # The screen turns off but power rails stay energized, draining the battery completely
      # and requiring a 10-30s power button hold (EC reset) to power back on.
      # Unbinding Microsoft (045e) USB devices before poweroff ensures the EC cuts power cleanly.

      systemd.shutdown."unbind-typecover" = unbindTypecover;

      systemd.shutdownRamfs.contents."/etc/systemd/system-shutdown/unbind-typecover".source =
        unbindTypecover;

      systemd.services.unbind-typecover = {
        description = "Unbind Surface Type Cover before poweroff";
        wantedBy = [ "poweroff.target" "halt.target" ];
        before = [ "poweroff.target" "halt.target" "shutdown.target" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${unbindTypecover} poweroff";
        };
      };
    };
}
