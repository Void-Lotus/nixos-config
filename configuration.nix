# Core NixOS System Configuration
{ config, pkgs, ... }:

{
  # Core System Strategy
  system.stateVersion = "26.05"; # Rolling release target base matching installation

  # Flake & Package Manager Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;

  # Bootloader configurations
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

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

  # User Accounts & default shell
  users.users.voidlotus = {
    isNormalUser = true;
    description = "Void Lotus";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };

  # Enable Zsh and Dynamic Linker (for portable binaries / agy client)
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # Core System Packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    ripgrep
    fd
  ];
}
