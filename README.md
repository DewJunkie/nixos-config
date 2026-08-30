# Nix-DLM Configuration

NixOS flake configuration for the `nix-dlm` host.

## 🚀 Workflow (Crucial)
This repository uses Nix Flakes. Nix only "sees" files that are tracked by Git.
- **Mandatory:** Always run `git add .` before any `nixos-rebuild` command.
- **Testing changes:** `git add . && sudo nixos-rebuild test --flake .#nix-dlm`

## 🛠 Feature Modules
Functionality is modularized in `modules/features/`.
- To add a feature, create a `.nix` file in that directory.
- Enable it in `modules/nixos/nix-dlm/default.nix`.
- **Note:** Large packages or custom sources (like Citrix from `nixpkgs-dewjunkie`) should live in their own feature module.

## 🔓 Unfree & Insecure Packages
- Global unfree packages are allowed in `modules/features/base.nix`.
- For custom nixpkgs inputs, unfree/insecure permissions must be set during the `import` in the specific module (see `modules/features/DewJunkie.nix`).

## 🔄 Updating Dependencies & Flake Inputs

`flake.lock` pins exact revisions of all inputs (`nixpkgs`, `nixpkgs-unstable`, `breezy-desktop`, etc.).

### 1. Update Everything
To update all flake inputs to their latest upstream versions:
```bash
nix flake update
git add flake.lock
sudo nixos-rebuild switch --flake .#nix-dlm
```

### 2. Update a Specific Input / Toolset
To update only a single input without modifying everything else:
- **Fast-evolving tools (LLMs / AI tools via `nixpkgs-unstable`):**
  ```bash
  nix flake update nixpkgs-unstable
  ```
- **Core system / base packages (`nixpkgs`):**
  ```bash
  nix flake update nixpkgs
  ```
- **Custom / third-party inputs:**
  ```bash
  nix flake update breezy-desktop
  nix flake update nixpkgs-dewjunkie
  ```
Then apply:
```bash
git add flake.lock
sudo nixos-rebuild switch --flake .#nix-dlm
```

### 3. Inspecting & Previewing Updates
- **View lock metadata & last updated dates:**
  ```bash
  nix flake metadata
  ```
- **View lockfile commit changes:**
  ```bash
  git diff flake.lock
  ```
- **Preview package version differences before switching:**
  ```bash
  # Build to ./result without activating
  nix build .#nixosConfigurations.nix-dlm.config.system.build.toplevel
  # Compare newly built system against currently running system
  nix run nixpkgs#nvd -- diff /run/current-system ./result
  ```

## 📋 Past Friction Points
- **Citrix:** If using `citrix_workspace`, ensure `libsoup-2.74.3` is in `permittedInsecurePackages` for that specific nixpkgs instance.
- **Warnings:** If a build or evaluation warning is encountered, the agent **must** prompt the user to ask if the warning should be addressed. If the user accepts, the agent should proceed to fix the warning.
  - **Exception:** The warning `evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'` is a known upstream issue and should be **ignored**. Do not attempt to fix it or prompt the user about it.


