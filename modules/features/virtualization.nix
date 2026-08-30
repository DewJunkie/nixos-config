{ self, inputs, ... }: {
  flake.nixosModules.virtualization = { config, pkgs, ... }: {
    virtualisation = {
      containers.enable = true;
      # Allow remote-viewer to redirect usb devices
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      spiceUSBRedirection.enable = true;
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
        };
      };
    };

    programs.virt-manager.enable = true;
    services.spice-webdavd.enable = true;

    environment.systemPackages = with pkgs; [
      gnome-boxes
      podman-compose
      podman-desktop
      virt-viewer
    ];
  };
}
