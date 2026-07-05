# Core NixOS System Configuration
{ config, pkgs, ... }:

{
  # Core System Strategy
  system.stateVersion = "26.05"; # Target base matching installation

  # Flake & Package Manager Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader configurations
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # Enable the KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

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

  # User Accounts & default shell
  users.users.voidlotus = {
    isNormalUser = true;
    description = "Void Lotus";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };

  # Enable Zsh and Dynamic Linker (required for Antigravity's agy agent and generic binaries)
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # Install Firefox
  programs.firefox.enable = true;

  # Core System Packages
  environment.systemPackages = with pkgs; [
    # Version Control & Terminal
    git
    alacritty
    
    # File Manager
    thunar
    
    # Core CLI Utilities / Dev Tools
    vim
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
  ];

  # System Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];
}
