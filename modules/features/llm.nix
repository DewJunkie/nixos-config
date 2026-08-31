{ self, inputs, ... }: {
  flake.nixosModules.llm = { config, pkgs, nixpkgs-unstable, ... }:
    let
      pkgs-unstable = import nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config = config.nixpkgs.config;
      };
    in
    {
      environment.systemPackages = [
        pkgs-unstable.litellm
        pkgs-unstable.lmstudio
        pkgs-unstable.ollama
        pkgs.mergerfs
      ];

      # MergerFS union pooling fast NVMe storage + SanDisk slow storage
      fileSystems."/var/lib/lemonade" = {
        fsType = "fuse.mergerfs";
        device = "/var/lib/lemonade-fast:/mnt/SanDisk/lemonade-slow";
        options = [
          "defaults"
          "allow_other"
          "use_ino"
          "category.create=ff"
          "nofail"
        ];
      };

      # NixOS OCI-containers module allows you to run Docker/Podman containers
    # declaratively. Since Lemonade isn't in nixpkgs yet, this is the best way
    # to get full hardware acceleration with minimal friction.
    virtualisation.oci-containers = {
      backend = "podman"; 
      containers."lemonade-server" = {
        # Using the official GHCR image as per their latest documentation
        image = "ghcr.io/lemonade-sdk/lemonade-server:latest";
        
        ports = [ 
          "13305:13305" 
          "9000:9000"
        ];

        # Official Environment Variables
        environment = {
          # Explicitly tell Lemonade to use the ROCm backend for llama.cpp
          "LEMONADE_LLAMACPP" = "rocm";
        };

        # Persistence (Volumes)
        # On NixOS, we map these to /var/lib/lemonade to keep your models 
        # and cache persistent across container restarts/rebuilds.
        volumes = [
          "/var/lib/lemonade/hf-cache:/root/.cache/huggingface"
          "/var/lib/lemonade/llama-models:/opt/lemonade/llama"
          "/var/lib/lemonade/recipe-cache:/root/.cache/lemonade"
        ];

        extraOptions = [
          # Hardware Passthrough
          "--device=/dev/kfd"
          "--device=/dev/dri"
          "--device=/dev/accel/accel0" # NPU support (requires IOMMU enabled)

          # Permissions: Using numeric IDs (303 for render, 26 for video) 
          # to avoid "group not found" errors in the container.
          "--group-add=26"
          "--group-add=303"

          # Shared Memory: Increased to 32GB for 120B+ models
          "--shm-size=32g"
        ];
      };
    };

    # Ensure the container service starts after the mergerfs union is mounted
    systemd.services.podman-lemonade-server = {
      after = [ "var-lib-lemonade.mount" ];
      wants = [ "var-lib-lemonade.mount" ];
    };

    # Ensure the host directories exist with the correct permissions
    systemd.tmpfiles.rules = [
      "d /var/lib/lemonade-fast 0755 root root -"
      "d /var/lib/lemonade-fast/hf-cache 0755 root root -"
      "d /var/lib/lemonade-fast/llama-models 0755 root root -"
      "d /var/lib/lemonade-fast/recipe-cache 0755 root root -"
      "d /var/lib/lemonade 0755 root root -"
    ];

    networking.firewall.allowedTCPPorts = [ 13305 9000 ];

    # Enable tuned daemon for performance optimizations
    services.tuned.enable = true;
  };
}
