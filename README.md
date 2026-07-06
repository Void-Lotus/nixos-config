# Void Lotus NixOS Configuration Flake

This repository contains the complete, declarative NixOS flake configuration for the `nixlotus` host. It sets up a highly customized, hardware-optimized Wayland desktop environment featuring the **Niri window manager** and the **Noctalia desktop shell**.

## Features
- **Window Manager:** [Niri](https://github.com/YaLTeR/niri) (Scrollable-tiling Wayland compositor)
- **Desktop Shell:** [Noctalia](https://github.com/noctalia-dev/noctalia) (Dynamic theming, system panels, widgets, and lockscreen)
- **Package Manager & Configs:** Nix Flakes & Home Manager (recursively mapped configs for writable templates)
- **Default Font:** JetBrains Mono (applied globally via Fontconfig for monospace, sans-serif, and serif)
- **CLI Utilities:** Git, Alacritty, Thunar, Kitty, Zsh (with Oh-My-Zsh), btop, fastfetch, and more.
- **Custom Keybinds:**
  - `Super + Return`: Open Alacritty
  - `Super + Shift + Return`: Open Thunar File Manager
  - `Super + D`: Open App Launcher
  - `Super + S`: Open Settings Panel
- **Custom Alias:**
  - `rs`: Quick rebuild and switch (`sudo nixos-rebuild switch --flake /home/voidlotus/nixos-config#nixlotus`)

---

## Walkthrough: Installation on a Clean NixOS Install

Follow these steps to deploy this configuration on a fresh, clean NixOS installation.

### Step 1: Install Git & Enable Flakes (if not already enabled)
During the initial NixOS installation or on the first boot, open a terminal and ensure `git` is available. If you don't have flakes enabled yet, you can run commands using the experimental feature flags:

```bash
nix-shell -p git
```

### Step 2: Clone this Repository
Clone this configuration repository into your home directory as `nixos-config`:

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL> ~/nixos-config
cd ~/nixos-config
```

### Step 3: Copy/Generate Your Hardware Configuration
Every computer requires a specific `hardware-configuration.nix` reflecting its drives, CPU, and peripherals. You must replace the template hardware configuration with one generated for your specific machine:

```bash
nixos-generate-config --show-hardware-config > hosts/nixlotus/hardware-configuration.nix
```

> [!IMPORTANT]
> Verify that the file path matches [hosts/nixlotus/hardware-configuration.nix](file:///home/voidlotus/nixos-config/hosts/nixlotus/hardware-configuration.nix). If you are changing the hostname from `nixlotus` to something else, you will need to update the hostname references in `flake.nix` and `configuration.nix`.

### Step 4: Clean up pre-existing XDG Config Symlinks (Prevent Activation Conflicts)
To avoid "Permission denied" or "Read-only file system" conflicts during the Home Manager activation step, make sure there are no pre-existing conflicting symlinks in your `~/.config` directory:

```bash
rm -rf ~/.config/{rofi,btop,cava,ghostty,kitty,noctalia,qt5ct,qt6ct,spicetify,wallust}
```

### Step 5: Build and Apply the Configuration
Run the rebuild command pointing to your flake directory. This will download all inputs, compile packages (including `nirimod` and `noctalia` directly from their respective source flakes), and apply the system and user configurations:

```bash
sudo nixos-rebuild switch --flake .#nixlotus
```

### Step 6: Log In and Enjoy
After the configuration successfully switches:
1. Reboot or log out of your current session.
2. At the SDDM login screen, select the **Niri** session.
3. Log in to load your customized, themed desktop!
4. From now on, you can rebuild and update your system from anywhere by simply running:
   ```bash
   rs
   ```

---

## File Structure
- `flake.nix`: Entrypoint defining inputs (nixpkgs, chaotic-nyx, noctalia, nirimod) and system modules.
- `configuration.nix`: Core NixOS system-level configuration (bootloader, accounts, default packages, global fonts).
- `home.nix`: User-level Home Manager configuration (packages, shell aliases, XDG config mappings).
- `modules/desktop/cachy-niri.nix`: Specific packages, portals, and service layers for Niri + Noctalia.
- `configs/`: Directory containing raw configs for your applications (Kitty, Alacritty, Rofi, Niri, Noctalia) which are mapped recursively into your home directory.
