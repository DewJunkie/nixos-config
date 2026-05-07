# Troubleshooting

This document contains common issues and their solutions for the `nix-dlm` host.

## Networking

### Route Priority (Metric) Issues
If both the bridge (`br0`) and the wireless adapter have valid IP addresses but you lack internet access, it may be due to incorrect route priorities. If the bridge is connected but not providing internet, you may need to increase the priority of the wireless connection to troubleshoot.

In networking, a **lower metric** value means a **higher priority**.

#### Temporary Fix (using `nmcli`)
You can adjust the route metric of a connection on the fly. For example, to give the bridge a lower priority (higher metric) than the wireless:

1. List your connections:
   ```bash
   nmcli connection show
   ```
2. Increase the metric of the bridge (e.g., to 1000):
   ```bash
   sudo nmcli connection modify br0 ipv4.route-metric 1000
   ```
3. Decrease the metric of your wireless connection (e.g., to 50):
   ```bash
   sudo nmcli connection modify <wifi-connection-name> ipv4.route-metric 50
   ```
4. Re-apply the connections:
   ```bash
   sudo nmcli connection up br0
   sudo nmcli connection up <wifi-connection-name>
   ```

#### Permanent Fix (NixOS Configuration)
To set a permanent route metric in your configuration, modify `modules/features/networking.nix`.

Example for `br0`:
```nix
"br0" = {
  connection = {
    id = "br0";
    type = "bridge";
    interface-name = "br0";
    autoconnect = true;
  };
  ipv4 = {
    method = "auto";
    route-metric = 100; # Lower number = Higher priority
  };
  # ...
};
```

After modifying the file, apply the changes:
```bash
git add .
sudo nixos-rebuild test --flake .#nix-dlm
```

### Checking the Default Gateway
If you have an IP address but no internet, check which interface is being used for the default gateway:
```bash
ip route show default
```
The line starting with `default via ... dev <interface>` tells you which interface is carrying your internet traffic. If it's the wrong one, use the `nmcli` instructions above to adjust the metric.

### Bringing an Interface Up/Down
If you need to completely isolate an interface to test connectivity on another (e.g., turning off the bridge to force traffic over WiFi), you can bring it down.

#### Using `nmcli` (Recommended)
This is the preferred method on NixOS when using NetworkManager, as it handles the connection state and prevents the interface from automatically reconnecting if using `down`.

- **To bring an interface down:**
  ```bash
  sudo nmcli connection down br0
  ```
- **To bring an interface up:**
  ```bash
  sudo nmcli connection up br0
  ```

#### Using `ip link` (Temporary/Manual)
This is a lower-level command that changes the administrative state of the interface. Note that NetworkManager might try to bring it back up automatically if it is set to autoconnect.

- **To bring an interface down:**
  ```bash
  sudo ip link set br0 down
  ```
- **To bring an interface up:**
  ```bash
  sudo ip link set br0 up
  ```

## Offline Diagnostics & Data Collection
If you are currently experiencing the issue, run these commands and save the output. This data will help an agent or yourself diagnose the root cause once you are back online.

### 1. Capture Routing & Interface State
Run these to see exactly how the kernel is prioritizing traffic:
```bash
# Show all routes with metrics
ip route show

# Show interface status and IP addresses
ip addr show

# Show neighbor table (ARP) to see if the gateway is reachable
ip neighbor show
```

### 2. NetworkManager Status
Check if NetworkManager sees any issues with the bridge or its slaves:
```bash
# Show detailed connection status
nmcli connection show

# Show device status
nmcli device status

# Show detailed information for the bridge
nmcli device show br0
```

### 3. Kernel & System Logs
Look for errors related to the bridge, STP, or the ethernet driver:
```bash
# Search for bridge or eth0 related errors in the current boot
sudo journalctl -b 0 | grep -Ei "br0|eth0|bridge|stp" | tail -n 50
```

### 4. Saving for Later
You can pipe these to a file to show an agent later:
```bash
(
  echo "--- IP ROUTES ---"; ip route show;
  echo "--- IP ADDR ---"; ip addr show;
  echo "--- NMCLI DEV ---"; nmcli device status;
  echo "--- JOURNAL ---"; sudo journalctl -b 0 | grep -Ei "br0|eth0|bridge" | tail -n 20
) > /tmp/network-debug.log
```
