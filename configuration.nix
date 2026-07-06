# Core NixOS System Configuration
{ config, pkgs, inputs, ... }:

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
  services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Enable Niri Window Manager and Noctalia Shell (Now handled in cachy-niri.nix)
  # programs.niri.enable = true;
  # programs.noctalia.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

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

  # Install Firefox
  programs.firefox.enable = true;

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Core System Packages
  environment.systemPackages = with pkgs; [
    # Version Control & Terminal
    git
    alacritty
    
    # File Manager
    thunar
    
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
