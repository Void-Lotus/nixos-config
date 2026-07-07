# User Home Manager Configuration
{ config, pkgs, ... }:

{
  home.username = "voidlotus";
  home.homeDirectory = "/home/voidlotus";
  home.stateVersion = "26.05";

  # User packages
  home.packages = with pkgs; [
    fastfetch
    btop
    acpi
    lsd
    cava
    ghostty
    kitty
    rofi
    wallust
    grim
    slurp
    swappy
    pamixer
    playerctl
    brightnessctl
    networkmanagerapplet
    blueman
    spicetify-cli
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    joplin
    google-chrome
    gh
    discord
    signal-desktop
  ];

  # XDG Config File Mappings
  xdg.configFile = {
    "alacritty/alacritty.toml".source = ./configs/alacritty/alacritty.toml;
    "btop" = { source = ./configs/btop; recursive = true; };
    "cava" = { source = ./configs/cava; recursive = true; };
    "fastfetch".source = ./configs/fastfetch;
    "ghostty" = { source = ./configs/ghostty; recursive = true; };
    "kitty" = { source = ./configs/kitty; recursive = true; };
    "niri/config.kdl".source = ./configs/niri/config.kdl;
    "niri/cfg" = { source = ./configs/niri/cfg; recursive = true; };
    "noctalia" = { source = ./configs/noctalia; recursive = true; };
    "noctalia/wallpaper_change.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Script triggered by Noctalia when wallpaper changes

        set -euo pipefail

        # 1. Read current wallpaper path
        wallpaper_path="''${1:-}"
        if [ -z "$wallpaper_path" ]; then
            settings_file="$HOME/.local/state/noctalia/settings.toml"
            if [ -f "$settings_file" ]; then
                wallpaper_path=$(${pkgs.gawk}/bin/awk -F'"' '/\[wallpaper\.last\]/{flag=1;next} /^\[/{flag=0} flag && /path/{print $2; exit}' "$settings_file")
            fi
        fi

        if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
            echo "Could not find a valid wallpaper path: $wallpaper_path" >&2
            exit 1
        fi

        echo "Active wallpaper: $wallpaper_path"

        # 2. Run Wallust to update Wallust templates
        if [ -x "${pkgs.wallust}/bin/wallust" ]; then
            echo "Running Wallust..."
            # Remove read-only symlinks from Nix store so Wallust can write new files
            for file in "$HOME/.config/rofi/wallust/colors-rofi.rasi" \
                        "$HOME/.config/kitty/kitty-themes/01-Wallust.conf" \
                        "$HOME/.config/cava/config" \
                        "$HOME/.config/ghostty/wallust.conf"; do
                if [ -L "$file" ]; then
                    rm -f "$file"
                fi
            done
            ${pkgs.wallust}/bin/wallust run -s "$wallpaper_path" || true
        else
            echo "Wallust command not found." >&2
        fi

        # 3. Create SDDM cache directory if it doesn't exist
        sddm_cache="/var/cache/sddm-wallpaper"
        if [ ! -d "$sddm_cache" ]; then
            echo "SDDM cache directory $sddm_cache does not exist." >&2
            exit 0
        fi

        # 4. Copy wallpaper and generate blurred version for SDDM
        echo "Generating blurred wallpaper for SDDM..."
        ${pkgs.coreutils}/bin/cp -f "$wallpaper_path" "$sddm_cache/background.png" || true

        # Generate Gaussian blurred version
        if [ -x "${pkgs.imagemagick}/bin/magick" ]; then
            ${pkgs.imagemagick}/bin/magick "$wallpaper_path" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x30 "$sddm_cache/background_blurred.png" || true
        else
            # Fallback to copy if no ImageMagick is installed
            ${pkgs.coreutils}/bin/cp -f "$wallpaper_path" "$sddm_cache/background_blurred.png" || true
        fi

        # 5. Extract colors from Wallust and write theme.conf for SDDM
        rofi_wallust="$HOME/.config/rofi/wallust/colors-rofi.rasi"

        if [ -f "$rofi_wallust" ]; then
            extract_color() {
                local key="$1"
                ${pkgs.gnugrep}/bin/grep -oP "$key:\s*\K#[A-Fa-f0-9]+" "$rofi_wallust" | ${pkgs.coreutils}/bin/head -n1 || echo "#ffffff"
            }

            color0=$(extract_color "color1")
            color1=$(extract_color "color0")
            color7=$(extract_color "color14")
            color10=$(extract_color "color10")
            color12=$(extract_color "color12")
            color13=$(extract_color "color13")
            foreground=$(extract_color "foreground")

            [ -z "$color0" ] && color0="#ffffff"
            [ -z "$color1" ] && color1="#1e1e2e"
            [ -z "$color7" ] && color7="#a6adc8"
            [ -z "$color10" ] && color10="#11111b"
            [ -z "$color12" ] && color12="#89b4fa"
            [ -z "$color13" ] && color13="#cdd6f4"

            cat <<EOF > "$sddm_cache/theme.conf"
[General]
ScreenWidth="1920"
ScreenHeight="1080"
ScreenPadding=""
FontSize="13"
KeyboardSize="0.4"
RoundCorners="20"
Locale=""
HourFormat="HH:mm"
DateFormat="dddd d MMMM"
HeaderText=""
BackgroundPlaceholder=""
Background="/var/cache/sddm-wallpaper/background.png"
BackgroundSpeed=""
PauseBackground=""
DimBackground="0.0"
CropBackground="true"
BackgroundHorizontalAlignment="center"
BackgroundVerticalAlignment="center"

HeaderTextColor="$color13"
DateTextColor="$color13"
TimeTextColor="$color13"
FormBackgroundColor="$color1"
BackgroundColor="$color1"
DimBackgroundColor="$color1"
LoginFieldBackgroundColor="$color1"
PasswordFieldBackgroundColor="$color1"
LoginFieldTextColor="$color12"
PasswordFieldTextColor="$color12"
UserIconColor="$color7"
PasswordIconColor="$color7"
PlaceholderTextColor="$color7"
WarningColor="#343746"
LoginButtonTextColor="$foreground"
LoginButtonBackgroundColor="$color1"
SystemButtonsIconsColor="$color13"
SessionButtonTextColor="$color13"
VirtualKeyboardButtonTextColor="$color13"
DropdownTextColor="$foreground"
DropdownSelectedBackgroundColor="$color13"
DropdownBackgroundColor="$color1"
HighlightTextColor="$color10"
HighlightBackgroundColor="$color12"
HighlightBorderColor="$color1"
HoverUserIconColor="$color7"
HoverPasswordIconColor="$color7"
HoverSystemButtonsIconsColor="$color13"
HoverSessionButtonTextColor="$color13"
HoverVirtualKeyboardButtonTextColor="$color13"

PartialBlur="true"
FullBlur=""
BlurMax="32"
Blur=""
HaveFormBackground="false"
FormPosition="left"
VirtualKeyboardPosition="center"
HideVirtualKeyboard="false"
HideSystemButtons="false"
HideLoginButton="false"
ForceLastUser="true"
PasswordFocus="true"
HideCompletePassword="true"
AllowEmptyPassword="false"
AllowUppercaseLettersInUsernames="false"
BypassSystemButtonsChecks="false"
RightToLeftLayout="false"
EOF
            ${pkgs.coreutils}/bin/chmod 664 "$sddm_cache/theme.conf" 2>/dev/null || true
        else
            echo "Wallust colors not found at $rofi_wallust, keeping default theme.conf" >&2
        fi

        echo "SDDM wallpaper and colors successfully updated."
      '';
    };
    "qt5ct" = { source = ./configs/qt5ct; recursive = true; };
    "qt6ct" = { source = ./configs/qt6ct; recursive = true; };
    "rofi" = { source = ./configs/rofi; recursive = true; };
    "spicetify" = { source = ./configs/spicetify; recursive = true; };
    "wallust" = { source = ./configs/wallust; recursive = true; };
  };

  # Custom Oh-My-Zsh Theme mapping
  home.file.".oh-my-zsh/custom/themes/agnosterzak.zsh-theme".source = ./configs/zsh-themes/agnosterzak.zsh-theme;

  # Configure GTK and Icon Themes
  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  # Configure Cursor Theme
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Shell configurations to ensure agy path is exported and Oh-My-Zsh is set up
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "lsd";
      l = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      lt = "ls --tree";
      rs = "sudo nixos-rebuild switch --no-reexec --flake /home/voidlotus/nixos-config#nixlotus";
    };

    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      custom = "${config.home.homeDirectory}/.oh-my-zsh/custom";
      theme = "agnosterzak";
    };

    initContent = ''
      # Antigravity CLI PATH
      export PATH="$HOME/.local/bin:$PATH"

      # Fastfetch config
      if [ -f "$HOME/.config/fastfetch/config-compact.jsonc" ]; then
        fastfetch -c "$HOME/.config/fastfetch/config-compact.jsonc"
      fi
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # Antigravity CLI PATH
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
