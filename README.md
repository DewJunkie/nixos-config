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

## 🧩 Running Unpatched Binaries & VS Code Extensions (nix-ld)

`nix-ld` is enabled in `modules/features/base.nix` to allow unpatched dynamically linked Linux binaries (such as VS Code extensions, language servers, and downloaded binaries) to run on NixOS.

### Handling Missing Library Errors

If an unpatched binary fails with an error like:
```text
error while loading shared libraries: lib<name>.so.<version>: cannot open shared object file: No such file or directory
```

1. **Find the Nix package providing the library:**
   - Use `nix-locate` (from `nix-index`):
     ```bash
     nix-locate --top-level lib<name>.so.<version>
     ```
   - Or search for the package on [search.nixos.org](https://search.nixos.org).

2. **Add the package to `programs.nix-ld.libraries` in `modules/features/base.nix`:**
   ```nix
   programs.nix-ld = {
     enable = true;
     libraries = with pkgs; [
       # Default libraries are included; add extra packages here:
       openssl
       zlib
       # <missing-package>
     ];
   };
   ```

3. **Rebuild the system:**
   ```bash
   git add modules/features/base.nix
   sudo nixos-rebuild switch --flake .#nix-dlm
   ```

## 📋 Past Friction Points
- **Citrix:** If using `citrix_workspace`, ensure `libsoup-2.74.3` is in `permittedInsecurePackages` for that specific nixpkgs instance.
- **Warnings:** If a build or evaluation warning is encountered, the agent **must** prompt the user to ask if the warning should be addressed. If the user accepts, the agent should proceed to fix the warning.
  - **Exception:** The warning `evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'` is a known upstream issue and should be **ignored**. Do not attempt to fix it or prompt the user about it.



