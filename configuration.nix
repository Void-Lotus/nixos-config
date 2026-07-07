# Core NixOS System Configuration
{ config, pkgs, inputs, ... }:

let
  sddm-blur-theme = pkgs.stdenv.mkDerivation {
    name = "sddm-blur-theme";
    src = ./modules/desktop/sddm-theme;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sddm-blur-theme
      cp -r * $out/share/sddm/themes/sddm-blur-theme
      rm -f $out/share/sddm/themes/sddm-blur-theme/theme.conf
      ln -s /var/cache/sddm-wallpaper/theme.conf $out/share/sddm/themes/sddm-blur-theme/theme.conf
    '';
  };
in
{
  # Core System Strategy
  system.stateVersion = "26.05"; # Target base matching installation

  # Flake & Package Manager Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = 2;
    cores = 2;
    trusted-users = [ "root" "voidlotus" ];
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Automatically prepend ~/.local/bin to PATH for all users/shells
  environment.localBinInPath = true;

  # Import DoD CA Certificates into the system trust store
  security.pki.certificateFiles = [
    ./certs/dod-ca-bundle.pem
  ];

  # Declarative configuration for Zen Browser policies (Firefox is handled via programs.firefox.policies)
  environment.etc = {
    "zen/policies/policies.json".text = builtins.toJSON {
      policies = {
        Certificates = {
          ImportEnterpriseRoots = true;
        };
        SecurityDevices = {
          "OpenSC PKCS11" = "/run/current-system/sw/lib/opensc-pkcs11.so";
        };
      };
    };
  };

  # Bootloader configurations
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Optimize kernel with CachyOS scheduler and optimizations (Chaotic Nyx)
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # Enable networking
  networking.networkmanager.enable = true;

  # Locale Configuration
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment (disabled as we use Niri + Noctalia)
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-blur-theme";
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qt5compat
      sddm-blur-theme
    ];
  };


  # Activation script to initialize the shared SDDM wallpaper directory
  system.activationScripts.sddm-wallpaper-init = {
    text = ''
      mkdir -p /var/cache/sddm-wallpaper
      chown voidlotus:sddm /var/cache/sddm-wallpaper
      chmod 775 /var/cache/sddm-wallpaper
      
      # If the default theme.conf does not exist, write a default layout configuration
      if [ ! -f /var/cache/sddm-wallpaper/theme.conf ]; then
        cat << 'EOF' > /var/cache/sddm-wallpaper/theme.conf
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

HeaderTextColor="#cdd6f4"
DateTextColor="#cdd6f4"
TimeTextColor="#cdd6f4"
FormBackgroundColor="#1e1e2e"
BackgroundColor="#1e1e2e"
DimBackgroundColor="#1e1e2e"
LoginFieldBackgroundColor="#1e1e2e"
PasswordFieldBackgroundColor="#1e1e2e"
LoginFieldTextColor="#89b4fa"
PasswordFieldTextColor="#89b4fa"
UserIconColor="#a6adc8"
PasswordIconColor="#a6adc8"
PlaceholderTextColor="#a6adc8"
WarningColor="#f38ba8"
LoginButtonTextColor="#11111b"
LoginButtonBackgroundColor="#89b4fa"
SystemButtonsIconsColor="#cdd6f4"
SessionButtonTextColor="#cdd6f4"
VirtualKeyboardButtonTextColor="#cdd6f4"
DropdownTextColor="#cdd6f4"
DropdownSelectedBackgroundColor="#89b4fa"
DropdownBackgroundColor="#313244"
HighlightTextColor="#11111b"
HighlightBackgroundColor="#89b4fa"
HighlightBorderColor="#313244"
HoverUserIconColor="#a6adc8"
HoverPasswordIconColor="#a6adc8"
HoverSystemButtonsIconsColor="#89b4fa"
HoverSessionButtonTextColor="#89b4fa"
HoverVirtualKeyboardButtonTextColor="#89b4fa"

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
        chown voidlotus:sddm /var/cache/sddm-wallpaper/theme.conf
        chmod 664 /var/cache/sddm-wallpaper/theme.conf
      fi

      # Setup default wallpaper/blurred wallpaper if not present
      if [ ! -f /var/cache/sddm-wallpaper/background_blurred.png ]; then
        if [ -f "/home/voidlotus/Pictures/wallpapers/Green Void Lotus.png" ]; then
          cp "/home/voidlotus/Pictures/wallpapers/Green Void Lotus.png" /var/cache/sddm-wallpaper/background_blurred.png
          cp "/home/voidlotus/Pictures/wallpapers/Green Void Lotus.png" /var/cache/sddm-wallpaper/background.png
        fi
        chown voidlotus:sddm /var/cache/sddm-wallpaper/background* || true
        chmod 664 /var/cache/sddm-wallpaper/background* || true
      fi
    '';
  };
  # services.desktopManager.plasma6.enable = true;

  # Enable Niri Window Manager and Noctalia Shell (Now handled in cachy-niri.nix)
  # programs.niri.enable = true;
  # programs.noctalia.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents and install HP printer drivers
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  # Enable Avahi for network printer autodiscovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable basic firewall
  networking.firewall = {
    enable = true;
  };

  # Enable 32-bit graphics libraries systemwide
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # CAC Smartcard support
  services.pcscd.enable = true;

  # GNOME Keyring for credential persistence (Now handled in cachy-niri.nix)
  # services.gnome.gnome-keyring.enable = true;
  # security.pam.services.sddm.enableGnomeKeyring = true;

  # User Accounts & default shell
  users.users.voidlotus = {
    isNormalUser = true;
    description = "Void Lotus";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };

  # Enable Zsh and Dynamic Linker (required for Antigravity's agy agent and generic binaries)
  programs.zsh.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      alsa-lib
      dbus
      openssl
      glib
      libx11
      libxcursor
      libxrandr
      libxi
      libxml2
    ];
  };

  # Install Firefox and configure policies for DoD certs and PKCS#11 CAC support
  programs.firefox = {
    enable = true;
    policies = {
      Certificates = {
        ImportEnterpriseRoots = true;
      };
      SecurityDevices = {
        "OpenSC PKCS11" = "/run/current-system/sw/lib/opensc-pkcs11.so";
      };
    };
  };

  # Enable Thunar, Thunar Archive Plugin, and xfconf (required for Thunar settings)
  programs.thunar = {
    enable = true;
    plugins = [
      pkgs.thunar-archive-plugin
    ];
  };
  programs.xfconf.enable = true;

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Core System Packages
  environment.systemPackages = with pkgs; [
    # Custom SDDM Theme
    sddm-blur-theme

    # Version Control & Terminal
    git
    alacritty
    
    # File Manager & Archive Utilities
    thunar
    file-roller
    zip
    p7zip
    
    # Core CLI Utilities / Dev Tools
    vim
    micro
    wget
    curl
    ripgrep
    fd
    jq
    unzip

    # CAC Smartcard components
    pcsclite
    ccid
    opensc
    pcsc-tools
    pkcs11helper

    # Zen Browser (via Flake input)
    inputs.zen-browser.packages.${pkgs.system}.default

    # NiriMod (via Flake input)
    inputs.nirimod.packages.${pkgs.system}.default

    # Keyring management & GUI
    seahorse
    gcr
  ];

  # System Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
      sansSerif = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
      serif = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
    };
  };

  # Enable Flatpak support
  services.flatpak.enable = true;
}
