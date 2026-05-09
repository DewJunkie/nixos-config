{ self, inputs, ... }: {
  flake.nixosModules.llm = { config, pkgs, ... }: {
    # NixOS OCI-containers module allows you to run Docker/Podman containers
    # declaratively. Since Lemonade isn't in nixpkgs yet, this is the best way
    # to get full hardware acceleration with minimal friction.
    virtualisation.oci-containers = {
      backend = "podman"; 
      containers."lemonade-server" = {
        # Using the official GHCR image as per their latest documentation
        image = "ghcr.io/lemonade-sdk/lemonade-server:latest";
        
        ports = [ "13305:13305" ];

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
          "--device=/dev/accel/accel0" # Added for your NPU support

          # Permissions: Using numeric IDs (303 for render, 26 for video) 
          # to avoid "group not found" errors in the container.
          "--group-add=26"
          "--group-add=303"

          # Shared Memory: Increased to 32GB for 120B+ models
          "--shm-size=32g"
        ];
      };
    };

    # Ensure the host directories exist with the correct permissions
    systemd.tmpfiles.rules = [
      "d /var/lib/lemonade 0755 root root -"
      "d /var/lib/lemonade/hf-cache 0755 root root -"
      "d /var/lib/lemonade/llama-models 0755 root root -"
      "d /var/lib/lemonade/recipe-cache 0755 root root -"
    ];

    networking.firewall.allowedTCPPorts = [ 13305 ];
  };
}
